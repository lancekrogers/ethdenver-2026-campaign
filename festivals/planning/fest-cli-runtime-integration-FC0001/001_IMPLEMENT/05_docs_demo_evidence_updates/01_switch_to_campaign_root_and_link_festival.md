---
fest_type: task
fest_id: 01_switch_to_campaign_root_and_link_festival.md
fest_name: switch_to_campaign_root_and_link_festival
fest_parent: 05_docs_demo_evidence_updates
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:56.164386-07:00
fest_tracking: true
---

# Task: Switch To Campaign Root And Link Festival

## Objective
Return to campaign root and bind festival context before documentation updates.

## Requirements

- [ ] Navigate to campaign root via `cgo`.
- [ ] Run `fest link .` and verify the link before editing docs.

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
- [ ] Campaign root link is confirmed before doc edits
