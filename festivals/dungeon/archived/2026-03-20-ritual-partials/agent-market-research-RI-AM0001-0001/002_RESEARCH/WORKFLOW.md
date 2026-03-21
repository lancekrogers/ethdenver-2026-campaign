---
fest_type: workflow
fest_id: 002_RESEARCH-WF
fest_parent: 002_RESEARCH
---

# Market Research & Analysis Workflow

This workflow analyzes ingested market data to determine whether a trading opportunity exists and quantify its strength. All analysis uses concrete heuristics — no subjective "the market feels good."

---

## Step 1: COMPUTE MOVING AVERAGE

**Goal:** Establish the baseline price the agent trades against.

**Actions:**
1. Load `001_INGEST/output_specs/market_snapshot.json` → extract `price_history`
2. Calculate Simple Moving Average (SMA) over the last 30 data points
3. If fewer than 30 points available, use what exists but reduce confidence by 20%

**Formula:**
```
SMA_30 = sum(prices[-30:]) / min(len(prices), 30)
```

**Output:** `findings/moving_average.json`
```json
{
  "sma_30": 3240.50,
  "data_points_used": 30,
  "oldest_point_age_minutes": 150,
  "confidence_modifier": 1.0
}
```

**Checkpoint:** SMA is non-zero and within reasonable range

---

## Step 2: CALCULATE PRICE DEVIATION

**Goal:** Determine how far current price has deviated from the moving average.

**Actions:**
1. Get current price from market snapshot
2. Calculate deviation percentage: `(current_price - SMA_30) / SMA_30 * 100`
3. Determine direction: `above_ma` or `below_ma`
4. Check against trading threshold (default: ±2%)

**Mean Reversion Heuristics:**
- Deviation < -2% → BUY signal (price below MA, expected to revert up)
- Deviation > +2% → SELL signal (price above MA, expected to revert down)
- Deviation between -2% and +2% → NO SIGNAL (within normal range)
- Deviation > ±5% → STRONG signal but also higher risk (potential trend, not mean reversion)
- Deviation > ±10% → CAUTION — likely structural move, not mean reversion candidate

**Signal strength scaling:**
```
base_confidence = min(abs(deviation_pct) / 4.0, 1.0)
# At 2% deviation → 0.5 confidence
# At 4% deviation → 1.0 confidence (capped)
# Below 2% → no signal
```

**Output:** `findings/price_deviation.json`
```json
{
  "current_price": 3172.34,
  "sma_30": 3240.50,
  "deviation_pct": -2.10,
  "deviation_direction": "below_ma",
  "signal": "BUY",
  "signal_strength": "normal",
  "base_confidence": 0.525
}
```

**Checkpoint:** If no signal (deviation within ±2%), skip to Step 5 with NO_GO fast path

---

## Step 3: RUN CRE RISK GATES

**Goal:** Evaluate the opportunity against all 8 risk gates.

**Actions:**
Run each CRE Risk Router gate in order. Document per-gate pass/fail with specific values.

### Gate 7: Hold Signal Filter (Fast Path)
- Check if external hold signal is active
- If HOLD → fail immediately, log reason
- **Pass criteria:** No hold signal active

### Gate 1: Signal Confidence
- Check: `base_confidence >= 0.6`
- If base_confidence was reduced by Step 1 (insufficient data), apply modifier here
- **Pass criteria:** Adjusted confidence ≥ 0.6

### Gate 2: Risk Score
- Composite risk from volatility + liquidity + position size
- Risk formula: `risk_score = (volatility_pct * 20) + (50 if low_volume) + (position_size_pct * 10)`
- **Pass criteria:** Risk score ≤ 75

### Gate 3: Signal Staleness
- Time since price deviation was calculated
- In a ritual context, this should always pass (data is fresh)
- **Pass criteria:** Signal age ≤ 300 seconds

### Gate 4: Oracle Health
- Verify Uniswap TWAP oracle is responsive
- Check: `observe()` call succeeded in ingest phase
- **Pass criteria:** Oracle responded with valid data

### Gate 5: Price Deviation vs Oracle
- Compare pool spot price vs TWAP price
- Large divergence suggests manipulation or extreme volatility
- **Pass criteria:** |spot - TWAP| ≤ 500 BPS

### Gate 6: Position Sizing
- Calculate recommended position size based on confidence and volatility
- Higher confidence + lower volatility = larger position
- Formula: `position_usd = min(base_confidence * max_swap_size, remaining_daily_capacity)`
- Apply volatility adjustment: `position_usd *= max(0.5, 1.0 - volatility_pct / 10.0)`
- **Pass criteria:** Calculated position > minimum profitable trade size

### Gate 8: Heartbeat Breaker
- Check agent liveness — has the agent been responsive within heartbeat window?
- In ritual context, if you're running this, you're alive
- **Pass criteria:** Agent responsive (always passes in ritual)

