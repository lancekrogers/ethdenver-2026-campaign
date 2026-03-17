---
fest_type: task
fest_id: 01_source_mainnet_funds.md
fest_name: source mainnet funds
fest_parent: 03_mainnet_deployment
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-16T21:39:47.508753-06:00
fest_updated: 2026-03-17T00:14:37.981634-06:00
fest_tracking: true
---



# Task: Source USDC and ETH on Base Mainnet

## Objective

Acquire USDC and ETH on Base mainnet to fund the ObeyVault deployment and live trading demo.

## Requirements

- [ ] Obtain at least 100 USDC on Base mainnet for vault deposit
- [ ] Obtain sufficient ETH on Base mainnet for gas (deployment + 5-10 transactions)
- [ ] Funds available in the guardian wallet

## Implementation

1. Determine the guardian wallet address that will deploy and fund the vault
2. Check current balances on Base mainnet (chainId 8453)
3. If funds are needed, options:
   - Bridge USDC from Ethereum mainnet via Base Bridge (https://bridge.base.org)
   - Bridge from another L2 via a cross-chain bridge (Across, Stargate, etc.)
   - Purchase directly on Base via an exchange that supports Base withdrawals
   - Transfer from another wallet that already holds Base USDC
4. For ETH gas: Bridge ETH to Base or use existing Base ETH balance
5. Budget: ~100 USDC for vault + ~0.01 ETH for gas (Base L2 gas is cheap)
6. Verify balances on Basescan after funding

## Done When

- [ ] All requirements met
- [ ] Guardian wallet has >= 100 USDC on Base mainnet
- [ ] Guardian wallet has sufficient ETH for gas on Base mainnet
- [ ] Balances confirmed on Basescan