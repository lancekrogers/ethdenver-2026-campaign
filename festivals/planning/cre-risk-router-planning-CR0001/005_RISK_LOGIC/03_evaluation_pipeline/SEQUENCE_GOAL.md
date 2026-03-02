---
fest_type: sequence
fest_id: 03_evaluation_pipeline
fest_name: evaluation pipeline
fest_parent: 003_RISK_LOGIC
fest_order: 3
fest_status: pending
fest_created: 2026-03-01T17:43:47.581844-07:00
fest_tracking: true
---

# Sequence Goal: 03_evaluation_pipeline

**Sequence:** 03_evaluation_pipeline | **Phase:** 003_RISK_LOGIC | **Status:** Pending | **Created:** 2026-03-01T17:43:47-07:00

## Sequence Objective

**Primary Goal:** Wire all 8 risk gates into the main `evaluateRisk()` function that runs gates sequentially, produces a `RiskDecision` with `run_id` and `decision_hash`, and implements fallback logic for external data failures.

**Contribution to Phase Goal:** This is the capstone sequence of the risk logic phase, combining all individual gates into a single callable function that the CRE workflow handlers invoke in Phase 004.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **evaluateRisk() function**: Runs all active gates sequentially on a `RiskRequest`, produces `RiskDecision` with generated `run_id` (keccak256 of task_id + agent_id + runtime.Now().UnixNano() + runtime.Rand()) and `decision_hash` (keccak256 of all fields)
- [ ] **Fallback logic**: CoinGecko failure skips Gate 5 and uses 10% fallback volatility in Gate 6; Chainlink failure triggers Gate 4 deny with `chainlink_feed_unavailable`

### Quality Standards

- [ ] **Deterministic run_id**: Uses CRE `runtime.Rand()` for DON-deterministic randomness to avoid collisions under retries
- [ ] **Always-valid output**: Function always returns a valid `RiskDecision` (approved or denied), never panics or returns an error without a decision

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_evaluate_risk | Implement evaluateRisk() in risk.go | Wires gates together into the callable evaluation function |
| 02_fallback_logic | Implement graceful degradation for external data failures | Ensures workflow never crashes regardless of data availability |

## Dependencies

### Prerequisites (from other sequences)

- 01_types_and_helpers: `RiskRequest`, `RiskDecision`, `Config` types, `generateRunID()`, `hashDecision()` helpers
- 02_risk_gates: All 8 gate functions implemented

### Provides (to other sequences)

- `evaluateRisk()` function: Used by 004_WORKFLOW_INTEGRATION/01_handlers in both HTTP and cron trigger handlers

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Gate ordering produces unexpected interactions | Low | Med | Test with all 5 simulation scenarios from spec Section 9 |
| Fallback volatility value (10%) is too conservative or aggressive | Low | Low | Configurable via `volatility_scale_factor`; 10% is spec default |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: `evaluateRisk()` function wired with all gates, producing correct decisions
- [ ] **Milestone 2**: Fallback logic handles both CoinGecko and Chainlink failures gracefully
- [ ] **Milestone 3**: All 5 simulation scenarios from spec Section 9 produce expected outcomes

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete
- [ ] Performance benchmarks met

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed
- [ ] Standards compliance verified

### Iteration Decision

- [ ] Need another iteration? TBD after execution
- [ ] If yes, new tasks created: TBD
