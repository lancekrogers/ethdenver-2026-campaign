---
fest_type: gate
fest_id: 05_testing.md
fest_name: Testing and Verification
fest_parent: 02_analysis_pipeline
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-13T02:27:19.941506-06:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 5 | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

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
go test ./internal/analysis/... -v -count=1
```

**Verify:**

- [ ] All new/modified code has test coverage
- [ ] Tests are meaningful (not just coverage padding)
- [ ] Test names describe what they verify

### Integration Tests

```bash
go test ./internal/analysis/... -v -tags=integration -run TestAnalysisPipeline
```

Run with live Claude API key against sample Drift market data. Verify:

- [ ] Claude client sends analysis prompts and parses structured responses
- [ ] Market normalizer populates NormalizedMarket from raw Drift data
- [ ] Resolution analyzer identifies mispricing between market price and fair value
- [ ] Signal generator produces valid Signal structs with edge, confidence, and sizing
- [ ] Pipeline rejects signals with unreasonably high edge claims (>30%)

**Verify:**

- [ ] Components work together correctly
- [ ] External integrations function properly
- [ ] Data flows correctly through the system

### Manual Verification

Walk through each requirement from the sequence:

1. [ ] **Claude client**: Send a market analysis prompt, verify parsed response contains probability estimate and reasoning
2. [ ] **Market normalizer**: Feed raw Drift market JSON, verify NormalizedMarket fields (question, outcomes, prices, volume, expiry) populated correctly
3. [ ] **Signal generation**: Run full pipeline on 3+ live markets, verify each Signal includes market_id, direction, edge, confidence, size, and reasoning text

## Coverage Requirements

- Minimum coverage: 80% for new code

```bash
go test ./internal/analysis/... -coverprofile=coverage.out -covermode=atomic
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
