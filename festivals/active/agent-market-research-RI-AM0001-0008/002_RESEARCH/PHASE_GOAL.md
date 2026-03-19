---
fest_type: phase
fest_id: 002_RESEARCH
fest_name: 002_RESEARCH
fest_parent: agent-market-research-RI-AM0001
fest_order: 2
fest_status: completed
fest_created: 2026-03-16T21:07:07.846654-06:00
fest_updated: 2026-03-19T03:19:32.566263-06:00
fest_phase_type: research
fest_tracking: true
---


# Phase Goal: 002_RESEARCH

**Phase:** 002_RESEARCH | **Status:** Pending | **Type:** Research

## Research Objective

**Primary Goal:** Analyze ingested market data to determine whether a trading opportunity exists and quantify its strength.

**Context:** This phase takes raw data from 001_INGEST and produces analysis that feeds into the 003_DECIDE go/no-go decision. All analysis must be documented with specific numbers and reasoning — not vague assessments.

## Research Questions

Questions this research phase must answer:

1. **Price deviation:** How far has the current price deviated from the 30-period moving average? Is it beyond the ±2% threshold?
2. **Risk assessment:** Do all 8 CRE Risk Router gates pass? Which gates (if any) fail, and why?
3. **Opportunity score:** What is the confidence level (0.0-1.0) for this opportunity?
4. **Cost analysis:** Given current gas prices and Uniswap fees, what is the minimum profitable trade size?
5. **Position check:** What is the current vault position? Does a new trade respect the daily volume cap?

## Information Sources

Where to gather information:

- `001_INGEST/output_specs/market_snapshot.json` — current market state
- `001_INGEST/output_specs/price_history.json` — historical prices for MA calculation
- CRE Risk Router — 8-gate evaluation pipeline
- ObeyVault contract state — current positions, daily volume used, approved tokens

## Expected Findings

What this research should produce:

- **Price deviation analysis** — exact deviation percentage, direction (above/below MA), magnitude vs threshold
- **CRE gate results** — per-gate pass/fail with specific values (e.g., "Gate 1: PASS — confidence 0.72 ≥ 0.6 threshold")
- **Opportunity score** — composite confidence level with breakdown of contributing factors
- **Cost-benefit analysis** — estimated trade profit vs costs (gas + fees + slippage)
- **Position sizing recommendation** — suggested trade size based on confidence and vault constraints

## Success Criteria

This research phase is complete when:

- [ ] Moving average calculated from 30+ data points
- [ ] Price deviation quantified as percentage with direction
- [ ] All 8 CRE gates evaluated with per-gate results documented
- [ ] Opportunity scored with confidence level (0.0-1.0)
- [ ] Cost-benefit analysis shows estimated net profit/loss
- [ ] Position sizing recommendation respects vault boundaries
- [ ] All findings saved to `findings/` directory as structured JSON + human-readable summary

## Notes

- If CRE gates fail, the research still completes — the failure is a valid finding that feeds into the DECIDE phase
- Opportunity score formula: base confidence from deviation magnitude, modified by risk gate results, adjusted for cost-benefit ratio
- This phase should take seconds, not minutes — it's analysis of already-ingested data

---

*Research phases use freeform structure. Organize findings by topic as they develop.*