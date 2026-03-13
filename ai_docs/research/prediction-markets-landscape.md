# Prediction Markets Landscape: AI Agent Integration Research

**Date:** 2026-03-13
**Purpose:** Exploration document for integrating prediction markets with an AI agent trading platform on-chain.

---

## 1. Polymarket — Technical Deep Dive

### Overview

Polymarket is the world's largest on-chain prediction market, operating on **Polygon (Chain ID: 137)**. It uses a **Central Limit Order Book (CLOB)** model rather than an AMM, which provides tighter spreads and more efficient price discovery. Collateral is denominated in **USDC.e** (bridged USDC on Polygon).

### Architecture

Polymarket's architecture consists of four primary API surfaces:

| API | Base URL | Purpose | Auth Required |
|-----|----------|---------|---------------|
| **CLOB API** | `https://clob.polymarket.com` | Orderbook, pricing, order management | Public reads; authenticated writes |
| **Gamma API** | `https://gamma-api.polymarket.com` | Markets, events, metadata | No |
| **Data API** | `https://data-api.polymarket.com` | User positions, trades, leaderboards | No |
| **Bridge API** | `https://bridge.polymarket.com` | Deposits/withdrawals | Yes |

**WebSocket:** `wss://ws-subscriptions-clob.polymarket.com/ws/market` for real-time orderbook, price changes, trades, and market resolution events. Requires PING every 10 seconds.

### CLOB vs AMM

Polymarket deliberately chose a CLOB over an AMM. Key characteristics:

- **Traditional bid-ask order levels** — bids sorted highest-first, asks sorted lowest-first
- **Configurable tick sizes** per market (minimum price increment)
- **Minimum order sizes** enforced
- **Spread** (best ask minus best bid) indicates liquidity depth
- **Order types:** GTC (Good-Till-Canceled), FOK (Fill-or-Kill)
- **Market orders** supported by walking the order book
- Prices range from **0.00 to 1.00**, representing implied probability

This is a significant advantage over AMM-based prediction markets — CLOBs provide better capital efficiency, tighter spreads, and more sophisticated order management for algorithmic traders and agents.

### Conditional Token Framework (CTF)

Polymarket uses the **Gnosis Conditional Token Framework** — an open standard that tokenizes prediction market outcomes as **ERC-1155 tokens**.

**How it works:**

1. **Binary markets** issue two tokens: YES and NO
2. Every YES + NO pair is **fully collateralized by $1.00 USDC.e**
3. Three core operations:
   - **Split:** Convert USDC.e into YES + NO token pairs
   - **Merge:** Convert YES + NO pairs back to USDC.e
   - **Redeem:** Exchange winning tokens for USDC.e post-resolution

**Position identification** uses a three-step derivation:
1. **Condition ID** — computed from oracle address (UMA CTF Adapter) + questionId hash + outcomeSlotCount (2 for binary)
2. **Collection IDs** — derived from parentCollectionId + conditionId + indexSet bitmask
3. **Position IDs** — combines collateral token (USDC.e) with collectionId to generate unique ERC-1155 token IDs

**Neg Risk Markets:** Multi-outcome markets use the Neg Risk CTF Exchange with additional conversion mechanics allowing No tokens to exchange for Yes tokens across outcomes.

### Smart Contracts (Polygon)

| Contract | Address | Purpose |
|----------|---------|---------|
| CTF Exchange | `0x4bFb41d5B3570DeFd03C39a9A4D8dE6Bd8B8982E` | Standard market order matching/settlement |
| Neg Risk CTF Exchange | `0xC5d563A36AE78145C45a50134d48A1215220f80a` | Multi-outcome market matching |
| Neg Risk Adapter | `0xd91E80cF2E7be2e162c6513ceD06f1dD0dA35296` | No token conversion across outcomes |
| Conditional Tokens (CTF) | `0x4D97DCd97eC945f40cF65F87097ACe5EA0476045` | ERC-1155 token operations |
| USDC.e | `0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174` | Collateral token (6 decimals) |
| UMA Adapter | `0x6A9D222616C90FcA5754cd1333cFD9b7fb6a4F74` | Links to UMA Optimistic Oracle |
| UMA Optimistic Oracle | `0xCB1822859cEF82Cd2Eb4E6276C7916e692995130` | Resolution proposals/disputes |

