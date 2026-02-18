---
fest_type: task
fest_id: 01_link_project.md
fest_name: link_project
fest_parent: 05_base_package
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Link Project

**Task Number:** 01 | **Sequence:** 05_base_package | **Autonomy:** medium

## Objective

Unlink the previously linked project (agent-inference) and link the festival to the agent-defi project for Base bounty packaging work.

## Requirements

- [ ] Previous project unlinked using `fest unlink`
- [ ] The agent-defi project exists at `projects/agent-defi/`
- [ ] Festival linked to agent-defi using `fest link`
- [ ] `fgo` navigation resolves to agent-defi project root

## Implementation

### Step 1: Unlink the current project

```bash
fest unlink
```

### Step 2: Verify agent-defi exists

```bash
ls -la /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi/
```

You should see the project structure. If it does not exist, stop and escalate.

### Step 3: Link to agent-defi

```bash
fest link /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
```

### Step 4: Verify the link

```bash
fgo
```

This should navigate to the agent-defi project root.

### Step 5: Verify the project builds

```bash
cd $(fgo) && go build ./...
```

## Done When

- [ ] Previous project unlinked
- [ ] `fest link` to agent-defi completes without errors
- [ ] `fgo` navigates to the agent-defi project root
- [ ] Project builds successfully
