---
fest_type: task
fest_id: 01_guardian_controls.md
fest_name: 03_guardian_controls
fest_parent: 01_vault_contract
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:22:36.008538-06:00
fest_tracking: true
---

# Task: Guardian Controls

## Objective

Implement guardian-only functions for managing agent assignment, token whitelist, swap limits, and pause/unpause, with full Foundry test coverage.

## Requirements

- [ ] Implement setAgent, setApprovedToken, setMaxSwapSize, setMaxDailyVolume, pause, unpause in ObeyVault.sol
- [ ] All functions restricted to onlyGuardian modifier
- [ ] Create `projects/contracts/test/ObeyVault.t.sol` with tests for all guardian functions
- [ ] Test that non-guardian callers are reverted

## Implementation

See implementation plan Task 3 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to modify/create:**
- `projects/contracts/src/ObeyVault.sol` (add guardian functions)
- `projects/contracts/test/ObeyVault.t.sol` (create test file)

## Done When

- [ ] All requirements met
- [ ] `cd projects/contracts && forge test --match-contract ObeyVaultTest -v` passes all 6 guardian tests
