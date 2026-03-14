---
fest_type: task
fest_id: 01_deposit_redeem.md
fest_name: 04_deposit_redeem
fest_parent: 01_vault_contract
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:22:36.954842-06:00
fest_tracking: true
---

# Task: ERC-4626 Deposit and Redeem

## Objective

Override ERC-4626 deposit/redeem with pause guards and implement totalAssets (initially USDC balance only, TWAP pricing added in Task 6).

## Requirements

- [ ] Override totalAssets() to return USDC balance of the vault
- [ ] Override deposit() with whenNotPaused modifier
- [ ] Override redeem() with whenNotPaused modifier
- [ ] Add tests: deposit receives shares, redeem returns assets, deposit-when-paused reverts

## Implementation

See implementation plan Task 4 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to modify:**
- `projects/contracts/src/ObeyVault.sol` (add overrides)
- `projects/contracts/test/ObeyVault.t.sol` (add deposit/redeem tests)

## Done When

- [ ] All requirements met
- [ ] `cd projects/contracts && forge test --match-contract ObeyVaultTest -v` passes all tests including deposit/redeem
