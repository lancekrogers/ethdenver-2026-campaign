---
fest_type: gate
fest_id: 04_testing.md
fest_name: Testing and Verification
fest_parent: 01_drift_client
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-13T02:27:19.939924-06:00
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
go test ./internal/adapters/drift/... -v -count=1
```

**Verify:**

- [ ] All new/modified code has test coverage
- [ ] Tests are meaningful (not just coverage padding)
- [ ] Test names describe what they verify

### Integration Tests

```bash
go test ./internal/adapters/drift/... -v -tags=integration -run TestDrift
```

Run against Drift BET devnet. Verify:

- [ ] ListMarkets returns valid market data
- [ ] GetMarket retrieves a specific market by ID
- [ ] GetOrderBook returns bid/ask data
- [ ] PlaceOrder submits and confirms on devnet
- [ ] GetPositions returns open positions
- [ ] CancelOrder cancels a pending order

**Verify:**

- [ ] Components work together correctly
- [ ] External integrations function properly
- [ ] Data flows correctly through the system

### Manual Verification

Walk through each requirement from the sequence:

1. [ ] **MarketAdapter interface**: All methods implemented (ListMarkets, GetMarket, GetOrderBook, PlaceOrder, CancelOrder, GetPositions, RedeemPosition, GetPositionValue)
2. [ ] **Context propagation**: Pass a cancelled context and verify HTTP calls abort
3. [ ] **Error wrapping**: Trigger errors and verify messages follow "drift: <operation>: <cause>" format

## Coverage Requirements

- Minimum coverage: 80% for new code

```bash
go test ./internal/adapters/drift/... -coverprofile=coverage.out -covermode=atomic
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
