---
fest_type: task
fest_id: 07_implement_hcs_integration.md
fest_name: implement_hcs_integration
fest_parent: 02_defi_base
fest_order: 7
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement HCS Integration

## Objective

Implement the HCS (Hedera Consensus Service) message handler for the DeFi agent. This package subscribes to HCS topics for incoming task assignments from the coordinator, publishes P&L reports and strategy status updates, and sends periodic health updates. The message envelope format must match the coordinator's format exactly for interoperability.

**Project:** `agent-defi` at `projects/agent-defi/`
**Package:** `internal/hcs/`

## Requirements

- [ ] Subscribe to HCS topics for task assignment messages from the coordinator
- [ ] Publish P&L reports to the coordinator via HCS
- [ ] Publish strategy status updates (trading signals, position changes)
- [ ] Publish periodic health/status updates via HCS
- [ ] Use the same message envelope format as the inference agent and coordinator
- [ ] Handle all errors with contextual wrapping
- [ ] Pass `context.Context` through all I/O operations

## Implementation

### Step 1: Review the coordinator's HCS message format

The DeFi agent must use the identical message envelope format as the coordinator and inference agent. Review:

```bash
ls /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator/internal/hedera/hcs/
```

Also review the inference agent's HCS message types from sequence 01:

```bash
ls /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference/internal/hcs/
```

Ensure the Envelope struct, MessageType constants, and JSON field names are identical across all three agents.

### Step 2: Define message types

In `internal/hcs/messages.go`:

```go
package hcs

import (
    "encoding/json"
    "time"
)

// MessageType identifies the kind of HCS message.
// These MUST match the coordinator and inference agent types exactly.
type MessageType string

const (
    MsgTypeTaskAssignment  MessageType = "task_assignment"
    MsgTypeTaskResult      MessageType = "task_result"
    MsgTypeHealthStatus    MessageType = "health_status"
    MsgTypeAgentRegister   MessageType = "agent_register"
    MsgTypePnLReport       MessageType = "pnl_report"
    MsgTypeStrategyUpdate  MessageType = "strategy_update"
)

// Envelope is the standard message wrapper for all HCS messages.
// This format MUST match the coordinator's envelope format exactly.
type Envelope struct {
    Type        MessageType     `json:"type"`
    SenderID    string          `json:"sender_id"`
    Timestamp   time.Time       `json:"timestamp"`
    SequenceNum uint64          `json:"sequence_num"`
    Payload     json.RawMessage `json:"payload"`
}

// TaskAssignment is a task sent from the coordinator to the DeFi agent.
type TaskAssignment struct {
    TaskID   string `json:"task_id"`
    Action   string `json:"action"` // "start_trading", "stop_trading", "adjust_strategy"
    Params   map[string]string `json:"params,omitempty"`
    Priority int    `json:"priority"`
}

// PnLReportMessage is the P&L summary published to HCS.
type PnLReportMessage struct {
    // AgentID identifies this DeFi agent.
    AgentID string `json:"agent_id"`

    // TotalRevenue is gross profit from trades (in USD or base token).
    TotalRevenue float64 `json:"total_revenue"`

    // TotalGasCosts is the sum of all gas spent.
    TotalGasCosts float64 `json:"total_gas_costs"`

    // TotalFees is the sum of all protocol fees.
    TotalFees float64 `json:"total_fees"`

    // NetPnL is the net profit/loss.
    NetPnL float64 `json:"net_pnl"`

    // TradeCount is the number of trades executed in this period.
    TradeCount int `json:"trade_count"`

    // WinRate is the percentage of profitable trades.
    WinRate float64 `json:"win_rate"`

    // IsSelfSustaining indicates revenue > costs.
    IsSelfSustaining bool `json:"is_self_sustaining"`

    // PeriodStart is the start of the reporting period.
    PeriodStart time.Time `json:"period_start"`

    // PeriodEnd is the end of the reporting period.
    PeriodEnd time.Time `json:"period_end"`

    // ActiveStrategy is the current trading strategy name.
    ActiveStrategy string `json:"active_strategy"`
}

// StrategyUpdate reports a strategy change or significant trading event.
type StrategyUpdate struct {
    AgentID    string `json:"agent_id"`
    Strategy   string `json:"strategy"`
    Event      string `json:"event"` // "signal_generated", "trade_executed", "position_changed"
    Details    string `json:"details"`
    Timestamp  time.Time `json:"timestamp"`
}

// HealthStatus is a periodic heartbeat from the DeFi agent.
type HealthStatus struct {
    AgentID        string  `json:"agent_id"`
    Status         string  `json:"status"` // "idle", "trading", "error"
    ActiveStrategy string  `json:"active_strategy"`
    CurrentPnL     float64 `json:"current_pnl"`
    UptimeSeconds  int64   `json:"uptime_seconds"`
    TradeCount     int     `json:"trade_count"`
}
```

### Step 3: Implement the HCS handler

In `internal/hcs/handler.go`:

