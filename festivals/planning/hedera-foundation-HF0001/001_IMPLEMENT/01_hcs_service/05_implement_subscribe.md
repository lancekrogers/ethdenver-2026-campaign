---
fest_type: task
fest_id: 05_implement_subscribe.md
fest_name: implement_subscribe
fest_parent: 01_hcs_service
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Message Subscription

**Task Number:** 05 | **Sequence:** 01_hcs_service | **Autonomy:** medium

## Objective

Implement the `MessageSubscriber` interface from `internal/hedera/hcs/interfaces.go`. This implementation subscribes to an HCS topic and streams deserialized `Envelope` messages through Go channels. It must handle context cancellation for graceful shutdown, automatically reconnect on transient failures, and properly close channels when the subscription ends.

## Requirements

- [ ] Create `internal/hedera/hcs/subscribe.go` implementing the `MessageSubscriber` interface
- [ ] Start a mirror node subscription using `hedera.TopicMessageQuery`
- [ ] Deserialize incoming HCS messages into `Envelope` structs
- [ ] Deliver envelopes through a buffered channel
- [ ] Send errors through a separate error channel
- [ ] Gracefully shut down when context is cancelled (close channels, stop goroutines)
- [ ] Implement reconnect-on-failure with configurable retry behavior
- [ ] Constructor accepts `*hedera.Client` via dependency injection
- [ ] Create `internal/hedera/hcs/subscribe_test.go` with table-driven tests

## Implementation

### Step 1: Create subscribe.go

Create `internal/hedera/hcs/subscribe.go` in the agent-coordinator project:

```go
package hcs

import (
    "context"
    "fmt"
    "time"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

const (
    defaultMessageBuffer  = 100
    defaultReconnectDelay = 2 * time.Second
    defaultMaxReconnects  = 10
)

// SubscribeConfig holds configuration for the subscriber.
type SubscribeConfig struct {
    MessageBuffer  int
    ReconnectDelay time.Duration
    MaxReconnects  int
}

// DefaultSubscribeConfig returns sensible defaults for testnet usage.
func DefaultSubscribeConfig() SubscribeConfig {
    return SubscribeConfig{
        MessageBuffer:  defaultMessageBuffer,
        ReconnectDelay: defaultReconnectDelay,
        MaxReconnects:  defaultMaxReconnects,
    }
}

// Subscriber implements the MessageSubscriber interface using the Hedera Go SDK.
type Subscriber struct {
    client *hedera.Client
    config SubscribeConfig
}

// NewSubscriber creates a new Subscriber with the given Hedera client and config.
func NewSubscriber(client *hedera.Client, config SubscribeConfig) *Subscriber {
    return &Subscriber{
        client: client,
        config: config,
    }
}
```

### Step 2: Implement the Subscribe method

The `Subscribe` method starts a goroutine that manages the subscription lifecycle:

```go
func (s *Subscriber) Subscribe(ctx context.Context, topicID hedera.TopicID) (<-chan Envelope, <-chan error) {
    msgCh := make(chan Envelope, s.config.MessageBuffer)
    errCh := make(chan error, s.config.MessageBuffer)

    go s.runSubscription(ctx, topicID, msgCh, errCh)

    return msgCh, errCh
}
```

### Step 3: Implement the subscription loop

The subscription loop handles reconnection and message processing:

```go
func (s *Subscriber) runSubscription(
    ctx context.Context,
    topicID hedera.TopicID,
    msgCh chan<- Envelope,
    errCh chan<- error,
) {
    defer close(msgCh)
    defer close(errCh)

    for reconnects := 0; reconnects <= s.config.MaxReconnects; reconnects++ {
        if err := ctx.Err(); err != nil {
            return
        }

        err := s.subscribeOnce(ctx, topicID, msgCh, errCh)
        if err == nil {
            return // clean shutdown via context cancellation
        }

        // Context cancelled means intentional shutdown, not a reconnect situation
        if ctx.Err() != nil {
            return
        }

        // Send the error to the error channel (non-blocking)
        select {
        case errCh <- fmt.Errorf("subscribe to topic %s: attempt %d: %w", topicID, reconnects+1, err):
        default:
            // error channel full, drop the error
        }

        // Wait before reconnecting
        select {
        case <-ctx.Done():
            return
        case <-time.After(s.config.ReconnectDelay):
            // continue to next reconnect attempt
        }
    }

    select {
    case errCh <- fmt.Errorf("subscribe to topic %s: exhausted %d reconnect attempts", topicID, s.config.MaxReconnects+1):
    default:
    }
}
```

### Step 4: Implement single subscription attempt

