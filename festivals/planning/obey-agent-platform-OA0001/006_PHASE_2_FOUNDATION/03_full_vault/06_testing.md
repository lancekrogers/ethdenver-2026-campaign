---
fest_type: gate
fest_id: 06_testing.md
fest_name: Testing and Verification
fest_parent: 03_full_vault
fest_order: 6
fest_status: pending
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-13T02:27:19.957453-06:00
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
anchor test
```

**Verify:**

- [ ] All new/modified code has test coverage
- [ ] Tests are meaningful (not just coverage padding)
- [ ] Test names describe what they verify

### Integration Tests

```bash
anchor test --provider.cluster devnet
```

Verify against local validator and devnet:

- [ ] Registry program: agent registration, vault creation, agent metadata updates
- [ ] NAV program: oracle-style NAV feeds with multi-sig or automated updates, historical NAV storage
- [ ] Fees program: management fee calculation, performance fee (high-water mark), fee collection instruction
- [ ] Full vault program: integrates registry, NAV, and fees into complete vault with all MVP features plus new capabilities
- [ ] Migration: existing MVP vault deposits migrated to full vault with correct share balances

**Verify:**

- [ ] Components work together correctly
- [ ] External integrations function properly
- [ ] Data flows correctly through the system

### Manual Verification

Walk through each requirement from the sequence:

1. [ ] **Registry**: Register an agent, verify agent metadata stored on-chain, query agent by ID
2. [ ] **Fee calculation**: Simulate 30 days of vault operation, verify management fee deducted correctly and performance fee applies only above high-water mark
3. [ ] **Migration**: Migrate MVP vault state to full vault, verify all depositor share balances preserved exactly

## Coverage Requirements

- Minimum coverage: 90% for new code (higher threshold for smart contract code handling funds)

```bash
anchor test 2>&1 | tail -20
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
