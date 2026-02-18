---
fest_type: task
fest_id: 03_fest_commit.md
fest_name: fest_commit
fest_parent: 06_integration
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Festival Commit

**Task Number:** 03 | **Sequence:** 06_integration | **Autonomy:** medium

## Objective

Finalize the hedera-foundation festival by running the fest commit workflow. This commits all changes in the agent-coordinator project, commits the festival planning changes in the campaign, and pushes everything to the remote repository. This is the last substantive task before the final quality gates.

## Requirements

- [ ] All code changes committed in the agent-coordinator project
- [ ] `fest commit` run successfully
- [ ] `camp p commit` run successfully
- [ ] Changes pushed to remote
- [ ] `camp push` run successfully

## Implementation

### Step 1: Verify all tests pass

Before committing, ensure nothing is broken:

```bash
cd $(fgo)
go build ./...
go vet ./...
go test ./... -v -count=1
```

If any test fails, fix it before proceeding.

### Step 2: Check git status

```bash
cd $(fgo)
git status
```

Review all untracked and modified files. Ensure:
- No `.env` files with secrets
- No temporary/build files
- All intended files are present

### Step 3: Commit project changes

From the agent-coordinator project root:

```bash
cd $(fgo)
git add -A
git commit -m "feat: complete Hedera foundation layer (HCS, HTS, Schedule, Coordinator, Daemon Client)"
```

The commit message should summarize the full scope of work:
- HCS service: topic creation, message publish, message subscribe
- HTS service: token creation, token transfer
- Schedule service: heartbeat via Schedule Service
- Coordinator: task assignment, progress monitor, quality gates, payment
- Daemon client: gRPC wrapper for daemon API
- Integration: E2E test on testnet

### Step 4: Run fest commit

```bash
fest commit -m "feat: complete hedera-foundation implementation"
```

This commits the festival planning directory changes (task status updates, results files, etc.).

### Step 5: Run camp p commit

```bash
camp p commit
```

This commits the project submodule reference update in the campaign.

### Step 6: Push changes

```bash
cd $(fgo)
git push
```

Then push the campaign:

```bash
camp push
```

### Step 7: Verify push

Confirm the remote repository has the latest changes:

```bash
cd $(fgo)
git log --oneline -5
git status
```

The working directory should be clean with no uncommitted changes.

## Done When

- [ ] All tests pass before commit
- [ ] No secrets in committed files
- [ ] Project commit created with descriptive message
- [ ] `fest commit` completed successfully
- [ ] `camp p commit` completed successfully
- [ ] Changes pushed to remote
- [ ] Working directory is clean
