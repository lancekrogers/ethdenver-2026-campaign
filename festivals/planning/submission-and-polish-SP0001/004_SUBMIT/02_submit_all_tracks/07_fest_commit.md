---
fest_type: task
fest_id: 07_fest_commit.md
fest_name: fest_commit
fest_parent: 02_submit_all_tracks
fest_order: 7
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Final Fest Commit

**Task Number:** 07 | **Sequence:** 02_submit_all_tracks | **Autonomy:** medium

## Objective

Create the final fest commit for the entire submission-and-polish festival. This commit captures all work done across the execute and submit phases: documentation, test reports, deployment configs, demo scripts, and submission records. Run the full commit chain (fest commit, camp project commit, push).

## Requirements

- [ ] All changes staged and reviewed
- [ ] No secrets or credentials in staged changes
- [ ] Commit message describes the full scope of work
- [ ] Fest commit created successfully
- [ ] Campaign project commit created
- [ ] Project repo pushed
- [ ] Campaign pushed with updated submodule refs

## Implementation

### Step 1: Review all changes

```bash
cd $(fgo)
git status
git diff --staged
git diff
```

Review all staged and unstaged changes. Ensure:

- No secrets, API keys, or private keys in any file
- No debug code or temporary files
- All test reports and documentation are included
- No unintended changes

### Step 2: Stage all relevant changes

Stage all documentation, reports, and config changes:

```bash
git add docs/
git add README.md
# Add other relevant files
git status
```

Do NOT stage:

- `.env` files with real secrets
- Private key files
- Temporary debug files
- IDE-specific files

### Step 3: Create the fest commit

```bash
fest commit -m "docs: complete submission packaging for all bounty tracks

Added and polished documentation for five ETHDenver bounty submissions:
- Hedera Track 3: agent-coordinator architecture, README, demo notes
- Hedera Track 4: hiero-plugin README, PR preparation
- 0G Track 2: agent-inference README, compute metrics
- 0G Track 3: iNFT showcase, ERC-7857 documentation
- Base: agent-defi README, P&L proof

Includes E2E test reports, failure recovery documentation,
profitability validation, deployment configs, and demo script.

Part of: submission-and-polish-SP0001/004_SUBMIT"
```

### Step 4: Create campaign project commit

```bash
camp p commit -m "docs: complete submission-and-polish festival SP0001"
```

### Step 5: Push the project repo

```bash
git push
```

### Step 6: Push the campaign

```bash
camp push
```

### Step 7: Verify the commit chain

```bash
git log -1 --stat
camp project list
```

Verify that the commit was created, the campaign project reference was updated, and both repos are pushed to remote.

## Done When

- [ ] All changes staged and reviewed (no secrets)
- [ ] Fest commit created with descriptive message
- [ ] Campaign project commit created
- [ ] Project repo pushed to GitHub
- [ ] Campaign pushed with updated submodule refs
- [ ] Commit chain verified end-to-end
