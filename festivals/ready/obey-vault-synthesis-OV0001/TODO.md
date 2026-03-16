# Festival TODO - obey-vault-synthesis

**Goal**: Build and deploy OBEY Vault for Synthesis hackathon — ERC-4626 vault on Base with agent swap constraints
**Status**: Planning

---

## Festival Progress Overview

### Phase Completion Status

- [ ] 001_IMPLEMENT: Build vault, agent, identity, deploy, submit

### Current Work Status

```
Active Phase: 001_IMPLEMENT
Active Sequences: Not started
Blockers: None
```

---

## Phase Progress

### 001_IMPLEMENT

**Status**: Not Started

#### Sequences

- [ ] 01_vault_contract: ERC-4626 vault with swap constraints, tests, deploy script
- [ ] 02_agent_runtime: Vault client, LLM strategy, risk manager, trading loop
- [ ] 03_identity: Synthesis API registration for ERC-8004
- [ ] 04_deploy_integrate: Testnet deploy, E2E testing, security review, mainnet deploy
- [ ] 05_submission: Observer CLI, demo recording, submission prep

---

## Blockers

None currently.

---

## Decision Log

- 2026-03-13: Chose Uniswap V3 SwapRouter02 over Universal Router (simpler ABI, deepest Base liquidity)
- 2026-03-13: NAV via Uniswap V3 TWAP oracle with 30-min window (no external oracle dependency)
- 2026-03-13: ERC-4626 for vault standard (composable, wallet support out of the box)
- 2026-03-13: Guardian sets agent address at deployment; can update via setAgent()

---

*Detailed progress available via `fest status`*
