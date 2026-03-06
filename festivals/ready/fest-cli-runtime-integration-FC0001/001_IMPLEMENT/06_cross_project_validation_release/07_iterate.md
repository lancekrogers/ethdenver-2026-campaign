---
fest_type: gate
fest_id: 07_iterate.md
fest_name: Review Results and Iterate
fest_parent: 06_cross_project_validation_release
fest_order: 7
fest_status: pending
fest_autonomy: medium
fest_gate_type: iterate
fest_created: 2026-03-06T13:39:01.572548-07:00
fest_tracking: true
---

# Task: Review Results and Iterate

**Task Number:** 07 | **Dependencies:** 06_review | **Autonomy:** medium

## Objective
Address review findings in validation/evidence artifacts and rerun final checks.

## Iteration Workflow

```bash
cgo obey-agent-economy
fest link .
fest validate
```

Re-check artifact references:
```bash
rg -n "preflight-live|source label|validation matrix" workflow/explore/cre-demo workflow/design/fest-cli-integration/implementation
```

## Exit Criteria

- [ ] Findings resolved or explicitly documented
- [ ] Festival still validates cleanly after updates
