---
fest_type: task
fest_id: 01_link_project.md
fest_name: link_project
fest_parent: 08_demo_video
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Link Project

**Task Number:** 01 | **Sequence:** 08_demo_video | **Autonomy:** medium

## Objective

Unlink the previously linked project and link the festival to the dashboard project for demo recording. The dashboard is the primary visual surface for the demo video.

## Requirements

- [ ] Previous project unlinked using `fest unlink`
- [ ] The dashboard project exists at `projects/dashboard/`
- [ ] Festival linked to dashboard using `fest link`
- [ ] `fgo` navigation resolves to dashboard project root

## Implementation

### Step 1: Unlink the current project

```bash
fest unlink
```

### Step 2: Verify dashboard exists

```bash
ls -la /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/dashboard/
```

### Step 3: Link to dashboard

```bash
fest link /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/dashboard
```

### Step 4: Verify the link

```bash
fgo
```

This should navigate to the dashboard project root.

### Step 5: Verify the dashboard is accessible

Confirm the deployed dashboard is still running and accessible at its public URL. Open the URL in a browser and verify all panels show live data from the running agents.

## Done When

- [ ] Previous project unlinked
- [ ] `fest link` to dashboard completes without errors
- [ ] `fgo` navigates to the dashboard project root
- [ ] Deployed dashboard is accessible and showing live data
