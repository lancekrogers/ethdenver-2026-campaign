---
id: QUALITY_GATE_DECISION_VALIDATION
aliases:
  - decision-validation
  - qg-decision
description: Quality gate for validating decision completeness and consistency

fest_type: gate
fest_id: <no value>
fest_name: Decision Completeness & Consistency
fest_parent: <no value>
fest_order: <no value>
fest_gate_type: decision_validation
fest_status: pending
fest_tracking: true
fest_created: 2026-03-16T21:06:06-06:00
---

# Gate: Decision Completeness & Consistency

**Dependencies:** All decision production tasks | **Autonomy:** high

## Objective

Validate that the trading decision artifact is complete (all fields present, correct types) and internally consistent (numbers match research findings, logic holds).

## Completeness Checks

- [ ] `decision.json` exists and is valid JSON
- [ ] `decision` field is exactly "GO" or "NO_GO"
- [ ] `confidence` is a number between 0.0 and 1.0
- [ ] `timestamp` is present and within last 5 minutes
- [ ] `rationale` object has all sub-fields populated (no nulls)
- [ ] If GO: `recommendation` includes direction, token_in, token_out, suggested_size_usd, max_slippage_bps
- [ ] If NO_GO: `blocking_factors` array is present and non-empty
- [ ] `vault_constraints_checked` has all three boolean fields
- [ ] `agent_log_entry.json` exists and is valid JSON

## Consistency Checks

- [ ] Confidence < 0.5 → decision is NO_GO
- [ ] All CRE gates failed → decision is NO_GO
- [ ] Vault paused → decision is NO_GO
- [ ] Net profit < $1.00 → decision is NO_GO
- [ ] Recommended size ≤ vault remaining daily capacity
- [ ] Recommended size ≤ vault maxSwapSize
- [ ] Token pair matches vault approved tokens
- [ ] Rationale numbers match `aggregated_findings.json` (spot check at least 2 values)

## Output

Write `results/validation_result.md`:
- PASS: all checks passed
- FAIL: list specific failing checks with expected vs actual values

## Definition of Done

- [ ] All completeness checks pass
- [ ] All consistency checks pass
- [ ] Validation result documented
