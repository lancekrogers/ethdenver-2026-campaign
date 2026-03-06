---
fest_type: task
fest_id: 01_switch_to_dashboard_and_link_festival.md
fest_name: switch_to_dashboard_and_link_festival
fest_parent: 04_dashboard_festival_progress_consumer
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-06T13:38:56.0994-07:00
fest_updated: 2026-03-06T15:46:31.101376-07:00
fest_tracking: true
---


# Task: Switch To Dashboard And Link Festival

## Objective
Set the working context to `projects/dashboard` and bind this festival before dashboard changes.

## Requirements

- [ ] Navigate to dashboard project using `cgo`.
- [ ] Run `fest link .` from dashboard directory and verify link state.

## Implementation

1. Navigate to dashboard project:
```bash
cgo dashboard
```
2. Link and verify:
```bash
fest link .
fest link --show
```
3. Confirm context:
```bash
pwd
fest id
```

## Done When

- [ ] All requirements met
- [ ] `fest link --show` confirms dashboard project path