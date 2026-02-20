---
fest_type: task
fest_id: 03_implement_topic_ops.md
fest_name: implement_topic_ops
fest_parent: 01_hcs_service
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Topic Operations

**Task Number:** 03 | **Sequence:** 01_hcs_service | **Autonomy:** medium

## Objective

Implement the `TopicCreator` interface from `internal/hedera/hcs/interfaces.go`. This implementation wraps the Hedera Go SDK's consensus service to create, delete, and query HCS topics on testnet. The implementation must propagate context, wrap errors with operational context, and support dependency injection via the interface.

## Requirements

- [ ] Create `internal/hedera/hcs/topic.go` implementing the `TopicCreator` interface
- [ ] Implement `CreateTopic` using `hedera.TopicCreateTransaction`
- [ ] Implement `DeleteTopic` using `hedera.TopicDeleteTransaction`
- [ ] Implement `TopicInfo` using `hedera.TopicInfoQuery`
- [ ] All methods propagate `context.Context` and check `ctx.Err()` before starting
- [ ] All errors are wrapped with operational context (what failed, with what arguments)
- [ ] Constructor accepts a `*hedera.Client` via dependency injection
- [ ] Create `internal/hedera/hcs/topic_test.go` with table-driven tests

## Implementation

### Step 1: Create topic.go

Create `internal/hedera/hcs/topic.go` in the agent-coordinator project. The file implements the `TopicCreator` interface.

```go
package hcs

import (
    "context"
    "fmt"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

// TopicService implements the TopicCreator interface using the Hedera Go SDK.
type TopicService struct {
    client *hedera.Client
}

// NewTopicService creates a new TopicService with the given Hedera client.
// The client must be configured with operator credentials for the target network.
func NewTopicService(client *hedera.Client) *TopicService {
    return &TopicService{client: client}
}
```

### Step 2: Implement CreateTopic

Add the `CreateTopic` method. Key requirements:

- Check `ctx.Err()` before starting the transaction
- Set the topic memo from the parameter
- Execute the transaction and extract the topic ID from the receipt
- Wrap all errors with context about what was attempted

```go
func (s *TopicService) CreateTopic(ctx context.Context, memo string) (hedera.TopicID, error) {
    if err := ctx.Err(); err != nil {
        return hedera.TopicID{}, fmt.Errorf("create topic: context cancelled before start: %w", err)
    }

    tx, err := hedera.NewTopicCreateTransaction().
        SetTopicMemo(memo).
        FreezeWith(s.client)
    if err != nil {
        return hedera.TopicID{}, fmt.Errorf("create topic: freeze transaction: %w", err)
    }

    resp, err := tx.Execute(s.client)
    if err != nil {
        return hedera.TopicID{}, fmt.Errorf("create topic with memo %q: execute: %w", memo, err)
    }

    receipt, err := resp.GetReceipt(s.client)
    if err != nil {
        return hedera.TopicID{}, fmt.Errorf("create topic with memo %q: get receipt: %w", memo, err)
    }

    if receipt.TopicID == nil {
        return hedera.TopicID{}, fmt.Errorf("create topic with memo %q: receipt contained nil topic ID", memo)
    }

    return *receipt.TopicID, nil
}
```

### Step 3: Implement DeleteTopic

Add the `DeleteTopic` method with the same error-wrapping and context-checking pattern:

```go
func (s *TopicService) DeleteTopic(ctx context.Context, topicID hedera.TopicID) error {
    if err := ctx.Err(); err != nil {
        return fmt.Errorf("delete topic %s: context cancelled before start: %w", topicID, err)
    }

    tx, err := hedera.NewTopicDeleteTransaction().
        SetTopicID(topicID).
        FreezeWith(s.client)
    if err != nil {
        return fmt.Errorf("delete topic %s: freeze transaction: %w", topicID, err)
    }

    resp, err := tx.Execute(s.client)
    if err != nil {
        return fmt.Errorf("delete topic %s: execute: %w", topicID, err)
    }

    _, err = resp.GetReceipt(s.client)
    if err != nil {
        return fmt.Errorf("delete topic %s: get receipt: %w", topicID, err)
    }

    return nil
}
```

### Step 4: Implement TopicInfo

Add the `TopicInfo` method:

```go
func (s *TopicService) TopicInfo(ctx context.Context, topicID hedera.TopicID) (*TopicMetadata, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("topic info %s: context cancelled before start: %w", topicID, err)
    }

    info, err := hedera.NewTopicInfoQuery().
        SetTopicID(topicID).
        Execute(s.client)
    if err != nil {
        return nil, fmt.Errorf("topic info %s: execute query: %w", topicID, err)
    }

    return &TopicMetadata{
        TopicID:        topicID,
        Memo:           info.TopicMemo,
        SequenceNumber: info.SequenceNumber,
    }, nil
}
```

### Step 5: Create topic_test.go

Create `internal/hedera/hcs/topic_test.go` with table-driven tests. Since Hedera SDK calls require network access, structure tests in two tiers:

1. **Unit tests** (always run): Test context cancellation, nil client handling, and constructor behavior
2. **Integration tests** (build tag `integration`): Test actual testnet operations

```go
package hcs_test

import (
    "context"
    "testing"

    "your-module/internal/hedera/hcs"
)

func TestNewTopicService(t *testing.T) {
    t.Run("nil client panics or returns error", func(t *testing.T) {
        // Verify constructor handles nil client gracefully
        svc := hcs.NewTopicService(nil)
        if svc == nil {
            t.Fatal("expected non-nil service even with nil client")
        }
    })
}

func TestCreateTopic_ContextCancellation(t *testing.T) {
    tests := []struct {
        name    string
        ctx     context.Context
        wantErr bool
    }{
        {
            name:    "cancelled context returns error",
            ctx:     cancelledContext(),
            wantErr: true,
        },
        {
            name:    "deadline exceeded context returns error",
            ctx:     expiredContext(),
            wantErr: true,
        },
    }

    svc := hcs.NewTopicService(nil) // nil client is fine -- context check happens first

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            _, err := svc.CreateTopic(tt.ctx, "test-memo")
            if (err != nil) != tt.wantErr {
                t.Errorf("CreateTopic() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}

// Similar table-driven tests for DeleteTopic and TopicInfo context cancellation.

func cancelledContext() context.Context {
    ctx, cancel := context.WithCancel(context.Background())
    cancel()
    return ctx
}

func expiredContext() context.Context {
    ctx, cancel := context.WithTimeout(context.Background(), 0)
    defer cancel()
    return ctx
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

- [ ] `internal/hedera/hcs/topic.go` exists and compiles
- [ ] `TopicService` implements the `TopicCreator` interface (verified by compiler)
- [ ] `NewTopicService` constructor accepts `*hedera.Client` via DI
- [ ] All three methods check `ctx.Err()` before proceeding
- [ ] All errors include operational context (topic ID, memo, operation name)
- [ ] `topic_test.go` has table-driven tests for context cancellation on all methods
- [ ] `go test ./internal/hedera/hcs/...` passes
- [ ] File is under 500 lines, all functions under 50 lines
