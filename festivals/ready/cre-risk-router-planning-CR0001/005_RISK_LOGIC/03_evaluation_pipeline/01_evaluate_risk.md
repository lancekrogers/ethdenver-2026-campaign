---
fest_type: task
fest_id: 01_evaluate_risk.md
fest_name: evaluate risk
fest_parent: 03_evaluation_pipeline
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:44:20.715605-07:00
fest_tracking: true
---

# Task: evaluate risk

## Objective

Implement the `evaluateRisk()` function in `risk.go` that runs all active gates sequentially on a `RiskRequest` and produces a `RiskDecision` with generated `run_id` and `decision_hash`.

## Requirements

- [ ] `evaluateRisk()` accepts `RiskRequest`, `MarketData`, oracle data, config, and runtime (Req P0.11)
- [ ] Runs all active gates sequentially: 7, 1, 2, 3, 4, 5, 6, 8 (hold filter first for fast rejection)
- [ ] On first deny, stops evaluation and produces denied `RiskDecision` with reason
- [ ] On all gates passing, produces approved `RiskDecision` with constrained position from Gate 6
- [ ] Generates `run_id` via `generateRunID()` and `decision_hash` via `hashDecision()`

## Implementation

1. **Add `evaluateRisk` function** to `risk.go`:
   - Check Gate 7 (hold filter) first for fast path rejection
   - Check Gates 1, 2, 3 (input validation)
   - Check Gate 4 (oracle health) -- get Chainlink price on success
   - Check Gate 5 (price deviation) -- skip if no market data
   - Calculate position via Gate 6 (volatility sizing)
   - Check Gate 8 (heartbeat) -- skip if disabled
   - Generate `run_id` using `generateRunID(req.TaskID, req.AgentID, runtime)`
   - Build `RiskDecision` with all fields
   - Generate `decision_hash` using `hashDecision(decision)`

2. **Return** the `RiskDecision` -- always valid (approved or denied), never nil or error-only.

## Done When

- [ ] All requirements met
- [ ] Function produces correct decisions for all 5 spec scenarios (Section 9)
- [ ] `run_id` and `decision_hash` are generated for every decision
