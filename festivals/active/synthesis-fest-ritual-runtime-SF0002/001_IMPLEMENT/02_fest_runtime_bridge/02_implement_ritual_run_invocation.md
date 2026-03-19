---
fest_type: task
fest_id: 02_implement_ritual_run_invocation.md
fest_name: implement ritual run invocation
fest_parent: 02_fest_runtime_bridge
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.383981-06:00
fest_updated: 2026-03-19T01:59:29.513592-06:00
fest_tracking: true
---


# Task: Implement ritual run invocation

## Objective

Add the code path that starts a ritual run from the campaign root and captures the created run metadata.


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

- [ ] Invoke the real `fest` binary from the campaign root using the ritual template selector.
- [ ] Capture the created run ID and run path in a structured runtime result.

## Implementation

1. Create or update the thin `fest` runtime bridge in `projects/agent-defi`.
2. Run `fest ritual run agent-market-research-RI-AM0001 --json` from `OBEY_CAMPAIGN_ROOT`.
3. Parse the JSON response into a struct the runtime can pass forward.
4. Log enough metadata to debug failed run creation without leaking unrelated information.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
fest ritual run agent-market-research-RI-AM0001 --json
```

## Done When

- [ ] All requirements met
- [ ] The runtime can create a real ritual run and capture its ID/path without manual intervention.