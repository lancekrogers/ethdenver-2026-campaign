# 08 — Build Sequence

## Overview

> **IMPORTANT: Start with doc 11 (Fast-Path MVP).** The milestones below are the full platform build. The MVP (doc 11) launches in 4 weeks with a single agent, simple vault, and landing page — generating real revenue while the full platform is built in parallel.
>
> **Execution order:** MVP first (4 weeks) → then Milestones 1-6 below (12 weeks) in parallel with growing the MVP.

The build is organized into milestones. Each milestone produces a working, deployable artifact. No milestone depends on a future milestone — every step is shippable.

## Milestone 1: Vault Contracts (Solana/Anchor)

**Deliverable:** Deployed, tested Anchor programs on Solana devnet.

### Tasks

```
1.1  Scaffold Anchor workspace
     - Initialize obey-platform Anchor project
     - Configure programs: obey_registry, obey_vault, obey_nav, obey_fees
     - Set up test framework (Bankrun or anchor test)

1.2  Implement obey_registry
     - PlatformConfig initialization
     - create_agent with full validation
     - Creator management: update_metadata, lower_owner_pct
     - Agent update timelock: propose, execute, cancel
     - Risk param management (tighten only)
     - Token/router approval (admin)

1.3  Implement obey_vault
     - Deposit: multi-asset, share minting, creator share split
     - Request burn: share escrow, delay tracking
     - Execute burn: proportional asset withdrawal
     - Execute trade: fee deduction, CPI to router, concentration check
     - NAV update: Pyth integration, staleness/confidence checks

1.4  Implement obey_nav
     - Pyth feed reading with validation
     - Tiered valuation (feed exists = value, no feed = $0)
     - Concentration limit enforcement

1.5  Implement obey_fees
     - Fee accumulation
     - Treasury claims

1.6  Integration tests
     - Full lifecycle: create → deposit → trade → burn
     - Multi-depositor proportional math
     - Circuit breaker / drawdown pause
     - Attack scenarios (unauthorized trade, concentration, NAV manipulation)
     - Agent update timelock flow

1.7  Deploy to devnet
     - Deploy all programs
     - Initialize platform config
     - Create test agent
     - Run through full flow on devnet
```

**Dependencies:** Pyth devnet feeds
**Estimate:** Largest milestone — vault + registry + NAV is the core

## Milestone 2: Market Adapters (Go)

**Deliverable:** Go services that can read markets and place orders on all 3 platforms.

### Tasks

```
2.1  Define MarketAdapter interface
     - Finalize interface contract (list, order, position, settlement, subscribe)
     - Market normalization types
     - Signal/Order types

2.2  Polymarket adapter
     - CLOB API client (REST)
     - Gamma API client (market metadata)
     - WebSocket client (real-time feeds)
     - EIP-712 authentication
     - HMAC-SHA256 API key auth
     - Order placement (GTC, FOK)
     - Position tracking (CTF tokens)
     - Redemption flow

2.3  Limitless adapter
     - REST client
     - WebSocket client
     - Order placement
     - Position tracking

2.4  Drift BET adapter
     - HTTP API client
     - Pyth oracle integration
     - Order placement via Drift SDK
     - Position tracking

2.5  Cross-platform event matcher
     - LLM-assisted market matching
     - Resolution rule comparison
     - Confidence scoring

2.6  Integration tests
     - Read live markets from all 3 platforms
     - Place test orders (testnet/paper)
     - Verify normalization consistency
```

**Dependencies:** API keys for Polymarket, Limitless, Drift
**Can be built in parallel with Milestone 1**

## Milestone 3: Agent Engine (Go)

**Deliverable:** Working agent runtime that connects vault + adapters + strategies.

### Tasks

```
3.1  Agent engine core
     - Config loading
     - Execution loop (cycle-based + event-driven)
     - Vault client (Solana RPC)
     - Multi-adapter management

3.2  Strategy framework
     - Strategy interface
     - Signal generation pipeline
     - Strategy composition (run multiple strategies per agent)

3.3  Arbitrage scanner strategy
     - Cross-platform price comparison
     - Edge calculation
     - Execution routing

3.4  News trader strategy
     - News feed integration (RSS, API)
     - LLM analysis pipeline
     - Market impact assessment

3.5  Resolution hunter strategy
     - Resolution rule parsing (LLM)
     - Edge detection vs market price
     - Title-vs-rule divergence scoring

3.6  Market maker strategy
     - Both-side quoting
     - Inventory management
     - Maker rebate optimization

3.7  Risk manager
     - Position sizing
     - Platform exposure limits
     - Category concentration limits
     - Daily loss limits
     - Drawdown halt

3.8  Portfolio manager
     - Cross-chain position tracking
     - NAV calculation
     - Settlement pipeline (redeem winners, bridge back)
     - P&L attribution by strategy

3.9  Bridge manager
     - Solana ↔ Polygon bridge (Wormhole)
     - Solana ↔ Base bridge (Wormhole)
     - Working capital management per chain
     - Bridge status tracking

3.10 HCS reporting
     - Extend existing coordinator integration
     - Trade events, NAV updates, P&L reports
     - Agent health monitoring
```

