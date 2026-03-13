# 01 — System Architecture

## Architecture Overview

The platform has five layers, each with clear responsibilities and interfaces:

```
┌─────────────────────────────────────────────────────────────────┐
│ LAYER 5: PRESENTATION                                            │
│                                                                   │
│  Dashboard (Next.js)          Creator Portal         Public API   │
│  - Agent marketplace          - Agent management     - REST       │
│  - Portfolio tracking          - Metadata editor     - WebSocket  │
│  - Leaderboards               - Analytics            - SDK        │
│  - NAV charts                 - Risk config                      │
├─────────────────────────────────────────────────────────────────┤
│ LAYER 4: COORDINATION                                            │
│                                                                   │
│  Agent Coordinator (Go)                                           │
│  - Task assignment via HCS                                        │
│  - Performance monitoring                                         │
│  - Agent reputation tracking                                      │
│  - Inter-agent communication                                      │
│  - Festival-structured work plans                                 │
├─────────────────────────────────────────────────────────────────┤
│ LAYER 3: AGENT RUNTIME                                           │
│                                                                   │
│  Agent Engine (Go)                                                │
│  - LLM integration (Claude/GPT for analysis)                     │
│  - Strategy execution loop                                        │
│  - Market adapter abstraction                                     │
│  - Position management                                            │
│  - Risk controls enforcement                                      │
│  - P&L reporting to HCS                                           │
├─────────────────────────────────────────────────────────────────┤
│ LAYER 2: MARKET ADAPTERS                                         │
│                                                                   │
│  ┌────────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Polymarket    │  │  Limitless   │  │  Drift BET           │  │
│  │  (Polygon)     │  │  (Base)      │  │  (Solana)            │  │
│  │                │  │              │  │                      │  │
│  │  CLOB API      │  │  REST + WS   │  │  Perp SDK            │  │
│  │  CTF tokens    │  │  Share model │  │  Pyth oracles        │  │
│  │  EIP-712 auth  │  │  USDC        │  │  Keeper bots         │  │
│  │  WebSocket     │  │              │  │                      │  │
│  │  $20M+/day vol │  │  $1B+ total  │  │  Growing             │  │
│  └────────────────┘  └──────────────┘  └──────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│ LAYER 1: ON-CHAIN CUSTODY & SETTLEMENT                           │
│                                                                   │
│  Solana Programs (Rust/Anchor)                                    │
│  - AgentRegistry: registration, metadata, ownership               │
│  - AgentVault: deposit, trade execution, share tokens             │
│  - NAVOracle: Pyth-based tiered valuation                         │
│  - PlatformFees: automated fee collection                         │
│                                                                   │
│  Cross-Chain Settlement                                           │
│  - Solana ↔ Polygon (Polymarket USDC)                             │
│  - Solana ↔ Base (Limitless USDC)                                 │
│  - Solana-native (Drift BET)                                      │
└─────────────────────────────────────────────────────────────────┘
```

## Component Breakdown

### Layer 1: On-Chain Custody (Solana — Rust/Anchor)

The trust layer. All funds, shares, and trading permissions live here. Users interact with these programs directly — no backend can override contract logic.

#### AgentRegistry Program

```
Accounts:
  PlatformState (PDA)     — global config, admin, fee rate
  AgentState (PDA)        — per-agent: creator, ownership_pct, agent_type,
                            accepted_assets[], approved_tokens[], risk_params,
                            metadata_uri, agent_signer, status
  AgentUpdateProposal     — pending agent address changes (timelock)

Instructions:
  initialize_platform(admin, fee_rate_bps)
  create_agent(agent_signer, owner_pct, agent_type, accepted_assets[],
               metadata_uri) → creates AgentState PDA + ShareMint PDA
  update_metadata(agent_id, new_uri) — creator only
  propose_agent_update(agent_id, new_signer) — starts 48hr timelock
  execute_agent_update(agent_id) — after timelock expires
  lower_owner_pct(agent_id, new_pct) — require new_pct < current
  add_accepted_asset(agent_id, mint) — must be platform-approved
  remove_accepted_asset(agent_id, mint) — creator only
  set_risk_params(agent_id, params) — can only tighten
  pause_agent(agent_id) — creator or circuit breaker
  unpause_agent(agent_id) — creator only
```

#### AgentVault Program

