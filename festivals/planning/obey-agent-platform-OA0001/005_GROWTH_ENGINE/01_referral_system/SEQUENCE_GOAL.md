---
fest_type: sequence
fest_id: 01_referral_system
fest_name: referral_system
fest_parent: 005_GROWTH_ENGINE
fest_order: 1
fest_status: pending
fest_created: 2026-03-13T02:20:39.889964-06:00
fest_tracking: true
---

# Sequence Goal: 01_referral_system

**Sequence:** 01_referral_system | **Phase:** 005_GROWTH_ENGINE | **Status:** Pending | **Created:** 2026-03-13T02:20:39-06:00

## Sequence Objective

**Primary Goal:** Implement on-chain referral tracking with a two-tier fee sharing model (10% L1, 3% L2) and a dashboard UI where users can view their referral code, referred users, and earnings.

**Contribution to Phase Goal:** The referral system is the primary organic growth driver. It creates a permanent revenue-sharing incentive: every user who refers depositors earns a share of platform fees forever. This turns early adopters into active recruiters without marketing spend.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **ReferralState PDA**: On-chain account storing referrer pubkey, referrer_l2 (optional), referred_users count, total_earned lifetime value
- [ ] **Referral registration**: Vault deposit instruction extended to register referral code on first deposit, linking L1 referrer from URL parameter and L2 referrer from L1's own referrer
- [ ] **Fee distribution**: On every platform fee collection, atomically distribute 10% to L1 referrer and 3% to L2 referrer wallets (remaining 87% to platform treasury)
- [ ] **Referral dashboard**: UI showing referral code, copy link button, table of referred users with deposit amounts, and lifetime + monthly earnings tracker

### Quality Standards

- [ ] **Atomic distribution**: Referral fees distributed in same transaction as trade fee collection (no partial state)
- [ ] **Self-referral prevention**: Users cannot refer themselves or create circular referral chains

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_referral_state.md | On-chain ReferralState PDA definition | Data model for referral tracking |
| 02_referral_registration.md | Link referral code on first deposit | Captures referral relationships |
| 03_fee_distribution.md | Distribute 10% L1 + 3% L2 on fee collection | Implements revenue sharing |
| 04_referral_ui.md | Dashboard: code display, copy link, earnings tracker | User-facing referral management |
| 05_testing.md | Quality gate: run full test suite | Validates referral logic and distribution |
| 06_review.md | Quality gate: code review | Validates on-chain logic security |
| 07_iterate.md | Quality gate: address review feedback | Resolves issues |
| 08_fest_commit.md | Quality gate: commit completed work | Finalizes deliverables |

## Dependencies

### Prerequisites (from other sequences)

- 002_MVP_VAULT/01_anchor_vault: Vault program (referral registration extends deposit instruction)
- 003_LANDING_PAGE/02_deposit_flow: Deposit UI (passes referral code from URL to vault instruction)

### Provides (to other sequences)

- Referral link generation: Used by 02_incentives (shareable performance cards include referral link)
- Fee distribution logic: Integrated into vault fee collection path

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Referral fee distribution increases transaction compute | Low | Med | Pre-calculate referrer accounts; optimize CPI calls |
| Sybil attack: create many wallets to self-refer | Med | Low | Referral fees only flow when capital is actively deposited; attack cost exceeds benefit |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: ReferralState PDA created and linked during deposit
- [ ] **Milestone 2**: Fee distribution pays L1 and L2 referrers atomically
- [ ] **Milestone 3**: Dashboard displays referral code, referred users, and earnings

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
