---
fest_type: task
fest_id: 01_insert_ritual_at_cycle_start.md
fest_name: insert ritual at cycle start
fest_parent: 04_ritual_decision_loop
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.53459-06:00
fest_updated: 2026-03-19T02:15:21.66807-06:00
fest_tracking: true
---


# Task: Insert ritual at cycle start

## Objective

Make ritual creation and execution the first step of every runtime cycle before trade decisioning continues.


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

- [ ] The runner must create and execute a ritual before any trade signal can be acted on.
- [ ] The new flow must preserve existing market fetch and risk behavior where they still add value.

## Implementation

1. Update the runner flow in `projects/agent-defi/internal/loop/runner.go` and related entry points.
2. Insert ritual creation and session execution before the existing swap path.
3. Keep market data and risk checks available as supporting inputs rather than the primary decision source.
4. Make the sequence fail closed when the ritual path fails.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
# Then run one controlled cycle and inspect logs for: ritual run -> obey session -> decision parse -> risk gate -> swap/no-swap
```

## Done When

- [ ] All requirements met
- [ ] A cycle cannot reach trade execution without first creating and running a ritual.