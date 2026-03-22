---
fest_type: gate
fest_id: 05_testing.md
fest_name: Testing and Verification
fest_parent: 04_ritual_decision_loop
fest_order: 5
fest_status: completed
fest_autonomy: medium
fest_gate_id: testing
fest_gate_type: testing
fest_created: 2026-03-18T07:27:46.56108-06:00
fest_updated: 2026-03-19T02:17:08.83483-06:00
fest_tracking: true
---


# Task: Testing and Verification

**Task Number:** <no value> | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Prove the runner now depends on ritual output before it can trade.

## Required Evidence

- [ ] `go test ./...` passes in `projects/agent-defi`.
- [ ] Parser tests or equivalent checks cover valid, invalid, and missing `decision.json` cases.
- [ ] A `NO_GO` result stops before `vault.ExecuteSwap`.
- [ ] A `GO` result reaches risk checks only after ritual parsing succeeds.
- [ ] Rationale and guardrail context survive into runtime logs or signal handling.

## Commands To Run

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
# Then run one controlled cycle and inspect logs for this order:
# ritual creation -> obey session -> fest next execution -> decision parse -> risk gate -> swap/no-swap
```

## Manual Checks

1. Point to the exact code path proving `vault.ExecuteSwap` is unreachable on missing or `NO_GO` ritual output.
2. Show one log sample where ritual metadata appears before risk or execution logs.
3. Verify malformed ritual output returns an error instead of defaulting to a trade signal.

## Definition of Done

- [ ] Parser and control-flow checks pass
- [ ] `NO_GO` blocks execution
- [ ] `GO` is gated behind ritual success
- [ ] Rationale fields remain available after parsing

## Notes

- `go test ./...` passed in `projects/agent-defi` on 2026-03-19 after sequence-04 hardening.
- `go vet ./...` passed in `projects/agent-defi`.
- Valid ritual parsing is covered by `TestRuntimeEvaluateReturnsHoldForNoGoDecision` and `TestRuntimeSignalFromDecisionBuildsBuySignal`.
- Invalid ritual output is covered by `TestRuntimeEvaluateFailsOnMalformedDecisionArtifact` and `TestRuntimeSignalFromDecisionRejectsGoWhenTradeNotAllowed`.
- Missing `decision.json` is covered by `TestRuntimeEvaluateFailsWhenDecisionArtifactMissing`, which proves the runtime fails closed when the ritual completes without the required decision artifact.
- The control-flow stop before swap is covered by `TestRunner_StrategyErrorSkipsSwap`, which proves strategy/runtime errors return from `Runner.cycle` before `vault.ExecuteSwap` can run.
- `NO_GO` no-swap behavior is covered by `TestRunner_HoldSignalSkipsSwap`.
- Rationale and guardrail logging is covered by `TestRunner_HoldSignalLogsRitualMetadata`, which asserts the runner logs ritual metadata including `campaign`, `ritual_run_id`, `session_id`, `trade_allowed`, and `blocking_factors` before the no-trade path completes.
- Runtime completion logging is covered by `TestRuntimeEvaluateLogsSessionMetadata`, which asserts campaign, session ID, provider, model, workdir, and ritual run ID are emitted together.

## Manual Checks

1. Code path proving swaps are gated:
   `internal/loop/runner.go` calls `r.strategy.Evaluate(...)` before any risk or swap logic.
   On error, `Runner.cycle` returns immediately.
   On ritual `NO_GO`, `signal.Type == hold`, so the runner returns before `vault.ExecuteSwap`.
2. Code path proving parsed ritual data survives:
   `internal/festruntime/runtime.go` maps rationale summary and guardrails into `trading.Signal.Ritual`.
   `internal/loop/runner.go` logs those ritual fields before hold/risk/swap handling.
3. Controlled log evidence:
   `TestRunner_HoldSignalLogsRitualMetadata` asserts the `"signal"` log entry with ritual metadata appears before `"ritual denied trade"`.

---

**Test Results Summary:**

- Unit tests: [x] Pass / [ ] Fail
- Integration tests: [x] Pass / [ ] Fail
- Manual/code-path verification: [x] Pass / [ ] Fail
- `NO_GO` blocks execution: [x] Verified / [ ] Failed
- Missing/invalid ritual output fails closed: [x] Verified / [ ] Failed