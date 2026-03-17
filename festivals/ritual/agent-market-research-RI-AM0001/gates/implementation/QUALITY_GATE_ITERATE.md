---
id: QUALITY_GATE_ITERATE
aliases:
  - decision-iterate
  - qg-iterate
description: Quality gate for addressing validation/review findings and iterating the decision

fest_type: gate
fest_id: <no value>
fest_name: Iterate If Needed
fest_parent: <no value>
fest_order: <no value>
fest_gate_type: iterate
fest_status: pending
fest_tracking: true
fest_created: 2026-03-16T21:06:06-06:00
---

# Gate: Iterate If Needed

**Dependencies:** Decision Validation, Rationale Review | **Autonomy:** medium

## Objective

Review gate results from validation and rationale review. Fix identified issues or finalize the decision.

## Findings to Address

### From Decision Validation

| Finding | Priority | Status | Notes |
|---------|----------|--------|-------|
| [populated at runtime] | | [ ] Fixed | |

### From Rationale Review

| Finding | Priority | Status | Notes |
|---------|----------|--------|-------|
| [populated at runtime] | | [ ] Fixed | |

## Iteration Process

### If Both Gates Passed → Finalize

1. Copy final `decision.json` to ritual output
2. Copy final `agent_log_entry.json` to ritual output
3. Write `results/ritual_complete.md`
4. Mark sequence complete

### If Either Gate Failed → Fix (1 iteration max)

1. Fix identified issues in `decision.json`:
   - Missing fields → populate from aggregated findings
   - Inconsistent numbers → recalculate from source
   - Vague rationale → replace with specific numbers
2. Re-verify against failing checks
3. If still failing → output NO_GO with "decision_quality_insufficient"

### Maximum Iterations

- **1 iteration** for rituals (speed matters)
- Unresolvable quality issues → default to NO_GO (safe default)
- Log as "ambiguous signal, defaulting to NO_GO for safety"

## Definition of Done

- [ ] Both gates passed (initially or after 1 fix)
- [ ] OR: 1 iteration attempted, still failing → NO_GO with explanation
- [ ] Final artifacts in output directory
- [ ] `results/ritual_complete.md` documents outcome
- [ ] Sequence marked complete
