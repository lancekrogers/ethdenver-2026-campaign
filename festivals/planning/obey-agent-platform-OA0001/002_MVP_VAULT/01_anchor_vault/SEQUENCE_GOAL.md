---
fest_type: sequence
fest_id: 01_anchor_vault
fest_name: anchor_vault
fest_parent: 002_MVP_VAULT
fest_order: 1
fest_status: pending
fest_created: 2026-03-13T02:20:39.636463-06:00
fest_tracking: true
---

# Sequence Goal: 01_anchor_vault

**Sequence:** 01_anchor_vault | **Phase:** 002_MVP_VAULT | **Status:** Pending | **Created:** 2026-03-13T02:20:39-06:00

## Sequence Objective

**Primary Goal:** Implement the MVP vault Anchor program (~200 LOC) with instructions for initialization, USDC deposit with proportional share minting, withdrawal with optional delay, and admin-controlled NAV update.

**Contribution to Phase Goal:** This is the core smart contract enabling user deposits. Without it, the agent trades only with platform capital. The vault transforms the platform from an internal tool into a product accepting external funds and generating fee revenue.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Anchor project**: Initialized with devnet configuration and test framework
- [ ] **VaultState account**: PDA with authority, agent_wallet, share_mint, usdc_vault, total_nav, total_shares, withdrawal_delay fields
- [ ] **Initialize instruction**: Creates vault PDA, share token mint (PDA-controlled), USDC vault ATA
- [ ] **Deposit instruction**: Transfers USDC to vault, mints proportional shares (1:1 bootstrap for first deposit)
- [ ] **Withdrawal instructions**: request_withdrawal (escrow shares, snapshot NAV, start delay) + execute_withdrawal (verify delay, burn shares, transfer proportional USDC)
- [ ] **NAV update instruction**: Admin-only, sets total_nav and timestamp

### Quality Standards

- [ ] **Checked arithmetic**: All math uses checked operations to prevent overflow
- [ ] **Access control**: Admin-only on NAV update, share-holder-only on withdrawal, correct PDA derivation

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_anchor_setup.md | Initialize Anchor project, configure devnet, test framework | Project foundation |
| 02_vault_state.md | Define VaultState account struct | Data model for vault operations |
| 03_initialize.md | Initialize instruction (vault PDA, share mint, USDC vault) | Creates vault infrastructure on-chain |
| 04_deposit.md | Deposit instruction with proportional share minting | Enables user deposits |
| 05_withdrawal.md | Request + execute withdrawal with delay | Enables user exits at NAV |
| 06_nav_update.md | Admin-only NAV update instruction | Keeps on-chain NAV synced with portfolio |
| 07_testing.md | Quality gate: run full test suite | Validates all instructions |
| 08_review.md | Quality gate: code review | Validates security and correctness |
| 09_iterate.md | Quality gate: address review feedback | Resolves issues |
| 10_fest_commit.md | Quality gate: commit completed work | Finalizes deliverables |

## Dependencies

### Prerequisites (from other sequences)

- 001_DRIFT_BET_AGENT/04_mainnet_deployment: Live agent with known wallet address (vault references agent_wallet)

### Provides (to other sequences)

- Vault program and account addresses: Used by 02_vault_tests and 03_agent_vault_client
- Share token mint: Used by 003_LANDING_PAGE/02_deposit_flow (UI displays share balance)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Share math rounding errors cause fund leakage | Low | High | Extensive multi-depositor tests; rounding favors vault |
| Anchor version incompatibility with devnet | Low | Med | Pin Anchor version; test deployment early |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Anchor project set up, VaultState defined, initialize working
- [ ] **Milestone 2**: Deposit and withdrawal instructions compiling
- [ ] **Milestone 3**: All instructions passing `anchor test`

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
