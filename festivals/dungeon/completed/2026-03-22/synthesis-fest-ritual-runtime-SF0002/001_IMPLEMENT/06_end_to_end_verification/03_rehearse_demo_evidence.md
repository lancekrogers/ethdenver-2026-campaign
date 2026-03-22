---
fest_type: task
fest_id: 03_rehearse_demo_evidence.md
fest_name: rehearse demo evidence
fest_parent: 06_end_to_end_verification
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.537141-06:00
fest_updated: 2026-03-19T03:26:37.569653-06:00
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

- [x] At least three real run IDs and corresponding obey session IDs are recorded in the sequence notes.
- [x] At least one `GO` and one `NO_GO` example include artifact paths for `decision.json` and `agent_log_entry.json`.
- [x] The demo checklist cites exact commands and file paths rather than ad-lib instructions.

## Requirements

- [x] The rehearsal must be based on real runtime artifacts, not screenshots from a synthetic path.
- [x] The demo sequence must be short enough to use during Synthesis judging feedback.

## Demo Checklist

1. Show the daemon is live:
   - `pgrep -af 'obey serve'`
2. Show a real session record for the `GO` cycle:
   - `obey session info --socket /tmp/obey.sock --campaign Obey-Agent-Economy c35c1631-3070-44db-bcd8-72f821c8a20b`
3. Show a real session record for the `NO_GO` cycle:
   - `obey session info --socket /tmp/obey.sock --campaign Obey-Agent-Economy 4bfcee1f-bbd3-4f51-9443-d3bca0b17b70`
4. Open the `GO` decision artifact:
   - `sed -n '1,160p' festivals/active/agent-market-research-RI-AM0001-000A/003_DECIDE/01_synthesize_decision/results/decision.json`
5. Open the `NO_GO` decision artifact:
   - `sed -n '1,160p' festivals/active/agent-market-research-RI-AM0001-000B/003_DECIDE/01_synthesize_decision/results/decision.json`
6. Open one machine-readable agent log artifact:
   - `sed -n '1,160p' festivals/active/agent-market-research-RI-AM0001-000B/003_DECIDE/01_synthesize_decision/results/agent_log_entry.json`
7. Show aggregate evidence:
   - `jq '.entries | length' projects/agent-defi/agent_log.json`

Rehearsal notes:

- The checklist was walked against live artifacts only; no screenshots or mocked payloads were needed.
- The slowest step is waiting for on-chain context, so the demo should inspect the completed artifacts directly rather than waiting for a fresh unattended cycle to finish in front of judges.
- End-to-end proof remains fast enough for judging because the exact run IDs, session IDs, tx hashes, and artifact paths are all pre-recorded.

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

- [x] All requirements met
- [x] A clean demo checklist exists and has been rehearsed against real runtime output.