---
fest_type: sequence
fest_id: 03_agent_vault_client
fest_name: agent_vault_client
fest_parent: 002_MVP_VAULT
fest_order: 3
fest_status: pending
fest_created: 2026-03-13T02:20:39.719279-06:00
fest_tracking: true
---

# Sequence Goal: 03_agent_vault_client

**Sequence:** 03_agent_vault_client | **Phase:** 002_MVP_VAULT | **Status:** Pending | **Created:** 2026-03-13T02:20:39-06:00

## Sequence Objective

**Primary Goal:** Build a Go client that reads vault state from the on-chain program and periodically updates the on-chain NAV from the agent's portfolio tracker, keeping share prices in sync with actual Drift BET position values.

**Contribution to Phase Goal:** The vault NAV update is admin-controlled in the MVP. This client automates that update so share prices stay fresh without manual intervention.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Vault client package**: Go client reading VaultState (total_nav, total_shares, share_mint, last update timestamp) via Solana RPC
- [ ] **NAV reporting service**: Periodic task (every 5 minutes) reading agent portfolio NAV and submitting update_nav transaction when deviation exceeds 0.5%

### Quality Standards

- [ ] **Idempotent updates**: Redundant NAV updates with same value skip transaction submission
- [ ] **Context propagation**: All RPC calls respect context cancellation

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_vault_client.md | Go client for reading vault state and submitting NAV updates | Core vault program interaction |
| 02_nav_reporting.md | Periodic NAV sync from agent portfolio to on-chain vault | Automated NAV freshness |
| 03_testing.md | Quality gate: run full test suite | Ensures client works against devnet |
| 04_review.md | Quality gate: code review | Validates client design |
| 05_iterate.md | Quality gate: address review feedback | Resolves issues |
| 06_fest_commit.md | Quality gate: commit completed work | Finalizes deliverables |

## Dependencies

### Prerequisites (from other sequences)

- 02_vault_tests: Verified vault program on devnet with known program ID
- 001_DRIFT_BET_AGENT/03_agent_loop: Portfolio tracker providing current NAV

### Provides (to other sequences)

- Automated on-chain NAV updates: Used by 003_LANDING_PAGE/01_agent_profile (REST API reads on-chain NAV)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| RPC rate limits cause missed NAV updates | Low | Low | Dedicated RPC endpoint; updates non-critical if delayed by minutes |
| Transaction fees from frequent updates | Low | Low | Threshold-based submission; ~0.00025 SOL per tx is negligible |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Go client reads VaultState from devnet
- [ ] **Milestone 2**: NAV reporting submits update transactions
- [ ] **Milestone 3**: End-to-end: trade changes NAV, on-chain vault reflects it

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
