---
fest_type: task
fest_id: 01_design_coordinator.md
fest_name: design_coordinator
fest_parent: 04_coordinator
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design Coordinator Architecture

**Task Number:** 01 | **Sequence:** 04_coordinator | **Autonomy:** medium

## Objective

Design the coordinator engine architecture. The coordinator is the central orchestration component that ties together HCS (communication), HTS (payment), and the Schedule Service (liveness). This task defines the component interfaces, the task lifecycle state machine, and the coordinator configuration. All coordinator code lives in `internal/coordinator/`.

## Requirements

- [ ] Create package directory `internal/coordinator/`
- [ ] Define component interfaces: TaskAssigner, ProgressMonitor, QualityGateEnforcer, PaymentManager
- [ ] Define the task lifecycle state machine with valid transitions
- [ ] Define coordinator configuration struct
- [ ] Define the festival plan format (simple struct for parsing)
- [ ] Write `internal/coordinator/interfaces.go` with all component interfaces
- [ ] Write `internal/coordinator/state.go` with the state machine
- [ ] Write `internal/coordinator/config.go` with configuration
- [ ] Write `internal/coordinator/plan.go` with the plan format

## Implementation

### Step 1: Create the package directory

```
internal/
  coordinator/
    interfaces.go
    state.go
    config.go
    plan.go
```

### Step 2: Write interfaces.go

Create `internal/coordinator/interfaces.go`. The coordinator depends on these interfaces -- each maps to one of the Hedera service packages or to internal coordinator logic:

```go
package coordinator

import (
    "context"
    "time"
)

// TaskAssigner reads a festival plan and assigns tasks to agents via HCS.
type TaskAssigner interface {
    // AssignTasks reads the plan and publishes task assignments to the HCS topic.
    // Returns the list of task IDs that were assigned.
    AssignTasks(ctx context.Context, plan Plan) ([]string, error)

    // AssignTask assigns a single task to a specific agent.
    AssignTask(ctx context.Context, taskID string, agentID string) error
}

// ProgressMonitor listens for agent status updates and tracks task progress.
type ProgressMonitor interface {
    // Start begins monitoring the HCS topic for status updates.
    // Blocks until context is cancelled. Updates are processed internally
    // and reflected in task state.
    Start(ctx context.Context) error

    // TaskState returns the current state of a task.
    TaskState(taskID string) (TaskStatus, error)

    // AllTaskStates returns a map of all tracked tasks and their states.
    AllTaskStates() map[string]TaskStatus
}

// QualityGateEnforcer checks whether a task has passed its quality gates.
type QualityGateEnforcer interface {
    // Evaluate checks the quality gate criteria for a task.
    // Returns true if the gate is passed, false if it needs more work.
    Evaluate(ctx context.Context, taskID string) (bool, error)
}

// PaymentManager handles triggering HTS token payments for completed tasks.
type PaymentManager interface {
    // PayForTask triggers a token transfer from the coordinator treasury
    // to the agent that completed the task.
    PayForTask(ctx context.Context, taskID string, agentID string, amount int64) error

    // PaymentStatus returns the payment status for a task.
    PaymentStatus(taskID string) (PaymentState, error)
}
```

Design decisions:
- Each interface has 2-3 methods (small, focused)
- The coordinator orchestrator will compose these interfaces, not inherit from them
- `ProgressMonitor.Start` blocks like `HeartbeatRunner.Start` -- consistent pattern
- `QualityGateEnforcer.Evaluate` is a simple boolean gate check
- `PaymentManager` is separate from `QualityGateEnforcer` (SRP)

### Step 3: Write state.go

Create `internal/coordinator/state.go` with the task lifecycle state machine:

```go
package coordinator

import "fmt"

// TaskStatus represents a task's position in the lifecycle state machine.
type TaskStatus string

const (
    StatusPending    TaskStatus = "pending"
    StatusAssigned   TaskStatus = "assigned"
    StatusInProgress TaskStatus = "in_progress"
    StatusReview     TaskStatus = "review"
    StatusComplete   TaskStatus = "complete"
    StatusPaid       TaskStatus = "paid"
    StatusFailed     TaskStatus = "failed"
)

// PaymentState represents the payment status for a task.
type PaymentState string

const (
    PaymentPending   PaymentState = "pending"
    PaymentProcessed PaymentState = "processed"
    PaymentFailed    PaymentState = "failed"
)

// validTransitions defines the allowed state transitions.
// Key is the current state, value is the set of valid next states.
var validTransitions = map[TaskStatus][]TaskStatus{
    StatusPending:    {StatusAssigned, StatusFailed},
    StatusAssigned:   {StatusInProgress, StatusFailed},
    StatusInProgress: {StatusReview, StatusFailed},
    StatusReview:     {StatusComplete, StatusInProgress, StatusFailed},
    StatusComplete:   {StatusPaid, StatusFailed},
    StatusPaid:       {}, // terminal state
    StatusFailed:     {StatusPending}, // can be retried
}

// CanTransition checks if a state transition is valid.
func CanTransition(from, to TaskStatus) bool {
    allowed, ok := validTransitions[from]
    if !ok {
        return false
    }
    for _, s := range allowed {
        if s == to {
            return true
        }
    }
    return false
}

// Transition validates and performs a state transition.
// Returns an error if the transition is not allowed.
func Transition(from, to TaskStatus) error {
    if !CanTransition(from, to) {
        return fmt.Errorf("invalid state transition from %s to %s", from, to)
    }
    return nil
}

// IsTerminal returns true if the status is a terminal state (no further transitions).
func IsTerminal(status TaskStatus) bool {
    return status == StatusPaid
}
```

