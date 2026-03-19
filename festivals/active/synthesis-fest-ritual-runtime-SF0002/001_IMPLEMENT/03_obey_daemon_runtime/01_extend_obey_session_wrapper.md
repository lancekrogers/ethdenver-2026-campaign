---
fest_type: task
fest_id: 01_extend_obey_session_wrapper.md
fest_name: extend obey session wrapper
fest_parent: 03_obey_daemon_runtime
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.383731-06:00
fest_tracking: true
---

# Task: Extend obey session wrapper

## Objective

Update the obey client path so runtime-created sessions support dynamic ritual IDs, workdir binding, and reusable metadata.


## Primary Files

- `projects/agent-defi/internal/strategy/obey.go` for `ObeyClient`, `createSession`, and `sendMessage`
- `projects/agent-defi/cmd/vault-agent/main.go`
- `projects/agent-defi/internal/loop/runner.go`

## Evidence To Capture

- [ ] Runtime logs record session ID, provider, model, festival ID, and workdir for real sessions.
- [ ] The session creation path includes `--workdir` and dynamic festival IDs instead of a fixed festival default only.
- [ ] There is no silent local fallback that can produce a trade decision without a live obey session.

## Requirements

- [ ] Add support for `--workdir` and dynamic per-cycle festival IDs to the session creation path.
- [ ] Expose session metadata such as provider, model, and session ID for runtime logging.

## Implementation

1. Inspect `projects/agent-defi/internal/strategy/obey.go` and related runtime entry points.
2. Refactor the wrapper so it is reusable outside a plain strategy-evaluation call.
3. Pass through the provider, model, campaign, festival, and workdir values the runtime needs.
4. Preserve a clean interface the runner can call directly.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
obey session create --help
# Use a real run ID and run path from `fest ritual run ... --json`:
obey session create --campaign Obey-Agent-Economy --festival <run-id> --workdir <run-path> --provider "$OBEY_PROVIDER" --model "$OBEY_MODEL" --agent vault-trader
```

## Done When

- [ ] All requirements met
- [ ] The runtime can create a session with dynamic festival ID and workdir and receive structured metadata back.
