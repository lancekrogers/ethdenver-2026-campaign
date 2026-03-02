---
fest_type: task
fest_id: 01_gate_7_hold_filter.md
fest_name: gate 7 hold filter
fest_parent: 02_risk_gates
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:44:07.804799-07:00
fest_tracking: true
---

# Task: gate 7 hold filter

## Objective

Implement Gate 7 (Hold Signal Filter) in `risk.go` as a simple hard deny when the signal is "hold".

## Requirements

- [ ] Deny if `signal == "hold"`, reason: `hold_signal_no_trade` (Req P0.9)
- [ ] A hold signal means "do nothing" -- CRE enforces this as a hard deny

## Implementation

1. **Add `checkHoldSignal` function** to `risk.go`:

   ```go
   func checkHoldSignal(req RiskRequest) (bool, string) {
       if req.Signal == "hold" {
           return false, "hold_signal_no_trade"
       }
       return true, ""
   }
   ```

2. This is the simplest gate -- single condition, single deny reason.

## Done When

- [ ] All requirements met
- [ ] Gate denies on "hold" signal with correct reason string
