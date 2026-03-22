---
fest_type: task
fest_id: 01_audit_current_ritual_template.md
fest_name: audit current ritual template
fest_parent: 01_ritual_contract
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-18T07:27:30.377296-06:00
fest_updated: 2026-03-19T01:01:44.747804-06:00
fest_tracking: true
---


# Task: Audit current ritual template

## Objective

Review the existing ritual template and record the workflow, artifact, and autonomy gaps that block unattended runtime use.


## Primary Files

- `festivals/ritual/agent-market-research-RI-AM0001/FESTIVAL_OVERVIEW.md`
- `festivals/ritual/agent-market-research-RI-AM0001/001_INGEST/WORKFLOW.md`
- `festivals/ritual/agent-market-research-RI-AM0001/002_RESEARCH/WORKFLOW.md`
- `festivals/ritual/agent-market-research-RI-AM0001/003_DECIDE/PHASE_GOAL.md`
- `festivals/ritual/agent-market-research-RI-AM0001/003_DECIDE/01_synthesize_decision/02_produce_decision.md`
- `festivals/ritual/agent-market-research-RI-AM0001/003_DECIDE/01_synthesize_decision/03_generate_log_entry.md`

## Evidence To Capture

- [ ] Ritual docs explicitly name the required `decision.json` and `agent_log_entry.json` output paths.
- [ ] A real ritual run can complete through `fest ritual run ...` and produces both artifacts under the decide sequence results directory.
- [ ] No task in the ritual still depends on a human choosing outputs or interpreting completion implicitly.

## Requirements

- [ ] Inspect `festivals/ritual/agent-market-research-RI-AM0001/` and note which tasks, outputs, and assumptions already exist.
- [ ] Compare the ritual to the runtime contract in `workflow/design/2026-03-18-synthesis-fest-ritual-runtime/README.md` and list every missing guarantee.

## Implementation

1. Read the ritual overview, TODO, and workflow/task files under `festivals/ritual/agent-market-research-RI-AM0001/`.
2. Capture the current output locations, decision shape, and any human-only steps or ambiguous instructions.
3. Write the gap analysis into the ritual or adjacent notes so later tasks can update the exact right files.
4. Prioritize issues that would break a daemon-backed `fest next` loop first.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
fest validate festivals/ritual/agent-market-research-RI-AM0001
fest ritual run agent-market-research-RI-AM0001 --json
find festivals/active -path '*agent-market-research*/*decision.json' -o -path '*agent-market-research*/*agent_log_entry.json'
```

## Done When

- [ ] All requirements met
- [ ] The ritual gap list is written down and every blocking ambiguity has an identified target file.