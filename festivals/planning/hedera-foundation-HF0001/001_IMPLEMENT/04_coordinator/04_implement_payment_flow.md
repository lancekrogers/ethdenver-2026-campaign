---
fest_type: task
fest_id: 04_implement_payment_flow.md
fest_name: implement_payment_flow
fest_parent: 04_coordinator
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Payment Flow

**Task Number:** 04 | **Sequence:** 04_coordinator | **Autonomy:** medium

## Objective

Implement the `PaymentManager` interface. The payment manager triggers HTS token transfers when tasks are marked complete and have passed quality gates. It uses the `TokenTransfer` interface from the HTS package (dependency injection) and tracks payment state for each task.

## Requirements

- [ ] Create `internal/coordinator/payment.go` implementing `PaymentManager`
- [ ] Trigger HTS token transfer when `PayForTask` is called
- [ ] Track payment state (pending/processed/failed) per task
- [ ] Publish a `PaymentSettled` HCS message after successful payment
- [ ] All methods propagate `context.Context`
- [ ] All errors wrapped with task ID, agent ID, and amount
- [ ] Constructor accepts HTS `TokenTransfer` and HCS `MessagePublisher` via DI
- [ ] Create `internal/coordinator/payment_test.go` with table-driven tests

## Implementation

### Step 1: Create payment.go

Create `internal/coordinator/payment.go`:

```go
package coordinator

import (
    "context"
    "encoding/json"
    "fmt"
    "sync"
    "time"

    "github.com/hashgraph/hedera-sdk-go/v2"
    "your-module/internal/hedera/hcs"
    "your-module/internal/hedera/hts"
)

// PaymentSettledPayload is the HCS message payload for a payment settlement.
type PaymentSettledPayload struct {
    TaskID   string `json:"task_id"`
    AgentID  string `json:"agent_id"`
    Amount   int64  `json:"amount"`
    TokenID  string `json:"token_id"`
    TxStatus string `json:"tx_status"`
}

// Payment implements the PaymentManager interface.
type Payment struct {
    transferSvc hts.TokenTransfer
    publisher   hcs.MessagePublisher
    config      Config

    mu       sync.RWMutex
    payments map[string]PaymentState // taskID -> payment state
    seqNum   uint64
}

// NewPayment creates a new payment manager.
func NewPayment(transferSvc hts.TokenTransfer, publisher hcs.MessagePublisher, config Config) *Payment {
    return &Payment{
        transferSvc: transferSvc,
        publisher:   publisher,
        config:      config,
        payments:    make(map[string]PaymentState),
    }
}

var _ PaymentManager = (*Payment)(nil)
```

### Step 2: Implement PayForTask

```go
func (p *Payment) PayForTask(ctx context.Context, taskID string, agentID string, amount int64) error {
    if err := ctx.Err(); err != nil {
        return fmt.Errorf("pay for task %s agent %s: context cancelled: %w", taskID, agentID, err)
    }

    if amount <= 0 {
        return fmt.Errorf("pay for task %s: amount must be positive, got %d", taskID, amount)
    }

    // Check if already paid
    p.mu.RLock()
    state := p.payments[taskID]
    p.mu.RUnlock()
    if state == PaymentProcessed {
        return fmt.Errorf("pay for task %s: already paid", taskID)
    }

    // Mark payment as in-progress
    p.mu.Lock()
    p.payments[taskID] = PaymentPending
    p.mu.Unlock()

    // Parse agent account ID from agentID string
    // In the real system, there would be an agent registry mapping agent IDs to account IDs.
    // For the hackathon demo, agent IDs are Hedera account ID strings.
    agentAccountID, err := hedera.AccountIDFromString(agentID)
    if err != nil {
        p.mu.Lock()
        p.payments[taskID] = PaymentFailed
        p.mu.Unlock()
        return fmt.Errorf("pay for task %s: parse agent account %s: %w", taskID, agentID, err)
    }

    // Execute the token transfer
    req := hts.TransferRequest{
        TokenID:       p.config.PaymentTokenID,
        FromAccountID: p.config.TreasuryAccountID,
        ToAccountID:   agentAccountID,
        Amount:        amount,
        Memo:          fmt.Sprintf("payment:task:%s", taskID),
    }

    receipt, err := p.transferSvc.Transfer(ctx, req)
    if err != nil {
        p.mu.Lock()
        p.payments[taskID] = PaymentFailed
        p.mu.Unlock()
        return fmt.Errorf("pay for task %s agent %s amount %d: transfer: %w", taskID, agentID, amount, err)
    }

    // Mark payment as processed
    p.mu.Lock()
    p.payments[taskID] = PaymentProcessed
    p.mu.Unlock()

    // Publish payment settled message to HCS
    if err := p.publishSettlement(ctx, taskID, agentID, amount, receipt.Status); err != nil {
        // Payment succeeded but notification failed -- log but don't fail
        _ = err
    }

    return nil
}
```

### Step 3: Implement publishSettlement

