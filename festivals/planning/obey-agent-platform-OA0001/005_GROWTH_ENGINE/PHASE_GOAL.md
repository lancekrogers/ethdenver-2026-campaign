---
fest_type: phase
fest_id: 005_GROWTH_ENGINE
fest_name: GROWTH_ENGINE
fest_parent: obey-agent-platform-OA0001
fest_order: 5
fest_status: pending
fest_created: 2026-03-13T02:20:18.456555-06:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 005_GROWTH_ENGINE

**Phase:** 005_GROWTH_ENGINE | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Implement on-chain referral tracking with fee sharing and early depositor incentives (bonus shares, fee waivers) to bootstrap organic user growth and drive deposits into the platform.

**Context:** Users will not show up organically. Every successful crypto platform invested in incentive loops to bootstrap supply and demand simultaneously. This phase adds the growth mechanics that turn early adopters into recruiters. The referral system creates permanent revenue sharing (10% L1 / 3% L2 of platform fees), bonus shares reward early depositors, fee waivers reduce friction, and shareable performance cards give users social proof to distribute. These mechanics are critical for demonstrating traction in the Bags hackathon submission.

## Required Outcomes

Deliverables this phase must produce:

- [ ] On-chain ReferralState PDA storing referrer, referrer_l2, referred_count, and total_earned per wallet
- [ ] Vault instruction registering referral code on first deposit, linking L1/L2 referrers from referral URL parameters
- [ ] Fee distribution logic: on every platform fee collection, distribute 10% to L1 referrer and 3% to L2 referrer wallets
- [ ] Referral dashboard UI: referral code display, copy link button, referred users table, lifetime and monthly earnings tracker
- [ ] Bonus shares: first-14-day depositors receive 15% additional shares (configurable deadline in vault state)
- [ ] Fee waiver: first-30-day deposits skip platform fee deduction (flag in vault state with expiration timestamp)
- [ ] Shareable performance card image generation: portfolio return, best agent name/return, total P&L, referral link — exportable as image for Twitter/Discord

## Quality Standards

Quality criteria for all work in this phase:

- [ ] Referral fee distribution is atomic with trade fee collection (no partial distributions)
- [ ] Bonus share calculation is precise and documented (platform absorbs dilution, not creator)
- [ ] Fee waiver cannot be exploited (deposit during waiver, withdraw, re-deposit pattern blocked)
- [ ] Performance card images render correctly at Twitter and Discord optimal dimensions
- [ ] All on-chain instructions include proper access control and edge case handling

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_referral_system | On-chain referral tracking with fee distribution and dashboard | Working referral system with permanent fee sharing |
| 02_incentives | Early depositor bonuses, fee waivers, and social sharing tools | Incentive mechanics driving deposits and viral distribution |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_referral_system
- [ ] 02_incentives

## Notes

- The referral system modifies the vault program from Phase 002. The ReferralState PDA is created alongside the first deposit.
- Fee waiver economics: at $200K AUM month 1, 5% daily turnover, foregone fees at 0.8% = ~$48/day = ~$1,440 total for 30 days. This is a trivial cost for validated product-market fit.
- Bonus shares: platform absorbs the 15% dilution cost, not the creator. If creator ownership is implemented (Phase 006), creator still gets their % of total shares including bonus.
- The shareable cards need to look professional. They are the primary viral distribution mechanism for the platform.
- Two-tier referral depth maximum (L1 + L2). No deeper pyramid to keep economics sustainable.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
