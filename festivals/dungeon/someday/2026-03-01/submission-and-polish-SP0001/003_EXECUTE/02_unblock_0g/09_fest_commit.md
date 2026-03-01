---
fest_type: gate
fest_id: 09_fest_commit.md
fest_name: Fest Commit Changes
fest_parent: 02_unblock_0g
fest_order: 9
fest_status: pending
fest_gate_type: fest_commit
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Fest Commit Sequence Changes

**Task Number:** 09 | **Parallel Group:** None | **Dependencies:** Testing, Code Review, Iteration | **Autonomy:** medium

## Objective

Create a clean, descriptive commit that captures all changes made in this sequence: the serving contract ABI fix, any storage or iNFT changes, and the `.env` contract address configuration.

## Pre-Commit Checklist

Before committing, verify:

- [ ] All tests pass (`go test ./...` clean)
- [ ] Linting is clean (`go vet ./...` no warnings)
- [ ] `just build` succeeds
- [ ] No debug code or temporary files staged
- [ ] No secrets or credentials in staged changes (`.env` must NOT be staged)
- [ ] `.env` is confirmed in `.gitignore`

## Staged Files

The following files should be staged — verify each is intentional:

- [ ] `internal/zerog/compute/broker.go` — ABI fix and `listFromChain` rewrite
- [ ] Any new test files covering the updated `listFromChain` path
- [ ] `internal/zerog/storage/` changes if any were required
- [ ] `internal/zerog/inft/` changes if any were required
- [ ] `results/compute_test_results.md` — compute test evidence
- [ ] `results/storage_test_results.md` — storage test evidence
- [ ] `results/inft_test_results.md` — iNFT test evidence
- [ ] `.env.example` — if updated to document the new `ZG_SERVING_CONTRACT` key

**Never stage:** `.env`, any file containing private keys, credentials, or secrets.

## Commit Message Requirements

The commit message MUST:

### Describe WHAT Changed

- ABI update: `servingABIJSON` now uses `getAllServices`/`getService(address)` instead of the non-existent `getServiceCount`/`getService(uint256)`
- `listFromChain` rewritten to call `getAllServices(0, 100)` and decode the tuple response
- Serving contract address configured: `0xa79F4c8311FF93C06b8CfB403690cc987c93F91E` on Galileo testnet
- 0G Storage and iNFT tested (document outcomes)

### Describe WHY It Changed

- The pre-deployed contract uses a different API than what `broker.go` assumed
- Without this fix, `listFromChain` fails on every call, blocking provider discovery and inference

### Format

```text
fix: correct 0G serving contract ABI to use getAllServices/getService(address)

Replace getServiceCount()+getService(uint256) ABI — which don't exist on the
real pre-deployed contract — with getAllServices(uint256,uint256) and
getService(address). Rewrite listFromChain() to call getAllServices(0,100)
and decode the returned tuple slice.

Contract: 0xa79F4c8311FF93C06b8CfB403690cc987c93F91E on Galileo testnet (chain ID 16602).
Verified provider discovery, storage upload/download, and iNFT mint.

Part of: 003_EXECUTE/02_unblock_0g
```

## Ethical Requirements

**CRITICAL**: The following practices are explicitly prohibited:

- [ ] **NO** "Co-authored-by" tags for AI assistants
- [ ] **NO** advertisements or promotional content
- [ ] **NO** AI tool attribution in commit messages
- [ ] **NO** links to AI services or products

## Commit Process

1. **Review staged changes**

   ```bash
   cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference
   git status
   git diff --staged
   ```

2. **Confirm `.env` is not staged**

   ```bash
   git diff --staged --name-only | grep "^\.env$"
   # Must return nothing
   ```

3. **Create the project commit**

   ```bash
   camp commit -m "fix: correct 0G serving contract ABI to use getAllServices/getService(address)"
   ```

   `camp commit` adds everything automatically and handles the submodule reference.

4. **Push the project repo**

   ```bash
   cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference
   git push
   ```

5. **Push the campaign**

   ```bash
   camp push
   ```

6. **Verify the commit chain**

   ```bash
   cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference
   git log -1 --stat
   ```

## Definition of Done

- [ ] Pre-commit checklist verified
- [ ] `.env` confirmed NOT staged
- [ ] Commit message describes WHAT changed (ABI methods, `listFromChain` logic)
- [ ] Commit message describes WHY it changed (mismatch with real contract)
- [ ] No prohibited content in commit message
- [ ] Camp commit created and campaign pushed
- [ ] Project repo pushed to GitHub

---

**Commit Status:**

- Pre-commit checks: [ ] Pass / [ ] Fail
- Commit created: [ ] Yes / [ ] No
- Commit hash: ________________
