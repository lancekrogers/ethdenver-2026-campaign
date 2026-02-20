---
fest_type: task
fest_id: 07_implement_hcs_integration.md
fest_name: implement_hcs_integration
fest_parent: 01_inference_0g
fest_order: 7
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement HCS Integration

## Objective

Implement the HCS (Hedera Consensus Service) message handler for the inference agent. This package subscribes to HCS topics for incoming task assignments from the coordinator, parses task messages, publishes inference results back, and sends periodic health status updates. The HCS integration reuses patterns from the agent-coordinator project's HCS package (built in hedera-foundation-HF0001).

**Project:** `agent-inference` at `projects/agent-inference/`
**Package:** `internal/hcs/`

## Requirements

- [ ] Subscribe to HCS topics for task assignment messages from the coordinator
- [ ] Parse incoming HCS messages into typed task assignment structs
- [ ] Publish inference result messages back to the coordinator via HCS
- [ ] Publish periodic health/status updates via HCS
- [ ] Reuse the Hedera Go SDK patterns from agent-coordinator's HCS package
- [ ] Handle all errors with contextual wrapping
- [ ] Pass `context.Context` through all I/O operations

## Implementation

### Step 1: Review the coordinator's HCS package

Before building the inference agent's HCS handler, study the patterns established in the coordinator project:

```bash
ls /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator/internal/hedera/hcs/
```

Look at:

- How topics are created and managed
- The message envelope format (serialization, sequence numbers, message types)
- How subscriptions are handled (reconnect logic, streaming)
- How messages are published (retry, confirmation)

The inference agent does not import the coordinator's internal packages directly. Instead, it replicates the same patterns and message formats to ensure compatibility. Shared message types should use identical JSON schemas.

### Step 2: Define message types

In `internal/hcs/messages.go`:

```go
package hcs

import "time"

// MessageType identifies the kind of HCS message.
type MessageType string

const (
    MsgTypeTaskAssignment MessageType = "task_assignment"
    MsgTypeTaskResult     MessageType = "task_result"
    MsgTypeHealthStatus   MessageType = "health_status"
    MsgTypeAgentRegister  MessageType = "agent_register"
)

// Envelope is the standard message wrapper for all HCS messages.
// This format MUST match the coordinator's envelope format exactly.
type Envelope struct {
    // Type identifies the message kind.
    Type MessageType `json:"type"`

    // SenderID identifies the sending agent.
    SenderID string `json:"sender_id"`

    // Timestamp is when the message was created.
    Timestamp time.Time `json:"timestamp"`

    // SequenceNum is a monotonically increasing counter per sender.
    SequenceNum uint64 `json:"sequence_num"`

    // Payload is the JSON-encoded message body.
    Payload json.RawMessage `json:"payload"`
}

// TaskAssignment is a task sent from the coordinator to the inference agent.
type TaskAssignment struct {
    // TaskID uniquely identifies this task.
    TaskID string `json:"task_id"`

    // ModelID is the AI model to use for inference.
    ModelID string `json:"model_id"`

    // Input is the inference input data (prompt, parameters, etc.).
    Input string `json:"input"`

    // MaxTokens limits the output length.
    MaxTokens int `json:"max_tokens,omitempty"`

    // Priority indicates task urgency (higher = more urgent).
    Priority int `json:"priority"`

    // Deadline is the latest acceptable completion time.
    Deadline time.Time `json:"deadline,omitempty"`
}

// TaskResult is the inference result sent back to the coordinator.
type TaskResult struct {
    // TaskID links back to the original task assignment.
    TaskID string `json:"task_id"`

    // Status is the outcome of the inference job.
    Status string `json:"status"`

    // Output is the inference result data.
    Output string `json:"output"`

    // Duration is how long the inference took.
    DurationMs int64 `json:"duration_ms"`

    // StorageContentID is where the full result is stored on 0G.
    StorageContentID string `json:"storage_content_id,omitempty"`

    // INFTTokenID is the minted iNFT token ID.
    INFTTokenID string `json:"inft_token_id,omitempty"`

    // AuditSubmissionID is the 0G DA submission for the audit trail.
    AuditSubmissionID string `json:"audit_submission_id,omitempty"`

    // Error contains error details if the task failed.
    Error string `json:"error,omitempty"`
}

// HealthStatus is a periodic heartbeat from the inference agent.
type HealthStatus struct {
    // AgentID identifies this agent.
    AgentID string `json:"agent_id"`

    // Status is the current agent state ("idle", "busy", "error").
    Status string `json:"status"`

    // ActiveTaskID is the ID of the currently executing task, if any.
    ActiveTaskID string `json:"active_task_id,omitempty"`

    // UptimeSeconds is how long the agent has been running.
    UptimeSeconds int64 `json:"uptime_seconds"`

    // CompletedTasks is the total number of tasks completed.
    CompletedTasks int `json:"completed_tasks"`
}
```