```go
func (p *Payment) publishSettlement(ctx context.Context, taskID, agentID string, amount int64, txStatus string) error {
    payload := PaymentSettledPayload{
        TaskID:   taskID,
        AgentID:  agentID,
        Amount:   amount,
        TokenID:  p.config.PaymentTokenID.String(),
        TxStatus: txStatus,
    }

    payloadBytes, err := json.Marshal(payload)
    if err != nil {
        return fmt.Errorf("marshal payment settled payload: %w", err)
    }

    p.mu.Lock()
    p.seqNum++
    seqNum := p.seqNum
    p.mu.Unlock()

    env := hcs.Envelope{
        Type:        hcs.MessageTypePaymentSettled,
        Sender:      "coordinator",
        Recipient:   agentID,
        TaskID:      taskID,
        SequenceNum: seqNum,
        Timestamp:   time.Now(),
        Payload:     payloadBytes,
    }

    return p.publisher.Publish(ctx, p.config.TaskTopicID, env)
}
```

### Step 4: Implement PaymentStatus

```go
func (p *Payment) PaymentStatus(taskID string) (PaymentState, error) {
    p.mu.RLock()
    defer p.mu.RUnlock()

    state, exists := p.payments[taskID]
    if !exists {
        return "", fmt.Errorf("payment status for task %s: not tracked", taskID)
    }
    return state, nil
}
```

### Step 5: Create payment_test.go

Create `internal/coordinator/payment_test.go`:

```go
package coordinator_test

import (
    "context"
    "testing"

    "your-module/internal/coordinator"
)

func TestPayForTask_ContextCancellation(t *testing.T) {
    cfg := coordinator.DefaultConfig()
    cfg.TaskTopicID = hedera.TopicID{Topic: 1}
    cfg.StatusTopicID = hedera.TopicID{Topic: 2}
    cfg.PaymentTokenID = hedera.TokenID{Token: 1}
    cfg.TreasuryAccountID = hedera.AccountID{Account: 100}

    pm := coordinator.NewPayment(nil, nil, cfg)
    ctx, cancel := context.WithCancel(context.Background())
    cancel()

    err := pm.PayForTask(ctx, "task-1", "0.0.200", 100)
    if err == nil {
        t.Error("expected error for cancelled context")
    }
}

func TestPayForTask_InvalidAmount(t *testing.T) {
    tests := []struct {
        name    string
        amount  int64
        wantErr bool
    }{
        {"zero amount", 0, true},
        {"negative amount", -10, true},
    }

    cfg := coordinator.DefaultConfig()
    cfg.TaskTopicID = hedera.TopicID{Topic: 1}
    cfg.StatusTopicID = hedera.TopicID{Topic: 2}
    cfg.PaymentTokenID = hedera.TokenID{Token: 1}
    cfg.TreasuryAccountID = hedera.AccountID{Account: 100}

    pm := coordinator.NewPayment(nil, nil, cfg)

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := pm.PayForTask(context.Background(), "task-1", "0.0.200", tt.amount)
            if (err != nil) != tt.wantErr {
                t.Errorf("PayForTask() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}

func TestPaymentStatus_NotTracked(t *testing.T) {
    cfg := coordinator.DefaultConfig()
    cfg.TaskTopicID = hedera.TopicID{Topic: 1}
    cfg.StatusTopicID = hedera.TopicID{Topic: 2}
    cfg.PaymentTokenID = hedera.TokenID{Token: 1}
    cfg.TreasuryAccountID = hedera.AccountID{Account: 100}

    pm := coordinator.NewPayment(nil, nil, cfg)
    _, err := pm.PaymentStatus("nonexistent")
    if err == nil {
        t.Error("expected error for untracked task")
    }
}

func TestConfigValidation(t *testing.T) {
    tests := []struct {
        name    string
        config  coordinator.Config
        wantErr bool
    }{
        {
            name:    "empty config fails",
            config:  coordinator.Config{},
            wantErr: true,
        },
        {
            name: "valid config passes",
            config: coordinator.Config{
                TaskTopicID:          hedera.TopicID{Topic: 1},
                StatusTopicID:        hedera.TopicID{Topic: 2},
                PaymentTokenID:       hedera.TokenID{Token: 1},
                TreasuryAccountID:    hedera.AccountID{Account: 100},
                DefaultPaymentAmount: 100,
            },
            wantErr: false,
        },
        {
            name: "missing task topic fails",
            config: coordinator.Config{
                StatusTopicID:        hedera.TopicID{Topic: 2},
                PaymentTokenID:       hedera.TokenID{Token: 1},
                TreasuryAccountID:    hedera.AccountID{Account: 100},
                DefaultPaymentAmount: 100,
            },
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := tt.config.Validate()
            if (err != nil) != tt.wantErr {
                t.Errorf("Validate() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}
```

Replace `your-module` with the actual module path.

### Step 6: Verify

```bash
go build ./internal/coordinator/...
go vet ./internal/coordinator/...
go test ./internal/coordinator/... -v -count=1
```

## Done When

- [ ] `internal/coordinator/payment.go` implements `PaymentManager`
- [ ] `PayForTask` validates amount, executes HTS transfer, publishes settlement to HCS
- [ ] Payment state tracking is thread-safe (pending/processed/failed)
- [ ] Double-payment prevention (already-paid tasks are rejected)
- [ ] `PaymentStatus` returns tracked state or error for untracked tasks
- [ ] Settlement notification is published via HCS after successful payment
- [ ] Tests cover context cancellation, invalid amount, untracked tasks, and config validation
- [ ] `go test ./internal/coordinator/...` passes
- [ ] File under 500 lines, functions under 50 lines
