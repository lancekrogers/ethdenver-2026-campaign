---
fest_type: task
fest_id: 02_run_cross_repo_validation_matrix.md
fest_name: run_cross_repo_validation_matrix
fest_parent: 06_cross_project_validation_release
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:56.0094-07:00
fest_tracking: true
---

# Task: Run Cross-Repo Validation Matrix

## Objective
Execute a full validation matrix across campaign root, coordinator, and dashboard to confirm integrated runtime behavior.

## Requirements

- [ ] Run root mode checks.
- [ ] Run coordinator test/build checks.
- [ ] Run dashboard test/build checks.
- [ ] Record pass/fail and exit codes.

## Implementation

1. Start at campaign root:
```bash
cgo obey-agent-economy
fest link .
just fest status
just fest doctor
just demo run || true
just mode doctor || true
```

2. Coordinator checks:
```bash
cgo agent-coordinator
fest link .
go test ./...
go build ./cmd/coordinator
```

3. Dashboard checks:
```bash
cgo dashboard
fest link .
npm test -- --runInBand
npm run build
```

4. Return to root and capture summary:
- Update `workflow/explore/cre-demo/fest-validation-matrix.md` with:
  - command
  - exit code
  - expected result
  - actual result

## Done When

- [ ] All requirements met
- [ ] Validation matrix file exists and includes all command outcomes
