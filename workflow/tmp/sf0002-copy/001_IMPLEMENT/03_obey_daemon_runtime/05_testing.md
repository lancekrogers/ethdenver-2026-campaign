---
fest_type: gate
fest_id: testing
fest_name: Testing and Verification
fest_parent: 03_obey_daemon_runtime
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-18T07:27:46.560199-06:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** <no value> | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Prove the runtime creates and uses a real daemon-backed obey session bound to a ritual run workdir.

## Required Evidence

- [ ] `go test ./...` passes in `projects/agent-defi`.
- [ ] A real `obey session create` command is executed with `--festival` and `--workdir`.
- [ ] A real session ID is captured in logs or notes.
- [ ] Provider, model, festival ID, and workdir are logged for that session.
- [ ] There is no remaining silent local fallback for decision generation.

## Commands To Run

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
obey session create --help
# Then execute a real create call using the run ID and run path returned by fest:
obey session create --campaign Obey-Agent-Economy --festival <run-id> --workdir <run-path> --provider "$OBEY_PROVIDER" --model "$OBEY_MODEL" --agent vault-trader
```

## Manual Checks

1. Show the exact create-session command used during verification.
2. Record the resulting session ID and the workdir it was bound to.
3. Confirm the code now refuses to proceed when session creation fails.

## Definition of Done

- [ ] Real session creation verified
- [ ] Workdir binding verified
- [ ] Session metadata logged
- [ ] Silent fallback removed or blocked