### UMA Oracle Resolution Process

Polymarket uses the **UMA Optimistic Oracle** for decentralized, permissionless market resolution:

1. **Proposal Phase:** Anyone can submit a resolution by selecting the winning outcome and posting a bond (typically $750 USDC.e). Incorrect proposals result in total bond loss.
2. **Challenge Period (2 hours):** Disputers can challenge by posting a matching counter-bond.
3. **UMA Vote (if disputed):** 24-48 hour debate period, then UMA token holders vote (~48 hours). Bonds distributed based on voting results.

**Resolution timelines:**
- No dispute: ~2 hours
- One dispute: Resolution after second proposal
- Two disputes: Full DVM token holder vote (4-6 days total)

Post-resolution: trading stops, winning tokens redeem for $1.00 USDC.e via `redeemPositions`, losing tokens become worthless.

### Fee Structure

The majority of Polymarket markets have **no trading fees**. Three categories charge taker fees:

| Category | Fee Rate | Exponent | Maker Rebate | Peak Fee (at 50% probability) |
|----------|----------|----------|--------------|-------------------------------|
| Crypto | 0.25 | 2 | 20% | 1.56% |
| Sports (NCAAB, Serie A) | 0.0175 | 1 | 25% | 0.44% |

Fee formula: `fee = C * p * feeRate * (p * (1 - p))^exponent`

Fees peak at 50% probability and decrease symmetrically toward extremes. Makers receive daily USDC rebates proportional to their liquidity contribution.

### Volume & Scale

Current active markets span politics (2028 US Presidential), geopolitics (Iran/Strait of Hormuz), macroeconomics (Fed decisions), crypto prices, sports, and weather. Single-day volumes on top markets:

- **Fed decision (March 2026):** ~$23M 24h volume
- **Iran/Strait of Hormuz:** ~$16.6M 24h volume
- **Democratic Presidential Nominee 2028:** ~$7.2M 24h volume
- **UEFA Europa League match:** ~$8.3M 24h volume

The platform runs 24/7 with continuous trading across short-term (5-minute, 15-minute crypto) to long-term (2028 elections) prediction windows.

### SDKs & Programmatic Access

Official client libraries:
- **TypeScript:** `@polymarket/clob-client`
- **Python:** `py_clob_client`
- **Rust:** `polymarket_client_sdk`

**Authentication:** Two-level system:
- **L1 (Private Key):** EIP-712 signed messages for credential creation
- **L2 (API Key):** HMAC-SHA256 signed requests using apiKey/secret/passphrase

**Rate Limits:**
- CLOB API: 9,000 req/10s general; POST /order: 3,500 req/10s burst, 36,000/10min sustained
- Gamma API: 4,000 req/10s general
- Data API: 1,000 req/10s general
- Relayer: 25 req/1min

### Gasless Trading (Builder Program)

Builders can route user orders through Polymarket's relayer infrastructure — **zero gas fees** for:
- Wallet deployment (Safe or Proxy wallets)
- Token approvals
- CTF operations (split, merge, redeem)
- Token transfers

Users only need USDC.e; Polymarket covers all gas. Builders get order attribution, leaderboard visibility, and weekly USDC rewards.

### Polymarket Agents (Official)

Polymarket has released an **open-source AI agent framework** (`github.com/Polymarket/agents`) for autonomous prediction market trading:

- **Architecture:** Modular Python framework (3.9+)
- **Components:**
  - Gamma API client for market metadata
  - Polymarket core for order signing and DEX execution
  - Chroma vector database for indexing news/data
  - LLM integration (OpenAI API) for analysis and decision-making
  - RAG (Retrieval-Augmented Generation) support
- **Workflow:** Data collection → LLM analysis → Order construction/signing → DEX submission
- **Deployment:** CLI, direct scripts, or Docker

This is a strong signal that Polymarket recognizes autonomous agents as a key user category.

---

## 2. Competitor Landscape

