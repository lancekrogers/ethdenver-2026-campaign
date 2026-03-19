---
fest_type: task
fest_id: 02_define_artifact_contract.md
fest_name: define artifact contract
fest_parent: 01_ritual_contract
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-18T07:27:30.377645-06:00
fest_updated: 2026-03-19T01:06:08.482386-06:00
fest_tracking: true
---


# Task: Define artifact contract

## Objective

Make the ritual artifact contract explicit so the runtime can parse results without guessing.


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

- [ ] Specify the required paths and minimum fields for `decision.json` and `agent_log_entry.json`.
- [ ] Make the contract clear enough that both the ritual and Go runtime can validate success consistently.

## Implementation

1. Update ritual documentation and task instructions to name the exact results directories and files.
2. Define the minimum machine-readable fields required for trade gating, rationale, confidence, and guardrails.
3. Ensure the contract matches what `projects/agent-defi` will parse later.
4. Reference the Protocol Labs evidence requirements where that improves clarity.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
fest validate festivals/ritual/agent-market-research-RI-AM0001
fest ritual run agent-market-research-RI-AM0001 --json
find festivals/active -path '*agent-market-research*/*decision.json' -o -path '*agent-market-research*/*agent_log_entry.json'
```

## Done When

- [ ] All requirements met
- [ ] A reader can point to one explicit artifact contract and know exactly what the runtime expects from each ritual run.