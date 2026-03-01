---
fest_type: task
fest_id: 01_link_project.md
fest_name: link_project
fest_parent: 04_e2e_testing
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Link Project

**Task Number:** 01 | **Sequence:** 01_e2e_testing | **Autonomy:** medium

## Objective

Link the submission-and-polish festival to the agent-coordinator project so that `fgo` navigation works for all E2E testing tasks. The agent-coordinator orchestrates the full economy cycle and is the central project for system-level testing.

## Requirements

- [ ] The agent-coordinator project exists at `projects/agent-coordinator/` (relative to the campaign root)
- [ ] The festival is linked to the project using `fest link`
- [ ] `fgo` navigation resolves correctly after linking
- [ ] The link is verified by navigating to the project root

## Implementation

### Step 1: Verify the project exists

From the campaign root at `/Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/`:

```bash
ls -la projects/agent-coordinator/
```

You should see the Go project structure (go.mod, cmd/, internal/, etc.). If the directory does not exist, stop and escalate.

### Step 2: Link the festival to the project

```bash
fest link /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator
```

This registers the project path so `fgo` and other fest navigation commands work.

### Step 3: Verify the link works

```bash
fgo
```

This should navigate to the agent-coordinator project root.

### Step 4: Verify the project builds

```bash
cd $(fgo) && go build ./...
```

This confirms all code compiles and dependencies are resolved. Any build failure must be investigated before proceeding to E2E testing.

### Step 5: Verify testnet configuration

Check that testnet environment variables or configuration files exist:

```bash
cd $(fgo) && ls -la .env* config/
```

The agent-coordinator needs Hedera testnet credentials (operator account ID, private key) and network configuration. If missing, check the project documentation or prior festival outputs.

## Done When

- [ ] `fest link` completes without errors
- [ ] `fgo` navigates to the agent-coordinator project root
- [ ] `go build ./...` passes with no errors
- [ ] Testnet configuration is present and accessible
