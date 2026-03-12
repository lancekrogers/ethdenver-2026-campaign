---
fest_type: task
fest_id: 01_execute_inft_mint.md
fest_name: execute-inft-mint
fest_parent: 01_0g_galileo_evidence
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-11T05:02:37.294941-06:00
fest_tracking: true
---

# Task: Execute iNFT Mint on 0G Galileo

## Objective

Execute a `mint()` write transaction on the deployed AgentINFT contract on 0G Galileo testnet to generate verifiable on-chain evidence of iNFT minting capability.

## Requirements

- [ ] Galileo wallet funded (05_fund_galileo_wallet completed)
- [ ] AgentINFT contract deployed (04_deploy_agent_inft completed) with known contract address
- [ ] Transaction hash and token ID recorded and verified on chainscan.io

## Implementation

### Step 1: Verify the AgentINFT contract is deployed

```bash
cast code <AGENT_INFT_CONTRACT_ADDRESS> --rpc-url https://evmrpc-testnet.0g.ai
```

Ensure the output is non-empty bytecode.

### Step 2: Execute the mint transaction

```bash
cast send <AGENT_INFT_CONTRACT_ADDRESS> \
  "mint(address,string)" \
  $(cast wallet address --private-key $PRIVATE_KEY) \
  "ipfs://obey-agent-economy-inft-metadata" \
  --rpc-url https://evmrpc-testnet.0g.ai \
  --private-key $PRIVATE_KEY
```

If the mint function signature differs, check the ABI:

```bash
cast abi-decode --help
# Or inspect the contract ABI from the Foundry artifacts
```

### Step 3: Record transaction details

From the transaction output, capture:
- **Tx hash**: The transaction hash
- **Token ID**: The minted token ID (parse from Transfer event logs)
- **Block number**: The block the transaction was included in

To extract the token ID from logs:

```bash
cast receipt <TX_HASH> --rpc-url https://evmrpc-testnet.0g.ai | grep -A5 "logs"
```

### Step 4: Verify on block explorer

Open `https://chainscan.0g.ai/tx/<TX_HASH>` and confirm:
- Transaction status is "Success"
- The `to` address is the AgentINFT contract
- Transfer event shows the minted token ID

## Done When

- [ ] All requirements met
- [ ] iNFT `mint()` transaction confirmed on chainscan.io with status "Success", token ID recorded from event logs
