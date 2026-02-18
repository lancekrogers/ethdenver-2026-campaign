---
fest_type: task
fest_id: 02_implement_task_assignment.md
fest_name: implement_task_assignment
fest_parent: 04_coordinator
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Task Assignment

**Task Number:** 02 | **Sequence:** 04_coordinator | **Autonomy:** medium

## Objective

Implement the `TaskAssigner` interface. The assigner reads a festival `Plan`, creates HCS task assignment messages, and publishes them to the task topic. It also tracks which tasks have been assigned to which agents and manages the assignment state.

## Requirements

- [ ] Create `internal/coordinator/assign.go` implementing `TaskAssigner`
- [ ] Parse the `Plan` struct and iterate through sequences and tasks in order
- [ ] For each task, create an HCS `Envelope` with `MessageTypeTaskAssignment`
- [ ] Publish the assignment message to the configured task HCS topic
- [ ] Track assignments in an in-memory map (task ID -> agent ID)
- [ ] Respect task dependencies (only assign after dependencies are complete)
- [ ] All methods propagate `context.Context`
- [ ] All errors wrapped with task ID and agent ID
- [ ] Create `internal/coordinator/assign_test.go` with table-driven tests

## Implementation

### Step 1: Create assign.go

Create `internal/coordinator/assign.go`:

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
)

// Assigner implements the TaskAssigner interface.
type Assigner struct {
    publisher hcs.MessagePublisher
    topicID   hedera.TopicID
    agentIDs  []string // available agents for auto-assignment

    mu          sync.RWMutex
    assignments map[string]string // taskID -> agentID
    seqNum      uint64
}

// NewAssigner creates a new task assigner.
// publisher is the HCS message publisher for the task topic.
// topicID is the HCS topic for task assignments.
// agentIDs is the list of available agent identifiers for round-robin auto-assignment.
func NewAssigner(publisher hcs.MessagePublisher, topicID hedera.TopicID, agentIDs []string) *Assigner {
    return &Assigner{
        publisher:   publisher,
        topicID:     topicID,
        agentIDs:    agentIDs,
        assignments: make(map[string]string),
    }
}

var _ TaskAssigner = (*Assigner)(nil)
```

### Step 2: Implement AssignTasks

```go
func (a *Assigner) AssignTasks(ctx context.Context, plan Plan) ([]string, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("assign tasks for plan %s: context cancelled before start: %w", plan.FestivalID, err)
    }

    var assignedIDs []string
    agentIdx := 0

    for _, seq := range plan.Sequences {
        for _, task := range seq.Tasks {
            if err := ctx.Err(); err != nil {
                return assignedIDs, fmt.Errorf("assign tasks: context cancelled during assignment: %w", err)
            }

            // Determine which agent to assign to
            agentID := task.AssignTo
            if agentID == "" && len(a.agentIDs) > 0 {
                agentID = a.agentIDs[agentIdx%len(a.agentIDs)]
                agentIdx++
            }

            if err := a.AssignTask(ctx, task.ID, agentID); err != nil {
                return assignedIDs, fmt.Errorf("assign tasks: task %s: %w", task.ID, err)
            }

            assignedIDs = append(assignedIDs, task.ID)
        }
    }

    return assignedIDs, nil
}
```

### Step 3: Implement AssignTask

```go
// TaskAssignmentPayload is the payload for a task assignment message.
type TaskAssignmentPayload struct {
    TaskID       string   `json:"task_id"`
    TaskName     string   `json:"task_name"`
    AgentID      string   `json:"agent_id"`
    Dependencies []string `json:"dependencies,omitempty"`
}

func (a *Assigner) AssignTask(ctx context.Context, taskID string, agentID string) error {
    if err := ctx.Err(); err != nil {
        return fmt.Errorf("assign task %s to %s: context cancelled: %w", taskID, agentID, err)
    }

    payload := TaskAssignmentPayload{
        TaskID:  taskID,
        AgentID: agentID,
    }

    payloadBytes, err := json.Marshal(payload)
    if err != nil {
        return fmt.Errorf("assign task %s to %s: marshal payload: %w", taskID, agentID, err)
    }

    a.mu.Lock()
    a.seqNum++
    seqNum := a.seqNum
    a.mu.Unlock()

    env := hcs.Envelope{
        Type:        hcs.MessageTypeTaskAssignment,
        Sender:      "coordinator",
        Recipient:   agentID,
        TaskID:      taskID,
        SequenceNum: seqNum,
        Timestamp:   time.Now(),
        Payload:     payloadBytes,
    }

    if err := a.publisher.Publish(ctx, a.topicID, env); err != nil {
        return fmt.Errorf("assign task %s to %s: publish: %w", taskID, agentID, err)
    }

    a.mu.Lock()
    a.assignments[taskID] = agentID
    a.mu.Unlock()

    return nil
}
```

### Step 4: Add helper methods

```go
// Assignment returns the agent ID assigned to a task, or empty string if not assigned.
func (a *Assigner) Assignment(taskID string) string {
    a.mu.RLock()
    defer a.mu.RUnlock()
    return a.assignments[taskID]
}

