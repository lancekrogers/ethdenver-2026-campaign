---
fest_type: task
fest_id: 09_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 01_inference_0g
fest_order: 9
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

## Objective

Verify that all functionality implemented in the 01_inference_0g sequence works correctly through comprehensive testing. This quality gate ensures the inference agent's 0G integrations (compute, storage, iNFT, DA) and HCS communication are reliable before proceeding to code review.

**Project:** `agent-inference` at `projects/agent-inference/`

## Requirements

- [ ] All unit tests pass across every package
- [ ] Integration tests verify the task processing pipeline
- [ ] Context cancellation tests confirm graceful shutdown
- [ ] Error handling paths are exercised
- [ ] Code coverage meets minimum threshold

## Implementation

### Step 1: Run all unit tests

Navigate to the agent-inference project and run the full test suite:

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
go test ./... -v -count=1
```

The `-count=1` flag disables test caching to ensure fresh execution. Every test must pass. If any fail, fix the implementation before continuing.

### Step 2: Verify package-level tests

Run tests for each package individually to isolate any failures:

```bash
go test ./internal/zerog/compute/... -v
go test ./internal/zerog/storage/... -v
go test ./internal/zerog/inft/... -v
go test ./internal/zerog/da/... -v
go test ./internal/hcs/... -v
go test ./internal/agent/... -v
```

For each package, verify:

- [ ] **compute**: Job submission, result polling, timeout, context cancellation, model listing
- [ ] **storage**: Upload (small and chunked), download, list, context cancellation, error cases
- [ ] **inft**: Minting, metadata encryption roundtrip, update, status query, chain errors
- [ ] **da**: Publish, retry with backoff, verify, context cancellation during retry
- [ ] **hcs**: Message serialization roundtrip, subscription, publishing, invalid message handling
- [ ] **agent**: Full pipeline processing, partial failure handling, health loop, graceful shutdown

### Step 3: Check test coverage

```bash
go test ./... -coverprofile=coverage.out
go tool cover -func=coverage.out
```

Review coverage for each package. Target minimum 70% coverage for new code. Focus on covering:

- All public functions
- Error return paths
- Context cancellation branches
- Interface boundary behavior

### Step 4: Verify context cancellation tests

Context cancellation is critical for the agent lifecycle. Confirm these specific test scenarios exist and pass:

- [ ] `compute.GetResult` exits cleanly when context is cancelled during polling
- [ ] `storage.Upload` exits cleanly when context is cancelled during chunked upload
- [ ] `da.Publish` exits cleanly when context is cancelled during retry backoff
- [ ] `hcs.StartSubscription` exits cleanly when context is cancelled
- [ ] `agent.Run` exits cleanly when context is cancelled (SIGTERM simulation)
- [ ] `agent.processTask` exits cleanly when context is cancelled mid-pipeline

### Step 5: Run static analysis

```bash
go vet ./...
```

If `staticcheck` is available:

```bash
staticcheck ./...
```

Both must produce zero warnings. Fix any issues found.

### Step 6: Verify the binary builds and starts

```bash
go build -o /tmp/agent-inference ./cmd/agent-inference/
```

Verify the binary exists and is executable. You do not need to run it against live services, but verify it starts and immediately exits gracefully when no configuration is provided (should print a config error and exit with non-zero status).

### Step 7: Manual verification checklist

Walk through each interface and confirm the implementation satisfies the contract:

1. [ ] **ComputeBroker**: SubmitJob sends a properly formatted request, GetResult polls correctly, ListModels returns parsed data
2. [ ] **StorageClient**: Upload handles both small and large data, Download retrieves by ID, List filters by prefix
3. [ ] **INFTMinter**: Mint encrypts metadata and submits a transaction, UpdateMetadata modifies existing token, GetStatus reads chain state
4. [ ] **AuditPublisher**: Publish serializes events deterministically and submits to DA, Verify checks availability
5. [ ] **HCS Handler**: Subscription parses incoming tasks, PublishResult sends results, PublishHealth sends heartbeats

### Step 8: Document results

Record test results in this file or a linked test report:

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Integration tests: [ ] Pass / [ ] Fail
- Context cancellation: [ ] Pass / [ ] Fail
- Static analysis: [ ] Pass / [ ] Fail
- Binary build: [ ] Pass / [ ] Fail
- Coverage: ____%

## Done When

- [ ] All automated tests pass with `go test ./... -v -count=1`
- [ ] Coverage meets 70% minimum for new code
- [ ] All context cancellation tests pass
- [ ] `go vet` and `staticcheck` produce zero warnings
- [ ] Binary builds successfully
- [ ] Manual verification checklist complete
- [ ] No regressions introduced
- [ ] Test results documented
