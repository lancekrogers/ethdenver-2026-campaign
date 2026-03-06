---
fest_type: task
fest_id: 01_switch_to_agent_coordinator_and_link_festival.md
fest_name: switch_to_agent_coordinator_and_link_festival
fest_parent: 02_coordinator_fest_adapter_core
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.945064-07:00
fest_updated: 2026-03-06T15:31:55.486294-07:00
fest_tracking: true
---


# Task: Switch To Agent-Coordinator And Link Festival

## Objective
Set the working context to `projects/agent-coordinator` and bind this festival before coordinator changes.

## Requirements

- [ ] Navigate to coordinator project using `cgo` command.
- [ ] Run `fest link .` from coordinator directory and verify link.

## Implementation

1. Navigate to coordinator project:
```bash
cgo agent-coordinator
```
2. Link festival to current project directory:
```bash
fest link .
fest link --show
```
3. Verify path and context:
```bash
pwd
fest id
```

## Done When

- [ ] All requirements met
- [ ] `fest link --show` confirms coordinator project path