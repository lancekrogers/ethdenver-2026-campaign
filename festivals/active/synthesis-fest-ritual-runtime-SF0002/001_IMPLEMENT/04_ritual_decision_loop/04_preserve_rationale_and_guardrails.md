---
fest_type: task
fest_id: 04_preserve_rationale_and_guardrails.md
fest_name: preserve rationale and guardrails
fest_parent: 04_ritual_decision_loop
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.535673-06:00
fest_tracking: true
---

# Task: Preserve rationale and guardrails

## Objective

Carry the ritual rationale and guardrail context forward into runtime logs and trade metadata.


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

- [ ] Keep the reasoning summary, confidence, and guardrail outputs available after decision parsing.
- [ ] Use those fields to strengthen runtime logs, vault reason bytes, or submission artifacts where appropriate.

## Implementation

1. Decide which fields should survive in memory and where they should be logged or persisted.
2. Update the runner or trading execution path to preserve that information.
3. Avoid leaking verbose internal thought while still documenting the decision process and constraints.
4. Check that the preserved fields improve Protocol Labs evidence quality.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
# Then run one controlled cycle and inspect logs for: ritual run -> obey session -> decision parse -> risk gate -> swap/no-swap
```

## Done When

- [ ] All requirements met
- [ ] Runtime outputs retain meaningful rationale and guardrail context after a ritual decision is consumed.