```
Accounts:
  VaultState (PDA)        — per-agent: total_assets, total_shares,
                            share_mint, positions[], last_nav_update
  VaultTokenAccount (ATA) — holds deposited assets (one per accepted asset)
  ShareMint (PDA)         — agent-specific share token mint
  UserShareAccount (ATA)  — user's share tokens for this agent
  BurnRequest (PDA)       — pending withdrawal (optional delay)

Instructions:
  deposit(agent_id, asset_mint, amount)
    → calculate shares at current NAV
    → mint creator_pct shares to creator
    → mint remaining shares to depositor
    → transfer asset to vault ATA

  request_burn(agent_id, share_amount)
    → lock shares in escrow
    → snapshot NAV
    → start withdrawal delay (if configured)

  execute_burn(agent_id, burn_request_id)
    → recalculate NAV at execution time
    → for each asset in vault: transfer proportional amount to user
    → burn share tokens

  execute_trade(agent_id, adapter_program, instruction_data)
    → require caller == agent_signer
    → require adapter_program is whitelisted
    → deduct platform fee (bps of trade value)
    → CPI to adapter program
    → post-trade: verify concentration limits
    → update position tracking

  report_nav(agent_id)
    → read Pyth feeds for all held assets
    → apply tiered valuation
    → update VaultState.total_assets
```

#### NAVOracle Module (within AgentVault)

```
Tiered Valuation Logic:

  fn calculate_nav(vault: &VaultState) -> u64:
    nav = 0
    for (mint, balance) in vault.token_balances:
      feed = pyth_registry.get_feed(mint)
      if feed.exists() AND feed.confidence < MAX_CONFIDENCE:
        price = feed.get_price_no_older_than(MAX_AGE)
        nav += balance * price
      else:
        nav += 0  // no feed or low confidence = $0
    return nav

Concentration Check:
  fn check_concentration(vault: &VaultState, nav: u64) -> bool:
    for (mint, balance) in vault.token_balances:
      if mint == vault.base_asset: continue  // USDC/SOL exempt
      token_value = balance * pyth_price(mint)
      if token_value * 100 / nav > MAX_CONCENTRATION_PCT:
        return false
    return true
```

#### PlatformFees Module

```
  fn deduct_fee(trade_value: u64, fee_rate_bps: u16) -> (net_value, fee):
    fee = trade_value * fee_rate_bps / 10_000
    net_value = trade_value - fee
    transfer fee to platform_treasury ATA
    return (net_value, fee)
```

### Layer 2: Market Adapters (Go)

Each adapter implements a common interface, abstracting platform differences:

```go
type MarketAdapter interface {
    // Discovery
    ListMarkets(ctx context.Context, filters MarketFilters) ([]Market, error)
    GetMarket(ctx context.Context, marketID string) (*Market, error)
    GetOrderBook(ctx context.Context, marketID string) (*OrderBook, error)

    // Trading
    PlaceOrder(ctx context.Context, order OrderRequest) (*OrderResult, error)
    CancelOrder(ctx context.Context, orderID string) error
    GetPositions(ctx context.Context) ([]Position, error)

    // Settlement
    RedeemPosition(ctx context.Context, positionID string) (*RedeemResult, error)
    GetClaimable(ctx context.Context) ([]ClaimablePosition, error)

    // Real-time
    SubscribeMarkets(ctx context.Context, marketIDs []string) (<-chan MarketEvent, error)
    SubscribeOrderBook(ctx context.Context, marketID string) (<-chan OrderBookUpdate, error)

    // NAV
    GetPositionValue(ctx context.Context, position Position) (decimal.Decimal, error)
}

type Market struct {
    ID              string
    Platform        string          // "polymarket" | "limitless" | "drift_bet"
    Question        string
    ResolutionRules string
    Outcomes        []Outcome       // [{name: "Yes", tokenID: "...", price: 0.65}, ...]
    Volume24h       decimal.Decimal
    Liquidity       decimal.Decimal
    ExpiresAt       time.Time
    Category        string
    Status          MarketStatus    // active | resolved | cancelled
}

type OrderRequest struct {
    MarketID  string
    Outcome   string          // "yes" | "no" | outcome name
    Side      Side            // buy | sell
    Price     decimal.Decimal // 0.01 - 0.99
    Size      decimal.Decimal // in collateral units
    OrderType OrderType       // limit | market | GTC | FOK
}
```

#### Polymarket Adapter

```go
type PolymarketAdapter struct {
    clobClient  *polymarket.CLOBClient    // CLOB API
    gammaClient *polymarket.GammaClient   // market metadata
    wsClient    *polymarket.WSClient      // real-time feeds
    signer      *ecdsa.PrivateKey         // EIP-712 signing
    apiCreds    *polymarket.APICredentials // HMAC-SHA256
}

// Key implementation details:
// - Auth: EIP-712 for credential creation, HMAC-SHA256 for requests
// - Orders: GTC/FOK via CLOB API, prices 0.00-1.00
// - Positions: CTF (ERC-1155) tokens — split/merge/redeem
// - Settlement: UMA Optimistic Oracle, ~2hr resolution
// - Rate limits: 9,000 req/10s (CLOB), 3,500/10s (orders)
// - WebSocket: wss://ws-subscriptions-clob.polymarket.com
// - Collateral: USDC.e on Polygon (bridged from Solana vault)
```

