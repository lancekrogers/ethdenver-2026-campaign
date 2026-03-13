# 00 — Executive Summary

## What We're Building

**OBEY Agent Platform** — a permissionless on-chain platform where anyone can create AI agents, fundraise capital from users, and let agents autonomously trade prediction markets across multiple platforms. Agents execute within smart contract custody — they can trade but never extract funds. Users burn share tokens to exit at NAV. The platform takes 1-2% of every transaction.

## Why Prediction Markets First

1. **AI agents have a structural edge** — 24/7 operation, multi-source information aggregation, resolution rule parsing, cross-platform arbitrage. No human can monitor 500 markets across 3 platforms continuously.
2. **Clear NAV** — prediction market positions have explicit probability prices (0.00-1.00). NAV calculation is simpler and more transparent than DeFi token valuation.
3. **Polymarket proves the market** — $20M+ daily volume on top markets, official AI agent framework already released. The market validates autonomous agent participation.
4. **Cross-platform arbitrage** — same events on Polymarket, Limitless, Kalshi, Drift BET with different prices. Funded agents can exploit discrepancies that retail cannot.
5. **Low manipulation risk** — prediction markets resolve to binary $0/$1 outcomes based on real-world events. No token price manipulation possible — the oracle is reality.

## Why Solana

- **40-400x cheaper** transactions than EVM ($0.00025 vs $0.01-0.10)
- **5x faster** blocks (400ms vs 2s)
- **Pyth oracles** — 500+ feeds, 400ms updates, Solana-native
- **Bags.fm** — native token launch platform with agent auth + fee sharing
- **Jupiter** — 90% aggregator share, HTTP APIs accessible from any language
- **Agent SDK ecosystem** — Solana Agent Kit v2, 60+ DeFi actions

## Business Model

| Revenue Stream | Mechanism | Scale |
|---------------|-----------|-------|
| Trade fees | 1-2% of every agent trade | Scales with AUM and trade frequency |
| Bags token fees | 1% creator fee on OBEY token volume | Scales with token trading activity |
| Premium agents | Featured placement, priority execution | Fixed + variable |

At $1M daily platform volume with 1.5% average fee: **$5.5M annual revenue**.

## The Full Stack

```
┌─────────────────────────────────────────────────────────┐
│                    OBEY AGENT PLATFORM                   │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │ Agent    │  │ Vault    │  │ NAV      │  │ Market  │ │
│  │ Registry │  │ Custody  │  │ Oracle   │  │ place   │ │
│  │          │  │          │  │          │  │         │ │
│  │ Create   │  │ Deposit  │  │ Pyth     │  │ Search  │ │
│  │ Manage   │  │ Trade    │  │ Chainlink│  │ Fund    │ │
│  │ Update   │  │ Burn     │  │ Tiered   │  │ Track   │ │
│  └──────────┘  └──────────┘  └──────────┘  └─────────┘ │
│                                                          │
│  ┌──────────────────────────────────────────────────────┐│
│  │              PREDICTION MARKET ADAPTERS              ││
│  │  Polymarket (Polygon) │ Limitless (Base) │ Drift BET││
│  └──────────────────────────────────────────────────────┘│
│                                                          │
│  ┌──────────────────────────────────────────────────────┐│
│  │              COORDINATION LAYER                      ││
│  │  HCS (Hedera) │ ERC-8004 Identity │ x402 Payments   ││
│  └──────────────────────────────────────────────────────┘│
│                                                          │
│  ┌──────────────────────────────────────────────────────┐│
│  │              INFRASTRUCTURE                          ││
│  │  Solana Vault Programs │ Bags.fm │ Dashboard         ││
│  └──────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Primary market | Prediction markets | AI structural edge, clear NAV, proven demand |
| Vault chain | Solana | Cost, speed, Bags integration, Pyth oracles |
| Primary target | Polymarket (Polygon) | Deepest liquidity, best APIs, CLOB model |
| Multi-platform | Yes — Polymarket + Limitless + Drift BET | Cross-platform arbitrage is a real edge |
| Agent runtime | Go | Existing codebase, performance, concurrency |
| Vault programs | Rust/Anchor | Required for Solana on-chain programs |
| NAV model | Oracle-only valuation | Pyth/Chainlink feeds only, no feed = $0 |
| Anti-gaming | Approved token list + oracle-only NAV + concentration limits | Closed system, no manipulation path |
| Coordination | HCS (Hedera) | Existing infrastructure, immutable audit trail |
| Identity | ERC-8004 | Existing infrastructure, on-chain agent identity |
