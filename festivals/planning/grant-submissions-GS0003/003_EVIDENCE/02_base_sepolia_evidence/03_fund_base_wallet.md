---
fest_type: task
fest_id: 01_fund_base_wallet.md
fest_name: fund-base-wallet
fest_parent: 02_base_sepolia_evidence
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-11T05:02:40.970143-06:00
fest_tracking: true
---

# Task: Fund Base Sepolia Wallet

## Objective

Fund the deployment wallet with testnet ETH and USDC on Base Sepolia (chain ID 84532) so it has sufficient balance for identity registration and Uniswap swap transactions.

## Requirements

- [ ] Wallet address known and private key available in environment (PRIVATE_KEY)
- [ ] Wallet funded with Base Sepolia ETH (for gas)
- [ ] Wallet funded with Base Sepolia USDC at `0x036CbD53842c5426634e7929541eC2318f3dCF7e` (for swap input)
- [ ] Both balances confirmed on sepolia.basescan.org

## Implementation

### Step 1: Verify wallet address

```bash
cast wallet address --private-key $PRIVATE_KEY
```

### Step 2: Check current ETH balance

```bash
cast balance $(cast wallet address --private-key $PRIVATE_KEY) --rpc-url https://sepolia.base.org
```

### Step 3: Request testnet ETH

1. Navigate to the Base Sepolia faucet (e.g., https://www.alchemy.com/faucets/base-sepolia or https://faucet.quicknode.com/base/sepolia)
2. Paste wallet address and request testnet ETH
3. Wait for faucet transaction to confirm

### Step 4: Obtain testnet USDC

Base Sepolia USDC contract: `0x036CbD53842c5426634e7929541eC2318f3dCF7e`

Options:
1. Use a USDC faucet if available (e.g., Circle's faucet at https://faucet.circle.com — select Base Sepolia)
2. Use a testnet bridge to move USDC from another testnet

### Step 5: Verify balances

```bash
# Check ETH balance
cast balance $(cast wallet address --private-key $PRIVATE_KEY) --rpc-url https://sepolia.base.org

# Check USDC balance
cast call 0x036CbD53842c5426634e7929541eC2318f3dCF7e \
  "balanceOf(address)(uint256)" \
  $(cast wallet address --private-key $PRIVATE_KEY) \
  --rpc-url https://sepolia.base.org
```

### Step 6: Verify on block explorer

Open `https://sepolia.basescan.org/address/<YOUR_WALLET_ADDRESS>` and confirm both ETH and USDC balances.

## Done When

- [ ] All requirements met
- [ ] Wallet has non-zero ETH balance and non-zero USDC balance on Base Sepolia (chain ID 84532) as confirmed by `cast` and sepolia.basescan.org
