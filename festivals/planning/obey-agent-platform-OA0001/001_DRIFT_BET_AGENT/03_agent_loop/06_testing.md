---
fest_type: gate
fest_id: 06_testing.md
fest_name: Testing and Verification
fest_parent: 03_agent_loop
fest_order: 6
fest_status: pending
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-13T02:27:19.942453-06:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 6 | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Verify all functionality implemented in this sequence works correctly through comprehensive testing.

## Requirements

- [ ] All unit tests pass
- [ ] Integration tests verify main workflows
- [ ] Manual testing confirms user stories work as expected
- [ ] Error cases are handled correctly
- [ ] Edge cases are addressed

## Test Categories

### Unit Tests

```bash
go test ./internal/agent/... ./internal/risk/... ./internal/portfolio/... ./cmd/pred-agent/... -v -count=1
```

**Verify:**

- [ ] All new/modified code has test coverage
- [ ] Tests are meaningful (not just coverage padding)
- [ ] Test names describe what they verify

### Integration Tests

```bash
go test ./internal/agent/... -v -tags=integration -run TestAgentLoop
```

Run in mock mode to verify full agent loop without real funds. Verify:

- [ ] Agent starts, loads config from PRED_ env vars, connects to mock Drift adapter
- [ ] Trading cycle executes: fetch markets, analyze, generate signals, apply risk checks, execute trades
- [ ] P&L reporting cycle calculates NAV from mock positions
- [ ] Health check cycle confirms all goroutines healthy
- [ ] Risk manager enforces position size limits, drawdown stop-loss, and daily loss limit
- [ ] Graceful shutdown on SIGTERM cancels context and waits for in-flight operations

**Verify:**

- [ ] Components work together correctly
- [ ] External integrations function properly
- [ ] Data flows correctly through the system

### Manual Verification

Walk through each requirement from the sequence:

1. [ ] **Config loading**: Set PRED_ env vars, start agent, verify config parsed correctly from logs
2. [ ] **Mock mode dry-run**: Run agent with `--mock` flag, verify full trading cycle completes with simulated data
3. [ ] **Graceful shutdown**: Send SIGTERM during active trading cycle, verify clean shutdown with no goroutine leaks

## Coverage Requirements

- Minimum coverage: 80% for new code

```bash
go test ./internal/agent/... ./internal/risk/... ./internal/portfolio/... -coverprofile=coverage.out -covermode=atomic
go tool cover -func=coverage.out
```

## Error Handling Verification

- [ ] Invalid inputs are rejected gracefully
- [ ] Error messages are clear and actionable
- [ ] Errors don't expose sensitive information
- [ ] Recovery paths work correctly

## Definition of Done

- [ ] All automated tests pass
- [ ] Manual verification complete
- [ ] Coverage meets requirements
- [ ] Error handling verified
- [ ] No regressions introduced

## Notes

Document any test gaps, flaky tests, or areas needing future attention here.

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Integration tests: [ ] Pass / [ ] Fail
- Manual tests: [ ] Pass / [ ] Fail
- Coverage: ____%