```go
package hcs

import (
    "context"
    "github.com/hashgraph/hedera-sdk-go/v2"
)

// HandlerConfig holds configuration for the HCS message handler.
type HandlerConfig struct {
    Client        *hedera.Client
    TaskTopicID   hedera.TopicID
    ResultTopicID hedera.TopicID
    HealthTopicID hedera.TopicID
    AgentID       string
}

// Handler manages HCS subscriptions and publishing for the DeFi agent.
type Handler struct {
    cfg    HandlerConfig
    seqNum uint64
    taskCh chan TaskAssignment
}
```

Key implementation details:

**Subscribe to task assignments:**
1. Use `hedera.NewTopicMessageQuery()` to subscribe to the task topic
2. Parse incoming Envelope messages, extract TaskAssignment payloads
3. Forward parsed tasks to the `taskCh` channel
4. Handle reconnection on subscription failure
5. Ignore messages not addressed to this agent type

**Publish P&L reports:**
1. Accept a PnLReportMessage from the agent main loop
2. Wrap it in an Envelope with type "pnl_report"
3. Serialize and submit to HCS
4. Wait for receipt confirmation

**Publish strategy updates:**
1. Accept a StrategyUpdate from the trading loop
2. Wrap in Envelope with type "strategy_update"
3. Submit to HCS

**Publish health status:**
1. Accept HealthStatus from the health loop
2. Wrap in Envelope with type "health_status"
3. Submit to HCS

All publish methods follow the same pattern:
```go
func (h *Handler) publish(ctx context.Context, msgType MessageType, payload interface{}) error {
    payloadBytes, err := json.Marshal(payload)
    if err != nil {
        return fmt.Errorf("hcs: failed to marshal %s payload: %w", msgType, err)
    }

    envelope := Envelope{
        Type:        msgType,
        SenderID:    h.cfg.AgentID,
        Timestamp:   time.Now(),
        SequenceNum: atomic.AddUint64(&h.seqNum, 1),
        Payload:     payloadBytes,
    }

    envBytes, err := json.Marshal(envelope)
    if err != nil {
        return fmt.Errorf("hcs: failed to marshal envelope: %w", err)
    }

    _, err = hedera.NewTopicMessageSubmitTransaction().
        SetTopicID(h.cfg.ResultTopicID).
        SetMessage(envBytes).
        Execute(h.cfg.Client)
    if err != nil {
        return fmt.Errorf("hcs: failed to submit %s message: %w", msgType, err)
    }

    return nil
}
```

### Step 4: Expose convenience methods

```go
// Tasks returns a read-only channel of incoming task assignments.
func (h *Handler) Tasks() <-chan TaskAssignment {
    return h.taskCh
}

// PublishPnL sends a P&L report to the coordinator.
func (h *Handler) PublishPnL(ctx context.Context, report PnLReportMessage) error {
    return h.publish(ctx, MsgTypePnLReport, report)
}

// PublishStrategyUpdate sends a strategy event to the coordinator.
func (h *Handler) PublishStrategyUpdate(ctx context.Context, update StrategyUpdate) error {
    return h.publish(ctx, MsgTypeStrategyUpdate, update)
}

// PublishHealth sends a health heartbeat.
func (h *Handler) PublishHealth(ctx context.Context, status HealthStatus) error {
    return h.publish(ctx, MsgTypeHealthStatus, status)
}
```

### Step 5: Define sentinel errors

```go
var (
    ErrSubscriptionFailed = errors.New("hcs: topic subscription failed")
    ErrPublishFailed      = errors.New("hcs: message publish failed")
    ErrInvalidMessage     = errors.New("hcs: received invalid message format")
    ErrTopicNotFound      = errors.New("hcs: topic not found")
)
```

### Step 6: Write unit tests

Create `internal/hcs/handler_test.go` and `internal/hcs/messages_test.go`:

**Message serialization tests:**
1. **TestEnvelope_RoundTrip**: Marshal and unmarshal envelope
2. **TestPnLReportMessage_RoundTrip**: Verify all PnL fields survive serialization
3. **TestStrategyUpdate_RoundTrip**: Verify strategy update serialization
4. **TestHealthStatus_RoundTrip**: Verify health status serialization

**Handler tests:**
1. **TestStartSubscription_ReceivesTask**: Mock task message, verify on channel
2. **TestStartSubscription_IgnoresNonTask**: Mock non-task message, verify skipped
3. **TestPublishPnL_Success**: Mock HCS submit, verify correct envelope type
4. **TestPublishPnL_Failed**: Mock submit failure, verify error
5. **TestPublishStrategyUpdate_Success**: Verify strategy update published
6. **TestPublishHealth_Success**: Verify health published
7. **TestPublish_SequenceNumbers**: Verify sequence numbers increment

### Step 7: Verify compilation and tests

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
go build ./internal/hcs/...
go test ./internal/hcs/... -v
go vet ./internal/hcs/...
```

## Done When

- [ ] HCS message handler fully implemented in `internal/hcs/handler.go`
- [ ] All message types defined in `internal/hcs/messages.go`
- [ ] P&L report message format includes all required fields
- [ ] Envelope format matches coordinator and inference agent exactly
- [ ] Task subscription, P&L publishing, strategy updates, and health all working
- [ ] Sentinel errors defined for all failure modes
- [ ] Table-driven unit tests cover serialization and handler behavior
- [ ] `go build`, `go test`, and `go vet` all pass cleanly
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
