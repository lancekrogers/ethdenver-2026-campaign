---
fest_type: sequence
fest_id: 02_incentives
fest_name: incentives
fest_parent: 005_GROWTH_ENGINE
fest_order: 2
fest_status: pending
fest_created: 2026-03-13T02:20:39.915777-06:00
fest_tracking: true
---

# Sequence Goal: 02_incentives

**Sequence:** 02_incentives | **Phase:** 005_GROWTH_ENGINE | **Status:** Pending | **Created:** 2026-03-13T02:20:39-06:00

## Sequence Objective

**Primary Goal:** Implement early depositor incentives (15% bonus shares for first 14 days, 30-day fee waiver) and shareable performance card image generation for viral social distribution.

**Contribution to Phase Goal:** Incentives reduce friction for early adopters (fee waiver) and reward them for being first (bonus shares). Shareable cards give users a branded, data-rich image to post on Twitter/Discord, embedding their referral link for organic distribution.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Bonus shares**: Vault deposit instruction extended to mint 15% additional shares for deposits made before configurable bonus_deadline timestamp in vault state
- [ ] **Fee waiver**: Vault trade fee logic extended with waiver_deadline timestamp; deposits during waiver period skip platform fee deduction
- [ ] **Shareable performance cards**: Server-side image generation producing cards with portfolio return %, best agent name and return, total P&L, and referral link — exportable as PNG at Twitter and Discord optimal dimensions

### Quality Standards

- [ ] **Bonus math**: Platform absorbs dilution cost (not creator); verified with multi-depositor test showing correct proportional returns
- [ ] **Anti-gaming**: Fee waiver cannot be exploited via deposit-withdraw-redeposit cycles (waiver tied to deposit timestamp, not withdrawals)

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_bonus_shares.md | 15% bonus shares for first-14-day depositors | Rewards early adoption with extra shares |
| 02_fee_waiver.md | 30-day fee waiver for early deposits | Reduces friction for first depositors |
| 03_shareable_cards.md | Performance card image generation with referral link | Viral distribution mechanism |
| 04_testing.md | Quality gate: run full test suite | Validates incentive mechanics |
| 05_review.md | Quality gate: code review | Validates anti-gaming protections |
| 06_iterate.md | Quality gate: address review feedback | Resolves issues |
| 07_fest_commit.md | Quality gate: commit completed work | Finalizes deliverables |

## Dependencies

### Prerequisites (from other sequences)

- 01_referral_system: Referral link generation (performance cards include referral link)
- 002_MVP_VAULT/01_anchor_vault: Vault program (bonus shares and fee waiver extend vault instructions)
- 003_LANDING_PAGE/01_agent_profile: Performance metrics data for card generation

### Provides (to other sequences)

- Incentive mechanics: Integrated into vault deposit and fee collection paths
- Shareable cards: Available from user dashboard for social posting

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Bonus shares dilute existing depositors unfairly | Low | Med | Platform absorbs cost via treasury shares; documented and transparent |
| Fee waiver period exploited for wash trading | Low | Low | Waiver only applies to platform fees; wash trading still costs gas and slippage |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Bonus shares minted correctly for early depositors
- [ ] **Milestone 2**: Fee waiver skips platform fees during waiver period
- [ ] **Milestone 3**: Performance card images render and include referral link

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