**Dependencies:** Milestones 1 + 2
**Can start 3.1-3.2 in parallel; 3.3-3.10 need adapters working**

## Milestone 4: Dashboard & Marketplace (Next.js)

**Deliverable:** User-facing platform with marketplace, agent profiles, deposit/withdraw.

### Tasks

```
4.1  Marketplace page
     - Agent listing with cards
     - Search and filter (type, performance, NAV, platform)
     - Sort (return, Sharpe, volume, depositors)

4.2  Agent profile page
     - Performance charts (NAV over time)
     - Strategy description
     - Trade history
     - Risk profile display
     - Depositor count and pool stats

4.3  Deposit flow
     - Wallet connection (Phantom, Solflare, Backpack)
     - Asset selection from accepted list
     - Amount input with share preview
     - Creator share disclosure
     - Transaction confirmation

4.4  Withdrawal flow
     - Share balance display
     - Burn amount input
     - Withdrawal delay display
     - Request + execute two-step flow

4.5  Portfolio view
     - All user positions across agents
     - Aggregate P&L
     - Individual agent P&L
     - Withdrawal management

4.6  Leaderboard
     - Ranked agents by multiple metrics
     - Time period filters
     - Agent comparison

4.7  Creator dashboard
     - Agent management (metadata, risk params)
     - Analytics (NAV, depositors, fees, trades)
     - Agent update (timelock flow)
     - Share burn (creator withdrawal)

4.8  Real-time feeds
     - WebSocket integration for live data
     - NAV updates
     - Trade notifications
     - Leaderboard movements

4.9  Public API
     - REST endpoints for agent data
     - WebSocket for real-time feeds
     - Rate limiting
     - Documentation
```

**Dependencies:** Milestone 1 (contract ABIs), partially Milestone 3 (for live data)
**Can start wireframes and static UI immediately; connect to contracts when ready**

## Milestone 5: Bags Integration

**Deliverable:** OBEY token launched on Bags, fee claiming automated.

### Tasks

```
5.1  Bags API client (Go)
     - Agent authentication (Moltbook JWT)
     - Token creation
     - Fee share configuration
     - Trade quote + swap
     - Fee claiming

5.2  Token launch
     - Create OBEY token metadata
     - Configure fee sharing (4 recipients)
     - Launch on Meteora DBC
     - Verify on-chain

5.3  Automated fee claiming
     - Periodic fee claim job (every 6 hours)
     - Fee distribution to platform treasury
     - Metrics reporting

5.4  Dashboard integration
     - OBEY token metrics on dashboard
     - Fee revenue display
     - Token holder stats

5.5  Hackathon submission
     - Application at bags.fm/hackathon
     - Documentation of integration depth
     - Traction metrics
```

**Dependencies:** API key from dev.bags.fm, Milestone 1 (vault for treasury)
**Can be built largely in parallel with other milestones**

## Milestone 6: Mainnet Deployment

**Deliverable:** Full platform live on Solana mainnet with real funds.

### Tasks

```
6.1  Security audit (self or third-party)
     - Contract audit
     - Attack scenario testing
     - Fuzzing

6.2  Mainnet deployment
     - Deploy all programs to Solana mainnet
     - Initialize platform config
     - Set fee rates
     - Configure approved tokens/routers

6.3  Reference agents deployment
     - Deploy 3 platform-operated agents
     - Seed with initial capital
     - Verify trading flow end-to-end

6.4  Monitoring setup
     - NAV deviation alerts
     - Trade pattern monitoring
     - Bridge status tracking
     - Drawdown alerts
     - Uptime monitoring

6.5  Launch
     - Open marketplace
     - Announce on socials
     - Community onboarding
```

**Dependencies:** All previous milestones
**This is the final milestone**

## Parallel Execution Map

