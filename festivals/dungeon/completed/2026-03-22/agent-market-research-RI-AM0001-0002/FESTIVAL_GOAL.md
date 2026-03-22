---
fest_type: festival
fest_id: RI-AM0001
fest_name: agent-market-research
fest_status: completed
fest_created: 2026-03-16T21:06:06.172823-06:00
fest_updated: 2026-03-22T13:28:10.664487-06:00
fest_tracking: true
---


# agent-market-research

**Status:** Planned | **Created:** 2026-03-16T21:06:06-06:00

## Festival Objective

**Primary Goal:** Evaluate current market conditions and produce a structured go/no-go trading decision with full rationale for the ObeyVault autonomous agent.

**Vision:** Each ritual execution produces a dated, auditable research artifact that documents what the agent discovered, what risks it evaluated, and why it decided to trade or not. This maps directly to Protocol Labs' "discover" step in the autonomous loop (discover → plan → execute → verify → submit) and generates structured input for `agent_log.json`.

## Success Criteria

### Functional Success

- [ ] Market data ingested from price feeds and Uniswap V3 pool state
- [ ] Price deviation from moving average calculated and documented
- [ ] CRE Risk Router 8-gate evaluation completed with per-gate results
- [ ] Opportunity scored with confidence level (0.0-1.0)
- [ ] Go/no-go decision produced with structured rationale
- [ ] Research output saved as dated artifact in `results/` directory

### Quality Success

- [ ] All data sources are real (no mocks or synthetic data)
- [ ] Risk evaluation covers all 8 CRE gates with pass/fail per gate
- [ ] Decision rationale is specific and auditable (not generic "market looks good")
- [ ] Output format is machine-readable (JSON) for downstream consumption by planning phase

## Progress Tracking

### Phase Completion

- [ ] 001_INGEST: Collect market data from on-chain and API sources
- [ ] 002_RESEARCH: Analyze data, evaluate risk, score opportunity
- [ ] 003_DECIDE: Produce structured go/no-go decision with rationale

## Complete When

- [ ] All phases completed
- [ ] Research artifact saved with timestamp
- [ ] Output consumable by trading agent's planning phase
- [ ] Execution log entry generated for agent_log.json