### Kalshi

**Type:** US-regulated prediction exchange (CFTC-regulated DCM)
**Chain:** Centralized / off-chain
**Key differentiator:** Only CFTC-regulated prediction market in the US

**Technical:**
- REST API + WebSocket + FIX protocol
- RSA public key cryptography for authentication
- TypeScript and Python SDKs
- Binary event contracts with centralized settlement
- Order types: limit orders, RFQs (Request for Quotes)
- Max 200,000 open orders per user
- Subaccount support (max 32 per user)
- Historical data endpoints with candlestick aggregations

**Market structure:**
- Events contain multiple binary markets
- Series templates for recurring events (e.g., Monthly Jobs Report, Daily Weather)
- Multivariate events with combo markets (up to 5,000 weekly creations)

**Comparison to Polymarket:** Kalshi is centralized and US-regulated, meaning it has legal clarity but limited composability. No smart contracts, no on-chain settlement, no DeFi integration. Less suitable for autonomous agent integration due to regulatory requirements around KYC/AML for all traders.

### Augur

**Type:** Decentralized prediction market protocol
**Chain:** Ethereum
**Token:** REP (governance/dispute resolution)
**Status:** Undergoing resurgence as of January 2026 with "Lituus" modular oracle

**Key features:**
- Fully decentralized market creation and resolution
- REP token holders serve as the dispute resolution oracle
- Pioneered the on-chain prediction market concept
- Open-source smart contracts

**Comparison:** Augur was first but suffered from high Ethereum gas costs and low liquidity. The Lituus reboot signals renewed activity, but it remains far behind Polymarket in volume and UX.

### Azuro

**Type:** Decentralized prediction market protocol / sports betting
**Chain:** EVM-compatible (multiple chains)
**Token:** AZUR
**Model:** AMM-based (not CLOB)

**Key features:**
- **Singleton concentrated liquidity pool** — all markets access the full pool capacity
- **LiquidityTree** — novel segment tree for tracking LP positions and P&L distribution
- **vAMMs** for market pricing
- Permissionless frontend creation — anyone can build a betting interface
- TypeScript SDK (`@azuro-org/toolkit`)
- Data providers supply event information

**Ecosystem roles:** Bettors, Apps/Frontends, LPs, Data Providers

**Comparison:** AMM-based model means less capital efficiency than Polymarket's CLOB. Focused more on sports betting. Interesting LP model but less suited for programmatic agent trading due to AMM mechanics.

### Limitless Exchange

**Type:** Prediction market
**Chain:** Base
**Volume:** $1B+ total trading volume claimed

**Key features:**
- Share-based model (YES/NO shares, $0.01-$0.99)
- Fully collateralized ($1 USDC per YES+NO pair)
- REST + WebSocket API
- Hourly and daily crypto/stock prediction markets

**Comparison:** Base-native, growing fast. Similar mechanics to Polymarket but smaller. API availability makes it potentially interesting for agent integration.

### Thales / Overtime

**Type:** On-chain sportsbook and digital options
**Chain:** Multiple EVM chains
**Model:** AMM with Chainlink oracles

**Key features:**
- Three dApps: Overtime Sportsbook, Speed Markets, Thales Markets
- Chainlink data feeds for resolution
- Trustless liquidity pools

**Comparison:** Primarily sports-focused. AMM model. Less prediction market, more structured betting.

### Manifold Markets

**Type:** Play-money prediction market
**Chain:** Off-chain (web platform)
**Currency:** Mana (play money, not convertible to cash)

**Key features:**
- World's largest social prediction market
- Forecasts within 4 percentage points of true probability on average
- Full REST API + WebSocket at `api.manifold.markets/v0`
- Market creation: M$50 for binary markets
- Bot-friendly: programmatic betting, market creation, and resolution
- 500 req/min rate limit

**API capabilities:**
- Create markets, place bets, resolve markets
- Limit orders, multi-bet, position selling
- WebSocket for real-time updates
- User management, comments, transaction history

**Comparison:** Excellent for training/backtesting AI agents at zero financial risk. Strong API. No real money involved, so it's a sandbox environment. Could be used as a training ground before deploying agents on Polymarket.

