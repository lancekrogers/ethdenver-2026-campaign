# Base Builder Grant — Social Media Content

> Track: External Proof. Only post claims here that are backed by the linked code and on-chain evidence.

## Twitter/X Thread (Primary Discovery Channel)

### Main Post

```
Built an autonomous DeFi agent on @base that:

→ Registers on-chain identity (ERC-8004)
→ Attributes every tx to the builder (ERC-8021)
→ Pays for services autonomously (x402)
→ Trades Uniswap V3 with risk controls

4 contracts deployed from our wallet on Base Sepolia, plus an ERC-8004 identity registration tx.

3 Base-native standards in one agent. All real code, all on Base Sepolia.

🧵👇
```

### Thread

```
1/ ERC-8004 — Trustless Agent Identity

Before the agent trades, it registers a verifiable on-chain identity on Base. Proves who built it, when it was deployed, what it's authorized to do.

No more anonymous wallets running wild.

Code: github.com/lancekrogers/[repo]/internal/base/identity/register.go
```

```
2/ x402 — Machine-to-Machine Payments

The agent autonomously handles payment-gated resources:
- Parses HTTP 402 invoices
- Validates amount + expiry
- Submits on-chain USDC payment
- Retries with proof

No human needed. This is implemented in the agent and ready for more live tx evidence.

445 lines of real x402 implementation.
```

```
3/ ERC-8021 — Builder Attribution

Every transaction — every swap, every payment — gets a 20-byte builder code appended to calldata.

Every trade this agent makes is traceable back to Obedience Corp.

On-chain accountability for autonomous agents.
```

```
4/ The agent runs a mean reversion strategy on Uniswap V3:
- USDC/WETH pair on Base Sepolia
- Buys 2% below 30-period MA
- Sells 2% above
- Tracks P&L, gas, and service costs in code
- Uses explicit cost accounting instead of hand-waving economics

Implemented agent economics, with more live trade evidence being collected.
```

```
5/ But it doesn't trade blind.

Every signal passes through 8 risk gates via @chainlink CRE before execution:
- Oracle health validation
- Price deviation checks
- Volatility-adjusted position sizing
- Agent heartbeat circuit breaker

First denial = no trade. Fail-closed.
```

```
6/ This is part of a larger multi-agent system:
- Hedera: coordination + payments
- 0G: decentralized inference + provenance
- Base: DeFi trading + identity + payments
- Ethereum: risk controls

But the Base integration stands on its own. 3 standards, 1 agent, real code.

[basescan tx links]
```

### Tags/Mentions

```
@base @jessepollak @BuildOnBase
#BuildOnBase #BaseSepolia #ERC8004 #x402 #DeFi #AIAgents
```

---

## Farcaster Post (Base Team Is Active Here)

```
Shipped an autonomous DeFi agent on Base using 3 emerging standards:

ERC-8004: On-chain agent identity
ERC-8021: Builder attribution on every tx
x402: Machine-to-machine payments

Agent trades Uniswap V3, tracks its operating costs, and every action is traceable.

40+ tests passing, all real implementations (no mocks in prod).

Repo: [github link]
Evidence: [basescan links]

@base
```

---

## Key Messaging Points

For any social post about this project on Base channels:

1. **Lead with the standards** — ERC-8004, ERC-8021, x402. These are new and Base wants adoption.
2. **"Implemented agent economics"** — the agent tracks costs, P&L, and machine payments in code. Use this instead of overstating live profit proof.
3. **"Traceable"** — ERC-8021 makes every tx attributable. This matters for accountability.
4. **"Real code"** — link to GitHub, link to basescan. Evidence beats claims.
5. **Don't oversell** — it's on testnet, say so. Honesty builds trust.

---

## TradeOS Comparison (What They Did to Get Users)

TradeOS reached ~70K MAU by:
- **"Vibe coding" narrative** — natural language → trading strategy. Viral concept.
- **12,500+ assets** — stocks, FX, commodities. Broad market = broad audience.
- **Multi-geography launch** — US, Canada, Hong Kong, Southeast Asia simultaneously
- **"Prosumer" positioning** — "Only 10% of traders know how to automate. We make it instant."
- **Early access/waitlist** — scarcity-driven signup model
- **PR press releases** — PRWeb launch announcement drove initial awareness
- **Community trading groups** — traders share strategies, creating network effects

### What You Can Borrow

You don't need 70K users for a Base grant. But you can:
1. **Post consistently** about what you're building (1-2 posts/week showing progress)
2. **Engage in Base/Farcaster communities** — comment on other builders' posts
3. **Share technical deep-dives** — "How I implemented x402 in Go" type content
4. **Tag Base team** on every relevant post — they scout social
5. **Join Base Discord** and be visible in builder channels
