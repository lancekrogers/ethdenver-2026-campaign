---
fest_type: sequence
fest_id: 01_vault_contract
fest_name: vault contract
fest_parent: 001_IMPLEMENT
fest_order: 1
fest_status: completed
fest_created: 2026-03-13T19:19:51.968673-06:00
fest_updated: 2026-03-15T19:34:11.481758-06:00
fest_tracking: true
---


# Sequence Goal: 01_vault_contract

**Sequence:** 01_vault_contract | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-03-13T19:19:51-06:00

## Sequence Objective

**Primary Goal:** Build an ERC-4626 vault smart contract on Base with agent swap constraints, guardian controls, and NAV calculation via Uniswap V3 TWAP oracle.

**Contribution to Phase Goal:** The vault is the core on-chain component that enforces all spending boundaries. Without it, the agent has no constrained execution environment. This sequence produces the deployed contract that all other sequences depend on.

## Working Directory

**Primary:** `projects/contracts/` (relative to campaign root)
**Absolute:** `/Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/contracts/`

> **IMPORTANT:** Before executing ANY command in this sequence, navigate to the working directory first:
> ```bash
> cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/contracts/
> ```
> All Solidity development, Foundry tests, and deployment scripts operate from this directory. Run `cd projects/contracts` before any `forge` command.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Uniswap V3 Interfaces**: ISwapRouter02.sol and IOracleLibrary.sol created in `projects/contracts/src/interfaces/`
- [ ] **ObeyVault.sol**: Complete ERC-4626 vault with storage layout, constructor, roles, guardian controls, deposit/redeem, executeSwap with boundary enforcement, and NAV via TWAP
- [ ] **Test Suite**: Foundry tests covering guardian controls, deposit/redeem, swap boundary enforcement, and NAV calculation
- [ ] **Deploy Script**: Foundry deployment script supporting both Base Sepolia and mainnet

### Quality Standards

- [ ] **Compilation**: `forge build` succeeds with zero errors
- [ ] **Test Coverage**: `forge test` passes all boundary enforcement tests (whitelist, size, volume, slippage, pause)

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_uniswap_interfaces | Create ISwapRouter02.sol and IOracleLibrary.sol | Provides swap and oracle interfaces the vault depends on |
| 02_vault_core | ObeyVault storage layout, constructor, roles, events | Establishes the vault skeleton all other tasks extend |
| 03_guardian_controls | setAgent, token whitelist, swap limits, pause | Gives the human guardian full control over agent boundaries |
| 04_deposit_redeem | ERC-4626 deposit/redeem with pause guard | Enables capital inflow/outflow with safety controls |
| 05_execute_swap | executeSwap with boundary enforcement | Core agent action path with whitelist, size, volume, slippage checks |
| 06_nav_twap | NAV calculation via Uniswap V3 TWAP oracle | Accurate share pricing for multi-token vault portfolios |
| 07_deploy_script | Foundry deploy script for Base Sepolia and mainnet | Enables deterministic deployment with correct addresses |

## Dependencies

### Prerequisites (from other sequences)

- None (this is the first sequence)

### Provides (to other sequences)

- Compiled ObeyVault contract and ABI: Used by 02_agent_runtime (abigen bindings)
- Deploy script: Used by 04_deploy_integrate (testnet and mainnet deployment)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Uniswap V3 interface incompatibility on Base | Low | High | Use verified Base mainnet SwapRouter02 address, test on Sepolia first |
| TWAP oracle manipulation | Med | High | 30-minute TWAP window makes manipulation expensive |
| OpenZeppelin version mismatch (v4 vs v5 imports) | Med | Low | Check OZ version before writing tests, adjust import paths |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Vault compiles with interfaces, storage, and constructor (Tasks 1-2)
- [ ] **Milestone 2**: All guardian controls and ERC-4626 deposit/redeem working with tests (Tasks 3-4)
- [ ] **Milestone 3**: executeSwap with full boundary enforcement and NAV via TWAP (Tasks 5-6-7)

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete
- [ ] Performance benchmarks met

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed
- [ ] Standards compliance verified

### Iteration Decision

- [ ] Need another iteration? No
- [ ] If yes, new tasks created: N/A