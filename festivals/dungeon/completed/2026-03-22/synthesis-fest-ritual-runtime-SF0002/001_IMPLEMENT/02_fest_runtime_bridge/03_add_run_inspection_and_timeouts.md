---
fest_type: task
fest_id: 03_add_run_inspection_and_timeouts.md
fest_name: add run inspection and timeouts
fest_parent: 02_fest_runtime_bridge
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.384252-06:00
fest_updated: 2026-03-19T02:00:21.313078-06:00
fest_tracking: true
---


# Task: Add run inspection and timeouts

## Objective

Bound the ritual runtime with explicit status inspection and timeout handling.


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

- [ ] The bridge must be able to inspect ritual status while waiting for artifacts to appear.
- [ ] The runtime must stop cleanly when a ritual stalls, fails, or exceeds the configured timeout.

## Implementation

1. Add a helper around `fest show --festival <run-id> --json --roadmap` or an equivalent status query.
2. Define timeout behavior using an explicit configuration value such as `OBEY_RITUAL_TIMEOUT`.
3. Make incomplete ritual runs a hard runtime failure rather than a silent fallback.
4. Preserve enough status context to support debugging and demo rehearsal.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
fest ritual run agent-market-research-RI-AM0001 --json
```

## Done When

- [ ] All requirements met
- [ ] A stuck ritual cannot hang the trading loop forever and failure reasons are visible in logs.