---
fest_type: task
fest_id: 01_coordinator_topic_keys.md
fest_name: coordinator topic keys
fest_parent: 05_system_polish
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.811192-07:00
fest_tracking: true
---

# Task: Add Admin/Submit Keys to Coordinator Topic Creation

## Objective

Set admin and submit keys on HCS topic creation in the coordinator so the security model claim in the README matches the actual code.

## Requirements

- [ ] `CreateTopic` in `projects/agent-coordinator/internal/hedera/hcs/topic.go` sets `SetAdminKey` and `SetSubmitKey` on the `TopicCreateTransaction`
- [ ] The coordinator's operator key is used as both the admin and submit key

## Implementation

### Step 1: Find CreateTopic

In `projects/agent-coordinator/internal/hedera/hcs/topic.go`, find the `CreateTopic` method. It currently only calls `SetTopicMemo` on the `hiero.NewTopicCreateTransaction()`.

### Step 2: Add key configuration

Add admin and submit keys to the transaction. The keys should come from the client's operator key:

```go
func (s *TopicService) CreateTopic(ctx context.Context, memo string) (*hiero.TopicID, error) {
    tx := hiero.NewTopicCreateTransaction().
        SetTopicMemo(memo).
        SetAdminKey(s.client.GetOperatorPublicKey()).
        SetSubmitKey(s.client.GetOperatorPublicKey())

    // ... rest of the existing execution logic
}
```

### Step 3: Update tests

In `projects/agent-coordinator/internal/hedera/hcs/topic_test.go`, verify the test still passes. If the test mocks the transaction, update the mock expectations to include the key-setting calls.

## Done When

- [ ] All requirements met
- [ ] `just test` passes in agent-coordinator and `CreateTopic` sets both admin and submit keys