```
Month 1:
  ┌── M1: Vault Contracts ──────────────────────────────┐
  │                                                       │
  ├── M2: Market Adapters (parallel) ───────────┐        │
  │                                              │        │
  ├── M4: Dashboard wireframes/static ──┐       │        │
  │                                      │       │        │
  └── M5: Bags API client (parallel) ──┐│       │        │
                                        ││       │        │
Month 2:                                ││       │        │
  ┌── M3: Agent Engine ────────────────┤│       │        │
  │   (needs M1 + M2)                  ││       │        │
  │                                     ││       │        │
  ├── M4: Dashboard connect to contracts│       │        │
  │                                     │        │        │
  ├── M5: Token launch ───────────────┘│        │        │
  │                                     │        │        │
Month 3:                                │        │        │
  ├── M3: Strategies + risk ───────────┘        │        │
  │                                              │        │
  ├── M4: Full dashboard ──────────────────────┘        │
  │                                                       │
  ├── M6: Devnet testing ────────────────────────────────┘
  │
Month 4:
  └── M6: Mainnet deployment + launch
```

## Project Structure (Scaffolded)

All new projects created via `camp project new`. The existing agent-defi runtime patterns
(Strategy interface, TradeExecutor, HCS messaging, execution loop) are the foundation —
agent-prediction follows the same architecture, not a new runtime.

```
projects/
├── agent-prediction/               # NEW — Prediction market trading agent (Go)
│   ├── cmd/agent-prediction/       # Entry point (same pattern as agent-defi)
│   ├── internal/
│   │   ├── adapters/               # MarketAdapter interface + implementations
│   │   │   ├── drift/              # Drift BET (Solana) — MVP primary
│   │   │   ├── polymarket/         # Polymarket (Polygon) — Phase 2
│   │   │   └── limitless/          # Limitless (Base) — Phase 2
│   │   ├── strategies/             # Strategy interface (extends agent-defi pattern)
│   │   ├── analysis/               # Claude API market analysis pipeline
│   │   ├── portfolio/              # Position tracking, NAV calculation
│   │   ├── risk/                   # Position sizing, drawdown controls
│   │   ├── agent/                  # Core execution loop (goroutine-based)
│   │   └── hcs/                    # Coordinator messaging (reuse agent-defi patterns)
│   ├── justfile
│   └── go.mod
│
├── obey-platform/                  # NEW — Solana/Anchor vault contracts
│   ├── programs/
│   │   └── obey-mvp-vault/         # MVP: simple deposit/withdraw (~200 LOC)
│   │       └── src/lib.rs          # initialize, deposit, request/execute withdrawal, update_nav
│   ├── tests/
│   ├── justfile
│   └── (Phase 2: obey-registry, obey-vault, obey-nav, obey-fees)
│
├── agent-bags/                     # NEW — Bags.fm integration service (Go)
│   ├── cmd/agent-bags/
│   ├── internal/
│   │   ├── bags/                   # Bags API HTTP client
│   │   ├── token/                  # OBEY token creation + metadata
│   │   ├── fees/                   # Periodic fee claiming + distribution
│   │   └── metrics/                # Token metrics monitoring
│   ├── justfile
│   └── go.mod
│
├── dashboard/                      # EXISTING — extend with marketplace
│   ├── src/components/
│   │   ├── (existing panels)
│   │   ├── Marketplace/            # NEW — agent discovery
│   │   ├── AgentProfile/           # NEW — NAV chart, trades, deposit
│   │   ├── DepositFlow/            # NEW — wallet connect → USDC → shares
│   │   ├── WithdrawFlow/           # NEW — burn shares → receive USDC
│   │   ├── Portfolio/              # NEW — user positions across agents
│   │   ├── Leaderboard/            # NEW — ranked agents
│   │   └── CreatorDashboard/       # NEW — agent management
│   └── justfile
│
├── agent-coordinator/              # EXISTING — extend with platform events
├── agent-defi/                     # EXISTING — runtime patterns (Strategy, TradeExecutor, HCS)
├── agent-inference/                # EXISTING — future integration
├── contracts/                      # EXISTING — EVM contracts (settlement, reputation)
├── cre-risk-router/                # EXISTING — risk assessment pipeline
└── hiero-plugin/                   # EXISTING — Hedera CLI integration
```

### Runtime Reuse Map

The existing agent-defi is NOT replaced — its patterns ARE the runtime:

| agent-defi Pattern | agent-prediction Equivalent |
|---|---|
| `Strategy` interface (Evaluate → Signal) | Same interface, new implementations (arbitrage, news, resolution) |
| `TradeExecutor` interface | `MarketAdapter` interface (prediction market primitives) |
| Goroutine execution loop (trading + P&L + health) | Same pattern, 15-min cycle for prediction markets |
| HCS envelope messaging | Same format, new message types (deposit, burn, nav_update) |
| CRE Guard (position constraints) | Risk manager (concentration limits, stop-loss) |
| PnL tracker | Portfolio manager (NAV across platforms) |
| Mock mode | Mock adapters for dry-run testing |
| Config via env vars | Same pattern with PRED_ prefix |
