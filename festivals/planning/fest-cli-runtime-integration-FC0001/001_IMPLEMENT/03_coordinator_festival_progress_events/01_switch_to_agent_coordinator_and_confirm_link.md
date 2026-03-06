---
fest_type: task
fest_id: 01_switch_to_agent_coordinator_and_confirm_link.md
fest_name: switch_to_agent_coordinator_and_confirm_link
fest_parent: 03_coordinator_festival_progress_events
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:56.032729-07:00
fest_tracking: true
---

# Task: Switch To Agent-Coordinator And Confirm Link

## Objective
Re-enter coordinator context and confirm festival link before event-publishing updates.

## Requirements

- [ ] Navigate to coordinator project via `cgo`.
- [ ] Re-run `fest link .` and verify active link.

## Implementation

1. Navigate to coordinator project:
```bash
cgo agent-coordinator
```
2. Refresh and verify link:
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
- [ ] Coordinator path is linked and verified before code edits
