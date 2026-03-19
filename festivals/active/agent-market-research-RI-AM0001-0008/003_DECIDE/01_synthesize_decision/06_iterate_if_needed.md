---
fest_type: task
fest_id: 06_iterate_if_needed
fest_parent: 01_synthesize_decision
fest_order: 6
fest_status: completed
fest_created: 0001-01-01T00:00:00Z
fest_updated: 2026-03-19T03:19:52.022438-06:00
---


# Iterate If Needed

## Objective

Review validation and rationale review results. If issues were found, fix them. If both passed, finalize the ritual output.

## Steps

### 1. Check Gate Results

1. Read `results/validation_result.md` — did completeness/consistency pass?
2. Read `results/rationale_review.md` — did rationale quality pass?

### 2. If Both Passed → Finalize

1. Treat `003_DECIDE/01_synthesize_decision/results/` as the ritual output directory
2. Leave the final artifacts at:
   - `003_DECIDE/01_synthesize_decision/results/decision.json`
   - `003_DECIDE/01_synthesize_decision/results/agent_log_entry.json`
3. Write `003_DECIDE/01_synthesize_decision/results/ritual_complete.md` with:
   - Ritual ID + timestamp
   - Decision: GO/NO_GO
   - Completion status: `success`
   - Confidence level
   - Duration (ingest start → decision finalized)
   - Trade path: `continue_to_planning` for `GO`, `skip_trade_and_end_cycle` for `NO_GO`
4. Mark sequence complete

### 3. If Either Failed → Iterate

1. Review specific failures documented in validation/review results
2. Fix the identified issues in `results/decision.json`:
   - Missing fields → populate from aggregated findings
   - Inconsistent numbers → recalculate from source data
   - Vague rationale → replace with specific numbers
   - Logical inconsistency → correct the decision logic
3. Re-run validation (task 04 checks) on the fixed decision
4. Re-run rationale review (task 05 checks) on the fixed rationale
5. If still failing after 1 iteration → log the failure and output NO_GO with "decision_quality_insufficient" as blocking factor

### 4. Maximum Iterations

- **1 iteration maximum** for rituals (speed matters)
- If the decision can't pass quality gates in 1 fix cycle, the ritual outputs NO_GO
- This is NOT a failure — it means the market conditions produced ambiguous signals that couldn't be resolved into a clean decision
- Log this as valuable data: "ritual produced ambiguous signal, defaulting to NO_GO for safety"

## Done When

- [ ] Both quality gates passed (either initially or after 1 iteration)
- [ ] OR: 1 iteration attempted, still failing → NO_GO with quality explanation
- [ ] Final `decision.json` and `agent_log_entry.json` remain in `003_DECIDE/01_synthesize_decision/results/`
- [ ] `003_DECIDE/01_synthesize_decision/results/ritual_complete.md` documents the outcome
- [ ] Sequence marked complete