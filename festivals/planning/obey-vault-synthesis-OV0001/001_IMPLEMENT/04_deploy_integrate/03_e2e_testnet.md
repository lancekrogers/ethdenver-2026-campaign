---
fest_type: task
fest_id: 01_e2e_testnet.md
fest_name: 03_e2e_testnet
fest_parent: 04_deploy_integrate
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:25:34.285292-06:00
fest_tracking: true
---

# Task: End-to-End Testnet Integration

## Objective

Run the full system end-to-end on Base Sepolia: fund the vault, run the agent, verify swaps execute on-chain, and confirm boundary enforcement works.

## Requirements

- [ ] Fund agent wallet with testnet ETH and USDC from Base Sepolia faucet
- [ ] Deposit USDC into the vault
- [ ] Approve WETH token on vault via cast or guardian script
- [ ] Run vault-agent binary pointing at Sepolia vault
- [ ] Verify SwapExecuted events appear on Basescan
- [ ] Test boundary enforcement: attempt a swap exceeding maxSwapSize, verify it reverts

## Implementation

See implementation plan Task 16 (`workflow/design/synthesis/01-implementation-plan.md`).

Run the agent:
```bash
cd projects/agent-defi
VAULT_ADDRESS=<deployed> AGENT_PRIVATE_KEY=<key> TOKEN_IN=0x036CbD53842c5426634e7929541eC2318f3dCF7e TOKEN_OUT=0x4200000000000000000000000000000000000006 ANTHROPIC_API_KEY=<key> just vault-agent
```

## Done When

- [ ] All requirements met
- [ ] At least one SwapExecuted event visible on Base Sepolia Basescan
- [ ] Boundary rejection verified (oversized swap reverted)
