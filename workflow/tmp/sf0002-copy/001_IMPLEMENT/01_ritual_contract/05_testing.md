---
fest_type: gate
fest_id: testing
fest_name: Testing and Verification
fest_parent: 01_ritual_contract
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-18T07:27:46.557617-06:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** <no value> | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Prove the ritual is executable by fest as an unattended runtime dependency, not just a better-written design doc.

## Required Evidence

- [ ] `fest validate festivals/ritual/agent-market-research-RI-AM0001` passes.
- [ ] A fresh ritual run ID is captured from `fest ritual run agent-market-research-RI-AM0001 --json`.
- [ ] The resulting run contains `003_DECIDE/01_synthesize_decision/results/decision.json`.
- [ ] The resulting run contains `003_DECIDE/01_synthesize_decision/results/agent_log_entry.json`.
- [ ] No ritual task still depends on a human choosing output locations or interpreting completion implicitly.

## Commands To Run

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
fest validate festivals/ritual/agent-market-research-RI-AM0001
fest ritual run agent-market-research-RI-AM0001 --json
find festivals/active -path '*agent-market-research*/*decision.json' -o -path '*agent-market-research*/*agent_log_entry.json'
```

## Manual Checks

1. Open the newly created ritual run and verify the decide sequence wrote both machine-readable artifacts.
2. Confirm the decision artifact matches the schema expected in `003_DECIDE/PHASE_GOAL.md`.
3. Confirm the log entry is DevSpot-shaped enough for `cmd/loggen` to ingest.

## Definition of Done

- [ ] Ritual validation passes
- [ ] A fresh run produced both artifacts
- [ ] Artifact paths and schema are explicit in ritual docs
- [ ] No hidden human-only blocker remains
