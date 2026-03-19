---
fest_type: phase
fest_id: 003_DECIDE
fest_name: 003_DECIDE
fest_parent: agent-market-research-RI-AM0001
fest_order: 3
fest_status: completed
fest_created: 2026-03-16T21:07:07.866858-06:00
fest_updated: 2026-03-19T03:24:28.635474-06:00
fest_phase_type: non_coding_action
fest_tracking: true
---


# Phase Goal: 003_DECIDE

**Phase:** 003_DECIDE | **Status:** Pending | **Type:** Non-Coding Action

## Phase Objective

**Primary Goal:** Produce a structured go/no-go trading decision with full rationale, consumable by the agent's planning/execution phase and by `agent_log.json`.

**Context:** This is the final phase of the research ritual. It synthesizes findings from 002_RESEARCH into a single, unambiguous decision. The output is a JSON artifact that the trading agent reads to determine whether to proceed with trade planning. This artifact IS the "discover" step evidence for Protocol Labs' autonomous loop.

## Action Items

Tasks to complete during this phase:

- [ ] Synthesize research findings into a go/no-go decision
- [ ] Document the rationale with specific numbers (not "market looks favorable")
- [ ] If GO: specify recommended trade direction, token pair, size range, and urgency
- [ ] If NO-GO: specify which factors blocked and what conditions would change the decision
- [ ] Generate `decision.json` artifact with structured fields
- [ ] Generate `agent_log_entry.json` compatible with Protocol Labs DevSpot format

## Canonical Artifact Directory

All final decision artifacts for a ritual run live in:

`003_DECIDE/01_synthesize_decision/results/`

Required files:

- `003_DECIDE/01_synthesize_decision/results/aggregated_findings.json`
- `003_DECIDE/01_synthesize_decision/results/decision.json`
- `003_DECIDE/01_synthesize_decision/results/agent_log_entry.json`
- `003_DECIDE/01_synthesize_decision/results/validation_result.md`
- `003_DECIDE/01_synthesize_decision/results/rationale_review.md`
- `003_DECIDE/01_synthesize_decision/results/ritual_complete.md`

## Prerequisites

What must be in place before starting:

- [ ] 001_INGEST completed with valid market data
- [ ] 002_RESEARCH completed with price deviation, CRE gate results, and opportunity score
- [ ] All research findings available in `002_RESEARCH/findings/`

## Decision Output Format

```json
{
  "ritual_id": "RI-AM0001",
  "ritual_run_id": "agent-market-research-RI-AM0001-0001",
  "timestamp": "2026-03-16T21:15:00Z",
  "decision": "GO" | "NO_GO",
  "confidence": 0.72,
  "blocking_factors": [],
  "rationale": {
    "price_deviation_pct": -2.3,
    "deviation_direction": "below_ma",
    "ma_period": 30,
    "cre_gates_passed": 8,
    "cre_gates_total": 8,
    "failed_gates": [],
    "estimated_net_profit_usd": 12.50,
    "risk_score": 42,
    "summary": "BUY candidate: price is 2.3% below the 30-period SMA, 8/8 CRE gates passed, and estimated net profit is $12.50."
  },
  "recommendation": {
    "direction": "BUY",
    "token_in": "USDC",
    "token_out": "WETH",
    "suggested_size_usd": 20.00,
    "max_slippage_bps": 100,
    "urgency": "normal"
  },
  "vault_constraints_checked": {
    "within_max_swap": true,
    "within_daily_volume": true,
    "token_whitelisted": true
  },
  "guardrails": {
    "trade_allowed": true,
    "min_confidence_required": 0.5,
    "min_net_profit_usd": 1.0,
    "min_cre_gates_passed": 6,
    "max_slippage_bps": 100
  },
  "artifact_paths": {
    "market_snapshot": "001_INGEST/output_specs/market_snapshot.json",
    "research_output": "002_RESEARCH/findings/research_output.json",
    "aggregated_findings": "003_DECIDE/01_synthesize_decision/results/aggregated_findings.json",
    "decision": "003_DECIDE/01_synthesize_decision/results/decision.json",
    "agent_log_entry": "003_DECIDE/01_synthesize_decision/results/agent_log_entry.json"
  }
}
```

`NO_GO` contract requirements:

- `decision` must be `NO_GO`
- `blocking_factors` must be non-empty
- `recommendation` may be omitted or set to `null`
- `guardrails.trade_allowed` must be `false`

## Agent Log Entry Contract

`003_DECIDE/01_synthesize_decision/results/agent_log_entry.json` must be a single JSON object per ritual run with, at minimum:

- `action`
- `timestamp`
- `phase`
- `festival_id`
- `run_id`
- `tools_used`
- `reasoning`
- `decision`
- `outcome`
- `retries`
- `duration_ms`
- `errors`
- `artifact_paths`

## Verification Steps

How to verify each action was completed successfully:

- Decision JSON is valid and parseable
- All required fields are present with real values (no nulls or placeholders)
- Rationale references specific numbers from research findings
- Recommendation respects vault boundaries (checked against contract state)
- If NO_GO, blocking factors are specific and actionable
- `decision.json` and `agent_log_entry.json` resolve at the canonical results paths listed above
- If inputs remain incomplete or ambiguous, the ritual still terminates unattended by outputting `NO_GO` with machine-readable blocking factors instead of waiting for a person

## Success Criteria

This action phase is complete when:

- [ ] `003_DECIDE/01_synthesize_decision/results/decision.json` generated with all required fields
- [ ] `003_DECIDE/01_synthesize_decision/results/agent_log_entry.json` generated in DevSpot-compatible format
- [ ] `GO` and `NO_GO` outcomes both write the same canonical artifact set
- [ ] `NO_GO` is treated as successful ritual completion when artifacts are valid
- [ ] Decision is unambiguous (GO or NO_GO, not "maybe")
- [ ] Rationale traces back to specific research findings
- [ ] All action items verified complete

## Notes

- A NO_GO decision is a valid and valuable output — it proves the agent exercises judgment, not just execution
- The decision artifact becomes immutable once `results/ritual_complete.md` is written for the run
- Multiple NO_GO decisions followed by a GO decision tells a story of patience and discipline, which judges should find compelling
- This output feeds directly into the trading agent's planning phase (if GO) or is logged and the cycle restarts (if NO_GO)
- `NO_GO` is a successful discover-cycle result, not a ritual failure

---

*Non-coding action phases handle documentation, releases, configuration, and other non-code tasks.*