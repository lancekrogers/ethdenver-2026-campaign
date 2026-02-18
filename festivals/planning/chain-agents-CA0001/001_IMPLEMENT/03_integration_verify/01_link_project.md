---
fest_type: task
fest_id: 01_link_project.md
fest_name: link_project
fest_parent: 03_integration_verify
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Link Project

## Objective

Unlink the agent-defi project from the previous sequence and link the chain-agents-CA0001 festival back to the `agent-coordinator` project for integration testing. The coordinator project is the natural home for orchestrating the three-agent integration test because it is the central hub that coordinates all agents.

**Project:** `agent-coordinator` at `projects/agent-coordinator/`

## Requirements

- [ ] Unlink the agent-defi project from sequence 02
- [ ] Link the festival to the agent-coordinator project
- [ ] Verify `fgo` navigates to the agent-coordinator project root
- [ ] Verify all three agent projects are buildable

## Implementation

### Step 1: Unlink the previous project

```bash
fest unlink
```

Verify:

```bash
fest status
```

### Step 2: Link to agent-coordinator

```bash
fest link /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator
```

### Step 3: Verify the link

```bash
fest status
fgo
pwd
# Expected: /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator
```

### Step 4: Verify all three agent projects build

Before running integration tests, confirm all three agents compile cleanly:

```bash
# Build coordinator
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator
go build ./...

# Build inference agent
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
go build ./...

# Build DeFi agent
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
go build ./...
```

All three must compile without errors. If any fail, the relevant sequence (01 or 02) must be revisited before integration testing can proceed.

### Step 5: Build all binaries

Build the binaries that will be used in the integration test:

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator
go build -o /tmp/agent-coordinator ./cmd/agent-coordinator/

cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
go build -o /tmp/agent-inference ./cmd/agent-inference/

cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
go build -o /tmp/agent-defi ./cmd/agent-defi/
```

Verify all three binaries exist:

```bash
ls -la /tmp/agent-coordinator /tmp/agent-inference /tmp/agent-defi
```

## Done When

- [ ] `fest unlink` successfully removed the agent-defi link
- [ ] `fest link` completed pointing to agent-coordinator
- [ ] `fgo` navigates to agent-coordinator project root
- [ ] All three agent projects compile with `go build ./...`
- [ ] All three agent binaries built to `/tmp/`
