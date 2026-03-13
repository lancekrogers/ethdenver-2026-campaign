---
fest_type: phase
fest_id: 003_LANDING_PAGE
fest_name: LANDING_PAGE
fest_parent: obey-agent-platform-OA0001
fest_order: 3
fest_status: pending
fest_created: 2026-03-13T02:20:18.418686-06:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 003_LANDING_PAGE

**Phase:** 003_LANDING_PAGE | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Deliver a public-facing web page that displays live agent performance data and provides a complete deposit/withdraw flow, converting visitors into depositors.

**Context:** Phases 001 and 002 produce a working agent and vault. This phase makes it user-accessible. The landing page is the single conversion point — it must clearly communicate the value proposition ("Fund AI agents that trade prediction markets"), show live proof of performance (NAV chart, trade history, win rate), and provide a frictionless deposit experience via Solana wallet connection. This page is also the primary artifact for the Bags hackathon submission.

## Required Outcomes

Deliverables this phase must produce:

- [ ] REST API endpoints serving agent stats (NAV, return %, win rate, Sharpe ratio, max drawdown), trade history, and NAV chart time-series data
- [ ] Next.js agent profile page with real-time NAV chart (Recharts), trade history table, strategy description, risk profile, and depositor stats
- [ ] Performance metrics calculation and display: return %, win rate, Sharpe ratio, max drawdown, trade count, average holding period
- [ ] Solana wallet adapter integration (Phantom, Solflare, Backpack) with connection state management
- [ ] Deposit UI: amount input, share preview calculation based on current NAV, USDC approval, transaction confirmation with success/error states
- [ ] Withdrawal UI: share balance display, burn amount input, withdrawal delay display, request + execute flow with pending state
- [ ] Landing page with hero section ("Fund AI agents that trade prediction markets"), how-it-works steps, featured agent card, and deposit CTA
- [ ] Responsive layout working on desktop and mobile browsers

## Quality Standards

Quality criteria for all work in this phase:

- [ ] Page loads under 2 seconds on desktop with production data
- [ ] All wallet interactions handle errors gracefully (rejected signatures, insufficient balance, network errors)
- [ ] NAV chart updates in near-real-time without page refresh
- [ ] Mobile layout is fully functional (wallet connect works on mobile browsers)
- [ ] No broken states in deposit/withdraw flow (loading, error, success all handled)

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_agent_profile | REST API and agent profile page with performance data | Live agent profile with NAV chart, trades, and metrics |
| 02_deposit_flow | Wallet connection and deposit/withdraw UI | Complete deposit and withdrawal user flow |
| 03_landing_design | Landing page design and responsive layout | Conversion-optimized landing page with mobile support |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_agent_profile
- [ ] 02_deposit_flow
- [ ] 03_landing_design

## Notes

- The frontend extends the existing Next.js dashboard in the codebase. Reuse existing component patterns and styling.
- The REST API serves data aggregated from Drift positions (on-chain) and agent trade logs (database). NAV chart data comes from historical NAV snapshots stored by the agent.
- Wallet adapter uses @solana/wallet-adapter-react, the standard Solana wallet connection library.
- The deposit flow interacts directly with the MVP vault program from Phase 002 via Anchor client-side SDK.
- For the Bags hackathon, this page needs to demonstrate real users, real capital, and real trades on mainnet.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
