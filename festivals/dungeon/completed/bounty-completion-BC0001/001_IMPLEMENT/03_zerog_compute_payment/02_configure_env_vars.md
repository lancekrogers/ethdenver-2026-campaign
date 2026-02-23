---
fest_type: task
fest_id: 02_configure_env_vars.md
fest_name: configure env vars
fest_parent: 03_zerog_compute_payment
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.77792-07:00
fest_updated: 2026-02-23T13:48:03.602878-07:00
fest_tracking: true
---


# Task: Configure Missing 0G Environment Variables

## Objective

Fill in the empty environment variables in `projects/agent-inference/.env` that are required for 0G Storage node uploads and compute endpoint connectivity.

## Requirements

- [ ] `ZG_STORAGE_NODE_ENDPOINT` is set to a valid 0G storage node URL
- [ ] `ZG_COMPUTE_ENDPOINT` is set (or confirmed unnecessary if broker uses on-chain provider discovery)
- [ ] `.env.example` is updated to document all required 0G variables with comments explaining what each one is

## Implementation

### Step 1: Research current 0G testnet endpoints

Check 0G documentation for current Galileo testnet storage node endpoints. As of early 2026, common endpoints include:

- Storage node: `https://storage-testnet.0g.ai` or similar
- The DA and compute contracts are already configured with correct addresses

### Step 2: Update .env

In `projects/agent-inference/.env`, fill in:

```bash
ZG_STORAGE_NODE_ENDPOINT=https://storage-testnet.0g.ai
# ZG_COMPUTE_ENDPOINT may not be needed — broker discovers providers on-chain
# If needed: ZG_COMPUTE_ENDPOINT=https://compute-testnet.0g.ai
```

### Step 3: Update .env.example

In `projects/agent-inference/.env.example`, add documentation comments for every `ZG_*` variable:

```bash
# 0G Chain
ZG_CHAIN_RPC=https://evmrpc-testnet.0g.ai
ZG_CHAIN_PRIVATE_KEY=  # ECDSA private key for 0G chain transactions

# 0G Compute
ZG_COMPUTE_SERVING_CONTRACT=0xa79F4c8311FF93C06b8CfB403690cc987c93F91E

# 0G Storage
ZG_STORAGE_NODE_ENDPOINT=  # HTTP endpoint of a 0G storage node
ZG_FLOW_CONTRACT=0x22E03a6A89B950F1c82ec5e74F8eCa321a105296

# 0G DA
ZG_DA_ENTRANCE_CONTRACT=0xE75A073dA5bb7b0eC622170Fd268f35E675a957B

# iNFT
ZG_INFT_CONTRACT=  # Deployed AgentINFT contract address (set after seq 02)
ZG_ENCRYPTION_KEY=  # 32-byte hex key for AES-256-GCM metadata encryption
```

### Step 4: Verify storage node is reachable

```bash
curl -s https://storage-testnet.0g.ai/health | head -5
```

If the endpoint doesn't respond, search 0G docs or Discord for the current testnet storage node URL.

## Done When

- [ ] All requirements met
- [ ] All `ZG_*` variables in `.env` are non-empty and `.env.example` documents each one with a comment