---
fest_type: task
fest_id: 01_run_live_daemon_backed_ritual_cycles.md
fest_name: run live daemon backed ritual cycles
fest_parent: 06_end_to_end_verification
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.536671-06:00
fest_tracking: true
---

# Task: Run live daemon backed ritual cycles

## Objective

Execute the full runtime path several times so the submission has live evidence instead of one-off claims.


## Primary Files

- `festivals/active/synthesis-fest-ritual-runtime-SF0002/001_IMPLEMENT/06_end_to_end_verification/*.md`
- `projects/agent-defi/agent_log.json`
- `festivals/active/* and festivals/dungeon/completed/* ritual run artifacts`

## Evidence To Capture

- [ ] At least three real run IDs and corresponding obey session IDs are recorded in the sequence notes.
- [ ] At least one `GO` and one `NO_GO` example include artifact paths for `decision.json` and `agent_log_entry.json`.
- [ ] The demo checklist cites exact commands and file paths rather than ad-lib instructions.

## Requirements

- [ ] Run at least three real cycles through the daemon-backed ritual path.
- [ ] Record the ritual run IDs, session IDs, and output file paths for each cycle.

## Implementation

1. Start the obey daemon and confirm the runtime environment is configured.
2. Run the vault agent through multiple cycles with the new ritual-backed flow enabled.
3. Capture the run IDs, session IDs, and artifact paths for each cycle.
4. Store the evidence in the festival or adjacent notes for later demo use.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
fest status
find festivals -path '*decision.json' -o -path '*agent_log_entry.json'
jq '.entries | length' projects/agent-defi/agent_log.json
```

## Done When

- [ ] All requirements met
- [ ] There are at least three runtime-driven ritual runs with recorded IDs and artifact locations.
