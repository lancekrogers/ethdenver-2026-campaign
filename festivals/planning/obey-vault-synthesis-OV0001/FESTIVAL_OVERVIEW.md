# Festival Overview: obey-vault-synthesis

## Problem Statement

**Current State:** AI agents that move money on behalf of humans have no transparent, enforceable way to scope what they're allowed to spend. The human can't verify the agent did what it was asked, and there's no on-chain settlement with auditable history.

**Desired State:** An ERC-4626 vault on Base where a guardian defines spending boundaries (token whitelist, swap size limits, daily volume cap, slippage limits) and an AI agent trades via Uniswap V3 within those constraints. Every trade emits an on-chain event with rationale. Depositors can exit at NAV anytime.

**Why This Matters:** This is our submission to the Synthesis hackathon (Mar 13-22, 2026), Track: "Agents that Pay". It demonstrates trust through constraint — the agent is powerful but the human never loses control.

## Scope

### In Scope

- ERC-4626 vault contract with agent swap constraints (Solidity/Foundry)
- Guardian controls: token whitelist, max swap size, daily volume cap, pause
- Uniswap V3 SwapRouter02 integration for on-chain swaps
- NAV calculation via Uniswap V3 TWAP oracle (30-min window)
- Go agent runtime with LLM strategy (Claude API), risk manager, vault client
- ERC-8004 identity registration via Synthesis API
- Observer CLI for vault state and trade history
- Deployment to Base Sepolia (testnet) and Base mainnet

### Out of Scope

- Fancy UI (CLI is sufficient)
- Complex quant strategy (simple momentum/mean-reversion)
- Multiple agents (one agent, one vault)
- Cross-chain anything (Base only)
- Custom oracle infrastructure (Uniswap TWAP is sufficient)
- Token launch / tokenomics

## Planned Phases

### 001_IMPLEMENT

Build all four components (vault contract, Go agent, ERC-8004 identity, observer), deploy to testnet and mainnet, prepare submission. Five sequences covering: vault contract, Go agent runtime, identity registration, deployment/integration, and submission.

## Notes

- Design spec: `workflow/design/synthesis/00-design-spec.md`
- Implementation plan: `workflow/design/synthesis/01-implementation-plan.md`
- Hackathon deadline: Mar 22, 2026 (11:59pm PST)
- Reuses patterns from existing `projects/agent-defi` codebase (TradeExecutor, Strategy, ethutil)
