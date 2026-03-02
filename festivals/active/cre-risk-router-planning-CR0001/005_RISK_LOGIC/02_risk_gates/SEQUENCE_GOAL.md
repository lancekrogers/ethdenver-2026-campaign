---
fest_type: sequence
fest_id: 02_risk_gates
fest_name: risk gates
fest_parent: 003_RISK_LOGIC
fest_order: 2
fest_status: pending
fest_created: 2026-03-01T17:43:47.562861-07:00
fest_tracking: true
---

# Sequence Goal: 02_risk_gates

**Sequence:** 02_risk_gates | **Phase:** 003_RISK_LOGIC | **Status:** Pending | **Created:** 2026-03-01T17:43:47-07:00

## Sequence Objective

**Primary Goal:** Implement all 8 risk gates in `risk.go`, each independently evaluating one dimension of trade risk.

**Contribution to Phase Goal:** The 8 gates are the core differentiator of the submission. They demonstrate substantive logic (not a passthrough) and use 5 CRE capabilities. This sequence produces all individual gate functions that the evaluation pipeline wires together.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Gates 1-3**: Signal confidence threshold (deny if < 0.6), risk score ceiling (deny if > 75), signal staleness (deny if expired, using `runtime.Now()`)
- [ ] **Gate 4**: Chainlink oracle health with full `latestRoundData()` validation (answer > 0, updatedAt > 0, answeredInRound >= roundId, staleness check)
- [ ] **Gate 5**: Price deviation vs oracle with 8-decimal normalization and BPS deviation calculation
- [ ] **Gate 6**: Volatility-adjusted position sizing with abs(), clamp(0.1, 1.0) on both factors, BPS cap enforcement, min(dynamic, bps_cap, requested)
- [ ] **Gate 7**: Hold signal filter (hard deny on "hold")
- [ ] **Gate 8**: Agent heartbeat circuit breaker (configurable via `enable_heartbeat_gate`, Hedera Mirror Node HTTP fetch, TTL check, off by default)

### Quality Standards

- [ ] **Deny reason strings**: Each gate uses the exact deny reason strings from the spec (e.g., `signal_confidence_below_threshold`, `risk_score_exceeds_maximum`)
- [ ] **Mathematical correctness**: Gate 5 normalizes both prices to 8 decimals before comparison; Gate 6 clamps factors to [0.1, 1.0] and takes min of three values

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_gates_1_3 | Implement gates 1, 2, and 3 (input validation + staleness) | Core input validation gates |
| 01_gate_4_oracle_health | Implement gate 4 (Chainlink oracle health) | EVM read capability validation gate |
| 01_gate_5_price_deviation | Implement gate 5 (price deviation vs oracle) | Cross-source price comparison gate |
| 02_gate_6_position_sizing | Implement gate 6 (volatility-adjusted sizing) | Position constraint gate |
| 02_gate_7_hold_filter | Implement gate 7 (hold signal filter) | Signal type filter gate |
| 02_gate_8_heartbeat | Implement gate 8 (agent heartbeat circuit breaker) | Configurable agent liveness gate |

## Dependencies

### Prerequisites (from other sequences)

- 01_types_and_helpers: `RiskRequest`, `RiskDecision`, `MarketData`, `Config` types plus `clamp()`, `toFeedDecimals()` helpers

### Provides (to other sequences)

- All 8 gate functions: Used by 03_evaluation_pipeline to wire into `evaluateRisk()`

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Chainlink `latestRoundData()` interface differs on chosen testnet | Low | Med | Validate against testnet feed in Phase 001 findings |
| CoinGecko rate limiting affects Gate 5 testing | Med | Low | Use fallback path (skip Gate 5 if CoinGecko unavailable) |
| Hedera Mirror Node API format unknown for Gate 8 | Low | Low | Gate 8 is off by default; can be stubbed initially |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Gates 1-3, 4, and 5 implemented (parallel group 01)
- [ ] **Milestone 2**: Gates 6, 7, and 8 implemented (parallel group 02)
- [ ] **Milestone 3**: All gates pass unit tests with correct deny reasons

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