State machine diagram:
```
pending -> assigned -> in_progress -> review -> complete -> paid (terminal)
                                        |
                                        v
                                   in_progress (quality gate rejected, re-do)
Any state -> failed -> pending (retry)
```

### Step 4: Write config.go

Create `internal/coordinator/config.go`:

```go
package coordinator

import (
    "fmt"
    "time"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

// Config holds configuration for the coordinator engine.
type Config struct {
    // TaskTopicID is the HCS topic for publishing task assignments and receiving results.
    TaskTopicID hedera.TopicID

    // StatusTopicID is the HCS topic for receiving agent status updates.
    StatusTopicID hedera.TopicID

    // PaymentTokenID is the HTS token used for agent payments.
    PaymentTokenID hedera.TokenID

    // TreasuryAccountID is the account that holds the payment token supply.
    TreasuryAccountID hedera.AccountID

    // DefaultPaymentAmount is the default token amount paid per task completion.
    DefaultPaymentAmount int64

    // MonitorPollInterval is how often the progress monitor checks for new messages.
    MonitorPollInterval time.Duration

    // QualityGateTimeout is the maximum time to wait for quality gate evaluation.
    QualityGateTimeout time.Duration
}

// DefaultConfig returns sensible defaults for testnet usage.
// The caller must set topic IDs, token ID, and treasury account.
func DefaultConfig() Config {
    return Config{
        DefaultPaymentAmount: 100,
        MonitorPollInterval:  5 * time.Second,
        QualityGateTimeout:   30 * time.Second,
    }
}

// Validate checks the config for required fields.
func (c Config) Validate() error {
    if c.TaskTopicID.Topic == 0 {
        return fmt.Errorf("coordinator config: task topic ID is required")
    }
    if c.StatusTopicID.Topic == 0 {
        return fmt.Errorf("coordinator config: status topic ID is required")
    }
    if c.PaymentTokenID.Token == 0 {
        return fmt.Errorf("coordinator config: payment token ID is required")
    }
    if c.TreasuryAccountID.Account == 0 {
        return fmt.Errorf("coordinator config: treasury account ID is required")
    }
    if c.DefaultPaymentAmount <= 0 {
        return fmt.Errorf("coordinator config: default payment amount must be positive")
    }
    return nil
}
```

### Step 5: Write plan.go

Create `internal/coordinator/plan.go` with the festival plan format:

```go
package coordinator

// Plan represents a parsed festival plan that the coordinator can execute.
// This is a simplified representation -- the coordinator reads festival task
// files and converts them into this structure for execution.
type Plan struct {
    // FestivalID is the festival this plan belongs to.
    FestivalID string `json:"festival_id"`

    // Sequences is the ordered list of sequences to execute.
    Sequences []PlanSequence `json:"sequences"`
}

// PlanSequence represents a sequence within the plan.
type PlanSequence struct {
    // ID is the sequence identifier (e.g., "01_hcs_service").
    ID string `json:"id"`

    // Tasks is the ordered list of tasks in this sequence.
    Tasks []PlanTask `json:"tasks"`
}

// PlanTask represents a single task in the plan.
type PlanTask struct {
    // ID is the task identifier (e.g., "01_link_project").
    ID string `json:"id"`

    // Name is the human-readable task name.
    Name string `json:"name"`

    // AssignTo is the agent ID this task should be assigned to.
    // Empty string means the coordinator will auto-assign.
    AssignTo string `json:"assign_to,omitempty"`

    // PaymentAmount overrides the default payment for this task.
    // Zero means use the coordinator's default payment amount.
    PaymentAmount int64 `json:"payment_amount,omitempty"`

    // Dependencies lists task IDs that must complete before this task can start.
    Dependencies []string `json:"dependencies,omitempty"`
}

// TaskCount returns the total number of tasks across all sequences.
func (p Plan) TaskCount() int {
    count := 0
    for _, seq := range p.Sequences {
        count += len(seq.Tasks)
    }
    return count
}

// TaskByID finds a task in the plan by its ID.
// Returns nil if not found.
func (p Plan) TaskByID(taskID string) *PlanTask {
    for i := range p.Sequences {
        for j := range p.Sequences[i].Tasks {
            if p.Sequences[i].Tasks[j].ID == taskID {
                return &p.Sequences[i].Tasks[j]
            }
        }
    }
    return nil
}
```

### Step 6: Verify compilation

```bash
go build ./internal/coordinator/...
go vet ./internal/coordinator/...
```

## Done When

- [ ] `internal/coordinator/interfaces.go` exists with TaskAssigner, ProgressMonitor, QualityGateEnforcer, PaymentManager
- [ ] `internal/coordinator/state.go` exists with TaskStatus, state transitions, CanTransition, Transition, IsTerminal
- [ ] `internal/coordinator/config.go` exists with Config, DefaultConfig, Validate
- [ ] `internal/coordinator/plan.go` exists with Plan, PlanSequence, PlanTask, TaskCount, TaskByID
- [ ] All interfaces have 2-3 methods
- [ ] State machine has 7 states with defined valid transitions
- [ ] Config validation checks all required fields
- [ ] `go build ./internal/coordinator/...` passes
- [ ] `go vet ./internal/coordinator/...` passes
