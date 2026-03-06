---
fest_type: gate
fest_id: 08_fest_commit.md
fest_name: Fest Commit Changes
fest_parent: 02_coordinator_fest_adapter_core
fest_order: 8
fest_status: pending
fest_autonomy: high
fest_gate_type: commit
fest_created: 2026-03-06T13:39:01.569194-07:00
fest_tracking: true
---

# Task: Fest Commit Sequence Changes

**Task Number:** 08 | **Dependencies:** 05_testing, 06_review, 07_iterate | **Autonomy:** medium

## Objective
Commit coordinator adapter sequence changes cleanly using `fest commit` from linked coordinator project.

## Steps

```bash
cgo agent-coordinator
fest link .
fest link --show
git status --short
git diff --stat
fest commit -m "FC0001 S02: implement coordinator fest adapter executor, selector, parser, and tests"
git log -1 --oneline
```

If campaign root tracks this repo as a submodule, also update root pointer in later root-level commit.

## Done When

- [ ] Sequence changes committed with descriptive message
- [ ] Commit contains only intended coordinator files