### Metaculus

**Type:** Forecasting platform (not a market)
**Chain:** Off-chain
**Model:** Scoring-based predictions, not trading

**Key features:**
- Open-source (Django/React stack)
- Sophisticated scoring system
- Questions wrapped in Posts
- Strong community of forecasters

**Comparison:** Not a prediction market — it's a forecasting platform. No financial positions, no trading. However, Metaculus aggregate forecasts could serve as a valuable data source for AI agents trading on actual prediction markets.

---

## 3. Solana Prediction Markets

The Solana prediction market ecosystem is notably thinner than EVM-based alternatives:

### Drift Protocol (BET Markets)

**Status:** Active but lightly documented
**Chain:** Solana
**SDKs:** TypeScript, Python

Drift's prediction markets operate as "BET" markets within their broader perpetuals DEX. Markets include:
- Election predictions
- Sports (Super Bowl, NBA, F1)
- Crypto events
- Miscellaneous predictions

Uses **Pyth Network** and **Switchboard** oracles for price feeds. Built on Drift's existing perpetual futures infrastructure, meaning it inherits the full Drift SDK (TypeScript/Python) and keeper bot infrastructure.

**Agent integration:** Drift has open-source keeper bots and a mature SDK, making programmatic trading feasible. The prediction market feature is an extension of their perp trading system.

### Hedgehog Markets

**Status:** Active
**Chain:** Solana
**Model:** P2P + parimutuel

Key repos: `hedgehog-escrow` (P2P markets), `hedgehog-program-library` (client SDKs), with TypeScript SDK and Rust on-chain programs. Uses Switchboard V2 for oracle services.

**Agent integration:** TypeScript SDK available. P2P model means less liquidity depth than CLOB markets but simpler mechanics for automated trading.

### HXRO Network

**Status:** Previously active on Solana; connectivity issues as of March 2026 (site unreachable)
**Chain:** Solana
**Model:** Parimutuel protocol

HXRO built a parimutuel prediction market protocol on Solana. Historically significant but current operational status is unclear given the unreachable documentation.

### Assessment

Solana prediction markets are **early-stage** compared to Polygon/EVM. Drift is the most credible player but their prediction market feature is secondary to their perp DEX. There is a significant **gap** in Solana for a purpose-built, high-liquidity prediction market with strong API/agent support.

---

## 4. Technical Integration Points for AI Agents

### Polymarket Integration Architecture

An autonomous agent trading on Polymarket would follow this stack:

```
[AI Agent Brain]
    ├── Data Ingestion Layer
    │   ├── Gamma API → market metadata, events
    │   ├── CLOB API → orderbook, prices, spreads
    │   ├── WebSocket → real-time price/trade/resolution feeds
    │   ├── Data API → positions, trade history
    │   └── External Sources → news, social, on-chain data
    │
    ├── Analysis Layer
    │   ├── LLM reasoning (event analysis, resolution rule parsing)
    │   ├── Quantitative models (probability estimation)
    │   ├── RAG over news/research corpus
    │   └── Portfolio risk management
    │
    ├── Execution Layer
    │   ├── py_clob_client / @polymarket/clob-client
    │   ├── Order construction (limit, market, GTC, FOK)
    │   ├── EIP-712 signing
    │   ├── HMAC-SHA256 API authentication
    │   └── Position management (split/merge/redeem CTF tokens)
    │
    └── Settlement Layer
        ├── Monitor resolution via WebSocket (market_resolved events)
        ├── Auto-redeem winning positions
        └── Rebalance portfolio
```

### Key Integration Code Path (Python)

```python
from py_clob_client.client import ClobClient
from py_clob_client.clob_types import OrderArgs, OrderType

# Initialize
client = ClobClient(
    host="https://clob.polymarket.com",
    key=PRIVATE_KEY,
    chain_id=137,
    signature_type=1,
    funder=FUNDER_ADDRESS
)
client.set_api_creds(client.create_or_derive_api_creds())

# Get market data
markets = client.get_simplified_markets()
book = client.get_order_book(token_id)
midpoint = client.get_midpoint(token_id)

# Place order
order = OrderArgs(token_id=TOKEN_ID, price=0.45, size=100.0, side=BUY)
signed = client.create_order(order)
response = client.post_order(signed, OrderType.GTC)

# Monitor positions
positions = client.get_orders()
```

