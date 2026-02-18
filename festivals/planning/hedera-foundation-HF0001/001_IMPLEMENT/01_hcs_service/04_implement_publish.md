---
fest_type: task
fest_id: 04_implement_publish.md
fest_name: implement_publish
fest_parent: 01_hcs_service
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Message Publishing

**Task Number:** 04 | **Sequence:** 01_hcs_service | **Autonomy:** medium

## Objective

Implement the `MessagePublisher` interface from `internal/hedera/hcs/interfaces.go`. This implementation serializes `Envelope` messages to JSON and publishes them to HCS topics via the Hedera Go SDK. It must include context propagation, error wrapping with operational context, and retry logic for transient failures.

## Requirements

- [ ] Create `internal/hedera/hcs/publish.go` implementing the `MessagePublisher` interface
- [ ] Serialize `Envelope` to JSON before publishing
- [ ] Implement retry logic with exponential backoff for transient HCS errors
- [ ] Propagate `context.Context` and check cancellation before each attempt
- [ ] Wrap all errors with operational context (topic ID, message type, attempt number)
- [ ] Constructor accepts `*hedera.Client` via dependency injection
- [ ] Create `internal/hedera/hcs/publish_test.go` with table-driven tests

## Implementation

### Step 1: Create publish.go

Create `internal/hedera/hcs/publish.go` in the agent-coordinator project:

```go
package hcs

import (
    "context"
    "fmt"
    "time"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

const (
    defaultMaxRetries    = 3
    defaultBaseBackoff   = 500 * time.Millisecond
    defaultMaxBackoff    = 5 * time.Second
)

// PublishConfig holds configuration for the publisher.
type PublishConfig struct {
    MaxRetries  int
    BaseBackoff time.Duration
    MaxBackoff  time.Duration
}

// DefaultPublishConfig returns sensible defaults for testnet usage.
func DefaultPublishConfig() PublishConfig {
    return PublishConfig{
        MaxRetries:  defaultMaxRetries,
        BaseBackoff: defaultBaseBackoff,
        MaxBackoff:  defaultMaxBackoff,
    }
}

// Publisher implements the MessagePublisher interface using the Hedera Go SDK.
type Publisher struct {
    client *hedera.Client
    config PublishConfig
}

// NewPublisher creates a new Publisher with the given Hedera client and config.
func NewPublisher(client *hedera.Client, config PublishConfig) *Publisher {
    return &Publisher{
        client: client,
        config: config,
    }
}
```

### Step 2: Implement the Publish method

The `Publish` method serializes the envelope, then submits it to HCS with retry logic:

```go
func (p *Publisher) Publish(ctx context.Context, topicID hedera.TopicID, msg Envelope) error {
    if err := ctx.Err(); err != nil {
        return fmt.Errorf("publish to topic %s: context cancelled before start: %w", topicID, err)
    }

    data, err := msg.Marshal()
    if err != nil {
        return fmt.Errorf("publish to topic %s: marshal envelope type %s: %w", topicID, msg.Type, err)
    }

    var lastErr error
    for attempt := 0; attempt <= p.config.MaxRetries; attempt++ {
        if err := ctx.Err(); err != nil {
            return fmt.Errorf("publish to topic %s: context cancelled on attempt %d: %w", topicID, attempt+1, err)
        }

        lastErr = p.submitMessage(topicID, data)
        if lastErr == nil {
            return nil
        }

        if attempt < p.config.MaxRetries {
            backoff := p.calculateBackoff(attempt)
            select {
            case <-ctx.Done():
                return fmt.Errorf("publish to topic %s: context cancelled during backoff: %w", topicID, ctx.Err())
            case <-time.After(backoff):
                // continue to next attempt
            }
        }
    }

    return fmt.Errorf("publish to topic %s type %s: exhausted %d retries: %w",
        topicID, msg.Type, p.config.MaxRetries+1, lastErr)
}
```

### Step 3: Implement helper methods

Add the private helpers for submission and backoff calculation:

```go
func (p *Publisher) submitMessage(topicID hedera.TopicID, data []byte) error {
    tx, err := hedera.NewTopicMessageSubmitTransaction().
        SetTopicID(topicID).
        SetMessage(data).
        FreezeWith(p.client)
    if err != nil {
        return fmt.Errorf("freeze transaction: %w", err)
    }

    resp, err := tx.Execute(p.client)
    if err != nil {
        return fmt.Errorf("execute transaction: %w", err)
    }

    _, err = resp.GetReceipt(p.client)
    if err != nil {
        return fmt.Errorf("get receipt: %w", err)
    }

    return nil
}

func (p *Publisher) calculateBackoff(attempt int) time.Duration {
    backoff := p.config.BaseBackoff
    for i := 0; i < attempt; i++ {
        backoff *= 2
    }
    if backoff > p.config.MaxBackoff {
        backoff = p.config.MaxBackoff
    }
    return backoff
}
```

