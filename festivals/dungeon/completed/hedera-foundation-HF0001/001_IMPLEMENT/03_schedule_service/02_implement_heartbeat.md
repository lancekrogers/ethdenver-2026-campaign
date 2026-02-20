---
fest_type: task
fest_id: 02_implement_heartbeat.md
fest_name: implement_heartbeat
fest_parent: 03_schedule_service
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Heartbeat

**Task Number:** 02 | **Sequence:** 03_schedule_service | **Autonomy:** medium

## Objective

Implement both the `ScheduleCreator` and `HeartbeatRunner` interfaces from `internal/hedera/schedule/interfaces.go`. The heartbeat runner periodically creates a scheduled transaction on Hedera as a liveness proof. It must support context cancellation for graceful shutdown, configurable intervals, and error recovery from transient failures.

## Requirements

- [ ] Create `internal/hedera/schedule/schedule.go` implementing `ScheduleCreator`
- [ ] Create `internal/hedera/schedule/heartbeat.go` implementing `HeartbeatRunner`
- [ ] Heartbeat loop respects context cancellation and stops cleanly
- [ ] Heartbeat interval is configurable via `HeartbeatConfig`
- [ ] Individual heartbeat failures send errors to the channel but do not stop the runner
- [ ] LastHeartbeat returns the time of the most recent successful heartbeat
- [ ] All methods propagate `context.Context` and check `ctx.Err()`
- [ ] All errors wrapped with operational context
- [ ] Create test files with table-driven tests

## Implementation

### Step 1: Create schedule.go

Create `internal/hedera/schedule/schedule.go` implementing `ScheduleCreator`:

```go
package schedule

import (
    "context"
    "fmt"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

// ScheduleService implements the ScheduleCreator interface.
type ScheduleService struct {
    client *hedera.Client
}

// NewScheduleService creates a new ScheduleService.
func NewScheduleService(client *hedera.Client) *ScheduleService {
    return &ScheduleService{client: client}
}

var _ ScheduleCreator = (*ScheduleService)(nil)

func (s *ScheduleService) CreateSchedule(ctx context.Context, innerTx hedera.Transaction, memo string) (hedera.ScheduleID, error) {
    if err := ctx.Err(); err != nil {
        return hedera.ScheduleID{}, fmt.Errorf("create schedule: context cancelled before start: %w", err)
    }

    tx, err := hedera.NewScheduleCreateTransaction().
        SetScheduledTransaction(innerTx).
        SetScheduleMemo(memo).
        FreezeWith(s.client)
    if err != nil {
        return hedera.ScheduleID{}, fmt.Errorf("create schedule with memo %q: freeze: %w", memo, err)
    }

    resp, err := tx.Execute(s.client)
    if err != nil {
        return hedera.ScheduleID{}, fmt.Errorf("create schedule with memo %q: execute: %w", memo, err)
    }

    receipt, err := resp.GetReceipt(s.client)
    if err != nil {
        return hedera.ScheduleID{}, fmt.Errorf("create schedule with memo %q: get receipt: %w", memo, err)
    }

    if receipt.ScheduleID == nil {
        return hedera.ScheduleID{}, fmt.Errorf("create schedule with memo %q: receipt contained nil schedule ID", memo)
    }

    return *receipt.ScheduleID, nil
}

func (s *ScheduleService) ScheduleInfo(ctx context.Context, scheduleID hedera.ScheduleID) (*ScheduleMetadata, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("schedule info %s: context cancelled before start: %w", scheduleID, err)
    }

    info, err := hedera.NewScheduleInfoQuery().
        SetScheduleID(scheduleID).
        Execute(s.client)
    if err != nil {
        return nil, fmt.Errorf("schedule info %s: execute query: %w", scheduleID, err)
    }

    return &ScheduleMetadata{
        ScheduleID: scheduleID,
        Memo:       info.Memo,
        Executed:   info.ExecutedAt != nil,
        Deleted:    info.DeletedAt != nil,
    }, nil
}
```

