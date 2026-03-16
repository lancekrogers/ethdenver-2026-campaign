---
fest_type: task
fest_id: 05_deploy_mainnet.md
fest_name: 05_deploy_mainnet
fest_parent: 04_deploy_integrate
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:25:34.323512-06:00
fest_tracking: true
---

# Task: Deploy to Base Mainnet

## Objective

Deploy the ObeyVault contract to Base mainnet with real USDC, deposit initial funds, and start the agent in production.

## Dependencies

- `02_security_review` MUST be complete and approved (status: PASS) before proceeding.
- All testnet E2E tests (`03_e2e_testnet`) must have passed.
- You need real ETH on Base mainnet for gas and real USDC for the initial deposit.

## Context

- This task uses **real USDC**. Security review MUST pass first.
- Base Mainnet RPC: `https://mainnet.base.org`
- Base Mainnet explorer: `https://basescan.org`
- Mainnet USDC contract: `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913`
- USDC has 6 decimals: 100 USDC = `100000000`

## Step 1: Deploy vault to Base mainnet

```bash
cd projects/contracts
source .env
MAINNET=true forge script script/DeployVault.s.sol:DeployVault \
    --rpc-url https://mainnet.base.org \
    --broadcast \
    --verify
```

Copy the deployed vault address from the output.

## Step 2: Record mainnet vault address

Add the mainnet deployment to `workflow/design/synthesis/deployment.md`:

```markdown
## Base Mainnet Deployment

- **Vault Address**: `0x<MAINNET_VAULT_ADDRESS>`
- **Deploy TX**: `0x<TX_HASH>`
- **Deployer**: `0x<DEPLOYER_ADDRESS>`
- **Agent**: `0x<AGENT_ADDRESS>`
- **Date**: YYYY-MM-DD
- **Security Review**: PASS (link to security-review.md)
```

## Step 3: Deposit initial USDC (100 USDC)

First, approve the vault to spend your USDC:

```bash
cast send 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913 "approve(address,uint256)" \
    <VAULT_ADDRESS> 100000000 \
    --rpc-url https://mainnet.base.org \
    --private-key $DEPLOYER_PRIVATE_KEY
```

Then deposit:

```bash
cast send <VAULT_ADDRESS> "deposit(uint256,address)" \
    100000000 <DEPLOYER_ADDRESS> \
    --rpc-url https://mainnet.base.org \
    --private-key $DEPLOYER_PRIVATE_KEY
```

Verify the deposit:

```bash
cast call <VAULT_ADDRESS> "totalAssets()" --rpc-url https://mainnet.base.org
```

Expected output: `100000000` (hex-encoded).

## Step 4: Update agent environment and run

Update the agent's `.env` or environment variables to point at mainnet:

```bash
cd projects/agent-defi
VAULT_ADDRESS=<mainnet vault address> \
AGENT_PRIVATE_KEY=<agent key> \
RPC_URL=https://mainnet.base.org \
TOKEN_IN=0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913 \
TOKEN_OUT=0x4200000000000000000000000000000000000006 \
ANTHROPIC_API_KEY=<key> \
just vault-agent
```

Monitor the agent logs. Verify the first trade executes successfully by checking Basescan:

```
https://basescan.org/address/<VAULT_ADDRESS>#events
```

## Verification Checklist

- [ ] Security review status is PASS in `workflow/design/synthesis/security-review.md`
- [ ] Vault deployed and verified on Base mainnet Basescan
- [ ] Vault address recorded in `workflow/design/synthesis/deployment.md`
- [ ] 100 USDC deposited (verify via `totalAssets()` call)
- [ ] Agent running against mainnet vault
- [ ] First trade visible on Basescan

## Done When

- [ ] All verification checks pass
- [ ] Vault deployed and verified on Base mainnet Basescan
- [ ] Initial USDC deposited
- [ ] Agent running against mainnet vault
