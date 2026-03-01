---
fest_type: task
fest_id: 01_set_serving_contract.md
fest_name: set_serving_contract
fest_parent: 02_unblock_0g
fest_order: 1
fest_status: pending
fest_autonomy: high
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Set Serving Contract Address

**Task Number:** 01 | **Sequence:** 02_unblock_0g | **Autonomy:** high

## Objective

Set the `ZG_SERVING_CONTRACT` environment variable in `projects/agent-inference/.env` to point at the pre-deployed serving contract on Galileo testnet. This is a configuration-only change — no code modifications required.

## Requirements

- [ ] The `.env` file at `projects/agent-inference/.env` contains `ZG_SERVING_CONTRACT=0xa79F4c8311FF93C06b8CfB403690cc987c93F91E`
- [ ] The contract address is on Galileo testnet (chain ID 16602)
- [ ] No other env vars are accidentally overwritten or removed
- [ ] `.env` is in `.gitignore` (secrets must not be committed)

## Implementation

### Step 1: Locate the .env file

```bash
ls /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference/.env
```

If it does not exist, check for `.env.example` to use as a template:

```bash
ls /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference/.env*
```

### Step 2: Set the contract address

Add or update the `ZG_SERVING_CONTRACT` line in `.env`:

```bash
# In projects/agent-inference/.env
ZG_SERVING_CONTRACT=0xa79F4c8311FF93C06b8CfB403690cc987c93F91E
ZG_CHAIN_ID=16602
ZG_RPC_URL=https://evmrpc-testnet.0g.ai
```

If the file does not exist, create it. If it exists, add the line without removing existing entries.

### Step 3: Verify .gitignore

```bash
grep -n "\.env" /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference/.gitignore
```

The `.env` file must appear in `.gitignore`. If it does not, add it:

```
.env
```

### Step 4: Verify the agent reads the variable

Check where `ServingContractAddress` is populated in the codebase:

```bash
grep -r "ServingContractAddress\|ZG_SERVING_CONTRACT" \
  /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference/
```

Confirm the env var name matches what the config loader expects. If the config key differs, use the correct name.

### Step 5: Verify the build still passes

```bash
cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference && just build
```

## Done When

- [ ] `ZG_SERVING_CONTRACT=0xa79F4c8311FF93C06b8CfB403690cc987c93F91E` is present in `.env`
- [ ] `.env` is confirmed in `.gitignore`
- [ ] `just build` passes without errors
- [ ] No existing env vars were removed or corrupted
