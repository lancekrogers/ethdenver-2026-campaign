---
fest_type: task
fest_id: 03_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 03_schedule_service
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 03 | **Sequence:** 03_schedule_service | **Autonomy:** medium | **Quality Gate**

## Objective

Verify all Schedule Service functionality implemented in tasks 01-02 works correctly through comprehensive testing.

## Requirements

- [ ] All unit tests pass for `internal/hedera/schedule/`
- [ ] HeartbeatConfig validation covers all required fields and minimum interval
- [ ] Context cancellation stops the heartbeat runner cleanly
- [ ] LastHeartbeat thread safety is verified
- [ ] Code compiles cleanly with `go build` and `go vet`
- [ ] Test coverage meets minimum 70%

## Implementation

### Step 1: Run all unit tests

```bash
go test ./internal/hedera/schedule/... -v -count=1
```

### Step 2: Check test coverage

```bash
go test ./internal/hedera/schedule/... -coverprofile=coverage.out -covermode=atomic
go tool cover -func=coverage.out
```

### Step 3: Run static analysis

```bash
go vet ./internal/hedera/schedule/...
staticcheck ./internal/hedera/schedule/...
```

### Step 4: Verify interface compliance

Check compile-time assertions:
- `var _ ScheduleCreator = (*ScheduleService)(nil)`
- `var _ HeartbeatRunner = (*Heartbeat)(nil)`

### Step 5: Test the heartbeat loop with a mock

If not already done, implement a mock `ScheduleCreator` for testing:

```go
type mockScheduler struct {
    callCount int
    mu        sync.Mutex
    err       error
}

func (m *mockScheduler) CreateSchedule(ctx context.Context, innerTx hedera.Transaction, memo string) (hedera.ScheduleID, error) {
    m.mu.Lock()
    defer m.mu.Unlock()
    m.callCount++
    return hedera.ScheduleID{}, m.err
}

func (m *mockScheduler) ScheduleInfo(ctx context.Context, scheduleID hedera.ScheduleID) (*ScheduleMetadata, error) {
    return nil, nil
}
```

Use this mock to test:
1. Heartbeat fires on the configured interval
2. Context cancellation stops the loop
3. Failed heartbeats send to error channel but loop continues
4. LastHeartbeat updates after successful heartbeat

### Step 6: Manual verification

1. [ ] **interfaces.go**: Both interfaces have 2 methods, all accept context
2. [ ] **config.go**: Validate checks interval, AgentID, and AccountID
3. [ ] **schedule.go**: CreateSchedule and ScheduleInfo both check ctx.Err()
4. [ ] **heartbeat.go**: Start blocks, run uses ticker, sendHeartbeat is non-fatal on error

### Step 7: Document results

Create `001_IMPLEMENT/03_schedule_service/results/testing_results.md`.

## Done When

- [ ] All tests pass
- [ ] Coverage at least 70%
- [ ] Static analysis clean
- [ ] Mock-based heartbeat tests verify loop behavior
- [ ] Results documented