```go
func (s *Subscriber) subscribeOnce(
    ctx context.Context,
    topicID hedera.TopicID,
    msgCh chan<- Envelope,
    errCh chan<- error,
) error {
    _, err := hedera.NewTopicMessageQuery().
        SetTopicID(topicID).
        SetStartTime(time.Unix(0, 0)).
        Subscribe(s.client, func(message hedera.TopicMessage) {
            env, err := UnmarshalEnvelope(message.Contents)
            if err != nil {
                select {
                case errCh <- fmt.Errorf("deserialize message from topic %s seq %d: %w",
                    topicID, message.SequenceNumber, err):
                default:
                }
                return
            }

            select {
            case msgCh <- *env:
            case <-ctx.Done():
                return
            }
        })

    if err != nil {
        return fmt.Errorf("start subscription: %w", err)
    }

    // Block until context is cancelled
    <-ctx.Done()
    return nil
}
```

**Important notes for the implementer:**
- The `hedera.TopicMessageQuery.Subscribe` callback runs in a separate goroutine managed by the SDK. You must not block in the callback.
- The `select` with `ctx.Done()` in the callback prevents blocking when the context is cancelled but the message channel is full.
- The `SetStartTime(time.Unix(0, 0))` subscribes from the beginning of the topic. For production, you may want to accept a start time parameter.
- Check the actual Hedera Go SDK API -- the subscription handle may provide an `Unsubscribe()` method that should be called on context cancellation.

### Step 5: Create subscribe_test.go

Create `internal/hedera/hcs/subscribe_test.go`:

```go
package hcs_test

import (
    "context"
    "testing"
    "time"

    "your-module/internal/hedera/hcs"
)

func TestSubscribe_ContextCancellation(t *testing.T) {
    sub := hcs.NewSubscriber(nil, hcs.DefaultSubscribeConfig())

    ctx, cancel := context.WithCancel(context.Background())
    cancel() // cancel immediately

    msgCh, errCh := sub.Subscribe(ctx, hedera.TopicID{})

    // Both channels should close quickly since context is already cancelled
    timeout := time.After(2 * time.Second)
    select {
    case _, ok := <-msgCh:
        if ok {
            t.Error("expected message channel to be closed")
        }
    case <-timeout:
        t.Error("message channel did not close within timeout")
    }

    select {
    case _, ok := <-errCh:
        if ok {
            // errors from the cancelled context are acceptable
        }
    case <-timeout:
        t.Error("error channel did not close within timeout")
    }
}

func TestSubscribeConfig_Defaults(t *testing.T) {
    cfg := hcs.DefaultSubscribeConfig()

    tests := []struct {
        name string
        got  interface{}
        want interface{}
    }{
        {"MessageBuffer", cfg.MessageBuffer, 100},
        {"ReconnectDelay", cfg.ReconnectDelay, 2 * time.Second},
        {"MaxReconnects", cfg.MaxReconnects, 10},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            if tt.got != tt.want {
                t.Errorf("%s = %v, want %v", tt.name, tt.got, tt.want)
            }
        })
    }
}

func TestUnmarshalEnvelope_InvalidJSON(t *testing.T) {
    tests := []struct {
        name    string
        data    []byte
        wantErr bool
    }{
        {
            name:    "empty bytes returns error",
            data:    []byte{},
            wantErr: true,
        },
        {
            name:    "invalid JSON returns error",
            data:    []byte("not json"),
            wantErr: true,
        },
        {
            name:    "valid envelope succeeds",
            data:    []byte(`{"type":"heartbeat","sender":"agent-1","sequence_num":1,"timestamp":"2026-02-18T14:00:00Z"}`),
            wantErr: false,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            _, err := hcs.UnmarshalEnvelope(tt.data)
            if (err != nil) != tt.wantErr {
                t.Errorf("UnmarshalEnvelope() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}
```

Replace `your-module` with the actual module path from go.mod.

### Step 6: Verify

```bash
go build ./internal/hedera/hcs/...
go vet ./internal/hedera/hcs/...
go test ./internal/hedera/hcs/... -v -count=1
```

## Done When

- [ ] `internal/hedera/hcs/subscribe.go` exists and compiles
- [ ] `Subscriber` implements the `MessageSubscriber` interface (verified by compiler)
- [ ] `Subscribe` returns two channels: messages and errors
- [ ] Both channels are closed when the context is cancelled
- [ ] Reconnect-on-failure logic is implemented with configurable delay and max attempts
- [ ] Incoming messages are deserialized from JSON into `Envelope` structs
- [ ] Deserialization errors are sent to the error channel, not silently dropped
- [ ] `subscribe_test.go` has table-driven tests for context cancellation, config defaults, and deserialization
- [ ] `go test ./internal/hedera/hcs/...` passes
- [ ] File is under 500 lines, all functions under 50 lines
