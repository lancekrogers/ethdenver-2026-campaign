---
fest_type: phase
fest_id: 004_BAGS_INTEGRATION
fest_name: BAGS_INTEGRATION
fest_parent: obey-agent-platform-OA0001
fest_order: 4
fest_status: pending
fest_created: 2026-03-13T02:20:18.436786-06:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 004_BAGS_INTEGRATION

**Phase:** 004_BAGS_INTEGRATION | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Launch the OBEY token on Bags/Meteora DBC with configured fee sharing and automated fee claiming, establishing a second revenue stream independent of agent trade fees.

**Context:** This phase can run in parallel with Phases 002 and 003. The OBEY token serves three purposes: (1) hackathon eligibility for the Bags $10K-$100K grant (AI Agents track), (2) a perpetual 1% creator fee revenue stream on all token trading volume, and (3) a user acquisition channel through the Bags community and marketplace. The token also creates future utility for governance, agent staking, and fee discounts.

## Required Outcomes

Deliverables this phase must produce:

- [ ] Bags API client in Go with agent auth (registration, Moltbook JWT acquisition, token refresh)
- [ ] Token operations client: create token, set metadata (name, symbol, image, description), configure fee sharing
- [ ] Trading client: get quote and execute swap operations for OBEY token
- [ ] Fee claiming client: list claimable positions, generate claim transactions, sign and submit
- [ ] OBEY token created on Bags with metadata (name: "OBEY Agent Economy", symbol: "OBEY")
- [ ] Fee sharing configured: 40% platform treasury, 30% agent performance pool, 20% holders (Bags dividends), 10% creator
- [ ] Token launched on Meteora DBC with verified on-chain state and live trading
- [ ] Automated fee claiming service running every 6 hours, distributing to treasury wallet
- [ ] Metrics reporting: token volume, fee revenue, holder count reported via HCS

## Quality Standards

Quality criteria for all work in this phase:

- [ ] All Bags API calls include retry logic with exponential backoff
- [ ] JWT refresh handled automatically before expiration
- [ ] Fee claiming transactions verified on-chain after submission
- [ ] Metrics reporting includes error counts and claim success rates
- [ ] All Go clients pass context through API calls with cancellation support

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_bags_client | Implement Go client for all Bags API operations | Auth, token, trading, and fee claiming clients |
| 02_token_launch | Create and launch OBEY token on Bags/Meteora | Live OBEY token with configured fee sharing |
| 03_automated_claiming | Automate fee collection and metrics reporting | Running service claiming fees every 6 hours |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_bags_client
- [ ] 02_token_launch
- [ ] 03_automated_claiming

## Notes

- This phase is independent of Phase 001 (agent) and can start as soon as the Bags API documentation is reviewed. It does not depend on a working agent or vault.
- The Bags hackathon requires: (1) have a Bags token, (2) use the Bags API, (3) release a fee sharing app. This phase satisfies all three.
- Initial liquidity for the OBEY token is provided in SOL/OBEY on the Meteora DBC bonding curve. When the curve reaches threshold, it auto-migrates to Meteora DAMM v2 pool.
- Top 100 OBEY holders receive dividends from the 20% holder share in 24hr Bags cycles.
- Token utility (staking, fee discounts, governance) is deferred to Phase 006 and beyond.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
