---
fest_type: task
fest_id: 01_create_hedera_hcs_mock.md
fest_name: create hedera hcs mock
fest_parent: 02_external_mocks
fest_order: 4
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-22T15:58:29.12355-06:00
fest_updated: 2026-03-22T16:20:19.352004-06:00
fest_tracking: true
---


# Task: Create Hedera HCS Mock

## Objective

Create a mock Hedera HCS client that accepts message submissions and topic subscriptions in-memory without connecting to real Hedera testnet.

## Requirements

- [ ] Implements the same HCS client interface used by the coordinator and agents
- [ ] `SubmitMessage(topicID, message)` stores message in memory and returns a fake transaction receipt
- [ ] `Subscribe(topicID)` returns stored messages as a channel (for the coordinator's HCS subscription loop)
- [ ] Mock HTS token transfers return success with fake tx IDs

## Implementation

1. Read the existing HCS client interface in `projects/agent-coordinator/internal/hcs/` to understand the contract
2. Create `internal/hcs/mock.go` implementing the same interface
3. Use an in-memory map of topicID → []messages with a mutex
4. Subscribe returns a channel that replays existing messages then blocks for new ones
5. Toggled by checking if HEDERA_COORDINATOR_ACCOUNT_ID is empty or a MOCK_HCS=true env var

## Done When

- [ ] All requirements met
- [ ] Coordinator starts with mock HCS and publishes festival_progress events without error
- [ ] No network calls to hedera testnet in mock mode