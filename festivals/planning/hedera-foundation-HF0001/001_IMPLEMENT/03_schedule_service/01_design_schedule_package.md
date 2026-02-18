---
fest_type: task
fest_id: 01_design_schedule_package.md
fest_name: design_schedule_package
fest_parent: 03_schedule_service
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design Schedule Package

**Task Number:** 01 | **Sequence:** 03_schedule_service | **Autonomy:** medium

## Objective

Design the Schedule Service package interfaces and configuration. This task produces the interface file that defines the contract for scheduled transaction operations and the heartbeat runner. The heartbeat uses Hedera's Schedule Service to submit periodic transactions that prove agent liveness.

## Requirements

- [ ] Create the package directory `internal/hedera/schedule/`
- [ ] Define the `ScheduleCreator` interface (creating scheduled transactions)
- [ ] Define the `HeartbeatRunner` interface (running periodic heartbeats)
- [ ] Define heartbeat configuration struct with configurable interval
- [ ] Write the interface file at `internal/hedera/schedule/interfaces.go`
- [ ] Write the config file at `internal/hedera/schedule/config.go`

## Implementation

### Step 1: Create the package directory

Working in the agent-coordinator project:

```
internal/
  hedera/
    schedule/
      interfaces.go
      config.go
```

### Step 2: Write interfaces.go

Create `internal/hedera/schedule/interfaces.go`:

```go
package schedule

import (
    "context"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

// ScheduleCreator handles creating scheduled transactions on Hedera.
type ScheduleCreator interface {
    // CreateSchedule creates a new scheduled transaction and returns its ID.
    // The inner transaction is the transaction to be scheduled for future execution.
    CreateSchedule(ctx context.Context, innerTx hedera.Transaction, memo string) (hedera.ScheduleID, error)

    // ScheduleInfo retrieves information about an existing scheduled transaction.
    ScheduleInfo(ctx context.Context, scheduleID hedera.ScheduleID) (*ScheduleMetadata, error)
}

// HeartbeatRunner manages a periodic heartbeat using the Hedera Schedule Service.
// The heartbeat proves agent liveness by submitting scheduled transactions at
// a configurable interval. The runner stops cleanly when the context is cancelled.
type HeartbeatRunner interface {
    // Start begins the heartbeat loop. It blocks until the context is cancelled
    // or an unrecoverable error occurs. Errors from individual heartbeat
    // submissions are sent to the error channel. The error channel is closed
    // when the runner stops.
    Start(ctx context.Context) <-chan error

    // LastHeartbeat returns the timestamp of the most recent successful heartbeat,
    // or zero time if no heartbeat has been sent yet.
    LastHeartbeat() time.Time
}

// ScheduleMetadata holds information about a scheduled transaction.
type ScheduleMetadata struct {
    ScheduleID hedera.ScheduleID
    Memo       string
    Executed   bool
    Deleted    bool
}
```

Design decisions:
- `ScheduleCreator` is generic (any transaction can be scheduled) while `HeartbeatRunner` is specific to the heartbeat use case
- `HeartbeatRunner.Start` blocks (like `http.ListenAndServe`) and returns an error channel for non-fatal errors
- `LastHeartbeat` provides observability without requiring external monitoring
- The heartbeat loop is controlled by context cancellation (Go-idiomatic shutdown)

### Step 3: Write config.go

Create `internal/hedera/schedule/config.go`:

```go
package schedule

import (
    "time"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

const (
    defaultHeartbeatInterval = 30 * time.Second
    defaultHeartbeatMemo     = "agent-heartbeat"
    minHeartbeatInterval     = 5 * time.Second
)

// HeartbeatConfig holds configuration for the heartbeat runner.
type HeartbeatConfig struct {
    // Interval is the time between heartbeat submissions.
    // Minimum is 5 seconds to avoid testnet rate limiting.
    Interval time.Duration

    // Memo is the memo attached to each heartbeat scheduled transaction.
    Memo string

    // AgentID identifies which agent this heartbeat belongs to.
    AgentID string

    // AccountID is the Hedera account submitting the heartbeat.
    AccountID hedera.AccountID

    // TopicID is an optional HCS topic to publish heartbeat notifications to.
    // If set, the heartbeat runner also publishes an HCS message alongside
    // the scheduled transaction. This allows the coordinator to monitor
    // heartbeats via HCS subscription.
    TopicID *hedera.TopicID
}

// DefaultHeartbeatConfig returns sensible defaults for testnet usage.
// The caller must set AgentID and AccountID.
func DefaultHeartbeatConfig() HeartbeatConfig {
    return HeartbeatConfig{
        Interval: defaultHeartbeatInterval,
        Memo:     defaultHeartbeatMemo,
    }
}

// Validate checks the heartbeat config for required fields and valid values.
func (c HeartbeatConfig) Validate() error {
    if c.Interval < minHeartbeatInterval {
        return fmt.Errorf("heartbeat interval %v is below minimum %v", c.Interval, minHeartbeatInterval)
    }
    if c.AgentID == "" {
        return fmt.Errorf("heartbeat agent ID is required")
    }
    if c.AccountID.Account == 0 {
        return fmt.Errorf("heartbeat account ID is required")
    }
    return nil
}
```

Note: Add `"fmt"` to the imports in config.go for the `Validate` method.

### Step 4: Verify compilation

```bash
go build ./internal/hedera/schedule/...
go vet ./internal/hedera/schedule/...
```

## Done When

- [ ] `internal/hedera/schedule/interfaces.go` exists with ScheduleCreator and HeartbeatRunner interfaces
- [ ] `internal/hedera/schedule/config.go` exists with HeartbeatConfig and DefaultHeartbeatConfig
- [ ] Interfaces have 2 methods each (small and focused)
- [ ] HeartbeatRunner.Start blocks and returns error channel (Go-idiomatic)
- [ ] Config includes Validate method with minimum interval enforcement
- [ ] `go build ./internal/hedera/schedule/...` passes
- [ ] `go vet ./internal/hedera/schedule/...` passes