**Important note:** The exact API for `SetScheduledTransaction` depends on the Hedera SDK version. Check the SDK documentation. In some versions, you may need to use `SetScheduledTransaction` with a specific transaction type (e.g., `TransferTransaction`). If the generic `hedera.Transaction` approach does not work, modify the interface to accept a specific transaction builder or use `ITransaction` interface.

### Step 2: Create heartbeat.go

Create `internal/hedera/schedule/heartbeat.go`:

```go
package schedule

import (
    "context"
    "fmt"
    "sync"
    "time"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

// Heartbeat implements the HeartbeatRunner interface.
// It periodically creates a scheduled transaction as a liveness proof.
type Heartbeat struct {
    client    *hedera.Client
    scheduler ScheduleCreator
    config    HeartbeatConfig

    mu            sync.RWMutex
    lastHeartbeat time.Time
}

// NewHeartbeat creates a new Heartbeat runner.
func NewHeartbeat(client *hedera.Client, scheduler ScheduleCreator, config HeartbeatConfig) (*Heartbeat, error) {
    if err := config.Validate(); err != nil {
        return nil, fmt.Errorf("invalid heartbeat config: %w", err)
    }

    return &Heartbeat{
        client:    client,
        scheduler: scheduler,
        config:    config,
    }, nil
}

var _ HeartbeatRunner = (*Heartbeat)(nil)

func (h *Heartbeat) Start(ctx context.Context) <-chan error {
    errCh := make(chan error, 10)

    go h.run(ctx, errCh)

    return errCh
}

func (h *Heartbeat) run(ctx context.Context, errCh chan<- error) {
    defer close(errCh)

    ticker := time.NewTicker(h.config.Interval)
    defer ticker.Stop()

    // Send initial heartbeat immediately
    h.sendHeartbeat(ctx, errCh)

    for {
        select {
        case <-ctx.Done():
            return
        case <-ticker.C:
            h.sendHeartbeat(ctx, errCh)
        }
    }
}

func (h *Heartbeat) sendHeartbeat(ctx context.Context, errCh chan<- error) {
    if err := ctx.Err(); err != nil {
        return
    }

    // Create a small transfer transaction as the inner scheduled transaction.
    // This is a zero-value transfer from the agent to itself -- it costs minimal
    // fees but creates a verifiable on-chain record.
    innerTx := hedera.NewTransferTransaction().
        AddHbarTransfer(h.config.AccountID, hedera.NewHbar(0))

    memo := fmt.Sprintf("%s:%s:%d", h.config.Memo, h.config.AgentID, time.Now().Unix())

    _, err := h.scheduler.CreateSchedule(ctx, innerTx, memo)
    if err != nil {
        select {
        case errCh <- fmt.Errorf("heartbeat for agent %s: %w", h.config.AgentID, err):
        default:
            // error channel full, drop the error
        }
        return
    }

    h.mu.Lock()
    h.lastHeartbeat = time.Now()
    h.mu.Unlock()
}

func (h *Heartbeat) LastHeartbeat() time.Time {
    h.mu.RLock()
    defer h.mu.RUnlock()
    return h.lastHeartbeat
}
```

Key implementation notes:

- `sendHeartbeat` creates a zero-value HBAR transfer as the inner transaction. This is a minimal-cost liveness proof.
- The memo encodes the agent ID and Unix timestamp for traceability.
- Individual heartbeat failures are non-fatal -- they send to the error channel but the loop continues.
- `LastHeartbeat` is thread-safe via `sync.RWMutex`.
- The initial heartbeat fires immediately, then subsequent ones fire on the ticker interval.
- The `ScheduleCreator` is injected (DI) rather than the Heartbeat creating schedules directly. This enables testing with a mock scheduler.

**Important note about `hedera.Transaction`:** The `NewTransferTransaction()` returns a `*TransferTransaction`, not a `hedera.Transaction`. You may need to adapt the `ScheduleCreator` interface or use type assertion. Check the SDK to see if `SetScheduledTransaction` accepts a concrete type or an interface. Adjust the interface in `interfaces.go` if needed (e.g., accept `hedera.ITransaction` or a specific builder).

