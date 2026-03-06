---
fest_type: task
fest_id: 01_switch_to_campaign_root_and_link_festival.md
fest_name: switch_to_campaign_root_and_link_festival
fest_parent: 06_cross_project_validation_release
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-06T13:38:56.234266-07:00
fest_updated: 2026-03-06T15:53:47.587883-07:00
fest_tracking: true
---


# Task: Switch To Campaign Root And Link Festival

## Objective
Set campaign-root context and link festival before cross-project validation and release checks.

## Requirements

- [ ] Navigate to campaign root with `cgo`.
- [ ] Run `fest link .` and verify active festival link.

## Implementation

1. Navigate:
```bash
cgo obey-agent-economy
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
- [ ] Campaign root context and link are verified before validation steps