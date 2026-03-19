---
fest_type: task
fest_id: 01_aggregate_findings
fest_parent: 01_synthesize_decision
fest_order: 1
fest_status: completed
fest_created: 0001-01-01T00:00:00Z
fest_updated: 2026-03-19T03:24:28.572217-06:00
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
6. Combine into `003_DECIDE/01_synthesize_decision/results/aggregated_findings.json`
7. Include enough machine-readable context that `02_produce_decision.md` can finish without guessing:
   - `ritual_id`
   - `ritual_run_id`
   - `artifact_paths` for the source files loaded
   - the exact vault constraint values used for later trade gating

## Output Format

```json
{
  "ritual_id": "RI-AM0001",
  "ritual_run_id": "agent-market-research-RI-AM0001-0001",
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
  },
  "artifact_paths": {
    "market_snapshot": "001_INGEST/output_specs/market_snapshot.json",
    "moving_average": "002_RESEARCH/findings/moving_average.json",
    "price_deviation": "002_RESEARCH/findings/price_deviation.json",
    "cre_gates": "002_RESEARCH/findings/cre_gates.json",
    "opportunity_score": "002_RESEARCH/findings/opportunity_score.json"
  }
}
```

## Done When

- [ ] All research findings loaded successfully
- [ ] Aggregated JSON contains market, risk, opportunity, and vault sections
- [ ] No null values in required fields
- [ ] File saved to `003_DECIDE/01_synthesize_decision/results/aggregated_findings.json`