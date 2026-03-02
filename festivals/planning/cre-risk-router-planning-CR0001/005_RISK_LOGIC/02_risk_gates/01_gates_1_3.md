---
fest_type: task
fest_id: 01_gates_1_3.md
fest_name: gates 1 3
fest_parent: 02_risk_gates
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:44:07.730572-07:00
fest_tracking: true
---

# Task: gates 1 3

## Objective

Implement Gates 1 (signal confidence threshold), 2 (risk score ceiling), and 3 (signal staleness) in `risk.go`.

## Requirements

- [ ] Gate 1: Deny if `signal_confidence < config.confidence_threshold` (default 0.6), reason: `signal_confidence_below_threshold` (Req P0.5)
- [ ] Gate 2: Deny if `risk_score > config.max_risk_score` (default 75), reason: `risk_score_exceeds_maximum` (Req P0.5)
- [ ] Gate 3: Deny if `(runtime.Now() - request.timestamp) > config.decision_ttl_seconds` (default 300), reason: `signal_expired`. Uses `runtime.Now()` for DON-deterministic time (Req P0.5)

## Implementation

1. **Add gate functions** to `risk.go`:

   - `checkSignalConfidence(req RiskRequest, cfg Config) (bool, string)` -- returns (false, "signal_confidence_below_threshold") if confidence below threshold
   - `checkRiskScore(req RiskRequest, cfg Config) (bool, string)` -- returns (false, "risk_score_exceeds_maximum") if score exceeds max
   - `checkSignalStaleness(req RiskRequest, cfg Config, now int64) (bool, string)` -- returns (false, "signal_expired") if (now - req.Timestamp) > cfg.DecisionTTLSec. The `now` parameter comes from `runtime.Now().Unix()` in the handler.

2. Each function returns `(true, "")` if the gate passes.

3. **Verify** deny reason strings match spec exactly.

## Done When

- [ ] All requirements met
- [ ] All 3 gates implemented with correct deny reasons
- [ ] Gate 3 accepts `now` parameter (not system clock) for DON-deterministic behavior
