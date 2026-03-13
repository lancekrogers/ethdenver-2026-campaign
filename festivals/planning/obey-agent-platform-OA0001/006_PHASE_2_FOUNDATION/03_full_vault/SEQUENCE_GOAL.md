---
fest_type: sequence
fest_id: 03_full_vault
fest_name: full_vault
fest_parent: 006_PHASE_2_FOUNDATION
fest_order: 3
fest_status: pending
fest_created: 2026-03-13T02:20:39.991819-06:00
fest_tracking: true
---

# Sequence Goal: 03_full_vault

**Sequence:** 03_full_vault | **Phase:** 006_PHASE_2_FOUNDATION | **Status:** Pending | **Created:** 2026-03-13T02:20:39-06:00

## Sequence Objective

**Primary Goal:** Implement the four production Anchor programs (obey_registry, obey_nav, obey_fees, obey_vault) with oracle-only NAV, anti-gaming protections, creator management, and circuit breakers — then migrate MVP vault depositors to the new system.

**Contribution to Phase Goal:** The full vault is the production trust layer that replaces the MVP. It enables: permissionless agent registration by external creators, oracle-only NAV (no Pyth feed = $0), concentration limits, drawdown circuit breakers, 48-hour timelock on signer updates, trade routing via whitelisted CPI, and tiered creator revenue sharing. This is what makes the platform trustless and scalable.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **obey_registry program**: PlatformConfig (admin, fee rate, approved tokens/routers), AgentState (creator, signer, type, ownership %, risk params, stats), create_agent, update_metadata, lower_owner_pct, tighten_risk, pause/unpause, 48-hour signer update timelock
- [ ] **obey_nav program**: Pyth feed reading with staleness check (60s max age), confidence interval validation, tiered valuation (no feed = $0 value)
- [ ] **obey_fees program**: Fee accumulation, treasury claims, creator tier revenue sharing (Seed/Growth/Scale/Elite based on AUM thresholds)
- [ ] **obey_vault program**: Multi-asset deposit with creator share minting, execute_trade via CPI to whitelisted routers, post-trade concentration check, drawdown circuit breaker, proportional multi-asset withdrawal
- [ ] **Migration**: Atomic transfer of MVP vault depositors to full vault with share token continuity and NAV preservation

### Quality Standards

- [ ] **Anti-gaming verified**: Attack scenarios from design doc 06 tested: junk token = $0, concentration limits hold, circuit breaker triggers, unauthorized trade reverts, timelock allows exit
- [ ] **Access control matrix**: Every instruction enforces correct caller authority per design doc 02 matrix

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_registry_program.md | PlatformConfig, AgentState, creator management, timelock | Agent registration and management layer |
| 02_nav_program.md | Pyth feed reading, staleness/confidence validation, tiered valuation | Oracle-only NAV — primary anti-gaming defense |
| 03_fees_program.md | Fee accumulation, treasury claims, creator tier sharing | Revenue distribution infrastructure |
| 04_full_vault_program.md | Multi-asset deposit, CPI trade routing, concentration limits, circuit breaker | Production custody and trading layer |
| 05_migration.md | Migrate MVP vault depositors to full vault | Seamless transition for existing users |
| 06_testing.md | Quality gate: run full test suite including attack scenarios | Validates security and correctness |
| 07_review.md | Quality gate: code review | Validates contract security |
| 08_iterate.md | Quality gate: address review feedback | Resolves issues |
| 09_fest_commit.md | Quality gate: commit completed work | Finalizes deliverables |

## Dependencies

### Prerequisites (from other sequences)

- 02_cross_platform: Bridge manager (vault tracks cross-chain assets in NAV)
- 002_MVP_VAULT/01_anchor_vault: Existing MVP vault depositors and share tokens (migration source)

### Provides (to other sequences)

- Production vault contracts: Replaces MVP vault as the canonical on-chain custody system
- Creator registration: Enables external developers to register and manage agents

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Smart contract bug in production vault | Low | Critical | Comprehensive test suite including attack scenarios; consider audit |
| Migration fails and locks depositor funds | Low | Critical | Test migration on devnet first; include rollback path; migration is admin-gated |
| Oracle-only NAV creates zero-valuation for legitimate positions | Med | Med | Maintain comprehensive Pyth feed registry; manual review of approved token list |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Registry and NAV programs compiled and tested
- [ ] **Milestone 2**: Fees and full vault programs compiled with attack tests passing
- [ ] **Milestone 3**: Migration from MVP vault completed on devnet

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
