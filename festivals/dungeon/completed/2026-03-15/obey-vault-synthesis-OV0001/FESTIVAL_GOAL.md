---
fest_type: festival
fest_id: OV0001
fest_name: obey-vault-synthesis
fest_status: completed
fest_created: 2026-03-13T19:18:37.306681-06:00
fest_updated: 2026-03-15T20:15:42.554547-06:00
fest_tracking: true
---




# obey-vault-synthesis

**Status:** Planned | **Created:** 2026-03-13T19:18:37-06:00

## Festival Objective

**Primary Goal:** Build and deploy an ERC-4626 vault on Base where an AI agent trades via Uniswap V3 within human-defined spending boundaries, for the Synthesis hackathon submission.

**Vision:** A working on-chain vault custody system where depositors provide USDC, receive share tokens, and an LLM-driven agent trades autonomously within guardian-enforced constraints. Every trade is auditable on-chain via SwapExecuted events. The human never loses control — the vault enforces the rules, not the agent's good behavior.

## Success Criteria

### Functional Success

- [ ] Vault contract deployed on Base mainnet with deposit/redeem/swap working
- [ ] Agent executes at least 2-3 autonomous swaps through the vault on-chain
- [ ] Boundary enforcement proven — rejected swap when limits exceeded
- [ ] ERC-8004 agent identity registered via Synthesis API
- [ ] Observer CLI displays vault state, NAV, and trade history

### Quality Success

- [ ] Vault passes security review — no token extraction paths, no role bypass
- [ ] All Foundry tests pass with >90% coverage on boundary enforcement
- [ ] Go agent tests pass for strategy, risk manager, and vault client
- [ ] On-chain audit trail visible on Basescan (SwapExecuted events with reason)

## Progress Tracking

### Phase Completion

- [ ] 001_IMPLEMENT: Build vault contract, Go agent, identity, deploy, and submit

## Complete When

- [ ] All phases completed
- [ ] Vault contract verified on Basescan (Base mainnet)
- [ ] ERC-8004 identity minted on Base
- [ ] Demo recorded or ready for live walkthrough
- [ ] Submission metadata prepared with conversation logs and on-chain artifacts