---
fest_type: task
fest_id: 02_update_readme_for_runtime_fest_integration.md
fest_name: update_readme_for_runtime_fest_integration
fest_parent: 05_docs_demo_evidence_updates
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.994164-07:00
fest_updated: 2026-03-06T15:52:34.831544-07:00
fest_tracking: true
---


# Task: Update README For Runtime Fest Integration

## Objective
Update root README to clearly describe real fest runtime integration, fallback behavior, and operator commands.

## Requirements

- [ ] Add concise explanation of `fest` runtime role.
- [ ] Document live strictness vs demo fallback behavior.
- [ ] List root commands for fest status/doctor checks.

## Implementation

1. Ensure root context:
```bash
cgo obey-agent-economy
fest link .
```

2. Update file:
- `README.md`

Add/update sections:
- runtime fest integration narrative
- command examples:
  - `just fest status`
  - `just fest doctor`
  - `just demo run`
  - `just mode doctor`

3. Validate references are consistent with implemented commands.

## Done When

- [ ] All requirements met
- [ ] README command examples are accurate and copy-pasteable