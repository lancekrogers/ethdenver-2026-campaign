---
fest_type: gate
fest_id: 07_iterate.md
fest_name: Review Results and Iterate
fest_parent: 05_artifact_aggregation
fest_order: 7
fest_status: pending
fest_autonomy: medium
fest_gate_type: iterate
fest_created: 2026-03-18T07:27:46.563491-06:00
fest_tracking: true
---

# Task: Review Results and Iterate

**Task Number:** <no value> | **Parallel Group:** None | **Dependencies:** Code Review | **Autonomy:** medium

## Objective

Address concrete blockers from testing and review, re-run the required checks, and stop the sequence from progressing while blockers remain.

## Inputs Required

- Testing gate results
- Review gate verdict
- Concrete blocker list with file paths and required fixes

## Iteration Procedure

1. Copy the blocking findings from testing and review into a checklist in this file.
2. Fix only those blockers; do not change unrelated files without documenting why.
3. Re-run the exact commands that previously failed.
4. Update each blocker with `fixed`, `still failing`, or `deferred with reason`.
5. If any blocker is still open, the sequence is not complete.

## Blocker Checklist

Record blockers here as they are discovered during execution:

- [ ] File path + blocker description + rerun command + status
- [ ] File path + blocker description + rerun command + status

## Definition of Done

- [ ] All blocking findings have explicit status updates
- [ ] All previously failing commands have been re-run
- [ ] No critical blocker remains open
- [ ] If a blocker is deferred, the reason and next owner are documented
