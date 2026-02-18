---
fest_type: task
fest_id: 05_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 04_coordinator
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 05 | **Sequence:** 04_coordinator | **Autonomy:** medium | **Quality Gate**

## Objective

Verify all coordinator functionality works correctly through comprehensive testing. This includes the state machine, task assignment, progress monitoring, quality gate enforcement, and payment flow.

## Requirements

- [ ] All unit tests pass for `internal/coordinator/`
- [ ] State machine transitions cover all valid and invalid paths
- [ ] Mock-based tests verify HCS/HTS integration points
- [ ] Payment double-pay prevention is verified
- [ ] Code compiles cleanly with `go build` and `go vet`
- [ ] Test coverage meets minimum 70%

## Implementation

### Step 1: Run all unit tests

```bash
go test ./internal/coordinator/... -v -count=1
```

### Step 2: Create mock interfaces for testing

If not already created, implement mock versions of the HCS and HTS interfaces for testing:

```go
// internal/coordinator/mock_test.go
type mockPublisher struct {
    messages []hcs.Envelope
    err      error
}

func (m *mockPublisher) Publish(ctx context.Context, topicID hedera.TopicID, msg hcs.Envelope) error {
    if m.err != nil {
        return m.err
    }
    m.messages = append(m.messages, msg)
    return nil
}

type mockTransferService struct {
    transfers []hts.TransferRequest
    receipt   *hts.TransferReceipt
    err       error
}

func (m *mockTransferService) Transfer(ctx context.Context, req hts.TransferRequest) (*hts.TransferReceipt, error) {
    if m.err != nil {
        return nil, m.err
    }
    m.transfers = append(m.transfers, req)
    return m.receipt, nil
}

func (m *mockTransferService) AssociateToken(ctx context.Context, tokenID hedera.TokenID, accountID hedera.AccountID) error {
    return nil
}
```

### Step 3: Write comprehensive integration-style tests

Test the full assignment -> monitor -> payment flow using mocks:

1. Create a plan with 3 tasks across 1 sequence
2. Assign all tasks using the assigner with mock publisher
3. Verify all 3 assignment messages were published to HCS
4. Simulate status updates by calling monitor methods directly
5. Verify state transitions are tracked correctly
6. Trigger payment for a completed task
7. Verify the HTS transfer was called with correct parameters
8. Verify the settlement HCS message was published

### Step 4: Check coverage

```bash
go test ./internal/coordinator/... -coverprofile=coverage.out -covermode=atomic
go tool cover -func=coverage.out
```

### Step 5: Static analysis

```bash
go vet ./internal/coordinator/...
staticcheck ./internal/coordinator/...
```

### Step 6: Verify DI compliance

Confirm the coordinator package does NOT import concrete Hedera SDK types directly for operations. It should only use:
- `hedera.TopicID`, `hedera.TokenID`, `hedera.AccountID` for configuration
- HCS and HTS interfaces for operations

### Step 7: Document results

Create `001_IMPLEMENT/04_coordinator/results/testing_results.md`.

## Done When

- [ ] All tests pass
- [ ] Coverage at least 70%
- [ ] Static analysis clean
- [ ] Mock-based flow test covers assignment through payment
- [ ] State machine has 100% transition coverage
- [ ] DI compliance verified
- [ ] Results documented
