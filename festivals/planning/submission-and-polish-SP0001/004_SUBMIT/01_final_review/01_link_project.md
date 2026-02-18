---
fest_type: task
fest_id: 01_link_project.md
fest_name: link_project
fest_parent: 01_final_review
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Link Project

**Task Number:** 01 | **Sequence:** 01_final_review | **Autonomy:** medium

## Objective

Link the festival to the agent-coordinator project for cross-project final review. The agent-coordinator is the central project and provides the best vantage point for reviewing the entire system.

## Requirements

- [ ] Any previously linked project unlinked using `fest unlink`
- [ ] Festival linked to agent-coordinator using `fest link`
- [ ] `fgo` navigation resolves to agent-coordinator project root

## Implementation

### Step 1: Unlink any current project

```bash
fest unlink
```

### Step 2: Link to agent-coordinator

```bash
fest link /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator
```

### Step 3: Verify the link

```bash
fgo
```

### Step 4: Verify all six projects are accessible

```bash
ls -la /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-coordinator/
ls -la /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference/
ls -la /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi/
ls -la /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/hiero-plugin/
ls -la /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/dashboard/
ls -la /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/contracts/
```

All six projects must be accessible for cross-project review.

## Done When

- [ ] `fest link` to agent-coordinator completes without errors
- [ ] `fgo` navigates to agent-coordinator
- [ ] All six project directories are accessible
