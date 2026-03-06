---
fest_type: gate
fest_id: 05_testing.md
fest_name: Testing and Verification
fest_parent: 05_docs_demo_evidence_updates
fest_order: 5
fest_status: completed
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-06T13:39:01.571037-07:00
fest_updated: 2026-03-06T15:52:34.878618-07:00
fest_tracking: true
---


# Task: Testing and Verification

**Task Number:** 05 | **Dependencies:** Tasks 01-04 | **Autonomy:** medium

## Objective
Verify documentation accuracy by executing documented commands and checking references.

## Required Verification

```bash
cgo obey-agent-economy
fest link .
rg -n "just fest status|just fest doctor|festival_progress|FEST_FALLBACK_ALLOW_SYNTHETIC" README.md docs/guides
just fest status
just fest doctor
```

## Verification Criteria

- [ ] All referenced commands exist and run.
- [ ] Docs and README use consistent terminology.
- [ ] No stale command names remain.

## Done When

- [ ] All verification criteria satisfied
- [ ] Doc updates are internally consistent and runnable