// AssignmentCount returns the number of tasks that have been assigned.
func (a *Assigner) AssignmentCount() int {
    a.mu.RLock()
    defer a.mu.RUnlock()
    return len(a.assignments)
}
```

### Step 5: Create assign_test.go

Create `internal/coordinator/assign_test.go`:

```go
package coordinator_test

import (
    "context"
    "testing"

    "your-module/internal/coordinator"
)

func TestAssigner_ContextCancellation(t *testing.T) {
    a := coordinator.NewAssigner(nil, hedera.TopicID{}, []string{"agent-1"})
    ctx, cancel := context.WithCancel(context.Background())
    cancel()

    _, err := a.AssignTasks(ctx, coordinator.Plan{})
    if err == nil {
        t.Error("expected error for cancelled context")
    }
}

func TestAssigner_RoundRobinAssignment(t *testing.T) {
    // Use a mock publisher that records published messages
    // Verify that tasks are assigned round-robin across agents
    t.Skip("requires mock MessagePublisher")
}

func TestAssigner_ExplicitAssignment(t *testing.T) {
    // Verify that tasks with AssignTo set go to the specified agent
    t.Skip("requires mock MessagePublisher")
}

func TestPlan_TaskCount(t *testing.T) {
    tests := []struct {
        name string
        plan coordinator.Plan
        want int
    }{
        {
            name: "empty plan",
            plan: coordinator.Plan{},
            want: 0,
        },
        {
            name: "single sequence with 3 tasks",
            plan: coordinator.Plan{
                Sequences: []coordinator.PlanSequence{
                    {
                        ID: "seq-1",
                        Tasks: []coordinator.PlanTask{
                            {ID: "task-1"},
                            {ID: "task-2"},
                            {ID: "task-3"},
                        },
                    },
                },
            },
            want: 3,
        },
        {
            name: "multiple sequences",
            plan: coordinator.Plan{
                Sequences: []coordinator.PlanSequence{
                    {ID: "seq-1", Tasks: []coordinator.PlanTask{{ID: "t1"}, {ID: "t2"}}},
                    {ID: "seq-2", Tasks: []coordinator.PlanTask{{ID: "t3"}}},
                },
            },
            want: 3,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            if got := tt.plan.TaskCount(); got != tt.want {
                t.Errorf("TaskCount() = %d, want %d", got, tt.want)
            }
        })
    }
}

func TestPlan_TaskByID(t *testing.T) {
    plan := coordinator.Plan{
        Sequences: []coordinator.PlanSequence{
            {
                ID: "seq-1",
                Tasks: []coordinator.PlanTask{
                    {ID: "task-1", Name: "First Task"},
                    {ID: "task-2", Name: "Second Task"},
                },
            },
        },
    }

    tests := []struct {
        name   string
        taskID string
        found  bool
    }{
        {"existing task", "task-1", true},
        {"another existing task", "task-2", true},
        {"non-existent task", "task-99", false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := plan.TaskByID(tt.taskID)
            if (result != nil) != tt.found {
                t.Errorf("TaskByID(%q) found = %v, want %v", tt.taskID, result != nil, tt.found)
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

- [ ] `internal/coordinator/assign.go` implements `TaskAssigner`
- [ ] `AssignTasks` iterates plan sequences in order and assigns tasks
- [ ] `AssignTask` creates HCS envelope with TaskAssignment type and publishes
- [ ] Auto-assignment uses round-robin across available agents
- [ ] Explicit assignment respects `AssignTo` field
- [ ] Assignment tracking is thread-safe
- [ ] Tests cover plan parsing, context cancellation, and task lookup
- [ ] `go test ./internal/coordinator/...` passes
- [ ] File under 500 lines, functions under 50 lines
