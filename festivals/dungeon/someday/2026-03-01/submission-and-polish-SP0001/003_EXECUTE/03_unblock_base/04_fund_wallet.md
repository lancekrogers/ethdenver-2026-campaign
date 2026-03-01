---
fest_type: task
fest_id: 04_fund_wallet.md
fest_name: fund_wallet
fest_parent: 03_unblock_base
fest_order: 4
fest_status: pending
fest_autonomy: high
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Fund Wallet

## Objective

Ensure the DeFi agent wallet has sufficient SepoliaETH for gas and test USDC for swap input on Base Sepolia, then verify the balances are visible through the agent's `GetBalance` function.

## Context

The agent wallet address is the same address set as `DEFI_BUILDER_CODE` in task 01. Two token types are needed:

- **SepoliaETH** — for gas on every transaction (approve, swap, registration)
- **Test USDC** — as the swap input token on Base Sepolia

Without these, every transaction will fail with "insufficient funds for gas" or "transfer amount exceeds balance".

## Implementation Steps

### 1. Identify the agent wallet address

The agent wallet address is printed at startup or can be derived from the private key in `projects/agent-defi/.env`. Confirm the address matches what is set in `DEFI_BUILDER_CODE`.

### 2. Fund with SepoliaETH

Use the Alchemy Base Sepolia faucet or Superchain faucet to send SepoliaETH to the agent wallet:
- https://www.alchemy.com/faucets/base-sepolia
- https://console.optimism.io/faucet

Minimum recommended: 0.05 SepoliaETH to cover multiple transactions during testing.

### 3. Fund with test USDC

Use the Circle USDC faucet for Base Sepolia to obtain test USDC:
- https://faucet.circle.com/

Select "Base Sepolia" and enter the agent wallet address. Circle's testnet USDC contract on Base Sepolia is the canonical token for DeFi testing.

Minimum recommended: 10 USDC to allow multiple swap attempts.

### 4. Verify balances

Confirm the balances are visible through the agent code:
```bash
cd projects/agent-defi && just run
```
Look for balance output at startup, or add a one-time balance check if `GetBalance` is not called at startup. The agent should log:
- ETH balance > 0
- USDC balance > 0

### 5. Record addresses

Document the following for use in task 05:
- Agent wallet address
- SepoliaETH funding transaction hash
- USDC faucet transaction hash
- USDC token contract address on Base Sepolia

## Done When

- Agent wallet has >= 0.05 SepoliaETH on Base Sepolia
- Agent wallet has >= 10 test USDC on Base Sepolia
- `GetBalance` (or startup logs) shows non-zero balances for both tokens
