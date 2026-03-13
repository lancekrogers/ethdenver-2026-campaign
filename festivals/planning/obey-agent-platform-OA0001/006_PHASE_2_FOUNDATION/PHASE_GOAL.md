---
fest_type: phase
fest_id: 006_PHASE_2_FOUNDATION
fest_name: PHASE_2_FOUNDATION
fest_parent: obey-agent-platform-OA0001
fest_order: 6
fest_status: pending
fest_created: 2026-03-13T02:20:18.474964-06:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 006_PHASE_2_FOUNDATION

**Phase:** 006_PHASE_2_FOUNDATION | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Deliver multi-platform prediction market support (Polymarket adapter + cross-platform arbitrage) and full vault contracts with oracle-only NAV, anti-gaming, concentration limits, circuit breakers, and creator management — replacing the MVP vault and enabling platform scale.

**Context:** This phase begins after the MVP is generating revenue (Phases 001-005 complete). The trigger conditions are: AUM exceeds $50K, more than 20 unique depositors, agent demonstrates >15% return in 30 days, or external creator requests registration. The full vault contracts are the production trust layer — funds in PDA custody, trade execution only via whitelisted routers, oracle-only NAV (no Pyth feed = $0 value), concentration limits, drawdown circuit breakers, and 48-hour timelock on agent signer updates. The Polymarket adapter unlocks the deepest prediction market liquidity ($20M+/day) and enables cross-platform arbitrage.

## Required Outcomes

Deliverables this phase must produce:

- [ ] Polymarket CLOB API client: REST + WebSocket, EIP-712 credential creation, HMAC-SHA256 API key auth, rate limit handling
- [ ] Gamma API client for market metadata, resolution rules, and category data
- [ ] Order placement (GTC, FOK), CTF token (ERC-1155) position tracking, and redemption flow
- [ ] Integration tests against Polymarket testnet/paper trading
- [ ] LLM-assisted cross-platform event matching: detect same event on Drift + Polymarket with confidence scoring and resolution rule compatibility check
- [ ] ArbitrageScanner strategy: detect price discrepancies, calculate edge net of fees and bridge costs, execute paired positions
- [ ] Solana-Polygon bridge manager via Wormhole: working capital management, batch bridging ($5K chunks), status tracking, in-transit NAV accounting
- [ ] obey_registry program: PlatformConfig, AgentState, create_agent, creator management (update metadata, lower ownership %, tighten risk), 48-hour timelock on agent signer updates
- [ ] obey_nav program: Pyth feed reading with staleness check (60s max age), confidence interval validation, tiered valuation (no feed = $0)
- [ ] obey_fees program: fee accumulation, treasury claims, creator tier revenue sharing (Seed/Growth/Scale/Elite)
- [ ] obey_vault program: multi-asset deposit with creator share minting, trade routing via CPI to whitelisted routers, post-trade concentration check, drawdown circuit breaker, proportional multi-asset withdrawal
- [ ] Migration path: transfer MVP vault depositors to full vault program with share token continuity and NAV preservation

## Quality Standards

Quality criteria for all work in this phase:

- [ ] All four Anchor programs pass comprehensive test suites (unit, integration, attack vectors from design doc 06)
- [ ] Oracle-only NAV verified: tokens without Pyth feeds valued at $0, confidence interval check rejects wide spreads
- [ ] Concentration limits enforced post-trade (configurable per agent, default 40%)
- [ ] Circuit breaker triggers correctly at configured max drawdown and auto-pauses agent
- [ ] 48-hour timelock emits events and allows depositor exit during pending period
- [ ] Cross-platform arbitrage calculates net edge after fees and bridge costs
- [ ] Bridge manager tracks all in-transit funds and includes them in NAV

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_polymarket_adapter | Implement Polymarket CLOB client with auth, orders, and positions | Full Polymarket MarketAdapter with integration tests |
| 02_cross_platform | Enable cross-platform event matching, arbitrage, and bridging | Working arbitrage between Drift BET and Polymarket |
| 03_full_vault | Deploy production vault contracts with anti-gaming and creator management | Four Anchor programs replacing MVP vault |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_polymarket_adapter
- [ ] 02_cross_platform
- [ ] 03_full_vault

## Notes

- The Polymarket adapter operates on Polygon. The agent needs USDC bridged from Solana via Wormhole. Bridge latency is ~15 minutes per direction, so agents batch bridge operations and hold working capital on Polygon.
- The full vault's four programs total ~2,800 LOC (registry ~800, vault ~1,200, nav ~500, fees ~300). Each is a separate Anchor program for modularity.
- Migration from MVP vault: existing share token holders get equivalent shares in the new vault. NAV is preserved. The migration instruction atomically transfers vault USDC and re-mints shares under the new program.
- Creator registration opens in this phase. External developers can register agents, set ownership % (max 50%), configure risk params, and earn tiered fee sharing based on AUM thresholds.
- Access control matrix from design doc 02 must be enforced: only agent_signer can execute_trade, only creator can update_metadata, only admin can approve_token, etc.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
