---
fest_type: task
fest_id: 02_design_hcs_package.md
fest_name: design_hcs_package
fest_parent: 01_hcs_service
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design HCS Package

**Task Number:** 02 | **Sequence:** 01_hcs_service | **Autonomy:** medium

## Objective

Design the HCS (Hedera Consensus Service) package interfaces and message envelope format. This task produces the interface file that defines the contract for all HCS operations. The interfaces must be small, focused, and DI-friendly. The message envelope must support the full festival protocol (task assignments, status updates, results, heartbeats).

## Requirements

- [ ] Create the package directory `internal/hedera/hcs/`
- [ ] Define the `TopicCreator` interface (topic creation and management)
- [ ] Define the `MessagePublisher` interface (publishing messages to topics)
- [ ] Define the `MessageSubscriber` interface (subscribing to topic messages)
- [ ] Define the message envelope struct for festival protocol messages
- [ ] Define message type constants for all protocol message types
- [ ] Write the interface file at `internal/hedera/hcs/interfaces.go`
- [ ] Write the message types file at `internal/hedera/hcs/message.go`

## Implementation

### Step 1: Create the package directory

Working in the agent-coordinator project (navigate with `fgo`), create the HCS package:

```
internal/
  hedera/
    hcs/
      interfaces.go
      message.go
```

### Step 2: Write interfaces.go

Create `internal/hedera/hcs/interfaces.go` with the following design:

```go
package hcs

import (
    "context"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

// TopicCreator handles HCS topic lifecycle operations.
// Topics are the communication channels for agent coordination.
type TopicCreator interface {
    // CreateTopic creates a new HCS topic and returns its ID.
    // The memo should describe the topic's purpose (e.g., "festival-tasks", "agent-status").
    CreateTopic(ctx context.Context, memo string) (hedera.TopicID, error)

    // DeleteTopic deletes an HCS topic by its ID.
    DeleteTopic(ctx context.Context, topicID hedera.TopicID) error

    // TopicInfo retrieves metadata about an existing topic.
    TopicInfo(ctx context.Context, topicID hedera.TopicID) (*TopicMetadata, error)
}

// MessagePublisher handles publishing messages to HCS topics.
type MessagePublisher interface {
    // Publish sends a message envelope to the specified HCS topic.
    // The message is serialized to JSON before publishing.
    Publish(ctx context.Context, topicID hedera.TopicID, msg Envelope) error
}

// MessageSubscriber handles subscribing to HCS topic messages.
type MessageSubscriber interface {
    // Subscribe starts a streaming subscription to an HCS topic.
    // Messages are delivered to the returned channel. The subscription
    // runs until the context is cancelled. The channel is closed when
    // the subscription ends.
    Subscribe(ctx context.Context, topicID hedera.TopicID) (<-chan Envelope, <-chan error)
}

// TopicMetadata holds information about an HCS topic.
type TopicMetadata struct {
    TopicID       hedera.TopicID
    Memo          string
    SequenceNumber uint64
}
```

Key design decisions:

- Each interface has 1-3 methods (small and focused per project standards)
- All methods take `context.Context` as the first parameter
- Return types use concrete Hedera SDK types where appropriate
- `Subscribe` returns channels for async streaming (Go-idiomatic)
- `TopicMetadata` is a simple struct, not an interface

### Step 3: Write message.go

Create `internal/hedera/hcs/message.go` with the message envelope format:

```go
package hcs

import (
    "encoding/json"
    "time"
)

// MessageType identifies the kind of protocol message in an envelope.
type MessageType string

const (
    // MessageTypeTaskAssignment is sent by the coordinator to assign a task to an agent.
    MessageTypeTaskAssignment MessageType = "task_assignment"

    // MessageTypeStatusUpdate is sent by an agent to report progress on a task.
    MessageTypeStatusUpdate MessageType = "status_update"

    // MessageTypeTaskResult is sent by an agent when a task is complete.
    MessageTypeTaskResult MessageType = "task_result"

    // MessageTypeHeartbeat is sent periodically to signal agent liveness.
    MessageTypeHeartbeat MessageType = "heartbeat"

    // MessageTypeQualityGate is sent by the coordinator for quality gate decisions.
    MessageTypeQualityGate MessageType = "quality_gate"

    // MessageTypePaymentSettled is sent after HTS payment is completed.
    MessageTypePaymentSettled MessageType = "payment_settled"
)

// Envelope is the standard message format for all festival protocol messages
// sent through HCS topics. Every message on the wire uses this structure.
type Envelope struct {
    // Type identifies what kind of message this is.
    Type MessageType `json:"type"`

    // Sender is the identifier of the agent or coordinator that sent this message.
    Sender string `json:"sender"`

    // Recipient is the intended recipient (empty string means broadcast to all subscribers).
    Recipient string `json:"recipient,omitempty"`

    // TaskID references the festival task this message relates to (if applicable).
    TaskID string `json:"task_id,omitempty"`

    // SequenceNum is a monotonically increasing number for ordering within a sender.
    SequenceNum uint64 `json:"sequence_num"`

    // Timestamp is when the message was created.
    Timestamp time.Time `json:"timestamp"`

    // Payload contains the type-specific message data as raw JSON.
    Payload json.RawMessage `json:"payload,omitempty"`
}

// Marshal serializes the envelope to JSON bytes for publishing to HCS.
func (e *Envelope) Marshal() ([]byte, error) {
    return json.Marshal(e)
}

// UnmarshalEnvelope deserializes JSON bytes from HCS into an Envelope.
func UnmarshalEnvelope(data []byte) (*Envelope, error) {
    var env Envelope
    if err := json.Unmarshal(data, &env); err != nil {
        return nil, err
    }
    return &env, nil
}
```

Key design decisions:

- `MessageType` is a string type for readability in JSON and logs
- `Payload` uses `json.RawMessage` for flexibility -- each message type can have different payload schemas without the envelope knowing about them
- `SequenceNum` enables ordering within a sender when HCS ordering guarantees are insufficient
- `Recipient` is optional to support both directed and broadcast messages
- Marshal/Unmarshal are methods on the struct, not on the interfaces, keeping serialization separate from I/O

### Step 4: Verify compilation

Run from the project root:

```bash
go build ./internal/hedera/hcs/...
go vet ./internal/hedera/hcs/...
```

Both commands must pass with zero errors and zero warnings.

## Done When

- [ ] `internal/hedera/hcs/interfaces.go` exists with TopicCreator, MessagePublisher, and MessageSubscriber interfaces
- [ ] `internal/hedera/hcs/message.go` exists with Envelope struct and MessageType constants
- [ ] All interfaces have 1-3 methods each (small and focused)
- [ ] All method signatures include `context.Context` as first parameter for I/O operations
- [ ] `go build ./internal/hedera/hcs/...` passes with no errors
- [ ] `go vet ./internal/hedera/hcs/...` passes with no warnings
- [ ] No file exceeds 500 lines
