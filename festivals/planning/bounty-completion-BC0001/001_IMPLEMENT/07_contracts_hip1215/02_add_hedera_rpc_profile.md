---
fest_type: task
fest_id: 02_add_hedera_rpc_profile.md
fest_name: add hedera rpc profile
fest_parent: 07_contracts_hip1215
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.845633-07:00
fest_tracking: true
---

# Task: Add Hedera RPC Profile to foundry.toml

## Objective

Add a Hedera testnet EVM RPC endpoint to `foundry.toml` so deploy scripts can use `--rpc-url hedera` instead of passing the URL manually.

## Requirements

- [ ] `projects/contracts/foundry.toml` has an `[rpc_endpoints]` section with `hedera = "https://testnet.hashio.io/api"`
- [ ] Deploy script works with `forge script script/Deploy.s.sol --rpc-url hedera --broadcast`

## Implementation

### Step 1: Update foundry.toml

In `projects/contracts/foundry.toml`, add:

```toml
[rpc_endpoints]
hedera = "https://testnet.hashio.io/api"
zerog = "https://evmrpc-testnet.0g.ai"
```

### Step 2: Verify

```bash
cd projects/contracts && forge script script/Deploy.s.sol --rpc-url hedera --broadcast --private-key $HEDERA_COORDINATOR_PRIVATE_KEY
```

## Done When

- [ ] All requirements met
- [ ] `forge script` with `--rpc-url hedera` connects successfully to Hedera testnet EVM