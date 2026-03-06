---
fest_type: task
fest_id: 01_switch_to_campaign_root_and_link_festival.md
fest_name: switch_to_campaign_root_and_link_festival
fest_parent: 01_campaign_root_mode_and_preflight
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.878236-07:00
fest_tracking: true
---

# Task: Switch To Campaign Root And Link Festival

## Objective
Set the working context to campaign root and bind this festival before root-level changes.

## Requirements

- [ ] Navigate to campaign root using `cgo` command.
- [ ] Run `fest link .` in campaign root and verify link state.

## Implementation

1. Navigate to campaign root:
```bash
cgo obey-agent-economy
```
2. Link the current festival to this directory:
```bash
fest link .
fest link --show
```
3. Verify location and festival context:
```bash
pwd
fest id
```

## Done When

- [ ] All requirements met
- [ ] `fest link --show` confirms campaign root path for this festival
