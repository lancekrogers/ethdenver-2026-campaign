---
fest_type: task
fest_id: 03_deploy_and_configure.md
fest_name: deploy and configure
fest_parent: 02_erc7857_inft_contract
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.760931-07:00
fest_updated: 2026-02-23T13:43:58.402728-07:00
fest_tracking: true
---


# Task: Deploy AgentINFT and Configure Environment

## Objective

Deploy the AgentINFT contract to the 0G Galileo testnet EVM and update `ZG_INFT_CONTRACT` and `ZG_ENCRYPTION_KEY` in the inference agent's `.env` so the Go minter can target the live contract.

## Requirements

- [ ] AgentINFT deployed to 0G Galileo testnet (chain ID 16602, RPC: `https://evmrpc-testnet.0g.ai`) with the deployed address recorded
- [ ] `ZG_INFT_CONTRACT` set to the deployed address in `projects/agent-inference/.env`
- [ ] `ZG_ENCRYPTION_KEY` set to a valid 32-byte hex key in `projects/agent-inference/.env`

## Implementation

### Step 1: Add deploy script

Update `projects/contracts/script/Deploy.s.sol` to include AgentINFT deployment alongside the existing Settlement and Reputation deployments:

```solidity
AgentINFT inft = new AgentINFT();
console.log("AgentINFT deployed at:", address(inft));
```

### Step 2: Add 0G RPC to foundry.toml

Add an RPC endpoint for 0G Galileo in `projects/contracts/foundry.toml`:

```toml
[rpc_endpoints]
zerog = "https://evmrpc-testnet.0g.ai"
```

### Step 3: Deploy

```bash
cd projects/contracts
forge script script/Deploy.s.sol --rpc-url zerog --broadcast --private-key $ZG_CHAIN_PRIVATE_KEY
```

Note: The `ZG_CHAIN_PRIVATE_KEY` is already set in `projects/agent-inference/.env`. Source it before running.

### Step 4: Configure the inference agent

In `projects/agent-inference/.env`:

```bash
ZG_INFT_CONTRACT=0x<deployed_address_from_step_3>
ZG_ENCRYPTION_KEY=<generate_32_random_hex_bytes>
```

Generate a 32-byte encryption key:

```bash
openssl rand -hex 32
```

### Step 5: Verify end-to-end

Run the inference agent's minter test (if a live test exists) or manually verify by checking the contract responds to `ownerOf(0)` via cast:

```bash
cast call $ZG_INFT_CONTRACT "ownerOf(uint256)" 0 --rpc-url https://evmrpc-testnet.0g.ai
```

## Done When

- [ ] All requirements met
- [ ] `cast call` to the deployed contract returns valid data, and `ZG_INFT_CONTRACT` + `ZG_ENCRYPTION_KEY` are non-empty in the inference agent `.env`