**Output:** `findings/cre_gates.json`
```json
{
  "gates_passed": 7,
  "gates_total": 8,
  "overall": "PASS",
  "results": [
    {"gate": 7, "name": "hold_signal", "result": "PASS", "value": "no hold active"},
    {"gate": 1, "name": "signal_confidence", "result": "PASS", "value": 0.525, "threshold": 0.6, "note": "FAIL if unadjusted"},
    ...
  ],
  "failed_gates": [
    {"gate": 1, "name": "signal_confidence", "reason": "0.525 < 0.6 threshold"}
  ]
}
```

**Checkpoint:** Log all gate results regardless of outcome. Failed gates don't stop the ritual — they inform the decision.

---

## Step 4: SCORE OPPORTUNITY

**Goal:** Produce a single confidence score and cost-benefit analysis.

**Actions:**

### Confidence Score
Combine all factors into final confidence:
```
final_confidence = base_confidence
                   * confidence_modifier (from Step 1, data completeness)
                   * (gates_passed / gates_total)
                   * volume_modifier (1.0 if normal, 0.7 if low volume)
```

### Cost-Benefit Analysis
Estimate trade profitability:
```
expected_reversion_usd = position_usd * abs(deviation_pct) / 100
uniswap_fee_usd       = position_usd * 0.003  (3000 BPS fee tier = 0.3%)
gas_cost_usd           = gas_gwei * 21000 * eth_price / 1e9  (Base gas is near-zero)
estimated_slippage_usd = position_usd * 0.001  (estimated 10 BPS on normal liquidity)

net_profit_estimate = expected_reversion_usd - uniswap_fee_usd - gas_cost_usd - estimated_slippage_usd
```

### Profit Threshold
- `net_profit_estimate > $1.00` → trade is worth executing
- `net_profit_estimate < $1.00` → not worth the risk for sub-dollar profit

**Output:** `findings/opportunity_score.json`
```json
{
  "final_confidence": 0.72,
  "breakdown": {
    "base_confidence": 0.525,
    "data_modifier": 1.0,
    "gate_modifier": 0.875,
    "volume_modifier": 1.0
  },
  "cost_benefit": {
    "position_usd": 20.00,
    "expected_reversion_usd": 0.42,
    "uniswap_fee_usd": 0.06,
    "gas_cost_usd": 0.001,
    "estimated_slippage_usd": 0.02,
    "net_profit_estimate": 0.34
  },
  "profitable": false,
  "reason": "Net profit $0.34 below $1.00 threshold"
}
```

**Checkpoint:** None — all outcomes (profitable or not) are valid findings

---

## Step 5: SYNTHESIZE FINDINGS

**Goal:** Package all research into a summary consumable by the DECIDE phase.

**Actions:**
1. Collect all findings from Steps 1-4
2. Write `findings/SUMMARY.md` — human-readable summary of the research
3. Write `findings/research_output.json` — machine-readable aggregate for DECIDE phase

**Summary template:**
```
Market Research Summary — {timestamp}
═══════════════════════════════════════
Current Price:    ${current_price}
Moving Average:   ${sma_30} (30-period)
Deviation:        {deviation_pct}% ({direction})
Signal:           {signal} (strength: {signal_strength})
CRE Gates:        {gates_passed}/{gates_total} passed
Confidence:       {final_confidence}
Net Profit Est:   ${net_profit_estimate}
Recommendation:   {GO/NO_GO with one-line reason}
```

**Output:** `findings/SUMMARY.md` + `findings/research_output.json`

**Checkpoint:** None — phase complete, output feeds into 003_DECIDE

---

## Fast Paths

These conditions skip directly to Step 5 with a NO_GO output:

| Condition | Detected At | Reason |
|-----------|-------------|--------|
| Vault paused | Ingest Step 4 | Guardian has paused operations |
| No daily capacity | Ingest Step 4 | Daily volume cap exhausted |
| Deviation within ±2% | Research Step 2 | No signal — price within normal range |
| All CRE gates fail | Research Step 3 | Risk too high on every dimension |
| Net profit < $1.00 | Research Step 4 | Trade not worth executing |

Fast paths are valuable — they demonstrate the agent exercises judgment and doesn't blindly trade.

---

## Workflow State Tracking

| Step | Status | Notes |
|------|--------|-------|
| 1. COMPUTE MOVING AVERAGE | [ ] pending | |
| 2. CALCULATE PRICE DEVIATION | [ ] pending | Fast path if no signal |
| 3. RUN CRE RISK GATES | [ ] pending | 8 gates, per-gate results |
| 4. SCORE OPPORTUNITY | [ ] pending | Confidence + cost-benefit |
| 5. SYNTHESIZE FINDINGS | [ ] pending | Always runs |
