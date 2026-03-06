---
fest_type: gate
fest_id: 07_iterate.md
fest_name: Review Results and Iterate
fest_parent: 02_coordinator_fest_adapter_core
fest_order: 7
fest_status: pending
fest_autonomy: medium
fest_gate_type: iterate
fest_created: 2026-03-06T13:39:01.569015-07:00
fest_tracking: true
---

# Task: Review Results and Iterate

**Task Number:** 07 | **Dependencies:** 06_review | **Autonomy:** medium

## Objective
Address review/testing findings and confirm corrected behavior through targeted reruns.

## Iteration Workflow

1. Apply fixes from review comments.
2. Re-run adapter test suite:
```bash
cgo agent-coordinator
fest link .
go test ./internal/festival/...
go test ./internal/coordinator/...
```
3. If parser/selector logic changed, rerun:
```bash
go test ./...
```

## Exit Criteria

- [ ] Findings resolved or explicitly accepted with rationale
- [ ] Regression tests pass after fixes
