---
fest_type: task
fest_id: 04_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 06_integration
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 04 | **Sequence:** 06_integration | **Autonomy:** medium | **Quality Gate**

## Objective

Final verification that the entire codebase works correctly. Run all unit tests across all packages, run the E2E integration test, and verify the codebase is clean and ready for submission.

## Requirements

- [ ] All unit tests pass across all packages
- [ ] E2E integration test passes on testnet
- [ ] Code compiles cleanly
- [ ] Static analysis clean across all packages
- [ ] No uncommitted changes

## Implementation

### Step 1: Run all unit tests

```bash
cd $(fgo)
go test ./... -v -count=1
```

This runs tests across:
- `internal/hedera/hcs/`
- `internal/hedera/hts/`
- `internal/hedera/schedule/`
- `internal/coordinator/`
- `pkg/daemon/`

### Step 2: Run E2E integration test

```bash
source .env
go test ./internal/integration/... -v -count=1 -tags=integration -timeout=10m
```

### Step 3: Check coverage across all packages

```bash
go test ./... -coverprofile=coverage.out -covermode=atomic
go tool cover -func=coverage.out | tail -1
```

### Step 4: Run static analysis

```bash
go vet ./...
staticcheck ./...
```

### Step 5: Verify clean git state

```bash
git status
git diff --stat
```

Working directory should be clean.

### Step 6: Document final results

Create `001_IMPLEMENT/06_integration/results/testing_results.md` with:
- Unit test results (pass/fail count)
- E2E test results
- Coverage summary
- Static analysis results

## Done When

- [ ] All unit tests green
- [ ] E2E test passes
- [ ] Static analysis clean
- [ ] Git working directory clean
- [ ] Results documented
