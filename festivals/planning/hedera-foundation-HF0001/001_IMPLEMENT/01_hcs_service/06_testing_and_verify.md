---
fest_type: task
fest_id: 06_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 01_hcs_service
fest_order: 6
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 06 | **Sequence:** 01_hcs_service | **Autonomy:** medium | **Quality Gate**

## Objective

Verify all HCS service functionality implemented in tasks 02-05 works correctly through comprehensive testing. This is a quality gate -- it must pass before proceeding to code review.

## Requirements

- [ ] All unit tests pass for the `internal/hedera/hcs/` package
- [ ] Context cancellation tests verify graceful shutdown for all three interfaces
- [ ] Envelope serialization/deserialization round-trips correctly
- [ ] Error wrapping includes operational context in all error paths
- [ ] Code compiles cleanly with `go build` and `go vet`
- [ ] Test coverage meets minimum 70% for new code

## Implementation

### Step 1: Run all unit tests

From the agent-coordinator project root:

```bash
go test ./internal/hedera/hcs/... -v -count=1
```

All tests must pass. If any fail, fix the implementation before proceeding.

### Step 2: Check test coverage

```bash
go test ./internal/hedera/hcs/... -coverprofile=coverage.out -covermode=atomic
go tool cover -func=coverage.out
```

Review the coverage output. Minimum 70% coverage for new code. Identify any uncovered paths and add tests if below threshold.

### Step 3: Run static analysis

```bash
go vet ./internal/hedera/hcs/...
```

If `staticcheck` is available:

```bash
staticcheck ./internal/hedera/hcs/...
```

Both must pass with zero warnings.

### Step 4: Verify interface compliance

Confirm that each implementation satisfies its interface. Add compile-time assertions if not already present:

```go
// In topic.go
var _ TopicCreator = (*TopicService)(nil)

// In publish.go
var _ MessagePublisher = (*Publisher)(nil)

// In subscribe.go
var _ MessageSubscriber = (*Subscriber)(nil)
```

Run `go build ./internal/hedera/hcs/...` to verify the compiler accepts these assertions.

### Step 5: Manual verification checklist

Walk through each implemented file and verify:

1. [ ] **interfaces.go**: All interfaces have 1-3 methods, all I/O methods accept `context.Context` first
2. [ ] **message.go**: All MessageType constants are defined, Envelope has Marshal/Unmarshal functions
3. [ ] **topic.go**: CreateTopic, DeleteTopic, TopicInfo all check `ctx.Err()`, all errors wrapped
4. [ ] **publish.go**: Publish serializes envelope, retries with backoff, checks context per attempt
5. [ ] **subscribe.go**: Subscribe returns channels, reconnects on failure, closes channels on context cancel

### Step 6: Verify error messages

Run a targeted test that triggers errors and inspect the error strings:

```bash
go test ./internal/hedera/hcs/... -v -run "Context|Error|Invalid"
```

Every error message should contain:
- The operation name (e.g., "create topic", "publish to topic", "subscribe to topic")
- The relevant identifiers (topic ID, message type)
- The wrapped underlying error

### Step 7: Document results

Create a `results/` directory in this sequence and write a test results summary:

```
001_IMPLEMENT/01_hcs_service/results/testing_results.md
```

Include:
- Test pass/fail counts
- Coverage percentage
- Static analysis results
- Any issues found and their resolution

## Done When

- [ ] `go test ./internal/hedera/hcs/... -v -count=1` passes with all tests green
- [ ] Test coverage is at least 70% for new code
- [ ] `go vet` and `staticcheck` pass with zero warnings
- [ ] All three interface compliance assertions compile
- [ ] Error messages include operational context in all paths
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
- [ ] Test results documented in `results/testing_results.md`
