---
fest_type: phase
fest_id: 003_DECIDE
fest_name: 003_DECIDE
fest_parent: agent-market-research-RI-AM0001
fest_order: 3
fest_status: pending
fest_created: 2026-03-16T21:07:07.866858-06:00
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

## Prerequisites

What must be in place before starting:

- [ ] 001_INGEST completed with valid market data
- [ ] 002_RESEARCH completed with price deviation, CRE gate results, and opportunity score
- [ ] All research findings available in `002_RESEARCH/findings/`

## Decision Output Format

```json
{
  "ritual_id": "RI-AM0001",
  "timestamp": "2026-03-16T21:15:00Z",
  "decision": "GO" | "NO_GO",
  "confidence": 0.72,
  "rationale": {
    "price_deviation_pct": -2.3,
    "deviation_direction": "below_ma",
    "ma_period": 30,
    "cre_gates_passed": 8,
    "cre_gates_total": 8,
    "failed_gates": [],
    "estimated_net_profit_usd": 12.50,
    "risk_score": 42
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
  }
}
```

## Verification Steps

How to verify each action was completed successfully:

- Decision JSON is valid and parseable
- All required fields are present with real values (no nulls or placeholders)
- Rationale references specific numbers from research findings
- Recommendation respects vault boundaries (checked against contract state)
- If NO_GO, blocking factors are specific and actionable

## Success Criteria

This action phase is complete when:

- [ ] `decision.json` generated with all required fields
- [ ] `agent_log_entry.json` generated in DevSpot-compatible format
- [ ] Decision is unambiguous (GO or NO_GO, not "maybe")
- [ ] Rationale traces back to specific research findings
- [ ] All action items verified complete

## Notes

- A NO_GO decision is a valid and valuable output — it proves the agent exercises judgment, not just execution
- The decision artifact is dated and immutable — it becomes part of the agent's auditable history
- Multiple NO_GO decisions followed by a GO decision tells a story of patience and discipline, which judges should find compelling
- This output feeds directly into the trading agent's planning phase (if GO) or is logged and the cycle restarts (if NO_GO)

---

*Non-coding action phases handle documentation, releases, configuration, and other non-code tasks.*
