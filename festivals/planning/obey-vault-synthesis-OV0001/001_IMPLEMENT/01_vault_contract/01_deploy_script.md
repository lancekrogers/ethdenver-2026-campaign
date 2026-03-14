---
fest_type: task
fest_id: 01_deploy_script.md
fest_name: 07_deploy_script
fest_parent: 01_vault_contract
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:22:39.606408-06:00
fest_tracking: true
---

# Task: Foundry Deploy Script

## Objective

Create a Foundry deployment script that deploys ObeyVault to both Base Sepolia testnet and Base mainnet, with correct USDC, SwapRouter, and Factory addresses for each network.

## Requirements

- [ ] Create `projects/contracts/script/DeployVault.s.sol`
- [ ] Define constants for Base Sepolia and Base mainnet (USDC, SwapRouter02, UniswapFactory addresses)
- [ ] Read DEPLOYER_PRIVATE_KEY and AGENT_ADDRESS from environment
- [ ] Support MAINNET=true flag to switch between Sepolia and mainnet addresses
- [ ] Deploy vault with default parameters (1000 USDC max swap, 10000 USDC daily volume, 1% slippage)
- [ ] Auto-approve WETH token after deployment
- [ ] Log deployed addresses

## Implementation

See implementation plan Task 7 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to create:**
- `projects/contracts/script/DeployVault.s.sol`

## Done When

- [ ] All requirements met
- [ ] `cd projects/contracts && forge build` compiles the deploy script without errors
