---
fest_type: task
fest_id: 01_link_project.md
fest_name: link_project
fest_parent: 01_inference_0g
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Link Project

## Objective

Link the chain-agents-CA0001 festival to the `agent-inference` project so that `fgo` navigation and all fest-aware tooling points at the correct codebase. This must be done before any other task in this sequence because every subsequent task assumes the festival is linked to `agent-inference`.

## Requirements

- [ ] Run `fest link` to connect the festival to the agent-inference project directory
- [ ] Verify `fgo` navigates to the agent-inference project root
- [ ] Confirm the project directory exists and contains a valid Go module

## Implementation

### Step 1: Verify the project directory exists

Before linking, confirm the agent-inference project is present at the expected location:

```bash
ls -la /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference/
```

You should see a Go project with at minimum a `go.mod` file. If the directory does not exist, the project must be created or cloned before proceeding.

### Step 2: Link the festival to the project

Run the fest link command from anywhere -- it uses absolute paths:

```bash
fest link /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
```

This tells the fest CLI that all work in the current festival targets the `agent-inference` codebase. The link is stored in the festival metadata and persists across sessions.

### Step 3: Verify the link

Confirm the link is active:

```bash
fest status
```

The output should show the linked project path pointing to `projects/agent-inference`. Additionally, test the `fgo` shortcut:

```bash
fgo
```

This should change your working directory to the agent-inference project root. Verify you are in the correct directory:

```bash
pwd
# Expected: /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
```

### Step 4: Verify the Go module

Confirm the Go module is valid:

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
go mod tidy
go build ./...
```

If the project is freshly scaffolded and has no source files yet, `go build ./...` may produce no output (which is fine). The important thing is that `go mod tidy` succeeds without errors.

## Done When

- [ ] `fest link` command completed successfully with no errors
- [ ] `fest status` shows the correct linked project path
- [ ] `fgo` navigates to `/Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference`
- [ ] Go module in the project directory is valid (go mod tidy succeeds)
