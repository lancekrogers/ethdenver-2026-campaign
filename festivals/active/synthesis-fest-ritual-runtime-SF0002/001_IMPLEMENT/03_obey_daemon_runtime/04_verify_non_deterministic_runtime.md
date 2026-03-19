---
fest_type: task
fest_id: 04_verify_non_deterministic_runtime.md
fest_name: verify non deterministic runtime
fest_parent: 03_obey_daemon_runtime
fest_order: 4
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.384569-06:00
fest_updated: 2026-03-19T02:10:58.474089-06:00
fest_tracking: true
---


# Task: Verify non deterministic runtime

## Objective

Prove the runtime is agent-driven through the daemon path and not a deterministic shortcut in local code.


## Primary Files

- `projects/agent-defi/internal/strategy/obey.go` for `ObeyClient`, `createSession`, and `sendMessage`
- `projects/agent-defi/cmd/vault-agent/main.go`
- `projects/agent-defi/internal/loop/runner.go`

## Evidence To Capture

- [ ] Runtime logs record session ID, provider, model, festival ID, and workdir for real sessions.
- [ ] The session creation path includes `--workdir` and dynamic festival IDs instead of a fixed festival default only.
- [ ] There is no silent local fallback that can produce a trade decision without a live obey session.

## Requirements

- [ ] Show that provider, model, and session creation happen through a live obey runtime path.
- [ ] Identify and remove or disable any local fallback that could bypass the daemon-backed session path silently.

## Implementation

1. Trace the runtime path from ritual creation through session creation and message send.
2. Confirm a real provider/model configuration is required for execution.
3. Audit the code for shortcut branches that would produce results without a live session.
4. Document the verification method in logs or notes that can be shown during judging.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
obey session create --help
# Use a real run ID and run path from `fest ritual run ... --json`:
obey session create --campaign Obey-Agent-Economy --festival <run-id> --workdir <run-path> --provider "$OBEY_PROVIDER" --model "$OBEY_MODEL" --agent vault-trader
```

## Done When

- [ ] All requirements met
- [ ] There is a concrete proof path showing the runtime depends on a live obey session rather than a deterministic local branch.