### Multi-Platform Agent Architecture

For an agent platform that spans multiple prediction markets:

```
[Agent Orchestrator]
    ├── Market Adapters
    │   ├── Polymarket Adapter (Polygon, CLOB, CTF)
    │   ├── Kalshi Adapter (Centralized, REST/FIX)
    │   ├── Drift BET Adapter (Solana, perp-based)
    │   ├── Limitless Adapter (Base, CLOB)
    │   └── Manifold Adapter (Play money, REST)
    │
    ├── Unified Market Interface
    │   ├── getMarkets() → normalized market objects
    │   ├── getOrderBook() → normalized bid/ask levels
    │   ├── placeOrder() → adapter-specific execution
    │   ├── getPositions() → portfolio view
    │   └── resolvePosition() → claim winnings
    │
    ├── Cross-Market Arbitrage Engine
    │   ├── Detect price discrepancies across platforms
    │   ├── Equivalent event matching (same question, different platforms)
    │   └── Execution with latency awareness
    │
    └── Risk Management
        ├── Position sizing per market/platform
        ├── Correlation tracking across bets
        ├── Maximum drawdown limits
        └── Liquidity-aware order sizing
```

### Smart Contract Direct Integration

For deeper on-chain integration, agents can interact directly with Polymarket's contracts:

- **CTF Contract** (`0x4D97...8982E`): `splitPosition()`, `mergePositions()`, `redeemPositions()`
- **Exchange Contracts**: Direct settlement if bypassing the CLOB API
- **UMA Oracle**: Propose/dispute resolutions (bond: ~$750 USDC.e)

### WebSocket Events for Agent Automation

Critical real-time events:

| Event | Agent Action |
|-------|-------------|
| `price_change` | Re-evaluate positions, adjust limit orders |
| `last_trade_price` | Update internal probability estimates |
| `tick_size_change` | Adjust order precision |
| `new_market` | Evaluate new opportunities |
| `market_resolved` | Trigger redemption of winning positions |
| `best_bid_ask` | Spread monitoring for market-making strategies |

---

## 5. The Opportunity: AI Agents in Prediction Markets

### Why AI Agents Are Uniquely Suited

**1. Information Aggregation at Scale**

Prediction markets fundamentally reward superior information processing. AI agents can:
- Continuously monitor thousands of news sources, social media signals, and on-chain data
- Cross-reference resolution rules against real-world data streams
- Process information in multiple languages simultaneously
- Detect relevant signals before human traders react

**2. 24/7 Operation**

Polymarket trades continuously. Human traders sleep; agents don't. This creates systematic advantages:
- Capturing overnight news events immediately
- Maintaining positions during low-liquidity periods (wider spreads = more alpha)
- Reacting to geopolitical events in real-time regardless of timezone
- Running 5-minute and 15-minute crypto prediction markets is impractical for humans but natural for agents

**3. Multi-Source Analysis**

Modern LLMs can synthesize:
- News articles and press releases
- Social media sentiment
- On-chain data (whale movements, governance votes)
- Historical prediction market accuracy
- Expert forecasts (Metaculus, academic predictions)
- Resolution rule parsing (critical — the rules, not the title, determine outcomes)

**4. Resolution Rule Arbitrage**

Polymarket's documentation emphasizes: "Always read the resolution rules before trading. The market title describes the question, but the rules define how it resolves." AI agents can:
- Parse resolution rules systematically
- Identify edge cases where market prices don't reflect the actual resolution criteria
- Detect mispriced markets where the title is ambiguous but rules are clear

**5. Market Making**

AI agents can serve as algorithmic market makers:
- Quote both sides of the book continuously
- Earn maker rebates (20-25% of taker fees)
- Manage inventory risk across correlated markets
- Provide liquidity in thin markets for additional spread capture

