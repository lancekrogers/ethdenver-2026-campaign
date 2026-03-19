---
fest_type: task
fest_id: 02_parse_decision_json.md
fest_name: parse decision json
fest_parent: 04_ritual_decision_loop
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.535167-06:00
fest_updated: 2026-03-19T02:15:21.710654-06:00
fest_tracking: true
---


# Task: Parse decision json

## Objective

Convert ritual output into a runtime signal that the existing vault loop can understand.


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

- [ ] Parse `decision.json` into an in-memory structure that captures decision, pair, size, rationale, and guardrails.
- [ ] Reject malformed or incomplete files as hard errors.

## Implementation

1. Define a small parser type near the runtime or trading signal structures.
2. Map the ritual fields into the runtime signal type expected by the runner.
3. Preserve rationale and confidence data rather than throwing them away after the parse.
4. Add validation that distinguishes missing files from invalid content.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
# Then run one controlled cycle and inspect logs for: ritual run -> obey session -> decision parse -> risk gate -> swap/no-swap
```

## Done When

- [ ] All requirements met
- [ ] The runtime can parse a valid ritual decision into a signal and rejects bad input clearly.