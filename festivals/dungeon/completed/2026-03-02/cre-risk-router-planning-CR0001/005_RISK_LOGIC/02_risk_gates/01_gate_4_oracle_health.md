---
fest_type: task
fest_id: 01_gate_4_oracle_health.md
fest_name: gate 4 oracle health
fest_parent: 02_risk_gates
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:44:07.749172-07:00
fest_updated: 2026-03-02T00:59:56.553858-07:00
fest_tracking: true
---


# Task: gate 4 oracle health

## Objective

Implement Gate 4 (Chainlink Oracle Health) in `risk.go` with full `latestRoundData()` validation: answer > 0, updatedAt > 0, answeredInRound >= roundId, staleness check.

## Requirements

- [ ] Read `latestRoundData()` from Chainlink price feed via CRE EVM read capability (Req P0.6)
- [ ] Deny if `answer <= 0`, reason: `chainlink_feed_invalid`
- [ ] Deny if `updatedAt == 0`, reason: `chainlink_feed_not_updated`
- [ ] Deny if `answeredInRound < roundId`, reason: `chainlink_round_incomplete`
- [ ] Deny if `(now - updatedAt) > config.oracle_staleness_seconds` (default 3600), reason: `chainlink_feed_stale`

## Implementation

1. **Add `checkOracleHealth` function** to `risk.go`:

   - Accept the 5-tuple from `latestRoundData()`: roundId, answer, startedAt, updatedAt, answeredInRound
   - Accept config for staleness threshold and current time
   - Run 4 checks in order, returning the first failure
   - On success, return the `answer` value as the Chainlink price (already in 8-decimal format)

2. **The actual EVM read call** happens in the handler (Phase 004), not in this gate function. This function validates the returned data.

3. **If the Chainlink read fails entirely** (network error), the handler passes a zero answer, and this gate denies with `chainlink_feed_invalid`.

## Done When

- [ ] All requirements met
- [ ] All 4 oracle health checks implemented with correct deny reasons
- [ ] Function returns Chainlink price on success for use by Gate 5