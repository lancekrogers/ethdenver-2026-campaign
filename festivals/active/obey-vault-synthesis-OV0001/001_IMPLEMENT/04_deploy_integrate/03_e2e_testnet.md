---
fest_type: task
fest_id: 03_e2e_testnet.md
fest_name: 03_e2e_testnet
fest_parent: 04_deploy_integrate
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-13T19:25:34.285292-06:00
fest_updated: 2026-03-15T19:51:56.493424-06:00
fest_tracking: true
---


# Task: End-to-End Testnet Integration

## Objective

Run the full system end-to-end on Base Sepolia: fund the vault, run the agent, verify swaps execute on-chain, and confirm boundary enforcement works.

## Dependencies

- `05_deploy_sepolia` must be complete (vault deployed on Base Sepolia).
- Sequence 02 (agent runtime) must be complete (vault-agent binary builds and runs).
- You need the deployed vault address from `workflow/design/synthesis/deployment.md`.

## Context

- This is a **MANUAL** task — requires testnet ETH, private keys, and human verification on Basescan.
- Base Sepolia RPC: `https://sepolia.base.org`
- Token addresses on Base Sepolia:
  - USDC: `0x036CbD53842c5426634e7929541eC2318f3dCF7e`
  - WETH: `0x4200000000000000000000000000000000000006`

## Step 1: Fund the agent wallet

Get testnet ETH and USDC from the Base Sepolia faucet. The agent wallet needs enough ETH to pay for gas.

## Step 2: Approve WETH as a tradeable token on the vault

The guardian must approve WETH so the agent can swap into it:

```bash
cast send <VAULT_ADDRESS> "setApprovedToken(address,bool)" \
    0x4200000000000000000000000000000000000006 true \
    --rpc-url https://sepolia.base.org \
    --private-key $DEPLOYER_PRIVATE_KEY
```

Replace `<VAULT_ADDRESS>` with the deployed vault address from `workflow/design/synthesis/deployment.md`.

## Step 3: Deposit USDC into the vault

First, approve the vault to spend your USDC:

```bash
cast send 0x036CbD53842c5426634e7929541eC2318f3dCF7e "approve(address,uint256)" \
    <VAULT_ADDRESS> 100000000 \
    --rpc-url https://sepolia.base.org \
    --private-key $DEPLOYER_PRIVATE_KEY
```

Then deposit 100 USDC (100000000 = 100 * 10^6 decimals):

```bash
cast send <VAULT_ADDRESS> "deposit(uint256,address)" \
    100000000 <DEPLOYER_ADDRESS> \
    --rpc-url https://sepolia.base.org \
    --private-key $DEPLOYER_PRIVATE_KEY
```

Replace `<DEPLOYER_ADDRESS>` with the guardian/deployer wallet address.

## Step 4: Run the agent

```bash
cd projects/agent-defi
VAULT_ADDRESS=<deployed vault> \
AGENT_PRIVATE_KEY=<agent key> \
TOKEN_IN=0x036CbD53842c5426634e7929541eC2318f3dCF7e \
TOKEN_OUT=0x4200000000000000000000000000000000000006 \
ANTHROPIC_API_KEY=<key> \
just vault-agent
```

Watch the agent logs. It should analyze market conditions and attempt a swap.

## Step 5: Verify on-chain

Open Basescan and check the vault address for `SwapExecuted` events:

```
https://sepolia.basescan.org/address/<VAULT_ADDRESS>#events
```

You should see at least one `SwapExecuted` event log with the trade details.

You can also query directly:

```bash
cast logs --from-block latest --address <VAULT_ADDRESS> \
    --rpc-url https://sepolia.base.org
```

## Step 6: Test boundary enforcement

Attempt a swap that exceeds `maxSwapSize` to verify the vault reverts it. This can be done by:

1. Temporarily lowering `maxSwapSize` on the vault (as guardian):
```bash
cast send <VAULT_ADDRESS> "setMaxSwapSize(uint256)" 1 \
    --rpc-url https://sepolia.base.org \
    --private-key $DEPLOYER_PRIVATE_KEY
```

2. Running the agent again — any swap attempt should revert with the boundary error.

3. Restore `maxSwapSize` to the original value after verification.

## Verification Checklist

- [ ] Agent wallet funded with testnet ETH
- [ ] WETH approved as tradeable token on vault
- [ ] USDC deposited into vault (verify balance via `cast call <VAULT_ADDRESS> "totalAssets()" --rpc-url https://sepolia.base.org`)
- [ ] Agent ran successfully and produced swap logs
- [ ] At least one `SwapExecuted` event visible on Base Sepolia Basescan
- [ ] Boundary enforcement verified — oversized swap reverted

## Done When

- [ ] All verification checks pass
- [ ] At least one SwapExecuted event visible on Base Sepolia Basescan
- [ ] Boundary rejection verified (oversized swap reverted)