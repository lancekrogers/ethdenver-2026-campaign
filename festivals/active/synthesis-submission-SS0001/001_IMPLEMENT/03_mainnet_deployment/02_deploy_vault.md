---
fest_type: task
fest_id: 02_deploy_vault.md
fest_name: deploy vault
fest_parent: 03_mainnet_deployment
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-16T21:39:47.509246-06:00
fest_tracking: true
---

# Task: Deploy ObeyVault Contract to Base Mainnet

## Objective

Deploy the ObeyVault (ERC-4626) smart contract to Base mainnet using the existing Foundry deployment scripts.

## Requirements

- [ ] Deploy ObeyVault.sol to Base mainnet (chainId 8453)
- [ ] Record the deployed contract address
- [ ] Verify the contract on Basescan

## Implementation

1. Navigate to `projects/contracts/`
2. Review the existing deployment script used for Base Sepolia (adapt for mainnet)
3. Set environment variables:
   - `RPC_URL` = Base mainnet RPC endpoint
   - `PRIVATE_KEY` = Guardian wallet private key
   - `ETHERSCAN_API_KEY` = Basescan API key for verification
4. Deploy using Foundry:
   ```bash
   forge script script/DeployObeyVault.s.sol --rpc-url $RPC_URL --broadcast --verify
   ```
5. Constructor args: USDC address on Base mainnet (`0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913`), Uniswap SwapRouter02 address
6. Record the deployed address
7. Verify on Basescan if not auto-verified:
   ```bash
   forge verify-contract <address> ObeyVault --chain base
   ```

## Done When

- [ ] All requirements met
- [ ] ObeyVault deployed to Base mainnet with confirmed contract address
- [ ] Contract verified on Basescan (source code readable)
- [ ] Deployment TxID recorded
