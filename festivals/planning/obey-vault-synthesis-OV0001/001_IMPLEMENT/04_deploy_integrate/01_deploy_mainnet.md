---
fest_type: task
fest_id: 01_deploy_mainnet.md
fest_name: 05_deploy_mainnet
fest_parent: 04_deploy_integrate
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:25:34.323512-06:00
fest_tracking: true
---

# Task: Deploy to Base Mainnet

## Objective

Deploy the ObeyVault contract to Base mainnet with real USDC, deposit initial funds, and start the agent in production.

## Requirements

- [ ] Deploy vault to Base mainnet: `MAINNET=true forge script script/DeployVault.s.sol:DeployVault --rpc-url https://mainnet.base.org --broadcast --verify`
- [ ] Record mainnet vault address in `workflow/design/synthesis/deployment.md`
- [ ] Deposit 100 USDC into the vault
- [ ] Update agent env to point at mainnet RPC and vault address
- [ ] Run agent against mainnet and verify first trade

## Implementation

See implementation plan Task 18 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to modify:**
- `workflow/design/synthesis/deployment.md` (add mainnet addresses)

## Done When

- [ ] All requirements met
- [ ] Vault deployed and verified on Base mainnet Basescan
- [ ] Initial USDC deposited
- [ ] Agent running against mainnet vault
