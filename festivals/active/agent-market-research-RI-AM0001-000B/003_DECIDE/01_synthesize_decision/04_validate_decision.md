---
fest_type: task
fest_id: 04_validate_decision
fest_parent: 01_synthesize_decision
fest_order: 4
fest_status: completed
fest_created: 0001-01-01T00:00:00Z
fest_updated: 2026-03-19T03:24:28.609863-06:00
---


# Validate Decision Completeness & Consistency

Validate the decision artifact for completeness and internal consistency.

## Validation Checks

### Completeness (all must pass)

- [ ] `003_DECIDE/01_synthesize_decision/results/decision.json` exists and is valid JSON
- [ ] `decision` field is exactly "GO" or "NO_GO" (no other values)
- [ ] `confidence` is a number between 0.0 and 1.0
- [ ] `timestamp` is present and recent (within last 5 minutes)
- [ ] `rationale` object is present with all sub-fields populated
- [ ] If GO: `recommendation` object is present with direction, token_in, token_out, suggested_size_usd, max_slippage_bps
- [ ] If NO_GO: `blocking_factors` array is present and non-empty
- [ ] `vault_constraints_checked` object is present with all three boolean fields
- [ ] `guardrails` object is present with the documented minimum fields
- [ ] `artifact_paths.decision` and `artifact_paths.agent_log_entry` point to the canonical results paths
- [ ] `003_DECIDE/01_synthesize_decision/results/agent_log_entry.json` exists and is valid JSON

### Consistency (all must pass)

- [ ] If confidence < 0.5, decision must be NO_GO
- [ ] If all CRE gates failed, decision must be NO_GO
- [ ] If vault is paused, decision must be NO_GO
- [ ] If net_profit_estimate < $1.00, decision must be NO_GO
- [ ] Recommended size does not exceed vault's remaining daily capacity
- [ ] Recommended size does not exceed vault's maxSwapSize
- [ ] Token pair in recommendation matches approved tokens in vault state
- [ ] Rationale numbers match the numbers in aggregated_findings.json (no drift)

### Cross-Reference (spot check)

- [ ] Pick one number from rationale → trace back to research findings → verify it matches
- [ ] Pick the confidence score → recompute from the formula in 002_RESEARCH/WORKFLOW.md → verify it's within ±0.01

## If Validation Fails

- Document which checks failed in `results/validation_result.md`
- Mark the specific fields that are wrong or missing
- Do NOT change the decision — flag for iteration in task 06

## Done When

- [ ] All completeness checks pass
- [ ] All consistency checks pass
- [ ] Cross-reference spot check passes
- [ ] `results/validation_result.md` written with PASS or FAIL + details