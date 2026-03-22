---
fest_type: task
fest_id: 01_map_fest_cli_command_contract.md
fest_name: map fest cli command contract
fest_parent: 02_fest_runtime_bridge
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.383387-06:00
fest_updated: 2026-03-19T01:59:03.781874-06:00
fest_tracking: true
---


# Task: Map fest CLI command contract

## Objective

Confirm the exact fest command surface and JSON expectations the runtime bridge will rely on.


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

- [ ] Verify the live commands, flags, and expected outputs for `fest ritual run`, `fest next`, and `fest show`.
- [ ] Capture failure modes the Go bridge must treat as hard errors.

## Implementation

1. Run `fest --help`, `fest ritual run --help`, `fest next --help`, and `fest show --help` as needed.
2. Document the required invocation forms and where JSON output is expected.
3. Record path assumptions, run IDs, and timeout/error conditions the bridge must handle.
4. Align the command contract with the runtime design spec before code changes begin.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
fest ritual run agent-market-research-RI-AM0001 --json
```

## Done When

- [ ] All requirements met
- [ ] The Go bridge can be implemented against one documented command contract instead of guesswork.