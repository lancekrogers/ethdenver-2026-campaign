---
fest_type: task
fest_id: 01_deploy_sepolia.md
fest_name: 01_deploy_sepolia
fest_parent: 04_deploy_integrate
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-13T19:25:34.24748-06:00
fest_updated: 2026-03-15T19:51:26.480596-06:00
fest_tracking: true
---


# Task: Deploy Vault to Base Sepolia

## Objective

Deploy the ObeyVault contract to Base Sepolia testnet using the Foundry deploy script and record deployment artifacts.

## Dependencies

- Sequence 01 (vault contract and deploy script) must be complete.
- You need testnet ETH on Base Sepolia to pay for gas. Use the Base Sepolia faucet.

## Context

- This is a **MANUAL** task — it requires real private keys and testnet ETH.
- The deploy script is at `projects/contracts/script/DeployVault.s.sol`.
- Base Sepolia RPC: `https://sepolia.base.org`
- Base Sepolia explorer: `https://sepolia.basescan.org`

## Step 1: Set up environment variables

Create `projects/contracts/.env` with the following (DO NOT commit this file):

```bash
DEPLOYER_PRIVATE_KEY=<guardian private key>
AGENT_ADDRESS=<agent wallet address>
```

Ensure `.env` is in `.gitignore`. Verify:

```bash
grep -q ".env" projects/contracts/.gitignore || echo ".env" >> projects/contracts/.gitignore
```

## Step 2: Deploy the contract

```bash
cd projects/contracts
source .env
forge script script/DeployVault.s.sol:DeployVault \
    --rpc-url https://sepolia.base.org \
    --broadcast \
    --verify
```

The output will include the deployed vault address. Copy it.

## Step 3: Record the vault address

Add the deployed vault address to `workflow/design/synthesis/deployment.md` under a "Base Sepolia" section:

```markdown
## Base Sepolia Deployment

- **Vault Address**: `0x<DEPLOYED_ADDRESS>`
- **Deploy TX**: `0x<TX_HASH>`
- **Deployer**: `0x<DEPLOYER_ADDRESS>`
- **Agent**: `0x<AGENT_ADDRESS>`
- **Date**: YYYY-MM-DD
```

## Step 4: Verify contract on Basescan

If `--verify` succeeded during deploy, the contract is already verified. Otherwise manually verify:

```bash
forge verify-contract <VAULT_ADDRESS> src/ObeyVault.sol:ObeyVault \
    --chain-id 84532 \
    --etherscan-api-key $BASESCAN_API_KEY
```

Confirm at: `https://sepolia.basescan.org/address/<VAULT_ADDRESS>#code`

## Verification Checklist

- [ ] `.env` exists at `projects/contracts/.env` and is NOT tracked by git
- [ ] `forge script` completed without errors
- [ ] Vault address recorded in `workflow/design/synthesis/deployment.md`
- [ ] Contract shows as verified on Base Sepolia Basescan (green checkmark on Code tab)

## Done When

- [ ] All verification checks pass
- [ ] Vault contract verified on Base Sepolia Basescan
- [ ] Vault address recorded in deployment.md