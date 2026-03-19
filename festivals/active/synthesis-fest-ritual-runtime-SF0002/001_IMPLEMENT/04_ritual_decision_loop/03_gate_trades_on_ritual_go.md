---
fest_type: task
fest_id: 03_gate_trades_on_ritual_go.md
fest_name: gate trades on ritual go
fest_parent: 04_ritual_decision_loop
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.535429-06:00
fest_tracking: true
---

# Task: Gate trades on ritual go

## Objective

Require a successful ritual `GO` before the vault runtime can continue to execution.


## Primary Files

- `projects/agent-defi/internal/loop/runner.go (`Runner.cycle`)`
- `projects/agent-defi/internal/base/trading/models.go (`Signal`, `SignalType`)`
- `projects/agent-defi/internal/strategy/llm.go (old decision path to replace or wrap)`
- `projects/agent-defi/internal/festruntime/*.go`

## Evidence To Capture

- [ ] A cycle cannot reach swap execution until a ritual result has been created, parsed, and accepted.
- [ ] `NO_GO` and malformed ritual outputs stop cleanly before `vault.ExecuteSwap` is called.
- [ ] Rationale and guardrail fields survive into runtime logs or final signal handling.

## Requirements

- [ ] A `NO_GO` decision must stop execution cleanly without looking like a runtime failure.
- [ ] Missing or invalid ritual output must stop execution before any swap path runs.

## Implementation

1. Wire the parsed ritual decision into the runner control flow.
2. Preserve the risk manager as defense in depth after ritual approval rather than removing it.
3. Return or log a clear no-trade result for `NO_GO` outcomes.
4. Test the control flow against missing, malformed, and negative decisions.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
# Then run one controlled cycle and inspect logs for: ritual run -> obey session -> decision parse -> risk gate -> swap/no-swap
```

## Done When

- [ ] All requirements met
- [ ] Trades only continue after ritual `GO`, and negative or invalid outcomes never trigger a swap.
