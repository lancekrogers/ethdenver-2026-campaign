---
fest_type: phase
fest_id: 005_RISK_LOGIC
fest_name: RISK_LOGIC
fest_parent: cre-risk-router-planning-CR0001
fest_order: 5
fest_status: pending
fest_created: 2026-03-01T17:42:33.405995-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 003_RISK_LOGIC

**Phase:** 003_RISK_LOGIC | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Implement all 8 risk gates, data types, helper functions, and the evaluation pipeline that produces `RiskDecision` outputs from `RiskRequest` inputs.

**Context:** This phase builds on the scaffolded project and deployed contract from Phase 002. It implements the core differentiator of the submission: 8 risk gates (7 active + 1 configurable) that independently evaluate trade risk across multiple dimensions. The completed risk logic is wired into CRE workflow handlers in Phase 004.

## Required Outcomes

Deliverables this phase must produce:

- [ ] `types.go` with `RiskRequest`, `RiskDecision`, `MarketData`, and `Config` structs per spec Section 5, using 8-decimal precision for `ChainlinkPrice`
- [ ] `helpers.go` with `generateRunID()`, `hashDecision()`, `calculateSlippage()`, `toFeedDecimals()`, and `clamp()` functions
- [ ] Gates 1-3 in `risk.go`: signal confidence threshold, risk score ceiling, signal staleness (using `runtime.Now()`)
- [ ] Gate 4 in `risk.go`: full `latestRoundData()` oracle health validation (answer > 0, updatedAt > 0, answeredInRound >= roundId, staleness check)
- [ ] Gate 5 in `risk.go`: price deviation vs oracle with 8-decimal normalization and BPS comparison
- [ ] Gate 6 in `risk.go`: volatility-adjusted position sizing with abs(), clamp(0.1, 1.0), BPS cap enforcement
- [ ] Gate 7 in `risk.go`: hold signal filter (hard deny on "hold")
- [ ] Gate 8 in `risk.go`: configurable agent heartbeat circuit breaker (off by default, Hedera Mirror Node HTTP fetch)
- [ ] `evaluateRisk()` function wiring all active gates sequentially, producing `RiskDecision` with `run_id` and `decision_hash`
- [ ] Fallback logic: CoinGecko failure skips Gate 5 and uses 10% fallback volatility in Gate 6; Chainlink failure triggers Gate 4 deny with `chainlink_feed_unavailable`

## Quality Standards

Quality criteria for all work in this phase:

- [ ] All price math uses 8-decimal precision matching Chainlink USD feed native format
- [ ] Every gate has clear deny reasons matching spec strings exactly
- [ ] Gate 6 clamps both volatility_factor and risk_factor to [0.1, 1.0] and applies BPS cap
- [ ] Gate 8 is disabled by default and does not block standalone simulation
- [ ] Fallback logic ensures the workflow always produces a valid result (approved or denied), never crashes

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_types_and_helpers | Define all data types and utility functions | `types.go` and `helpers.go` |
| 02_risk_gates | Implement each of the 8 risk gates | All gates in `risk.go` |
| 03_evaluation_pipeline | Wire gates into main evaluation function with fallback logic | `evaluateRisk()` function |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_types_and_helpers
- [ ] 02_risk_gates
- [ ] 03_evaluation_pipeline

## Notes

Gates 1-3, 4, and 5 can be implemented in parallel (same task number prefix 01). Gates 6, 7, and 8 can be implemented in parallel (prefix 02). The evaluation pipeline depends on all gates being complete. Requirements traced: P0.5-P0.12.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
