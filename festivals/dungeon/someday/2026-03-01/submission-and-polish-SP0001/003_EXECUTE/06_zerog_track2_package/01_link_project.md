---
fest_type: task
fest_id: 01_link_project.md
fest_name: link_project
fest_parent: 06_zerog_track2_package
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_updated: 2026-02-21T12:09:24.571457-07:00
fest_tracking: true
---


# Task: Link Project

**Task Number:** 01 | **Sequence:** 03_zerog_track2_package | **Autonomy:** medium

## Objective

Unlink the previously linked project (agent-coordinator) and link the festival to the agent-inference project for 0G Track 2 packaging work.

## Requirements

- [ ] Previous project unlinked using `fest unlink`
- [ ] The agent-inference project exists at `projects/agent-inference/`
- [ ] Festival linked to agent-inference using `fest link`
- [ ] `fgo` navigation resolves to agent-inference project root

## Implementation

### Step 1: Unlink the current project

```bash
fest unlink
```

This removes the current project link so we can link to a different project.

### Step 2: Verify agent-inference exists

```bash
ls -la /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference/
```

You should see the project structure. If it does not exist, stop and escalate.

### Step 3: Link to agent-inference

```bash
fest link /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
```

### Step 4: Verify the link

```bash
fgo
```

This should navigate to the agent-inference project root.

### Step 5: Verify the project builds

```bash
cd $(fgo) && go build ./...
```

## Done When

- [ ] Previous project unlinked
- [ ] `fest link` to agent-inference completes without errors
- [ ] `fgo` navigates to the agent-inference project root
- [ ] Project builds successfully