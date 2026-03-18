---
fest_type: task
fest_id: 03_configure_vault.md
fest_name: configure vault
fest_parent: 03_mainnet_deployment
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-16T21:39:47.509559-06:00
fest_updated: 2026-03-17T00:16:17.391953-06:00
fest_tracking: true
---


# Task: Configure ObeyVault on Base Mainnet

## Objective

Configure the deployed ObeyVault with agent address, token whitelist, boundary parameters, and deposit USDC.

## Requirements

- [ ] Set the agent address authorized to call executeSwap()
- [ ] Add WETH to the token whitelist
- [ ] Set boundary parameters (maxSwapSize, maxDailyVolume, maxSlippageBps)
- [ ] Deposit USDC into the vault

## Implementation

1. Using the deployed vault address from task 02, call configuration functions:
2. Set agent address:
   ```
   vault.setAgent(<agent_wallet_address>)
   ```
3. Approve WETH as tradeable token:
   ```
   vault.addWhitelistedToken(<WETH_address_on_base>)
   ```
   - WETH on Base mainnet: `0x4200000000000000000000000000000000000006`
4. Set boundary parameters:
   ```
   vault.setMaxSwapSize(25e6)       // 25 USDC max per swap
   vault.setMaxDailyVolume(100e6)   // 100 USDC daily cap
   vault.setMaxSlippageBps(100)     // 1% max slippage
   ```
5. Approve USDC spending and deposit:
   ```
   usdc.approve(vault, 100e6)
   vault.deposit(100e6, guardian)
   ```
6. Verify configuration by reading vault state on Basescan

## Done When

- [ ] All requirements met
- [ ] Agent address set and verified
- [ ] WETH whitelisted
- [ ] Boundaries configured (maxSwapSize=25 USDC, maxDailyVolume=100 USDC, maxSlippage=1%)
- [ ] 100 USDC deposited into vault
- [ ] All config TxIDs recorded