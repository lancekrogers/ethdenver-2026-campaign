---
fest_type: task
fest_id: 01_gate_6_position_sizing.md
fest_name: gate 6 position sizing
fest_parent: 02_risk_gates
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:44:07.78593-07:00
fest_updated: 2026-03-02T00:59:56.603665-07:00
fest_tracking: true
---


# Task: gate 6 position sizing

## Objective

Implement Gate 6 (Volatility-Adjusted Position Sizing) in `risk.go` with abs(), clamp(0.1, 1.0) on both factors, BPS cap enforcement, and min(dynamic, bps_cap, requested).

## Requirements

- [ ] Calculate `abs_volatility = abs(volatility_24h)` (Req P0.8)
- [ ] Calculate `volatility_factor = clamp(1.0 - (abs_volatility / 100.0 * config.volatility_scale), 0.1, 1.0)`
- [ ] Calculate `risk_factor = clamp(1.0 - (risk_score / 100.0), 0.1, 1.0)`
- [ ] Calculate `dynamic_position = requested_position * volatility_factor * risk_factor`
- [ ] Enforce BPS cap: `bps_cap = requested_position * config.default_max_position_bps / 10000`
- [ ] Final position: `max_position = min(dynamic_position, bps_cap, requested_position)`
- [ ] This gate does not deny -- it constrains the position size

## Implementation

1. **Add `calculatePositionSize` function** to `risk.go`:

   - Accept requested position (float64), volatility (float64), risk score (int), and config
   - Use `math.Abs()` on volatility (can be negative for price drops)
   - Clamp both factors to [0.1, 1.0] to prevent positions exceeding request or going negative
   - Floor at 10% of requested -- if risk is that extreme, Gates 2 or 4 should deny outright
   - Apply BPS cap from config (default 10000 = 100%, acts as configurable ceiling)
   - Return `uint64(min(dynamic, bps_cap, requested))`

2. **If CoinGecko fails**, the evaluation pipeline passes 10% fallback volatility to this function.

## Done When

- [ ] All requirements met
- [ ] Both factors clamped to [0.1, 1.0]
- [ ] BPS cap enforced
- [ ] Final position is min of three values