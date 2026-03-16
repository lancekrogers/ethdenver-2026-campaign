---
fest_type: task
fest_id: 04_security_review.md
fest_name: 04_security_review
fest_parent: 04_deploy_integrate
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:25:34.304002-06:00
fest_tracking: true
---

# Task: Security Review

## Objective

Conduct a manual code review of ObeyVault.sol and the agent runtime to verify no critical vulnerabilities exist before mainnet deployment with real USDC.

## Dependencies

- `03_e2e_testnet` must be complete (confirms on-chain behavior matches expectations).
- Sequence 01 (vault contract) and Sequence 02 (agent runtime) must be complete.

## Context

- This review gates mainnet deployment. `01_deploy_mainnet` CANNOT proceed until this task passes.
- Real USDC will be at risk after mainnet deployment, so this review is critical.
- Key files to review:
  - `projects/contracts/src/ObeyVault.sol` — the vault smart contract
  - `projects/agent-defi/internal/vault/client.go` — Go client that calls the vault
  - `projects/agent-defi/internal/risk/manager.go` — risk boundaries enforced off-chain

## Step 1: Manual code review of ObeyVault.sol

Open `projects/contracts/src/ObeyVault.sol` and verify each of the following:

### 1a. Role assignment
- Only the `guardian` role can call `setAgent()` to change the agent address.
- There is no function that allows the agent to escalate its own privileges.
- The guardian is set in the constructor and cannot be changed (or can only be changed by the current guardian).

### 1b. No token extraction paths
- The agent can ONLY call `executeSwap()` — it cannot call `transfer()`, `withdraw()`, or `redeem()` on vault-held tokens.
- `executeSwap()` swaps tokens within the vault; tokens never leave the vault contract.
- Verify there is no fallback/receive function that could be exploited.

### 1c. Daily volume tracking
- `dailyVolume` resets on a calendar-day boundary (not manipulable by the agent).
- The agent cannot call any function to reset or modify `dailyVolume`.
- `executeSwap()` increments `dailyVolume` and checks against `maxDailyVolume` BEFORE executing.

### 1d. Pause mechanism
- When paused, `executeSwap()` reverts (uses `whenNotPaused` modifier or equivalent).
- Only the guardian can pause/unpause.
- Verify `deposit()` and `redeem()` behavior when paused (should they also pause?).

### 1e. TWAP oracle resistance
- The TWAP window is 30 minutes (1800 seconds).
- This is hardcoded or only changeable by the guardian.
- Short-term price manipulation (single block) should not affect the TWAP price.
- Check that the slippage check compares the swap execution price against the TWAP price.

### 1f. Reentrancy
- `executeSwap()` follows checks-effects-interactions pattern, or uses `nonReentrant` modifier.
- No external calls are made before state updates.

## Step 2: Run Foundry tests

```bash
cd projects/contracts
forge test -vvv
```

All tests must pass. Review the verbose output for any warnings or unexpected behavior.

## Step 3: Optional static analysis

If `slither` is installed:

```bash
cd projects/contracts
slither .
```

Review any findings. Not all findings are actionable — focus on High and Medium severity.

## Step 4: Document findings

Create `workflow/design/synthesis/security-review.md` with the following structure:

```markdown
# Security Review — ObeyVault

**Date**: YYYY-MM-DD
**Reviewer**: <name>
**Status**: PASS / FAIL

## Summary

<1-2 sentence summary>

## Findings

### Critical
- (none, or list)

### High
- (none, or list)

### Medium
- (none, or list)

### Low / Informational
- (list any minor observations)

## Checklist

- [ ] Role assignment: guardian-only agent changes
- [ ] No token extraction: agent can only swap
- [ ] Daily volume: cannot be bypassed
- [ ] Pause: stops all agent operations
- [ ] TWAP: 30-min window, manipulation-resistant
- [ ] No reentrancy in executeSwap
- [ ] All forge tests pass

## Recommendation

<Deploy to mainnet / Do not deploy until X is fixed>
```

## Verification Checklist

- [ ] All 6 review areas (1a-1f) examined and documented
- [ ] `forge test -vvv` passes all tests
- [ ] `workflow/design/synthesis/security-review.md` created with findings
- [ ] No critical vulnerabilities found (or all critical findings fixed before proceeding)

## Done When

- [ ] All verification checks pass
- [ ] Security review document written with findings (or clean bill)
- [ ] No critical vulnerabilities identified (or all critical findings fixed)
