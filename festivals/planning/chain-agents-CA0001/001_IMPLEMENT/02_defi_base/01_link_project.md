---
fest_type: task
fest_id: 01_link_project.md
fest_name: link_project
fest_parent: 02_defi_base
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Link Project

## Objective

Unlink the agent-inference project from the previous sequence and link the chain-agents-CA0001 festival to the `agent-defi` project. The fest CLI supports only one linked project at a time per festival, so you must unlink the previous project first. After linking, `fgo` navigation and all fest-aware tooling will point at the agent-defi codebase.

**Project:** `agent-defi` at `projects/agent-defi/`

## Requirements

- [ ] Unlink the agent-inference project from sequence 01
- [ ] Link the festival to the agent-defi project directory
- [ ] Verify `fgo` navigates to the agent-defi project root
- [ ] Confirm the project directory exists and contains a valid Go module

## Implementation

### Step 1: Unlink the previous project

The festival is currently linked to `agent-inference` from sequence 01. Remove that link:

```bash
fest unlink
```

Verify the unlink succeeded:

```bash
fest status
```

The output should show no linked project, or indicate the link was removed.

### Step 2: Verify the agent-defi project directory exists

```bash
ls -la /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi/
```

You should see a Go project with at minimum a `go.mod` file. If the directory does not exist, the project must be created or cloned before proceeding.

### Step 3: Link the festival to agent-defi

```bash
fest link /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
```

This tells the fest CLI that all work in the current festival now targets the `agent-defi` codebase.

### Step 4: Verify the link

```bash
fest status
```

The output should show the linked project path pointing to `projects/agent-defi/`.

### Step 5: Test fgo navigation

```bash
fgo
pwd
# Expected: /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
```

The `fgo` shortcut should now navigate to the agent-defi project root. All subsequent tasks in this sequence assume `fgo` takes you to agent-defi.

### Step 6: Verify the Go module

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
go mod tidy
go build ./...
```

If the project is freshly scaffolded and has no source files yet, `go build ./...` may produce no output (which is fine). The important thing is that `go mod tidy` succeeds without errors.

## Done When

- [ ] `fest unlink` successfully removed the agent-inference link
- [ ] `fest link` completed successfully with no errors pointing to agent-defi
- [ ] `fest status` shows the correct linked project path (`projects/agent-defi`)
- [ ] `fgo` navigates to `/Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi`
- [ ] Go module in the project directory is valid (go mod tidy succeeds)