### Step 3: Create test files

Create `internal/hedera/schedule/heartbeat_test.go`:

```go
package schedule_test

import (
    "context"
    "testing"
    "time"

    "your-module/internal/hedera/schedule"
)

func TestHeartbeatConfig_Validate(t *testing.T) {
    tests := []struct {
        name    string
        config  schedule.HeartbeatConfig
        wantErr bool
    }{
        {
            name: "valid config",
            config: schedule.HeartbeatConfig{
                Interval:  30 * time.Second,
                AgentID:   "agent-1",
                AccountID: hedera.AccountID{Account: 100},
            },
            wantErr: false,
        },
        {
            name: "interval below minimum",
            config: schedule.HeartbeatConfig{
                Interval:  1 * time.Second,
                AgentID:   "agent-1",
                AccountID: hedera.AccountID{Account: 100},
            },
            wantErr: true,
        },
        {
            name: "missing agent ID",
            config: schedule.HeartbeatConfig{
                Interval:  30 * time.Second,
                AccountID: hedera.AccountID{Account: 100},
            },
            wantErr: true,
        },
        {
            name: "missing account ID",
            config: schedule.HeartbeatConfig{
                Interval: 30 * time.Second,
                AgentID:  "agent-1",
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

func TestNewHeartbeat_InvalidConfig(t *testing.T) {
    badConfig := schedule.HeartbeatConfig{Interval: 1 * time.Second}
    _, err := schedule.NewHeartbeat(nil, nil, badConfig)
    if err == nil {
        t.Error("expected error for invalid config")
    }
}

func TestHeartbeat_ContextCancellation(t *testing.T) {
    // This test verifies the heartbeat stops when context is cancelled.
    // Uses a mock ScheduleCreator that counts calls.
    // The heartbeat should stop within a reasonable time after cancel.
    t.Skip("requires mock ScheduleCreator -- implement after mock is available")
}

func TestHeartbeat_LastHeartbeat_ZeroBeforeStart(t *testing.T) {
    cfg := schedule.HeartbeatConfig{
        Interval:  10 * time.Second,
        AgentID:   "agent-1",
        AccountID: hedera.AccountID{Account: 100},
    }
    hb, err := schedule.NewHeartbeat(nil, nil, cfg)
    if err != nil {
        t.Fatalf("NewHeartbeat() error = %v", err)
    }

    if !hb.LastHeartbeat().IsZero() {
        t.Error("expected zero time before any heartbeat sent")
    }
}

func TestDefaultHeartbeatConfig(t *testing.T) {
    cfg := schedule.DefaultHeartbeatConfig()
    if cfg.Interval != 30*time.Second {
        t.Errorf("Interval = %v, want 30s", cfg.Interval)
    }
    if cfg.Memo != "agent-heartbeat" {
        t.Errorf("Memo = %q, want %q", cfg.Memo, "agent-heartbeat")
    }
}
```

Replace `your-module` with the actual module path from go.mod.

### Step 4: Verify

```bash
go build ./internal/hedera/schedule/...
go vet ./internal/hedera/schedule/...
go test ./internal/hedera/schedule/... -v -count=1
```

## Done When

- [ ] `internal/hedera/schedule/schedule.go` implements `ScheduleCreator`
- [ ] `internal/hedera/schedule/heartbeat.go` implements `HeartbeatRunner`
- [ ] `NewHeartbeat` validates config before returning
- [ ] `Start` blocks via goroutine, returns error channel, stops on context cancel
- [ ] `sendHeartbeat` creates a scheduled zero-value transfer as liveness proof
- [ ] `LastHeartbeat` is thread-safe and returns zero time before first heartbeat
- [ ] Individual heartbeat failures are non-fatal (sent to error channel)
- [ ] All errors include agent ID and operational context
- [ ] Tests cover config validation, context cancellation, and default config
- [ ] `go test` passes, files under 500 lines, functions under 50 lines
