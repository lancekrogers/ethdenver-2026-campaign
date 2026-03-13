# Festival Overview: OBEY Agent Platform

## Problem Statement

**Current State:** The existing OBEY Agent Economy infrastructure (coordinator, trading agent, inference agent, dashboard, contracts, hiero plugin) provides agent coordination and identity but lacks a user-facing product that generates revenue. There is no mechanism for external users to fund AI agents, no prediction market trading capability, and no token-based revenue stream.

**Desired State:** A live platform where AI agents autonomously trade prediction markets across Drift BET, Polymarket, and Limitless, funded by user deposits through smart contract custody on Solana. The platform earns 0.8% per trade + 10% performance fees, and the OBEY token on Bags generates 1% creator fees on all trading volume.

**Why This Matters:** AI agents have a structural edge in prediction markets (24/7 operation, multi-source information aggregation, cross-platform arbitrage). This platform captures that edge as a product — users get AI-powered trading with smart contract custody, creators get capital to manage, and the platform earns sustainable revenue. At $2M AUM with 5% daily turnover, the platform generates ~$292K annual revenue from trade fees alone.

## Scope

### In Scope

- Drift BET market adapter (Go HTTP client implementing MarketAdapter interface)
- LLM-powered analysis pipeline (Claude API for market analysis, resolution rule parsing, signal generation)
- Agent execution loop with risk management (position sizing, drawdown limits, concentration checks)
- MVP vault program (Anchor/Rust, ~200 LOC: deposit, withdraw, NAV update)
- Full vault contracts (obey_registry, obey_vault, obey_nav, obey_fees)
- Landing page and agent profile (Next.js, NAV chart, trade history, deposit flow)
- Solana wallet integration (Phantom, Solflare, Backpack)
- OBEY token creation and launch on Bags/Meteora DBC
- Bags API client (auth, token operations, fee claiming, trading)
- Referral system (on-chain ReferralState, L1/L2 fee distribution)
- Early depositor incentives (15% bonus shares, 30-day fee waiver)
- Polymarket CLOB adapter (EIP-712 auth, HMAC-SHA256, CTF tokens)
- Cross-platform event matching and arbitrage strategy
- Solana-Polygon bridge management via Wormhole

### Out of Scope

- Limitless adapter (deferred beyond Phase 2 foundation)
- DeFi trading agents (non-prediction-market strategies)
- Mobile native app (responsive web only)
- Agent composability (agents delegating to other agents)
- Institutional features (large deposits, custom risk profiles)
- Governance binding votes (sentiment-only initially)
- Community pools with group governance

## Planned Phases

### 001_DRIFT_BET_AGENT

Build and deploy a live prediction market agent on Drift BET (Solana). This is the critical first step — a working agent trading real markets with platform seed capital ($5K-$10K). Includes Go HTTP client for Drift, Claude-powered analysis pipeline, agent execution loop with risk management, and mainnet deployment with HCS reporting.

### 002_MVP_VAULT

On-chain deposit/withdraw system enabling users to fund the agent. Implements a minimal Anchor program (~200 LOC) with USDC deposits, proportional share token minting, withdrawal with optional delay, and admin-controlled NAV updates verified against Drift positions. Revenue begins here via 0.8% trade fees.

### 003_LANDING_PAGE

Public-facing page that converts visitors into depositors. REST API for agent stats (NAV, return, Sharpe, trade history), Next.js agent profile page with NAV chart, Solana wallet connection, deposit/withdraw UI, and a landing page with hero section and conversion CTA.

### 004_BAGS_INTEGRATION

Launch the OBEY token on Bags/Meteora DBC as a second revenue stream. Implements Bags API client (auth, token creation, fee claiming, trading), configures fee sharing (40% treasury, 30% performance pool, 20% holders, 10% creator), and sets up automated fee claiming every 6 hours with metrics reporting via HCS.

### 005_GROWTH_ENGINE

Referral system and early depositor incentives to bootstrap organic growth. On-chain referral tracking with 10% L1 / 3% L2 fee sharing, 15% bonus shares for first-14-day depositors, 30-day fee waiver, and shareable performance card images for social distribution.

### 006_PHASE_2_FOUNDATION

Multi-platform support and full vault contracts for scale. Polymarket CLOB adapter with EIP-712/HMAC auth, cross-platform event matching with LLM-assisted arbitrage, Wormhole bridge management, and full vault programs (registry, NAV oracle, fees, trade routing via CPI, anti-gaming, circuit breakers) with migration from MVP vault.

## Notes

- Phase 001 is the hard gate — nothing proceeds without a working agent generating real trades on mainnet
- Phase 004 (Bags) can run in parallel with phases 002 and 003
- Phase 006 begins after MVP is generating revenue (phases 001-005 complete)
- The MVP vault uses admin-controlled NAV updates (trusted model acceptable for <$50K AUM); the full vault in Phase 006 uses oracle-only NAV
- Agent runtime is Go (extending existing agent-defi patterns); vault programs are Rust/Anchor; frontend is Next.js (extending existing dashboard)
- Design docs 00-11 in workflow/design/obey-agent-platform/ are the authoritative source for all architecture decisions
