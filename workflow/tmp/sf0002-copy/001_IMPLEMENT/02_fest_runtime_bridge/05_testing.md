---
fest_type: gate
fest_id: testing
fest_name: Testing and Verification
fest_parent: 02_fest_runtime_bridge
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-18T07:27:46.559237-06:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** <no value> | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Prove the Go bridge consumes real fest output and fails cleanly on bad runtime conditions.

## Required Evidence

- [ ] `go test ./...` passes in `projects/agent-defi`.
- [ ] A real `fest ritual run ... --json` payload has been captured and parsed by bridge code or bridge tests.
- [ ] Run ID and run path are surfaced in structured form.
- [ ] Missing artifact files or bad JSON produce explicit bridge errors.

## Commands To Run

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy
fest ritual run agent-market-research-RI-AM0001 --json
```

## Manual Checks

1. Point to the exact test or harness proving the bridge parsed a real fest payload.
2. Show the code path that resolves artifact paths from the created run.
3. Demonstrate the error returned when the run output is incomplete or malformed.

## Definition of Done

- [ ] Bridge tests pass
- [ ] Real fest JSON is parsed by code
- [ ] Artifact path resolution is exercised
- [ ] Failure paths are explicit and fail closed
