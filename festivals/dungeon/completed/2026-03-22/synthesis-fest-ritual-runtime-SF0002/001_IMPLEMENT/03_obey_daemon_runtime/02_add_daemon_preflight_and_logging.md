---
fest_type: task
fest_id: 02_add_daemon_preflight_and_logging.md
fest_name: add daemon preflight and logging
fest_parent: 03_obey_daemon_runtime
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.384038-06:00
fest_updated: 2026-03-19T02:09:58.039303-06:00
fest_tracking: true
---


# Task: Add daemon preflight and logging

## Objective

Verify daemon availability before each cycle and log the runtime metadata needed to prove real agent execution.


## Primary Files

- `projects/agent-defi/internal/strategy/obey.go` for `ObeyClient`, `createSession`, and `sendMessage`
- `projects/agent-defi/cmd/vault-agent/main.go`
- `projects/agent-defi/internal/loop/runner.go`

## Evidence To Capture

- [ ] Runtime logs record session ID, provider, model, festival ID, and workdir for real sessions.
- [ ] The session creation path includes `--workdir` and dynamic festival IDs instead of a fixed festival default only.
- [ ] There is no silent local fallback that can produce a trade decision without a live obey session.

## Requirements

- [ ] Fail closed if the obey binary or daemon path is unavailable.
- [ ] Log campaign, ritual run, provider, model, session ID, and related runtime metadata on success.

## Implementation

1. Add explicit checks for the obey binary and any daemon socket or runtime dependency the environment requires.
2. Make session-creation failure stop the cycle immediately.
3. Log the session metadata defined in the design spec without exposing secrets.
4. Keep the logging format stable enough to use in demo rehearsal and debugging.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
obey session create --help
# Use a real run ID and run path from `fest ritual run ... --json`:
obey session create --campaign Obey-Agent-Economy --festival <run-id> --workdir <run-path> --provider "$OBEY_PROVIDER" --model "$OBEY_MODEL" --agent vault-trader
```

## Done When

- [ ] All requirements met
- [ ] A failed daemon preflight stops execution and a successful preflight produces clear session metadata.