#### Limitless Adapter

```go
type LimitlessAdapter struct {
    restClient *limitless.Client
    wsClient   *limitless.WSClient
}

// Key implementation details:
// - Chain: Base
// - Model: Share-based ($0.01-$0.99), fully collateralized
// - Collateral: USDC on Base (bridged from Solana vault)
// - API: REST + WebSocket
```

#### Drift BET Adapter

```go
type DriftBETAdapter struct {
    driftClient *drift.Client
    pythClient  *pyth.Client
}

// Key implementation details:
// - Chain: Solana (native — no bridge needed)
// - Model: Perp-based BET markets
// - Oracles: Pyth + Switchboard
// - SDK: TypeScript/Python official, Go via HTTP
// - Collateral: USDC on Solana (direct from vault)
```

### Layer 3: Agent Runtime (Go)

The brain. Each funded agent runs an instance of the agent engine:

```go
type AgentEngine struct {
    id          string
    config      AgentConfig
    vault       VaultClient          // talks to Solana vault program
    adapters    []MarketAdapter      // prediction market connections
    llm         LLMClient            // Claude/GPT for analysis
    coordinator CoordinatorClient    // HCS for reporting
    riskMgr     RiskManager          // enforces risk params
    portfolio   PortfolioManager     // tracks positions across platforms
}

type AgentConfig struct {
    AgentID         string
    AgentType       AgentType        // prediction_market | defi_trading | hybrid
    Strategies      []StrategyConfig // which strategies to run
    RiskParams      RiskParams       // max drawdown, position limits, etc.
    Platforms       []string         // which adapters to use
    LLMProvider     string           // claude | gpt | deepseek
    RebalanceFreq   time.Duration    // how often to rebalance
}

// Main execution loop
func (e *AgentEngine) Run(ctx context.Context) error {
    ticker := time.NewTicker(e.config.RebalanceFreq)
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        case <-ticker.C:
            if err := e.executeCycle(ctx); err != nil {
                e.coordinator.ReportError(ctx, e.id, err)
            }
        case event := <-e.marketEvents:
            e.handleMarketEvent(ctx, event)
        }
    }
}

func (e *AgentEngine) executeCycle(ctx context.Context) error {
    // 1. Gather market data across all platforms
    markets, err := e.gatherMarkets(ctx)

    // 2. Get current positions and portfolio state
    positions, err := e.portfolio.GetAllPositions(ctx)

    // 3. LLM analysis — evaluate markets, generate signals
    signals, err := e.analyzeMarkets(ctx, markets, positions)

    // 4. Risk check — filter signals through risk manager
    approved, err := e.riskMgr.FilterSignals(ctx, signals, positions)

    // 5. Execute approved trades through vault
    for _, signal := range approved {
        result, err := e.executeTrade(ctx, signal)
        // ...
    }

    // 6. Check for resolved markets, redeem winners
    e.redeemResolved(ctx)

    // 7. Report P&L to coordinator via HCS
    e.coordinator.ReportPnL(ctx, e.id, e.portfolio.CalculatePnL())

    return nil
}
```

#### Strategy Framework

```go
type Strategy interface {
    Name() string
    Analyze(ctx context.Context, input StrategyInput) ([]Signal, error)
}

type StrategyInput struct {
    Markets     []Market
    Positions   []Position
    PortfolioNAV decimal.Decimal
    NewsEvents  []NewsEvent
    Forecasts   []ExternalForecast  // Metaculus, Manifold data
}

type Signal struct {
    MarketID    string
    Platform    string
    Direction   Side                // buy | sell
    Outcome     string              // "yes" | "no"
    Confidence  decimal.Decimal     // 0.0 - 1.0
    EdgeEstimate decimal.Decimal    // estimated edge vs market price
    Size        decimal.Decimal     // recommended position size
    Reasoning   string              // LLM explanation
    Strategy    string              // which strategy generated this
}
```

**Built-in Strategies:**

| Strategy | How It Works | Risk |
|----------|-------------|------|
| `NewsTrader` | LLM monitors news feeds, reacts to events affecting open markets | Medium-High |
| `ResolutionHunter` | LLM parses resolution rules, finds mispriced markets based on rule interpretation | Medium |
| `ArbitrageScanner` | Compares prices for equivalent events across Polymarket/Limitless/Drift | Low |
| `MarketMaker` | Provides liquidity on both sides, earns spread + maker rebates | Low-Medium |
| `FundamentalAnalyst` | Deep research on specific event categories (politics, crypto, macro) | Medium |
| `SentimentTracker` | Aggregates social media + forecasting platform signals | Medium |

