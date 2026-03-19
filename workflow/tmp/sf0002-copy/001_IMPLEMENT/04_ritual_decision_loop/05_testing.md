---
fest_type: gate
fest_id: testing
fest_name: Testing and Verification
fest_parent: 04_ritual_decision_loop
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-18T07:27:46.56108-06:00
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
