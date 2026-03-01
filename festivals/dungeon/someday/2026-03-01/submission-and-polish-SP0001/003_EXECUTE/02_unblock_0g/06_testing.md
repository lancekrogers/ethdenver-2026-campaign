---
fest_type: gate
fest_id: 06_testing.md
fest_name: Testing
fest_parent: 02_unblock_0g
fest_order: 6
fest_status: pending
fest_gate_type: testing
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 06 | **Parallel Group:** None | **Dependencies:** All implementation tasks (01–05) | **Autonomy:** medium

## Objective

Run the full test suite for `agent-inference` and verify that the ABI changes in `broker.go` introduce no regressions. Confirm that the new `getAllServices`-based implementation is covered by tests and behaves correctly under error conditions.

## Requirements

- [ ] `go test ./...` passes in `projects/agent-inference`
- [ ] ABI-related tests cover the new `getAllServices` path
- [ ] Context cancellation is tested for `listFromChain`
- [ ] Empty service list is handled gracefully (no panic, returns `ErrNoModels`)
- [ ] Malformed ABI response is handled gracefully (no panic)

## Test Categories

### Unit Tests

```bash
cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference
go test ./internal/zerog/compute/... -v -count=1
```

**Verify:**

- [ ] `listFromChain` returns models when `getAllServices` returns non-empty slice
- [ ] `listFromChain` returns nil (not error) when `getAllServices` returns empty slice
- [ ] `listFromChain` returns error when the call itself fails
- [ ] `ListModels` falls back to HTTP when chain returns empty and `Endpoint` is set
- [ ] Cache hit returns without calling chain again

### Full Suite

```bash
cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference
go test ./... -count=1
```

All packages must pass. Any pre-existing test failures must be documented as known issues, not introduced by this sequence.

### Linting

```bash
cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference
go vet ./...
```

No new `vet` warnings introduced.

### Coverage Check

```bash
cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference
go test ./internal/zerog/compute/... -coverprofile=coverage.out -count=1
go tool cover -func=coverage.out | grep -E "listFromChain|ListModels"
```

The `listFromChain` and `ListModels` functions should have meaningful coverage. Target: 70%+ for modified code.

### Error Handling Verification

Confirm the following error paths are exercised by tests:

- [ ] `getAllServices` RPC call fails — returns wrapped error from `listFromChain`
- [ ] `getAllServices` returns empty list — `ListModels` falls back to HTTP or returns `ErrNoModels`
- [ ] Context cancelled before call — returns context error
- [ ] Provider URL is empty in returned struct — entry is skipped without panic

## Definition of Done

- [ ] `go test ./...` passes with no failures
- [ ] `go vet ./...` produces no new warnings
- [ ] `listFromChain` and `ListModels` coverage at 70%+
- [ ] All error paths verified
- [ ] No pre-existing failures hidden or masked

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Full suite: [ ] Pass / [ ] Fail
- Linting (`go vet`): [ ] Pass / [ ] Fail
- Coverage (compute package): ____%