### Layer 4: Coordination (Go — Existing)

Extends the existing coordinator:

```go
// Extends existing HCS-based coordination
type PlatformCoordinator struct {
    hcsClient    HCSClient           // existing Hedera integration
    agentManager AgentManager        // manages running agent instances
    metrics      MetricsCollector    // performance tracking
    leaderboard  LeaderboardService  // ranking agents
}

// HCS Message Types (extending existing protocol)
const (
    MsgAgentRegistered   = "agent_registered"
    MsgDepositReceived   = "deposit_received"
    MsgTradeExecuted     = "trade_executed"
    MsgPositionResolved  = "position_resolved"
    MsgPnLReport         = "pnl_report"
    MsgAgentPaused       = "agent_paused"
    MsgNAVUpdate         = "nav_update"
)
```

### Layer 5: Presentation (Next.js — Existing Dashboard Extended)

#### Marketplace Views

```
/agents                     — Browse/search all registered agents
/agents/:id                 — Agent profile (strategy, NAV chart, trade history)
/agents/:id/deposit         — Deposit flow
/agents/:id/withdraw        — Burn shares flow
/portfolio                  — User's funded agents + P&L
/leaderboard                — Top agents by NAV growth, Sharpe, volume
/creator                    — Creator management dashboard
/creator/:agentId/manage    — Edit metadata, config, risk params
```

## Cross-Chain Architecture

### Fund Flow

```
USER DEPOSITS (Solana)
    │
    ├── USDC deposited to AgentVault on Solana
    │
    ├── Agent needs to trade on Polymarket (Polygon)?
    │   └── Bridge USDC: Solana → Polygon via Wormhole/deBridge
    │       └── Trade on Polymarket CLOB
    │       └── Positions held as CTF tokens on Polygon
    │       └── Winnings: redeem CTF → USDC.e on Polygon
    │       └── Bridge back: Polygon → Solana vault
    │
    ├── Agent needs to trade on Limitless (Base)?
    │   └── Bridge USDC: Solana → Base via Wormhole/deBridge
    │       └── Trade on Limitless
    │       └── Bridge back: Base → Solana vault
    │
    ├── Agent needs to trade on Drift BET (Solana)?
    │   └── Direct: USDC from vault → Drift (same chain, no bridge)
    │       └── Trade on Drift BET markets
    │       └── Returns directly to vault
    │
    └── USER BURNS SHARES
        └── Receives proportional underlying assets from vault
```

### Bridge Strategy

| Route | Bridge | Latency | Cost |
|-------|--------|---------|------|
| Solana ↔ Polygon | Wormhole | ~15 min | ~$0.10 |
| Solana ↔ Base | Wormhole/deBridge | ~15 min | ~$0.10 |
| Solana ↔ Solana | Direct | Instant | $0.00025 |

**Optimization:** Agents batch bridge operations. Instead of bridging per-trade, they bridge in chunks (e.g., $5K at a time) and hold working capital on each chain. The vault tracks total assets across all chains.

### Multi-Chain Position Tracking

```go
type CrossChainPosition struct {
    Chain       string              // "solana" | "polygon" | "base"
    Platform    string              // "polymarket" | "limitless" | "drift_bet"
    MarketID    string
    Outcome     string
    Size        decimal.Decimal
    EntryPrice  decimal.Decimal
    CurrentPrice decimal.Decimal
    Value       decimal.Decimal     // size * currentPrice
    TokenID     string              // CTF token ID, share ID, etc.
}

// NAV = vault_solana_balance
//     + sum(polygon_positions.value)
//     + sum(base_positions.value)
//     + sum(solana_positions.value)
//     + bridged_in_transit
```

## Technology Stack

| Layer | Technology | Language |
|-------|-----------|----------|
| Vault programs | Anchor | Rust |
| Agent runtime | Custom engine | Go |
| Market adapters | HTTP/WS clients | Go |
| Coordinator | HCS (Hedera) | Go |
| Dashboard | Next.js | TypeScript/React |
| Bridge | Wormhole SDK | Go/TypeScript |
| Oracles | Pyth (Solana), Chainlink (EVM) | Rust (on-chain), Go (off-chain reads) |
| LLM | Claude API / GPT API | Go |
| Database | PostgreSQL | — |
| Cache | Redis | — |
| Queue | NATS | — |
| Deployment | Docker + K8s | — |
