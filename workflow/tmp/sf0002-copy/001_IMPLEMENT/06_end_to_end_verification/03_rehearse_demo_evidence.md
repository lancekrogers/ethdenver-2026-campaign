---
fest_type: task
fest_id: 03_rehearse_demo_evidence.md
fest_name: rehearse demo evidence
fest_parent: 06_end_to_end_verification
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.537141-06:00
fest_tracking: true
---

# Task: Rehearse demo evidence

## Objective

Practice the judge-facing flow that shows the live ritual run, obey session, produced artifacts, and aggregate evidence.


## Primary Files

- `festivals/active/synthesis-fest-ritual-runtime-SF0002/001_IMPLEMENT/06_end_to_end_verification/*.md`
- `projects/agent-defi/agent_log.json`
- `festivals/active/* and festivals/dungeon/completed/* ritual run artifacts`

## Evidence To Capture

- [ ] At least three real run IDs and corresponding obey session IDs are recorded in the sequence notes.
- [ ] At least one `GO` and one `NO_GO` example include artifact paths for `decision.json` and `agent_log_entry.json`.
- [ ] The demo checklist cites exact commands and file paths rather than ad-lib instructions.

## Requirements

- [ ] The rehearsal must be based on real runtime artifacts, not screenshots from a synthetic path.
- [ ] The demo sequence must be short enough to use during Synthesis judging feedback.

## Implementation

1. Create a short demo checklist that starts from runtime startup and ends at artifact inspection.
2. Include the exact commands or file paths needed to show the active run, session metadata, archived run, and aggregate log.
3. Run through the checklist once without improvising and note any confusing or flaky steps.
4. Tighten the checklist until it is reliable and fast.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
fest status
find festivals -path '*decision.json' -o -path '*agent_log_entry.json'
jq '.entries | length' projects/agent-defi/agent_log.json
```

## Done When

- [ ] All requirements met
- [ ] A clean demo checklist exists and has been rehearsed against real runtime output.
