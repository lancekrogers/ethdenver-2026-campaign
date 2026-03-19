---
fest_type: task
fest_id: 03_bind_session_to_ritual_workdir.md
fest_name: bind session to ritual workdir
fest_parent: 03_obey_daemon_runtime
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.384301-06:00
fest_tracking: true
---

# Task: Bind session to ritual workdir

## Objective

Ensure each runtime-created obey session is bound to the live ritual run and starts in the ritual workdir.


## Primary Files

- `projects/agent-defi/internal/strategy/obey.go` for `ObeyClient`, `createSession`, and `sendMessage`
- `projects/agent-defi/cmd/vault-agent/main.go`
- `projects/agent-defi/internal/loop/runner.go`

## Evidence To Capture

- [ ] Runtime logs record session ID, provider, model, festival ID, and workdir for real sessions.
- [ ] The session creation path includes `--workdir` and dynamic festival IDs instead of a fixed festival default only.
- [ ] There is no silent local fallback that can produce a trade decision without a live obey session.

## Requirements

- [ ] Use the created ritual run ID as the session festival context.
- [ ] Use the created ritual run path as `--workdir` so `fest next` operates in the active run directory.

## Implementation

1. Pass the run ID and run path from the fest bridge into the obey session creation call.
2. Update the runtime prompt or message path so the session is told to execute the ritual from within that directory.
3. Check that subsequent commands run against the live active ritual rather than the template or root campaign directory.
4. Keep the session/workdir binding visible in logs.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
obey session create --help
# Use a real run ID and run path from `fest ritual run ... --json`:
obey session create --campaign Obey-Agent-Economy --festival <run-id> --workdir <run-path> --provider "$OBEY_PROVIDER" --model "$OBEY_MODEL" --agent vault-trader
```

## Done When

- [ ] All requirements met
- [ ] The created session is tied to the active ritual run and starts in the correct workdir.
