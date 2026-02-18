---
fest_type: task
fest_id: 03_fest_commit.md
fest_name: fest_commit
fest_parent: 04_submission
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Fest Commit

**Task Number:** 03 | **Sequence:** 04_submission | **Autonomy:** medium

## Objective

Create the final fest commit that captures the complete hiero-plugin implementation. Run the full commit chain through fest, camp project commit, git push, and camp push to ensure all changes are tracked end-to-end from the festival through the project to the campaign.

## Requirements

- [ ] All code changes are staged and committed
- [ ] Commit message is descriptive and follows project conventions
- [ ] Fest commit includes the festival task reference
- [ ] Camp project commit updates submodule references
- [ ] Project repo is pushed to GitHub
- [ ] Campaign is pushed with updated submodule references

## Implementation

### Step 1: Pre-commit verification

Before committing, run the full verification suite to ensure everything is clean:

```bash
# Verify TypeScript compiles
cd $(fgo) && npx tsc --noEmit

# Verify all tests pass
cd $(fgo) && npx jest

# Verify linting is clean
cd $(fgo) && npx eslint src/

# Verify no debug code or temporary files
cd $(fgo) && grep -rn "console.debug\|debugger\|TODO\|HACK" src/ || echo "Clean"

# Verify no secrets
cd $(fgo) && grep -rn "HEDERA_.*_KEY\|private_key\|secret" src/ --include='*.ts' || echo "No secrets found"
```

### Step 2: Review staged changes

Check what will be committed:

```bash
cd $(fgo) && git status
cd $(fgo) && git diff --stat
```

Ensure all expected files are present:
- `src/index.ts` - Plugin entry point
- `src/camp.ts` - Camp binary discovery
- `src/commands/init.ts` - Init command
- `src/commands/status.ts` - Status command
- `src/commands/navigate.ts` - Navigate command
- `src/templates.ts` - Template loading module
- `templates/` - All three template directories
- `docs/` - All documentation files
- `plugin.json` - Plugin manifest
- `package.json` - Updated package metadata
- `tsconfig.json` - TypeScript configuration
- `demo.sh` - Demo script
- `README.md` - Project README

### Step 3: Stage all changes

```bash
cd $(fgo) && git add -A
```

Review what is staged:

```bash
cd $(fgo) && git diff --staged --stat
```

Verify no unwanted files are included:
- No `node_modules/`
- No `dist/`
- No `.env` files (only `.env.example`)
- No `.DS_Store` or other OS files

If unwanted files are staged, update `.gitignore` and unstage them:

```bash
cd $(fgo) && git reset HEAD node_modules/ dist/ .env
```

### Step 4: Create the fest commit

Use `fest commit` to create the commit with the festival task reference:

```bash
fest commit -m "feat: complete hiero-plugin implementation

Implemented a Hiero CLI plugin that wraps the camp binary to provide
Hedera developers with workspace management commands.

Plugin components:
- Plugin manifest and Hiero CLI registration
- Camp binary discovery with clear error messages
- hiero camp init: workspace initialization with Hedera templates
- hiero camp status: workspace status with formatted output
- hiero camp navigate: fuzzy-find project navigation

Bundled Hedera scaffold templates:
- hedera-smart-contract: Solidity + Hardhat for Hedera
- hedera-dapp: React + HashConnect
- hedera-agent: Go agent with HCS/HTS

Documentation:
- README with installation and usage guide
- Detailed usage guide with examples
- Architecture document with design decisions
- Bounty submission materials

Target: Hedera Track 4 bounty (developer tooling)"
```

### Step 5: Create the camp project commit

After the fest commit succeeds, commit at the campaign project level:

```bash
camp p commit -m "feat: complete hiero-plugin implementation"
```

This records the change at the campaign project level so submodule references stay in sync.

### Step 6: Push the project repo

```bash
cd $(fgo) && git push
```

If this is the first push, set the upstream:

```bash
cd $(fgo) && git push -u origin main
```

### Step 7: Push the campaign

```bash
camp push
```

This pushes the campaign repo with updated submodule references.

### Step 8: Verify the commit chain

Confirm everything is pushed and in sync:

```bash
# Verify project commit
cd $(fgo) && git log -1 --stat

# Verify campaign state
camp project list

# Verify remote is up to date
cd $(fgo) && git status
```

The output should show:
- Clean working tree (nothing to commit)
- Branch up to date with remote
- Campaign projects all synced

## Done When

- [ ] Pre-commit verification passed (compile, tests, lint, no secrets)
- [ ] All expected files are staged
- [ ] Fest commit created with descriptive message and task reference
- [ ] Camp project commit created
- [ ] Project repo pushed to GitHub
- [ ] Campaign pushed with updated submodule references
- [ ] Commit chain verified (project and campaign in sync)
- [ ] Working tree is clean after all pushes
