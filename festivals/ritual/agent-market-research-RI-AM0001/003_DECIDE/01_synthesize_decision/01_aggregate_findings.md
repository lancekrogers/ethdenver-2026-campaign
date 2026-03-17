---
fest_type: task
fest_id: 01_aggregate_findings
fest_parent: 01_synthesize_decision
fest_order: 1
fest_status: pending
---

# Task: Aggregate Research Findings

## Objective

Collect all structured outputs from 002_RESEARCH into a single aggregated view for decision-making.

## Steps

1. Load `002_RESEARCH/findings/moving_average.json` — SMA value, data points used, confidence modifier
2. Load `002_RESEARCH/findings/price_deviation.json` — deviation %, direction, signal, base confidence
3. Load `002_RESEARCH/findings/cre_gates.json` — per-gate results, gates passed/total, failed gates
4. Load `002_RESEARCH/findings/opportunity_score.json` — final confidence, cost-benefit analysis, profitability
5. Load `001_INGEST/output_specs/market_snapshot.json` — vault state (paused, capacity, NAV)
6. Combine into `results/aggregated_findings.json`

## Output Format

```json
{
  "timestamp": "2026-03-16T21:15:00Z",
  "market": {
    "current_price": 3172.34,
    "sma_30": 3240.50,
    "deviation_pct": -2.10,
    "signal": "BUY"
  },
  "risk": {
    "gates_passed": 7,
    "gates_total": 8,
    "failed_gates": ["signal_confidence"],
    "risk_score": 42
  },
  "opportunity": {
    "final_confidence": 0.72,
    "net_profit_estimate": 12.50,
    "profitable": true
  },
  "vault": {
    "nav": 100.00,
    "remaining_capacity": 80.00,
    "paused": false
  }
}
```

## Done When

- [ ] All research findings loaded successfully
- [ ] Aggregated JSON contains market, risk, opportunity, and vault sections
- [ ] No null values in required fields
- [ ] File saved to `results/aggregated_findings.json`
