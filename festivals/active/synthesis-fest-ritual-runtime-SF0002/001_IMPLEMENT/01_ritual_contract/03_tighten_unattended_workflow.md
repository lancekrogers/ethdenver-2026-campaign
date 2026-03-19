---
fest_type: task
fest_id: 03_tighten_unattended_workflow.md
fest_name: tighten unattended workflow
fest_parent: 01_ritual_contract
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-18T07:27:30.377901-06:00
fest_tracking: true
---

# Task: Tighten unattended workflow

## Objective

Rewrite ritual tasks so an agent can complete the workflow unattended through repeated `fest next` execution.


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

- [ ] Remove or rewrite any step that assumes a human will interpret intent or choose an output path manually.
- [ ] Make each task precise enough that an `obey` agent operating in the ritual workdir can finish it without extra context.

## Implementation

1. Review each ritual task for ambiguity, hidden assumptions, or missing output requirements.
2. Replace vague directives with explicit file targets, command guidance, and completion criteria.
3. Make sure the workflow still reflects real agent reasoning instead of reducing everything to deterministic shell work.
4. Keep the ritual aligned with the source-of-truth campaign workspace.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
fest validate festivals/ritual/agent-market-research-RI-AM0001
fest ritual run agent-market-research-RI-AM0001 --json
find festivals/active -path '*agent-market-research*/*decision.json' -o -path '*agent-market-research*/*agent_log_entry.json'
```

## Done When

- [ ] All requirements met
- [ ] Every ritual task has explicit outputs and an unattended agent can tell what done looks like.
