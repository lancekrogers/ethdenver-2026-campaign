---
fest_type: task
fest_id: 01_deploy_sepolia.md
fest_name: 01_deploy_sepolia
fest_parent: 04_deploy_integrate
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:25:34.24748-06:00
fest_tracking: true
---

# Task: Deploy Vault to Base Sepolia

## Objective

Deploy the ObeyVault contract to Base Sepolia testnet using the Foundry deploy script and record deployment artifacts.

## Requirements

- [ ] Set up .env with DEPLOYER_PRIVATE_KEY and AGENT_ADDRESS (DO NOT commit)
- [ ] Run `forge script script/DeployVault.s.sol:DeployVault --rpc-url https://sepolia.base.org --broadcast --verify`
- [ ] Record vault address in `workflow/design/synthesis/deployment.md`
- [ ] Verify contract on Base Sepolia Basescan

## Implementation

See implementation plan Task 14 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to create/modify:**
- `projects/contracts/.env` (secrets, NOT committed)
- `workflow/design/synthesis/deployment.md`

## Done When

- [ ] All requirements met
- [ ] Vault contract verified on Base Sepolia Basescan
- [ ] Vault address recorded in deployment.md
