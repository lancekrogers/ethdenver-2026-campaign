---
fest_type: task
fest_id: 01_link_project.md
fest_name: link_project
fest_parent: 06_hedera_track4_package
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Link Project

**Task Number:** 01 | **Sequence:** 06_hedera_track4_package | **Autonomy:** medium

## Objective

Unlink the previously linked project (agent-defi) and link the festival to the hiero-plugin project for Hedera Track 4 packaging work.

## Requirements

- [ ] Previous project unlinked using `fest unlink`
- [ ] The hiero-plugin project exists at `projects/hiero-plugin/`
- [ ] Festival linked to hiero-plugin using `fest link`
- [ ] `fgo` navigation resolves to hiero-plugin project root

## Implementation

### Step 1: Unlink the current project

```bash
fest unlink
```

### Step 2: Verify hiero-plugin exists

```bash
ls -la /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/hiero-plugin/
```

You should see the plugin project structure. If it does not exist, stop and escalate.

### Step 3: Link to hiero-plugin

```bash
fest link /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/hiero-plugin
```

### Step 4: Verify the link

```bash
fgo
```

This should navigate to the hiero-plugin project root.

### Step 5: Verify the project builds

```bash
cd $(fgo) && go build ./...
```

Or use the project's build command if different (check the justfile).

## Done When

- [ ] Previous project unlinked
- [ ] `fest link` to hiero-plugin completes without errors
- [ ] `fgo` navigates to the hiero-plugin project root
- [ ] Project builds successfully
