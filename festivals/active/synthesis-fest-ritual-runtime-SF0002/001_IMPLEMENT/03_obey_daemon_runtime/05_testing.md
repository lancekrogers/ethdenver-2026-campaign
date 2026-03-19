---
fest_type: gate
fest_id: 05_testing.md
fest_name: Testing and Verification
fest_parent: 03_obey_daemon_runtime
fest_order: 5
fest_status: completed
fest_autonomy: medium
fest_gate_id: testing
fest_gate_type: testing
fest_created: 2026-03-18T07:27:46.560199-06:00
fest_updated: 2026-03-19T02:12:20.881826-06:00
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

## Notes

- `go test ./...` passed in `projects/agent-defi` on 2026-03-19 after adding sequence-03 coverage for fail-closed preflight and runtime session logging.
- `obey ping --socket /tmp/obey.sock` succeeded before the live create-session check, confirming the daemon path was available.
- Live ritual run verification used run `agent-market-research-RI-AM0001-0004` at `/Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/festivals/active/agent-market-research-RI-AM0001-0004`.
- Exact live create-session command:

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
obey session create --socket /tmp/obey.sock --campaign Obey-Agent-Economy --festival agent-market-research-RI-AM0001-0004 --workdir /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/festivals/active/agent-market-research-RI-AM0001-0004 --provider claude-code --model claude-sonnet-4-6 --agent vault-trader
```

- Live session result:
  `Session: 80399e25-b3c3-4d75-954e-bc04e3f14721`
  `Provider: claude-code/claude-sonnet-4-6`
- `cd festivals/active/agent-market-research-RI-AM0001-0004 && fest context && fest next` resolved the new run as the active festival and returned the first workflow step, which matches the intended `--workdir` binding target.
- Silent fallback is blocked in two places:
  `internal/strategy/obey.go` fails on `Preflight`, `CreateSession`, or `session send` errors.
  `internal/festruntime/runtime_test.go` now includes `TestRuntimeEvaluateFailsClosedWhenPreflightFails`, which verifies `Evaluate` returns before any ritual run execution path can continue.
- Runtime session metadata logging is covered by `TestRuntimeEvaluateLogsSessionMetadata`, which asserts log output includes campaign, ritual run ID, session ID, provider, model, and workdir.

---

**Test Results Summary:**

- Unit tests: [x] Pass / [ ] Fail
- Integration tests: [x] Pass / [ ] Fail
- Manual tests: [x] Pass / [ ] Fail
- Real session creation: [x] Verified / [ ] Failed
- Silent fallback blocked: [x] Yes / [ ] No