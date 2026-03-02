---
fest_type: task
fest_id: 01_gate_5_price_deviation.md
fest_name: gate 5 price deviation
fest_parent: 02_risk_gates
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:44:07.767235-07:00
fest_tracking: true
---

# Task: gate 5 price deviation

## Objective

Implement Gate 5 (Price Deviation vs Oracle) in `risk.go` with 8-decimal normalization and BPS deviation calculation.

## Requirements

- [ ] Convert market price (float64 from CoinGecko) to 8-decimal integer using `toFeedDecimals()` (Req P0.7)
- [ ] Calculate deviation in BPS: `abs(market_price - chainlink_price) / chainlink_price * 10000`
- [ ] Deny if `deviation_bps > config.price_deviation_max_bps` (default 500 = 5%), reason: `price_deviation_exceeds_threshold`

## Implementation

1. **Add `checkPriceDeviation` function** to `risk.go`:

   - Accept Chainlink price (uint64, already 8 decimals from Gate 4), market price (float64 from HTTP fetch), and config
   - Convert market price: `marketPrice8d := toFeedDecimals(marketPrice, config.FeedDecimals)`
   - Calculate deviation: work in uint64 space to avoid float precision issues
   - `deviationBps = abs(int64(marketPrice8d) - int64(chainlinkPrice)) * 10000 / int64(chainlinkPrice)`
   - Compare against `config.PriceDevMaxBps`

2. **All price math uses 8-decimal precision** -- this is the Chainlink USD feed native format.

3. **Gate is skipped** if CoinGecko data is unavailable (handled by fallback logic in evaluation pipeline).

## Done When

- [ ] All requirements met
- [ ] Price deviation calculated in BPS with 8-decimal normalization
- [ ] Correct deny reason string: `price_deviation_exceeds_threshold`
