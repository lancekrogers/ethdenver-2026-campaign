---
fest_type: task
fest_id: 01_scenarios.md
fest_name: scenarios
fest_parent: 01_documentation
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:45:12.195965-07:00
fest_updated: 2026-03-02T01:16:52.585554-07:00
fest_tracking: true
---


# Task: scenarios

## Objective

Create 5 pre-built JSON simulation scenarios in `scenarios/` with documented expected outcomes per spec Section 9.

## Requirements

- [ ] `scenarios/approved_trade.json`: buy, confidence 0.85, risk 10, $1000, expected approved with constrained position (Req P0.19)
- [ ] `scenarios/denied_low_confidence.json`: buy, confidence 0.45, risk 35, expected denied `signal_confidence_below_threshold`
- [ ] `scenarios/denied_high_risk.json`: sell, confidence 0.9, risk 82, expected denied `risk_score_exceeds_maximum`
- [ ] `scenarios/denied_stale_signal.json`: buy, confidence 0.8, risk 40, timestamp 600s old, expected denied `signal_expired`
- [ ] `scenarios/denied_price_deviation.json`: scenario triggering Gate 5 denial

## Implementation

1. **Create each JSON file** in `projects/cre-risk-router/scenarios/` matching spec Section 9 exactly.

2. **Each file** should include:
   - The `RiskRequest` JSON payload
   - A comment/description field documenting the expected outcome
   - The specific gate that triggers and the expected deny reason

3. **For the stale signal scenario**, use a timestamp that is `now - 600` seconds to exceed the 300s TTL.

4. **For price deviation**, construct a scenario where market conditions would trigger >5% deviation.

## Done When

- [ ] All requirements met
- [ ] All 5 scenario JSON files created with expected outcomes documented
- [ ] Scenarios cover approved, denied (multiple reasons) outcomes