---
fest_type: task
fest_id: 01_execute_uniswap_swap.md
fest_name: execute-uniswap-swap
fest_parent: 02_base_sepolia_evidence
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-11T05:02:41.005693-06:00
fest_tracking: true
---

# Task: Execute Uniswap V3 Swap on Base Sepolia

## Objective

Execute a Uniswap V3 swap write transaction on Base Sepolia (chain ID 84532) via agent-defi to generate verifiable on-chain evidence of DEX swap integration.

## Requirements

- [ ] Base Sepolia wallet funded with ETH and USDC (03_fund_base_wallet completed)
- [ ] agent-defi built and configured for Base Sepolia with Uniswap V3 SwapRouter address
- [ ] USDC approved for SwapRouter spending
- [ ] Transaction hash recorded and verified on sepolia.basescan.org

## Implementation

### Step 1: Verify USDC balance

```bash
cast call 0x036CbD53842c5426634e7929541eC2318f3dCF7e \
  "balanceOf(address)(uint256)" \
  $(cast wallet address --private-key $PRIVATE_KEY) \
  --rpc-url https://sepolia.base.org
```

### Step 2: Approve USDC for SwapRouter

Approve the Uniswap V3 SwapRouter to spend USDC:

```bash
cast send 0x036CbD53842c5426634e7929541eC2318f3dCF7e \
  "approve(address,uint256)" \
  <SWAP_ROUTER_ADDRESS> \
  1000000 \
  --rpc-url https://sepolia.base.org \
  --private-key $PRIVATE_KEY
```

Note: 1000000 = 1 USDC (6 decimals). Replace `<SWAP_ROUTER_ADDRESS>` with the Base Sepolia Uniswap V3 SwapRouter address.

### Step 3: Execute the swap

Using agent-defi CLI:

```bash
# Execute Uniswap V3 swap on Base Sepolia via agent-defi
agent-defi swap \
  --chain base-sepolia \
  --rpc-url https://sepolia.base.org \
  --token-in 0x036CbD53842c5426634e7929541eC2318f3dCF7e \
  --token-out 0x4200000000000000000000000000000000000006 \
  --amount 1000000 \
  --private-key $PRIVATE_KEY
```

If calling directly via cast (fallback), use the SwapRouter's `exactInputSingle`:

```bash
cast send <SWAP_ROUTER_ADDRESS> \
  "exactInputSingle((address,address,uint24,address,uint256,uint256,uint256,uint160))" \
  "(0x036CbD53842c5426634e7929541eC2318f3dCF7e,0x4200000000000000000000000000000000000006,3000,$(cast wallet address --private-key $PRIVATE_KEY),1000000,0,0,0)" \
  --rpc-url https://sepolia.base.org \
  --private-key $PRIVATE_KEY
```

### Step 4: Record transaction details

From the transaction output, capture:
- **Tx hash**: The transaction hash
- **Block number**: The block the transaction was included in
- **Amount swapped**: Input and output token amounts

### Step 5: Verify on block explorer

Open `https://sepolia.basescan.org/tx/<TX_HASH>` and confirm:
- Transaction status is "Success"
- The contract interaction is with the Uniswap V3 SwapRouter
- Token transfer events show USDC in and WETH out

## Done When

- [ ] All requirements met
- [ ] Uniswap V3 swap transaction confirmed on sepolia.basescan.org with status "Success", showing token swap events
