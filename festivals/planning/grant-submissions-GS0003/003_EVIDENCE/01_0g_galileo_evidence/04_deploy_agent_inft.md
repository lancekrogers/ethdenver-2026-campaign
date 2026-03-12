---
fest_type: task
fest_id: 01_deploy_agent_inft.md
fest_name: deploy-agent-inft
fest_parent: 01_0g_galileo_evidence
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-11T05:02:37.243436-06:00
fest_tracking: true
---

# Task: Deploy AgentINFT.sol to 0G Galileo

## Objective

Deploy the AgentINFT.sol smart contract to the 0G Galileo testnet (chain ID 16602) and record the deployed contract address for subsequent iNFT mint operations.

## Requirements

- [ ] Galileo wallet funded (05_fund_galileo_wallet completed)
- [ ] AgentINFT.sol compiles successfully with Foundry
- [ ] Deploy script (script/Deploy.s.sol) configured for Galileo
- [ ] Contract address recorded and verified on chainscan.io

## Implementation

### Step 1: Verify Foundry project compiles

```bash
forge build
```

### Step 2: Verify deploy script exists and is configured

Check that `script/Deploy.s.sol` targets the AgentINFT contract. If an `.env` is needed, ensure the following are set:

```bash
export PRIVATE_KEY=<your-private-key>
export RPC_URL=https://evmrpc-testnet.0g.ai
```

### Step 3: Deploy to 0G Galileo

```bash
forge script script/Deploy.s.sol \
  --rpc-url https://evmrpc-testnet.0g.ai \
  --broadcast \
  --private-key $PRIVATE_KEY
```

### Step 4: Record deployment details

From the Foundry broadcast output, capture:
- **Contract address**: The deployed AgentINFT proxy/implementation address
- **Deploy tx hash**: The transaction hash of the deployment
- **Block number**: The block the deployment was included in

### Step 5: Verify on block explorer

```bash
# Verify the contract exists
cast code <DEPLOYED_CONTRACT_ADDRESS> --rpc-url https://evmrpc-testnet.0g.ai
```

Open `https://chainscan.0g.ai/tx/<DEPLOY_TX_HASH>` to confirm the deployment transaction.

## Done When

- [ ] All requirements met
- [ ] AgentINFT.sol deployed to 0G Galileo with a confirmed contract address on chainscan.io and non-empty bytecode at the deployed address
