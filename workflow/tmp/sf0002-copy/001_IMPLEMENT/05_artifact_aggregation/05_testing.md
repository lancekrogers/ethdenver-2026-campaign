---
fest_type: gate
fest_id: testing
fest_name: Testing and Verification
fest_parent: 05_artifact_aggregation
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-18T07:27:46.562971-06:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** <no value> | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Prove aggregate Protocol Labs evidence is generated from real ritual artifacts and real execution data.

## Required Evidence

- [ ] `go test ./...` passes in `projects/agent-defi`.
- [ ] `go run ./cmd/loggen ...` completes successfully.
- [ ] `agent_log.json` is valid JSON.
- [ ] At least one discover entry in the aggregate log came from a ritual artifact.
- [ ] The evidence notes point judges to the exact files to inspect.

## Commands To Run

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
go run ./cmd/loggen -rituals /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/festivals/dungeon/completed -out agent_log.json
jq '.' agent_log.json >/dev/null
```

## Manual Checks

1. Show which ritual artifact files fed the aggregate log.
2. Confirm the log still reads archived ritual runs after they leave `festivals/active/`.
3. Verify the documentation maps each artifact type to the Protocol Labs narrative.

## Definition of Done

- [ ] Aggregate log generation passes
- [ ] Discover entries come from ritual artifacts
- [ ] Archived artifact intake works
- [ ] Evidence notes are judge-ready