### Step 3: Implement the HCS handler

In `internal/hcs/handler.go`:

```go
package hcs

import (
    "context"
    "encoding/json"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

// HandlerConfig holds configuration for the HCS message handler.
type HandlerConfig struct {
    // Client is the Hedera SDK client.
    Client *hedera.Client

    // TaskTopicID is the HCS topic for task assignments.
    TaskTopicID hedera.TopicID

    // ResultTopicID is the HCS topic for publishing results.
    ResultTopicID hedera.TopicID

    // HealthTopicID is the HCS topic for health updates.
    HealthTopicID hedera.TopicID

    // AgentID is this agent's unique identifier.
    AgentID string
}

// Handler manages HCS subscriptions and publishing for the inference agent.
type Handler struct {
    cfg     HandlerConfig
    seqNum  uint64
    taskCh  chan TaskAssignment
}
```

Key implementation details:

**Subscribe to task assignments:**

1. Use `hedera.NewTopicMessageQuery()` to subscribe to the task topic
2. Filter messages by type == "task_assignment"
3. Deserialize the envelope, then deserialize the payload into TaskAssignment
4. Send parsed tasks to the `taskCh` channel for the agent main loop to consume
5. Handle reconnection on subscription failure
6. Run the subscription in a goroutine with context cancellation

**Publish results:**

1. Create an Envelope with type "task_result" and the serialized TaskResult
2. Use `hedera.NewTopicMessageSubmitTransaction()` to publish
3. Wait for receipt confirmation
4. Increment sequence number
5. Retry on transient failures

**Publish health:**

1. Same pattern as result publishing but with type "health_status"
2. Called on a timer from the agent main loop (every 30-60 seconds)

### Step 4: Implement the task channel pattern

The handler exposes a channel that the agent main loop reads from:

```go
// Tasks returns a read-only channel of incoming task assignments.
func (h *Handler) Tasks() <-chan TaskAssignment {
    return h.taskCh
}

// StartSubscription begins listening for task assignments on HCS.
// It runs until the context is cancelled.
func (h *Handler) StartSubscription(ctx context.Context) error {
    // Create the topic message query
    // Set the subscription handler to parse and forward tasks
    // Handle reconnection on error
    // Return when context is done
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

1. **TestEnvelope_RoundTrip**: Marshal and unmarshal envelope, verify all fields
2. **TestTaskAssignment_RoundTrip**: Marshal and unmarshal task, verify all fields
3. **TestTaskResult_RoundTrip**: Marshal and unmarshal result, verify all fields
4. **TestHealthStatus_RoundTrip**: Marshal and unmarshal health, verify all fields

**Handler tests (use mock Hedera client):**

1. **TestStartSubscription_ReceivesTask**: Mock incoming message, verify task on channel
2. **TestStartSubscription_InvalidMessage**: Mock malformed message, verify skipped gracefully
3. **TestStartSubscription_ContextCancelled**: Cancel context, verify clean shutdown
4. **TestPublishResult_Success**: Mock successful publish, verify receipt
5. **TestPublishResult_Failed**: Mock publish failure, verify ErrPublishFailed
6. **TestPublishHealth_Success**: Mock successful health publish

### Step 7: Verify compilation and tests

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
go build ./internal/hcs/...
go test ./internal/hcs/... -v
go vet ./internal/hcs/...
```

## Done When

- [ ] HCS message handler fully implemented in `internal/hcs/handler.go`
- [ ] All message types defined in `internal/hcs/messages.go` matching coordinator format
- [ ] Task subscription delivers parsed TaskAssignment structs via channel
- [ ] Result and health publishing works with retry and receipt confirmation
- [ ] Sentinel errors defined for all failure modes
- [ ] Table-driven unit tests cover serialization, subscription, publishing, and error cases
- [ ] `go build`, `go test`, and `go vet` all pass cleanly
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
- [ ] Message envelope format documented and matches coordinator's format
