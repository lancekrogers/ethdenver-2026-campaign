# Prediction Markets — Platform Integration Exploration

## Opportunity

AI agents are uniquely suited for prediction markets: 24/7 operation, multi-source information aggregation, resolution rule parsing, and cross-platform arbitrage. Our agent platform (vault + shares + custody) maps directly — users fund prediction market agents the same way they fund trading agents.

## Landscape Summary

| Platform | Chain | Model | Volume | Agent-Ready |
|----------|-------|-------|--------|-------------|
| **Polymarket** | Polygon | CLOB | $20M+/day top markets | Yes — official agent framework, 3 SDKs |
| **Kalshi** | Centralized | Orderbook | Growing | Yes — REST/WS/FIX APIs, but KYC required |
| **Limitless** | Base | CLOB | $1B+ total | Yes — REST + WebSocket |
| **Drift BET** | Solana | Perp-based | Secondary feature | Yes — mature SDK |
| **Azuro** | Multi-EVM | AMM | Moderate | Partial — AMM less suited for agents |
| **Manifold** | Off-chain | Play money | Large social | Yes — full API, zero-risk training |
| **Metaculus** | Off-chain | Scoring | N/A | Data source only — not a market |

## Polymarket (Primary Target)

### Why Polymarket First
- Largest volume, deepest liquidity
- CLOB model = tight spreads, limit orders, algorithmic market making
- **Already built an open-source AI agent framework** (`github.com/Polymarket/agents`)
- Gasless builder program (zero gas for order operations)
- 3 official SDKs: TypeScript, Python, Rust

### Technical Integration

**Architecture:**
```
OBEY Prediction Agent
├── Data Layer
│   ├── Gamma API → market metadata
│   ├── CLOB API → orderbook, prices
│   ├── WebSocket → real-time feeds
│   └── External → news, social, on-chain data
├── Analysis Layer
│   ├── LLM reasoning (resolution rule parsing)
│   ├── Probability estimation models
│   └── Portfolio risk management
├── Execution Layer
│   ├── py_clob_client / clob-client SDK
│   ├── EIP-712 signing
│   └── CTF token management (split/merge/redeem)
└── Settlement
    ├── Auto-redeem winning positions
    └── Report P&L to HCS
```

**Key APIs:**
- CLOB: `https://clob.polymarket.com` — orders, orderbook, pricing
- Gamma: `https://gamma-api.polymarket.com` — markets, events, metadata
- Data: `https://data-api.polymarket.com` — positions, trades, leaderboards
- WebSocket: `wss://ws-subscriptions-clob.polymarket.com/ws/market`

**Conditional Token Framework (CTF):**
- Binary markets → YES token + NO token (ERC-1155)
- YES + NO = $1.00 USDC.e (fully collateralized)
- Split (USDC → YES+NO), Merge (YES+NO → USDC), Redeem (winner → USDC)
- Contracts on Polygon (`0x4bFb...982E` exchange, `0x4D97...8982E` CTF)

**Auth:** Two-level — EIP-712 for credentials, HMAC-SHA256 for API requests

**Rate Limits:** 9,000 req/10s (CLOB), 4,000/10s (Gamma), 3,500/10s burst for orders

### Fee Structure
- Most markets: **no fees**
- Crypto markets: up to 1.56% taker fee at 50% probability
- Sports: up to 0.44% taker fee
- Maker rebates: 20-25% of taker fees

## Agent Strategy Categories

| Strategy | Description | Risk | Fit for Platform |
|----------|-------------|------|-----------------|
| **News Trader** | React to breaking news faster than market | Medium-High | High — LLM-native advantage |
| **Market Maker** | Provide liquidity, earn spread + rebates | Low-Medium | High — consistent, algorithmic |
| **Resolution Hunter** | Parse rules to find mispriced markets | Medium | High — LLM excels at text analysis |
| **Cross-Platform Arb** | Price discrepancies across platforms | Low | High — multi-platform monitoring |
| **Fundamental Analyst** | Deep research on event categories | Medium | Medium — requires domain expertise |

## How It Fits Our Platform

Prediction market agents slot directly into the agent platform architecture:

1. **Creator registers a prediction market agent** with strategy description
2. **Users fund the agent** with USDC (or other accepted assets)
3. **Agent operates on Polymarket** — places orders, manages positions, redeems winners
4. **All funds stay in custody** — agent interacts with Polymarket via the vault contract
5. **Users burn shares to exit** at proportional NAV
6. **Platform takes 1-2%** of trade volume

### NAV for Prediction Market Agents

Prediction market positions have clear valuations:
- **Open positions** = current market price × quantity (from CLOB API)
- **Won positions** = $1.00 × quantity (pending redemption)
- **Lost positions** = $0.00
- **Cash** = USDC.e balance

This is actually *simpler* than DeFi NAV because prediction market prices are explicit probabilities (0.00-1.00) rather than oracle-derived.

### Multi-Chain Consideration

Polymarket is on Polygon, our platform vaults would be on Base or Solana. Options:
- **Bridge approach:** Vault on Base → bridge USDC to Polygon → trade on Polymarket
- **Separate custody:** Polygon-native vault for prediction market agents
- **API-only:** Agent holds its own Polygon wallet, reports P&L to HCS, vault tracks NAV off bridge

## Solana Prediction Market Gap

The Solana prediction market landscape is notably thin:
- **Drift BET** — secondary feature on their perp DEX
- **Hedgehog** — P2P/parimutuel, low liquidity
- **HXRO** — possibly inactive

This is either:
1. **An opportunity** — build a Solana-native prediction market with agent-first design
2. **A signal** — prediction markets work better on EVM (Polymarket's success proves the model)

For now, Polymarket integration is the clear first move. Solana prediction markets can come later if the gap persists.

## Cross-Platform Arbitrage

Same events listed on Polymarket, Kalshi, Limitless, Manifold with different prices due to:
- Different user bases and biases
- Liquidity fragmentation
- Regulatory arbitrage (US-only Kalshi vs global Polymarket)
- Timezone effects on thin markets

An agent monitoring equivalent markets across platforms can capture low-risk profit from these discrepancies. This is a strong differentiator for funded agents on our platform.

## Training Pipeline

**Manifold Markets** (play money, full API) is perfect for:
- Training agents at zero financial risk
- Backtesting strategies against real crowd forecasts
- Validating resolution rule parsing
- Building track records before deploying real capital

Flow: Train on Manifold → Validate → Deploy on Polymarket with real capital

## Next Steps

1. Prototype a Polymarket agent using their official framework (`github.com/Polymarket/agents`)
2. Extend with custom LLM analysis (resolution rule parsing, news aggregation)
3. Design vault integration for Polygon-based prediction market agents
4. Test cross-platform arbitrage between Polymarket and Limitless (both have APIs)
5. Build Manifold training pipeline for strategy validation

## Full Research

See `ai_docs/research/prediction-markets-landscape.md` for complete technical details including all API endpoints, contract addresses, SDK examples, and competitor deep dives.
