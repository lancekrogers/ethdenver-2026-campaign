---
fest_type: task
fest_id: 02_produce_decision
fest_parent: 01_synthesize_decision
fest_order: 2
fest_status: completed
fest_created: 0001-01-01T00:00:00Z
fest_updated: 2026-03-19T03:20:57.138785-06:00
---


# Task: Produce GO/NO_GO Decision

## Objective

Generate the final trading decision with structured rationale based on aggregated findings.

## Decision Logic

### Automatic NO_GO (any of these = immediate NO_GO)
- Vault is paused
- Remaining daily capacity < minimum profitable trade size
- No signal (deviation within ±2%)
- All CRE gates failed
- Net profit estimate < $1.00
- NAV < $10.00

### GO Criteria (ALL must be true)
- Signal exists (deviation beyond ±2%)
- Final confidence ≥ 0.5
- At least 6/8 CRE gates passed
- Net profit estimate ≥ $1.00
- Vault has capacity for the recommended position size
- Vault is not paused

### Edge Cases
- Confidence between 0.5-0.6: GO but flag as "low confidence" with reduced position size
- 6-7 gates passed (not all 8): GO but note which gates failed in rationale
- Deviation > ±5%: GO but flag as "strong signal — verify not structural move"

## Steps

1. Load `003_DECIDE/01_synthesize_decision/results/aggregated_findings.json`
2. Run through automatic NO_GO checks first (fast path)
3. If no auto-NO_GO, evaluate GO criteria
4. Generate `003_DECIDE/01_synthesize_decision/results/decision.json` with full rationale
5. If GO: include recommendation (direction, token pair, size, slippage, urgency)
6. If NO_GO: include `blocking_factors`, set `guardrails.trade_allowed` to `false`, and describe conditions that would change the decision
7. If evidence is incomplete, contradictory, or still ambiguous after one bounded correction pass, output `NO_GO` with a specific blocking factor such as `insufficient_data`, `inconsistent_inputs`, or `decision_quality_insufficient`

## Output

Write `003_DECIDE/01_synthesize_decision/results/decision.json` following the schema defined in `003_DECIDE/PHASE_GOAL.md`.

Minimum required machine-readable fields:

- `ritual_id`
- `ritual_run_id`
- `timestamp`
- `decision`
- `confidence`
- `blocking_factors` (required when `decision == "NO_GO"`)
- `rationale`
- `vault_constraints_checked`
- `guardrails`
- `artifact_paths`

If `decision == "GO"`, also include:

- `recommendation.direction`
- `recommendation.token_in`
- `recommendation.token_out`
- `recommendation.suggested_size_usd`
- `recommendation.max_slippage_bps`
- `recommendation.urgency`

Completion rule for both outcomes:

- `GO` and `NO_GO` must both produce `decision.json` at the same canonical path.
- `NO_GO` is a successful result when the file is valid and includes explicit `blocking_factors`.
- Only missing/invalid artifacts or an unfinished quality-gate flow should be treated as ritual failure.

## Rationale Requirements

The rationale MUST:
- Cite specific numbers: "Price deviated -2.3% from SMA of $3,240.50"
- Reference gate results: "7/8 CRE gates passed; Gate 1 (signal confidence) failed at 0.525 vs 0.6 threshold"
- Include cost-benefit: "Estimated net profit $12.50 after $0.06 Uniswap fee and $0.02 slippage"
- For NO_GO, specify what would change the decision: "Trade would be viable if deviation exceeds -2.5% (currently -1.8%)"

The rationale MUST NOT:
- Use vague language: "market conditions look favorable"
- Omit numbers: "confidence is high"
- Skip failed gates: only mentioning passed gates

Unattended execution rule:

- Do not wait for a human to decide between `GO` and `NO_GO`.
- If the available evidence is not good enough for a safe `GO`, emit `NO_GO` with explicit blocking factors.

## Done When

- [ ] Decision is binary: GO or NO_GO
- [ ] Rationale cites specific numbers from aggregated findings
- [ ] GO includes recommendation with direction, size, slippage
- [ ] NO_GO includes blocking factors and change conditions
- [ ] `003_DECIDE/01_synthesize_decision/results/decision.json` saved with all required fields