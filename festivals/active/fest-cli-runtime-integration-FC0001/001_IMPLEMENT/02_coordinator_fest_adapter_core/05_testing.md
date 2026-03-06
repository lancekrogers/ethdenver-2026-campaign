---
fest_type: gate
fest_id: 05_testing.md
fest_name: Testing and Verification
fest_parent: 02_coordinator_fest_adapter_core
fest_order: 5
fest_status: completed
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-06T13:39:01.568636-07:00
fest_updated: 2026-03-06T15:36:11.108919-07:00
fest_tracking: true
---


# Task: Testing and Verification

**Task Number:** 05 | **Dependencies:** Tasks 01-04 | **Autonomy:** medium

## Objective
Verify coordinator fest adapter behavior with automated tests and real command-path smoke checks.

## Required Test Run

```bash
cgo agent-coordinator
fest link .
go test ./internal/festival/...
go test ./internal/coordinator/...
go test ./...
```

Optional smoke check from campaign root:
```bash
cgo obey-agent-economy
fest show --festival fest-cli-runtime-integration-FC0001 --json --roadmap | jq '.festival.metadata_id'
```

## Verification Criteria

- [ ] New/updated festival package tests pass.
- [ ] Existing coordinator tests still pass.
- [ ] No regression introduced to assignment path.

## Done When

- [ ] All verification criteria satisfied
- [ ] Test output evidence is captured in task notes