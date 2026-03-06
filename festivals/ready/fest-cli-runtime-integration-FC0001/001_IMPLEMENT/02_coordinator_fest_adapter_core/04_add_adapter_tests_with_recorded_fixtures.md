---
fest_type: task
fest_id: 04_add_adapter_tests_with_recorded_fixtures.md
fest_name: add_adapter_tests_with_recorded_fixtures
fest_parent: 02_coordinator_fest_adapter_core
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.946053-07:00
fest_tracking: true
---

# Task: Add Adapter Tests With Recorded Fixtures

## Objective
Add fixture-driven tests for selector resolution, JSON parsing, and mapping behavior.

## Requirements

- [ ] Add fixture files for `show all` and `show --roadmap` outputs.
- [ ] Cover success and failure cases.
- [ ] Validate status normalization and deterministic plan ordering.

## Implementation

1. Ensure context:
```bash
cgo agent-coordinator
fest link .
```

2. Add fixture directory:
- `testdata/fest/`

Suggested fixtures:
- `show_all_active.json`
- `show_all_no_active.json`
- `show_roadmap_valid.json`
- `show_roadmap_malformed.json`

3. Add tests in `internal/festival/`:
- `reader_test.go`
- `mapper_test.go` (or equivalent)

Must test:
- explicit selector override
- fallback selector priority
- parse failure handling
- status normalization output
- deterministic ordering of generated `PlanTask` entries

4. Run tests:
```bash
go test ./internal/festival/...
go test ./internal/coordinator/...
```

## Done When

- [ ] All requirements met
- [ ] Festival adapter tests pass locally
- [ ] Failure paths are covered and assert typed errors
