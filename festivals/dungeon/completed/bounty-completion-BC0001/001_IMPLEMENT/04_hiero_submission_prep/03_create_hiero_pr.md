---
fest_type: task
fest_id: 03_create_hiero_pr.md
fest_name: create hiero pr
fest_parent: 04_hiero_submission_prep
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.794832-07:00
fest_updated: 2026-02-23T13:53:08.708255-07:00
fest_tracking: true
---


# Task: Create PR to hiero-ledger/hiero-cli

## Objective

Fork the `hiero-ledger/hiero-cli` repo, add the camp plugin following their PLUGIN_ARCHITECTURE_GUIDE.md, and open a PR — this is the primary submission artifact for Hedera Track 4.

## Requirements

- [ ] PR opened against `hiero-ledger/hiero-cli` with the camp plugin code following their plugin architecture guide
- [ ] PR URL added to `projects/hiero-plugin/docs/submission.md`

## Implementation

### Step 1: Fork hiero-cli

```bash
gh repo fork hiero-ledger/hiero-cli --clone
```

### Step 2: Follow their plugin guide

Read `PLUGIN_ARCHITECTURE_GUIDE.md` in the hiero-cli repo. The plugin needs to:

- Be in a specific directory structure under `plugins/`
- Export a manifest with command definitions
- Follow their Node.js plugin interface

The camp plugin code is already built in `projects/hiero-plugin/dist/`. Copy the relevant files into the forked repo's plugin directory following their conventions.

### Step 3: Create the PR

```bash
cd hiero-cli-fork
git checkout -b feat/camp-plugin
# Copy plugin files
git add .
git commit -m "feat: add camp workspace management plugin"
gh pr create --title "feat: add camp workspace management plugin" --body "..."
```

Include in the PR body:

- What camp does (workspace management for Hedera development)
- The 5 templates available (3 Hedera + 2 0G)
- Link to demo video (from task 04)
- Link to documentation

### Step 4: Update submission.md

Add the PR URL to `projects/hiero-plugin/docs/submission.md` in the repository/links section.

**NOTE:** This task requires Lance's GitHub account for the actual PR creation. The agent should prepare all materials and stage the PR, then flag it for Lance to submit.

## Done When

- [ ] All requirements met
- [ ] PR URL exists and is referenced in `docs/submission.md`