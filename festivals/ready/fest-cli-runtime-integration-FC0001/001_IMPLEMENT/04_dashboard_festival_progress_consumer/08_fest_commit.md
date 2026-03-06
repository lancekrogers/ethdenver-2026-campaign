---
fest_type: gate
fest_id: 08_fest_commit.md
fest_name: Fest Commit Changes
fest_parent: 04_dashboard_festival_progress_consumer
fest_order: 8
fest_status: pending
fest_autonomy: high
fest_gate_type: commit
fest_created: 2026-03-06T13:39:01.570815-07:00
fest_tracking: true
---

# Task: Fest Commit Sequence Changes

**Task Number:** 08 | **Dependencies:** 05_testing, 06_review, 07_iterate | **Autonomy:** medium

## Objective
Commit sequence 04 dashboard integration changes using `fest commit`.

## Steps

```bash
cgo dashboard
fest link .
git status --short
git diff --stat
fest commit -m "FC0001 S04: support festival_progress parsing and source labeling in dashboard"
git log -1 --oneline
```

## Done When

- [ ] Sequence changes committed with clear scope
- [ ] Commit includes only intended S04 dashboard files
