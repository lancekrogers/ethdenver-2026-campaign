---
fest_type: task
fest_id: 01_vault_core.md
fest_name: 02_vault_core
fest_parent: 01_vault_contract
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:22:35.125438-06:00
fest_tracking: true
---

# Task: ObeyVault Core Storage and Constructor

## Objective

Create the ObeyVault.sol contract skeleton with storage layout, constructor, roles (guardian/agent), modifiers, events, and custom errors.

## Requirements

- [ ] Create `projects/contracts/src/ObeyVault.sol` extending ERC4626 and Pausable
- [ ] Define storage: guardian, agent, approvedTokens, maxSwapSize, maxDailyVolume, maxSlippageBps, dailyVolumeUsed, currentDay, _heldTokens (EnumerableSet), swapRouter, uniswapFactory
- [ ] Constructor accepts asset, agent, swapRouter, uniswapFactory, maxSwapSize, maxDailyVolume, maxSlippageBps
- [ ] Install Uniswap V3 Foundry dependencies and add remappings
- [ ] Define onlyGuardian and onlyAgent modifiers
- [ ] Define all events and custom errors

## Implementation

See implementation plan Task 2 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to create/modify:**
- `projects/contracts/src/ObeyVault.sol`
- `projects/contracts/remappings.txt`

## Done When

- [ ] All requirements met
- [ ] `cd projects/contracts && forge build` compiles the vault skeleton
