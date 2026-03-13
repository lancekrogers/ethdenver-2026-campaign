---
fest_type: gate
fest_id: 04_testing.md
fest_name: Testing and Verification
fest_parent: 04_mainnet_deployment
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-13T02:27:19.943453-06:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 4 | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

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
go test ./... -v -count=1
```

**Verify:**

- [ ] All new/modified code has test coverage
- [ ] Tests are meaningful (not just coverage padding)
- [ ] Test names describe what they verify

### Integration Tests

```bash
# Verify agent is running and healthy on mainnet
curl -s http://localhost:8080/health | jq .
# Verify HCS messages are being published
go test ./internal/hcs/... -v -tags=integration -run TestHCSPublish
```

Verify against live mainnet deployment:

- [ ] Agent health endpoint returns healthy status
- [ ] Agent has executed at least one trade on Drift BET mainnet
- [ ] HCS topic receives trade events and P&L reports
- [ ] Wallet balance shows SOL for gas and USDC seed capital
- [ ] Position sizes respect 2% max cap during initial 24h

**Verify:**

- [ ] Components work together correctly
- [ ] External integrations function properly
- [ ] Data flows correctly through the system

### Manual Verification

Walk through each requirement from the sequence:

1. [ ] **Wallet funding**: Verify wallet has SOL for gas + USDC seed capital via `solana balance` and SPL token balance
2. [ ] **24-hour stability**: Agent has been running for 24h with no crashes, restarts, or OOM events
3. [ ] **HCS integration**: Check HCS topic for trade broadcasts and P&L reports using topic explorer

## Coverage Requirements

- Minimum coverage: 80% for new code

```bash
go test ./internal/hcs/... -coverprofile=coverage.out -covermode=atomic
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
