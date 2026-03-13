# Festival TODO - OBEY Agent Platform

**Goal**: Build and launch the OBEY Agent Platform with live AI agents trading prediction markets, on-chain custody, real deposits, and dual revenue streams (trade fees + OBEY token).
**Status**: Planning

---

## Festival Progress Overview

### Phase Completion Status

- [ ] 001_DRIFT_BET_AGENT: Live prediction market agent on Drift BET (Solana mainnet)
- [ ] 002_MVP_VAULT: On-chain deposit/withdraw with share tokens and NAV tracking
- [ ] 003_LANDING_PAGE: Public agent profile page with deposit/withdraw flow
- [ ] 004_BAGS_INTEGRATION: OBEY token on Bags with automated fee claiming
- [ ] 005_GROWTH_ENGINE: Referral system and early depositor incentives
- [ ] 006_PHASE_2_FOUNDATION: Polymarket adapter, cross-platform arbitrage, full vault contracts

### Current Work Status

```
Active Phase: 001_DRIFT_BET_AGENT
Active Sequences: 01_drift_client
Blockers: None
```

---

## Phase Progress

### 001_DRIFT_BET_AGENT

**Status**: Not Started

#### Sequences

- [ ] 01_drift_client: Go HTTP client for Drift BET API (markets, orders, positions, settlement)
- [ ] 02_analysis_pipeline: Claude-powered market analysis with resolution rule parsing and signal generation
- [ ] 03_agent_loop: Execution loop with risk management, portfolio tracking, and mock mode
- [ ] 04_mainnet_deployment: Wallet setup, mainnet deploy, HCS integration

### 002_MVP_VAULT

**Status**: Not Started

#### Sequences

- [ ] 01_anchor_vault: Anchor program with deposit, withdrawal, share minting, NAV update
- [ ] 02_vault_tests: Lifecycle tests, attack tests, devnet deployment
- [ ] 03_agent_vault_client: Go client for vault program, automated NAV reporting

### 003_LANDING_PAGE

**Status**: Not Started

#### Sequences

- [ ] 01_agent_profile: REST API for agent stats, Next.js profile page with NAV chart
- [ ] 02_deposit_flow: Wallet connect, deposit UI, withdrawal UI
- [ ] 03_landing_design: Hero section, how-it-works, responsive layout

### 004_BAGS_INTEGRATION

**Status**: Not Started

#### Sequences

- [ ] 01_bags_client: Bags API client (auth, token ops, trading, fee claiming)
- [ ] 02_token_launch: Create OBEY token, configure fee sharing, launch on Meteora DBC
- [ ] 03_automated_claiming: Periodic fee claiming service, metrics reporting via HCS

### 005_GROWTH_ENGINE

**Status**: Not Started

#### Sequences

- [ ] 01_referral_system: On-chain referral state, registration, fee distribution, dashboard UI
- [ ] 02_incentives: Bonus shares, fee waiver, shareable performance cards

### 006_PHASE_2_FOUNDATION

**Status**: Not Started

#### Sequences

- [ ] 01_polymarket_adapter: CLOB API client, Gamma metadata client, order placement, tests
- [ ] 02_cross_platform: LLM event matching, arbitrage strategy, Wormhole bridge manager
- [ ] 03_full_vault: Registry, NAV oracle, fees, full vault program, MVP migration

---

## Blockers

None currently.

---

## Decision Log

- **Drift BET first**: Solana-native (no bridges), USDC stays on-chain, Pyth oracles for resolution, instant settlement. Polymarket deferred to Phase 2.
- **MVP vault before full vault**: ~200 LOC Anchor program with admin NAV updates is sufficient for <$50K AUM. Full oracle-only NAV and anti-gaming comes in Phase 2.
- **Fee structure**: 0.8% per trade + 10% quarterly performance fee above high-water mark. Competitive with DeFi vault alternatives, cheaper than traditional hedge funds.
- **OBEY token fee split**: 40% treasury, 30% agent performance pool, 20% holders (Bags dividends), 10% creator.

---

*Detailed progress available via `fest status`*
