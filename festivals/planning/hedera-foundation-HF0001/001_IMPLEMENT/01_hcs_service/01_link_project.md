---
fest_type: task
fest_id: 01_link_project.md
fest_name: link_project
fest_parent: 01_hcs_service
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Link Project

**Task Number:** 01 | **Sequence:** 01_hcs_service | **Autonomy:** medium

## Objective

Link the hedera-foundation festival to the agent-coordinator project so that `fgo` (festival go) navigation works for all subsequent tasks. This must be the very first task executed in the entire festival because every other task references files and packages inside the agent-coordinator project, and `fgo` shortcuts depend on this link being established.

## Requirements

- [ ] The agent-coordinator project exists at `projects/agent-coordinator/` (relative to the campaign root)
- [ ] The festival is linked to the project using `fest link`
- [ ] `fgo` navigation resolves correctly after linking
- [ ] The link is verified by navigating to the project root

## Implementation

### Step 1: Verify the project exists

Before linking, confirm the agent-coordinator project directory exists. From the campaign root at `/Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/`:

```bash
ls -la projects/agent-coordinator/
```

You should see the Go project structure (go.mod, go.sum, cmd/, internal/, pkg/, etc.). If the directory does not exist, stop and escalate -- the project must be created or cloned first.

### Step 2: Link the festival to the project

Run the `fest link` command, providing the absolute path to the agent-coordinator project:

```bash
fest link /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator
```

This command registers the project path in the festival metadata so that `fgo` and other fest navigation commands know where to find source code.

### Step 3: Verify the link works

After linking, verify that `fgo` navigation resolves:

```bash
fgo
```

This should navigate you to the agent-coordinator project root. You should see the Go project files (go.mod, main.go or cmd/ directory, etc.).

### Step 4: Verify Go module

Confirm the Go module is properly initialized:

```bash
cd $(fgo) && cat go.mod
```

Note the module path (e.g., `github.com/yourorg/agent-coordinator`) -- you will need this for all import paths in subsequent tasks.

### Step 5: Verify Hedera Go SDK dependency

Check if the Hedera Go SDK is already a dependency:

```bash
cd $(fgo) && grep hedera go.mod
```

If the Hedera SDK is not present, add it:

```bash
cd $(fgo) && go get github.com/hashgraph/hedera-sdk-go/v2
```

## Done When

- [ ] `fest link` completes without errors
- [ ] `fgo` navigates to the agent-coordinator project root
- [ ] The Go module is initialized and the module path is known
- [ ] The Hedera Go SDK is available as a dependency in go.mod
- [ ] You can run `go build ./...` from the project root without errors
