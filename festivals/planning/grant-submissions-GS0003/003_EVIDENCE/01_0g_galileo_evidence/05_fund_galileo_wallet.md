---
fest_type: task
fest_id: 01_fund_galileo_wallet.md
fest_name: fund-galileo-wallet
fest_parent: 01_0g_galileo_evidence
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-11T05:02:37.225057-06:00
fest_tracking: true
---

# Task: Fund Galileo Wallet

## Objective

Fund the deployment wallet with testnet A0GI on 0G Galileo (chain ID 16602) via the official faucet so it has sufficient balance for contract deployment and transaction execution.

## Requirements

- [ ] Wallet address known and private key available in environment (PRIVATE_KEY)
- [ ] Wallet funded with sufficient A0GI for 4+ write transactions (deploy + 3 contract calls)
- [ ] Balance confirmed on chainscan.io

## Implementation

### Step 1: Verify wallet address

```bash
cast wallet address --private-key $PRIVATE_KEY
```

### Step 2: Check current balance

```bash
cast balance $(cast wallet address --private-key $PRIVATE_KEY) --rpc-url https://evmrpc-testnet.0g.ai
```

### Step 3: Request testnet tokens from faucet

1. Navigate to https://faucet.0g.ai
2. Connect wallet or paste wallet address
3. Request testnet A0GI tokens
4. Wait for faucet transaction to confirm

### Step 4: Verify funded balance

```bash
cast balance $(cast wallet address --private-key $PRIVATE_KEY) --rpc-url https://evmrpc-testnet.0g.ai
```

### Step 5: Verify on block explorer

Open `https://chainscan.0g.ai/address/<YOUR_WALLET_ADDRESS>` and confirm the faucet deposit transaction is visible.

## Done When

- [ ] All requirements met
- [ ] Wallet balance is non-zero on 0G Galileo (chain ID 16602) as confirmed by `cast balance` and chainscan.io
