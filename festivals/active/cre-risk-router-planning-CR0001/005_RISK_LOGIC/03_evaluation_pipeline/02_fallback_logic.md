---
fest_type: task
fest_id: 01_fallback_logic.md
fest_name: fallback logic
fest_parent: 03_evaluation_pipeline
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:44:20.733398-07:00
fest_tracking: true
---

# Task: fallback logic

## Objective

Implement graceful degradation for external data failures: CoinGecko failure handling (skip Gate 5, 10% fallback volatility for Gate 6) and Chainlink failure handling (Gate 4 denies with `chainlink_feed_unavailable`).

## Requirements

- [ ] CoinGecko failure: skip Gate 5 (price deviation), Gate 6 uses 10% fallback volatility (volatility_factor ~ 0.90) (Req P0.12)
- [ ] Chainlink failure: Gate 4 denies with reason `chainlink_feed_unavailable`
- [ ] Workflow always produces a valid result (approved or denied), never crashes

## Implementation

1. **In `evaluateRisk()`**, check whether market data is available (non-nil, non-zero price):
   - If CoinGecko data is missing, set a flag `hasMarketData = false`
   - Skip Gate 5 when `!hasMarketData`
   - Pass `fallbackVolatility = 10.0` to Gate 6 when `!hasMarketData` (instead of actual volatility)

2. **In the handler** (Phase 004), if the Chainlink EVM read fails entirely:
   - Pass zero values to Gate 4
   - Gate 4 will deny with `chainlink_feed_invalid` (answer <= 0)
   - This produces a denied receipt on-chain, not a simulation failure

3. **Both outcomes (approved and denied) produce an on-chain write** -- the workflow always completes.

## Done When

- [ ] All requirements met
- [ ] CoinGecko failure produces valid approved/denied decision (not crash)
- [ ] Chainlink failure produces denied decision with `chainlink_feed_unavailable`/`chainlink_feed_invalid`
- [ ] No panic paths exist in the evaluation pipeline