### Platform Model: Users Fund Agents That Trade Prediction Markets

The business model where users fund AI agents to trade prediction markets has several powerful dynamics:

**For Users:**
- Access to 24/7 automated prediction market trading
- Exposure to a unique alpha source (information markets)
- Diversification beyond traditional DeFi (lending, LPing, perps)
- Transparent on-chain performance tracking

**For the Platform:**
- Management fees / performance fees on agent profits
- Aggregated liquidity across many users
- Ability to run sophisticated strategies that require scale
- Network effects — more capital → better market making → tighter spreads → more users

**Agent Strategy Categories:**

| Strategy | Description | Risk Profile |
|----------|-------------|-------------|
| **News Trader** | React to breaking news faster than the market | Medium-High |
| **Fundamental Analyst** | Deep research on specific event categories | Medium |
| **Market Maker** | Provide liquidity, earn spread + rebates | Low-Medium |
| **Arbitrageur** | Cross-platform price discrepancy capture | Low |
| **Sentiment Analyst** | Social media/prediction aggregation | Medium |
| **Resolution Hunter** | Parse resolution rules to find mispriced markets | Medium |

### Cross-Platform Arbitrage Opportunity

The same events are often listed across multiple platforms (Polymarket, Kalshi, Limitless, Manifold). Price discrepancies arise from:
- Different user bases with different biases
- Liquidity fragmentation
- Regulatory arbitrage (Kalshi US-only pricing vs global Polymarket pricing)
- Time-zone effects on thin markets

An AI agent that monitors equivalent markets across platforms can capture risk-free or low-risk profit from these discrepancies.

### Solana Integration Opportunity

Given the thin Solana prediction market landscape, there's an opportunity to:
1. Build a Solana-native prediction market protocol with agent-first APIs
2. Integrate with Drift's existing BET infrastructure via their SDK
3. Use Pyth oracles for resolution (already established on Solana)
4. Leverage Solana's speed/cost for high-frequency prediction market strategies (5-min, 15-min markets)

### Data Sources for Agent Intelligence

| Source | Type | Value |
|--------|------|-------|
| Polymarket Gamma API | Market data | Current odds, event metadata |
| Polymarket WebSocket | Real-time | Price changes, trades, resolutions |
| Metaculus | Forecasts | Expert probability estimates |
| Manifold Markets | Crowd forecasts | Free play-money market signals |
| News APIs | Text | Breaking news for event analysis |
| Social Media APIs | Sentiment | Twitter/X, Reddit for public opinion |
| On-chain data | Blockchain | Whale movements, governance votes |
| Economic data feeds | Macroeconomic | For Fed/inflation/employment markets |
| Sports data APIs | Statistics | For sports betting markets |

---

## 6. Key Takeaways

1. **Polymarket is the clear leader** — CLOB model, CTF tokens, robust APIs, official AI agent framework, gasless builder program, $20M+ daily volume on top markets.

2. **The CLOB model is superior for agents** — limit orders, FOK/GTC, real-time WebSocket, programmatic order management. AMM-based alternatives (Azuro, Thales) are less suitable for sophisticated algorithmic trading.

3. **Polymarket already validates the thesis** — they've built and open-sourced an AI agent trading framework. The market recognizes agents as a first-class participant category.

4. **Multi-platform integration creates alpha** — cross-platform arbitrage between Polymarket, Kalshi, Limitless, and Manifold is a concrete, low-risk strategy.

5. **Solana is underserved** — no dominant prediction market protocol. Drift BET exists but is secondary to their perp DEX. This is either an opportunity (build it) or a constraint (bridge to Polygon for Polymarket access).

6. **The agent-as-fund model works** — users deposit capital, agents trade prediction markets autonomously, transparent on-chain P&L. This is a natural extension of the AI agent economy concept.

7. **Key technical requirements:**
   - Polygon integration (for Polymarket)
   - EIP-712 signing and HMAC-SHA256 auth
   - WebSocket management for real-time data
   - LLM integration for event analysis
   - CTF token management (split/merge/redeem)
   - Risk management and position sizing
   - Multi-chain support if spanning multiple platforms
