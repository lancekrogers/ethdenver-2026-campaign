---
fest_type: task
fest_id: 04_resolve_artifact_paths.md
fest_name: resolve artifact paths
fest_parent: 02_fest_runtime_bridge
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.384508-06:00
fest_tracking: true
---

# Task: Resolve artifact paths

## Objective

Locate the ritual outputs reliably from the created run path and validate their presence before parsing.


## Primary Files

- `projects/agent-defi/cmd/vault-agent/main.go`
- `projects/agent-defi/internal/loop/runner.go`
- `projects/agent-defi/internal/strategy/obey.go`
- `projects/agent-defi/internal/festruntime/*.go (new package expected)`
- `projects/agent-defi/internal/festruntime/*_test.go (new tests expected)`

## Evidence To Capture

- [ ] A bridge type exists that shells out to the real `fest` binary and returns run ID and run path metadata.
- [ ] Real JSON from `fest ritual run agent-market-research-RI-AM0001 --json` is parsed by code, not only by human inspection.
- [ ] Artifact path resolution and timeout handling are covered by tests or focused harness output.

## Requirements

- [ ] Resolve the exact file paths for `decision.json` and `agent_log_entry.json` from the active run directory.
- [ ] Treat missing or malformed artifacts as hard errors for the cycle.

## Implementation

1. Use the run metadata and known ritual layout to derive artifact locations.
2. Validate the files exist before attempting to parse them.
3. Return structured path information to the runner so later steps do not repeat path logic.
4. Keep the path logic aligned with the ritual contract from sequence 01.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
fest ritual run agent-market-research-RI-AM0001 --json
```

## Done When

- [ ] All requirements met
- [ ] The runtime can always tell whether the ritual produced valid machine-readable outputs.