### Step 4: Create publish_test.go

Create `internal/hedera/hcs/publish_test.go` with table-driven tests:

```go
package hcs_test

import (
    "context"
    "encoding/json"
    "testing"
    "time"

    "your-module/internal/hedera/hcs"
)

func TestPublish_ContextCancellation(t *testing.T) {
    tests := []struct {
        name    string
        ctx     context.Context
        wantErr bool
    }{
        {
            name:    "cancelled context returns error immediately",
            ctx:     cancelledContext(),
            wantErr: true,
        },
        {
            name:    "expired context returns error immediately",
            ctx:     expiredContext(),
            wantErr: true,
        },
    }

    pub := hcs.NewPublisher(nil, hcs.DefaultPublishConfig())

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            env := hcs.Envelope{
                Type:      hcs.MessageTypeHeartbeat,
                Sender:    "test-agent",
                Timestamp: time.Now(),
            }
            // TopicID zero value is fine -- context check happens first
            err := pub.Publish(tt.ctx, hedera.TopicID{}, env)
            if (err != nil) != tt.wantErr {
                t.Errorf("Publish() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}

func TestEnvelope_Marshal(t *testing.T) {
    tests := []struct {
        name     string
        envelope hcs.Envelope
        wantType string
    }{
        {
            name: "task assignment serializes correctly",
            envelope: hcs.Envelope{
                Type:        hcs.MessageTypeTaskAssignment,
                Sender:      "coordinator",
                Recipient:   "agent-1",
                TaskID:      "01_link_project",
                SequenceNum: 1,
                Timestamp:   time.Date(2026, 2, 18, 14, 0, 0, 0, time.UTC),
            },
            wantType: "task_assignment",
        },
        {
            name: "heartbeat with no payload serializes correctly",
            envelope: hcs.Envelope{
                Type:        hcs.MessageTypeHeartbeat,
                Sender:      "agent-1",
                SequenceNum: 42,
                Timestamp:   time.Date(2026, 2, 18, 14, 0, 0, 0, time.UTC),
            },
            wantType: "heartbeat",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            data, err := tt.envelope.Marshal()
            if err != nil {
                t.Fatalf("Marshal() error = %v", err)
            }

            var result map[string]interface{}
            if err := json.Unmarshal(data, &result); err != nil {
                t.Fatalf("Unmarshal result: %v", err)
            }

            if got := result["type"]; got != tt.wantType {
                t.Errorf("type = %v, want %v", got, tt.wantType)
            }
        })
    }
}

func TestPublishConfig_Defaults(t *testing.T) {
    cfg := hcs.DefaultPublishConfig()
    if cfg.MaxRetries != 3 {
        t.Errorf("MaxRetries = %d, want 3", cfg.MaxRetries)
    }
    if cfg.BaseBackoff != 500*time.Millisecond {
        t.Errorf("BaseBackoff = %v, want 500ms", cfg.BaseBackoff)
    }
    if cfg.MaxBackoff != 5*time.Second {
        t.Errorf("MaxBackoff = %v, want 5s", cfg.MaxBackoff)
    }
}
```

Replace `your-module` with the actual module path from go.mod.

### Step 5: Verify

```bash
go build ./internal/hedera/hcs/...
go vet ./internal/hedera/hcs/...
go test ./internal/hedera/hcs/... -v -count=1 -run TestPublish
go test ./internal/hedera/hcs/... -v -count=1 -run TestEnvelope
go test ./internal/hedera/hcs/... -v -count=1 -run TestPublishConfig
```

## Done When

- [ ] `internal/hedera/hcs/publish.go` exists and compiles
- [ ] `Publisher` implements the `MessagePublisher` interface (verified by compiler)
- [ ] `Publish` method serializes `Envelope` to JSON before sending
- [ ] Retry logic with exponential backoff is implemented and configurable
- [ ] Context cancellation is checked before each retry attempt and during backoff waits
- [ ] All errors include topic ID, message type, and attempt number
- [ ] `publish_test.go` has table-driven tests for context cancellation and envelope serialization
- [ ] `go test ./internal/hedera/hcs/...` passes
- [ ] File is under 500 lines, all functions under 50 lines
