# 07 — Revenue Model & Growth Strategy

## Revenue Streams

### Stream 1: Platform Trade Fees (Primary)

**Mechanism:** 1-2% of every trade value executed through the vault.
**Collection:** Automated, on-chain, deducted before trade execution.

```
Agent executes $10,000 trade
  → Platform fee (1.5%): $150
  → Net trade value: $9,850
  → Fee sent to platform treasury
```

**Scale projections:**

| AUM | Avg Daily Turnover | Daily Volume | Daily Revenue | Annual Revenue |
|-----|-------------------|-------------|--------------|----------------|
| $500K | 5% | $25K | $375 | $137K |
| $2M | 5% | $100K | $1,500 | $547K |
| $10M | 5% | $500K | $7,500 | $2.7M |
| $50M | 5% | $2.5M | $37,500 | $13.7M |
| $100M | 5% | $5M | $75,000 | $27.4M |

5% daily turnover is conservative for prediction market agents — Polymarket agents trade frequently on short-term markets (5-min, 15-min, hourly crypto markets).

### Stream 2: OBEY Token Fees (Bags)

**Mechanism:** 1% creator fee on all OBEY token trading volume on Bags/Meteora.
**Collection:** Claimed periodically via Bags API.

| Daily OBEY Volume | Daily Fee (1%) | Platform Share (40%) | Annual Platform Revenue |
|-------------------|---------------|---------------------|----------------------|
| $10K | $100 | $40 | $14.6K |
| $100K | $1,000 | $400 | $146K |
| $1M | $10,000 | $4,000 | $1.46M |

### Stream 3: Agent Registration Fees (Future)

Optional one-time fee for agent registration. Could be in SOL or OBEY tokens.
- Prevents spam registrations
- Revenue: small but scales with agent count
- Alternative: require OBEY token staking (not a fee, but creates token demand)

### Stream 4: Premium Features (Future)

| Feature | Price | Value Proposition |
|---------|-------|-------------------|
| Featured Agent Placement | $500/month | Top of marketplace |
| Priority Execution | $200/month | Faster trade routing |
| Advanced Analytics | $100/month | Deep performance attribution |
| Custom Strategies | Negotiated | White-glove agent strategy development |

## Growth Strategy

### Phase 1: Prove the Model (Month 1-2)

**Goal:** 3-5 reference agents generating real returns on mainnet.

```
Steps:
1. Deploy vault contracts on Solana mainnet
2. Register 3 platform-operated agents:
   - "OBEY Arb" — cross-platform arbitrage (Polymarket + Limitless)
   - "OBEY News" — news-driven trading on Polymarket
   - "OBEY Macro" — macro/Fed/economic event specialist
3. Seed each with $5K-$10K in platform capital
4. Run for 30 days, publish results transparently
5. Launch OBEY token on Bags
6. Submit Bags hackathon application with live results

Target: $15K-$30K AUM, positive returns, live proof of concept
```

### Phase 2: Open Registration (Month 2-4)

**Goal:** External creators register agents, first external depositors.

```
Steps:
1. Open agent registration to external creators
2. Launch marketplace UI (search, filter, leaderboards)
3. Marketing push: "Fund AI agents that trade prediction markets"
4. Content: blog posts, Twitter threads, Discord community
5. Incentive: first 10 agents get fee waiver for 30 days
6. Partner with Polymarket builder program (gasless orders)

Target: 20+ agents, $100K+ AUM, 50+ depositors
```

### Phase 3: Scale (Month 4-8)

**Goal:** Significant AUM, agent diversity, community growth.

```
Steps:
1. Add Drift BET adapter (Solana-native prediction markets)
2. OBEY token staking for agent registration
3. Fee discounts for OBEY holders
4. Agent Performance Pool distributions (reward top agents)
5. SDK release for third-party integrations
6. Mobile-friendly dashboard
7. Referral program (share of platform fees)

Target: 100+ agents, $2M+ AUM, 500+ depositors
```

### Phase 4: Expand Markets (Month 8-12)

**Goal:** Beyond prediction markets — DeFi trading agents.

```
Steps:
1. DeFi trading adapter (Jupiter swaps, LP management)
2. Cross-chain DeFi agents (Base, Solana, Polygon)
3. Agent composability (agents delegating to other agents)
4. Institutional features (large deposits, custom risk)
5. API marketplace for data providers

Target: 500+ agents, $20M+ AUM, multi-market
```

## Growth Flywheel

```
┌──────────────────────────────────────────────────────────┐
│                                                           │
│         More Agents → More Capital Raised →               │
│              ↑                         ↓                  │
│     More creators    More Trading Volume →                │
│     attracted by          ↓                               │
│     revenue share    More Platform Fees →                 │
│              ↑                         ↓                  │
│     Higher OBEY     Better Infrastructure →               │
│     token value          ↓                                │
│              ↑      More Users Attracted →                │
│              └──────────────────────────┘                 │
│                                                           │
│  Each loop: agents earn → users earn → platform earns →   │
│  token value grows → more agents join                     │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

## Unit Economics

### Per-Agent Economics

```
Assumptions:
  Agent AUM: $50,000
  Daily turnover: 5%
  Platform fee: 1.5%
  Creator ownership: 15%

Daily:
  Trade volume: $2,500
  Platform fee: $37.50
  Agent gross return (target): 0.1% = $50
  Agent return after fees: $50 - $37.50 = $12.50

Monthly:
  Platform revenue per agent: $1,125
  Agent net return to pool: $375 (0.75% monthly)
  Creator share of growth: $56.25

Annualized:
  Platform revenue per agent: $13,500
  Agent return to depositors: 9% APY (after fees)
  Creator return: ~$675/year from ownership + share appreciation
```

### Break-Even Analysis

```
Fixed costs (estimated):
  Infrastructure (servers, RPC, APIs): $2,000/month
  LLM API costs (Claude/GPT): $1,000/month
  Bridge costs: $200/month
  Monitoring/security: $500/month
  Total: ~$3,700/month

Break-even at 1.5% fee:
  Required daily volume: $3,700 / 30 / 0.015 = ~$8,200/day
  At 5% turnover: ~$164K AUM

Platform is profitable above ~$200K AUM.
```

## Competitive Moat

| Moat | Description |
|------|-------------|
| **Network effects** | More agents → more depositors → more agents |
| **Data advantage** | Agent performance data improves strategies over time |
| **Multi-platform edge** | Cross-platform arbitrage requires infrastructure most can't replicate |
| **Agent reputation** | Track records are hard to replicate — first movers have history |
| **OBEY token** | Token creates stickiness — holders have economic incentive to stay |
| **Existing infrastructure** | OBEY economy (HCS, identity, payments) already built |

## Key Metrics to Track

| Metric | Definition | Target (Month 6) |
|--------|-----------|-----------------|
| AUM | Total deposited across all agents | $2M |
| Active Agents | Agents with > $1K NAV actively trading | 50 |
| Depositors | Unique wallets with share tokens | 300 |
| Daily Volume | Total trade value across all agents | $100K |
| Daily Revenue | Platform fees collected | $1,500 |
| Agent Win Rate | % of resolved positions that won (platform avg) | > 55% |
| Avg Agent Return | NAV growth annualized (platform avg) | > 15% |
| OBEY Token Volume | Daily Bags trading volume | $50K |
| Retention | % of depositors still active after 30 days | > 60% |
