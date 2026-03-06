---
fest_type: gate
fest_id: 05_testing.md
fest_name: Testing and Verification
fest_parent: 06_cross_project_validation_release
fest_order: 5
fest_status: completed
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-06T13:39:01.572149-07:00
fest_updated: 2026-03-06T15:56:30.026578-07:00
fest_tracking: true
---


# Task: Testing and Verification

**Task Number:** 05 | **Dependencies:** Tasks 01-04 | **Autonomy:** medium

## Objective
Validate that cross-project execution evidence and release notes are complete and accurate.

## Required Verification

```bash
cgo obey-agent-economy
fest link .
fest validate
rg -n "validation matrix|source label|preflight-live" workflow/explore/cre-demo workflow/design/fest-cli-integration/implementation
```

## Verification Criteria

- [ ] Validation matrix exists and includes all required command families.
- [ ] Evidence artifacts are present and referenced.
- [ ] Release/handoff notes are actionable.

## Done When

- [ ] All verification criteria satisfied
- [ ] No missing artifact paths in handoff documentation