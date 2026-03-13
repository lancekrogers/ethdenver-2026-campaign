# Bags Hackathon — Integration Plan

## Goal

Extend the Obey Agent Economy to Solana via Bags, qualifying for the AI Agents track of the Bags Hackathon. Deploy a working product on mainnet with real users and real transactions to maximize traction and grant eligibility ($10K–$100K).

## Why Bags Fits Our System

| Our System | Bags Equivalent | Integration Opportunity |
|------------|----------------|------------------------|
| ERC-8004 Agent Identity | Bags Agent Auth (Moltbook JWT) | Dual-chain agent identity |
| x402 Machine Payments | Bags Fee Sharing (basis points) | Autonomous fee claiming |
| Uniswap V3 Trading | Bags Swap API (Meteora pools) | Solana-side trading agent |
| HCS Coordination | Bags Token + On-chain verification | Public traction metrics |
| 0G Inference Routing | Agent-launched inference tokens | Tokenized compute marketplace |

## Qualification Path

The hackathon requires ONE of:
1. **Have a Bags token** — Launch an OBEY ecosystem token on Bags
2. **Use the Bags API** — Agent uses Bags API for trading/fee sharing
3. **Release a fee sharing app** — Build a fee-sharing product on Bags

**Recommended: Do all three** for maximum integration depth (judges rank deeper integrations higher).

## Architecture: Bags-Native OBEY Agent

### Core Components

```
┌─────────────────────────────────────────────┐
│           OBEY Coordinator (HCS)            │
│        Assigns tasks, collects reports       │
└──────────────┬──────────────────────────────┘
               │
    ┌──────────▼──────────┐
    │   OBEY Bags Agent   │
    │   (New - Solana)     │
    ├─────────────────────┤
    │ • Bags Agent Auth    │ ← Moltbook JWT (365-day)
    │ • Token Launcher     │ ← Bags Token Launch API
    │ • Fee Share Manager  │ ← Configure + claim fees
    │ • Swap Executor      │ ← Bags Trade/Swap API
    │ • Revenue Reporter   │ ← P&L to HCS
    └─────────────────────┘
               │
    ┌──────────▼──────────┐
    │   Solana Mainnet     │
    │ • Meteora Pools      │
    │ • Fee Share Vaults   │
    │ • OBEY Token         │
    └─────────────────────┘
```

### Agent Capabilities

1. **Authenticate** — Agent registers via Moltbook, gets JWT, creates dev API keys
2. **Launch Token** — Create OBEY ecosystem token with metadata + fee sharing config
3. **Configure Fee Sharing** — Set basis point allocations across agent operators, treasury, stakers
4. **Trade** — Execute swaps via Bags API (quote → build tx → sign → send)
5. **Claim Fees** — Autonomously claim accumulated trading fees
6. **Report Revenue** — Publish real P&L data to HCS for coordinator visibility

## Token Strategy

### OBEY Ecosystem Token on Bags

Launch a token that represents the agent economy's Solana presence:

- **Fee Sharing Config:**
  - Agent Treasury: 40% (4000 bps) — funds agent operations
  - Protocol Revenue: 30% (3000 bps) — OBEY ecosystem fund
  - Community/Stakers: 20% (2000 bps) — incentivize holders
  - Dev Fund: 10% (1000 bps) — ongoing development

- **Self-Sustaining Loop:**
  1. Token trades generate 1% creator fees (Bags native)
  2. Agent claims its share of fees autonomously
  3. Revenue covers Solana tx costs + funds further operations
  4. P&L reported to coordinator → proves economic viability

## Implementation Steps

### Step 1: Bags Agent Service (New Project)
- Go service: `projects/agent-bags/`
- Bags API client (REST, `x-api-key` auth)
- Solana wallet management (Keypair generation, tx signing)
- HCS integration for reporting

### Step 2: Agent Authentication
- Implement Moltbook challenge/response flow
- Store JWT (365-day validity)
- Generate and manage dev API keys

### Step 3: Token Launch
- Upload token metadata (image, name, symbol, description)
- Configure fee sharing (basis point allocations)
- Build and submit launch transaction
- Verify on-chain deployment

### Step 4: Trading + Fee Claiming
- Get quotes via Bags API
- Execute swaps to generate trading volume
- Implement automated fee claiming schedule
- Track all revenue on-chain

### Step 5: Mainnet Deployment + Traction
- Deploy agent on Solana mainnet (not devnet)
- Generate real transactions and real fee revenue
- Build dashboards showing live traction metrics
- Open source the agent code (GitHub stars = traction signal)

### Step 6: Hackathon Submission
- Apply at bags.fm/hackathon
- Show: working product, real txs, real revenue, verified on-chain
- Highlight deep integration (token + API + fee sharing)

## Traction Maximization Strategy

Judges evaluate **Product Traction** (MRR, DAU, GitHub Stars) and **Onchain Performance** (market cap, volume, active traders, revenue).

### Quick Wins for Traction
1. **Open Source** — Public repo, good README, MIT license → GitHub stars
2. **Dashboard** — Real-time agent metrics (trades, fees claimed, P&L) → DAU
3. **Community Token** — Fee sharing incentivizes holders to trade → volume + active traders
4. **Agent Composability** — Let other agents plug into our Bags agent → ecosystem play
5. **Blog/Thread** — Document the "autonomous agent economy on Bags" narrative → visibility

### Mainnet Revenue Path
- Even small trading volume generates real fees via 1% creator share
- Agent claiming fees = verifiable on-chain revenue = MRR signal
- Self-sustaining narrative is strong for judging criteria

## Technical Dependencies

- Solana Go SDK (`github.com/gagliardetto/solana-go`)
- Bags API client (REST, no official SDK — we build a thin wrapper)
- Existing HCS integration (already in coordinator)
- Solana wallet with SOL for tx fees

## Risk Assessment

| Risk | Mitigation |
|------|-----------|
| Solana unfamiliar territory | Bags API abstracts most complexity — tx building is API-driven |
| Token launch regulatory | This is a utility/governance token for agent coordination, not a security |
| Low initial traction | Agent generates own trading activity; fee sharing incentivizes organic volume |
| Rolling deadline pressure | Applications reviewed continuously — submit early, iterate |
| Mainnet costs | Solana tx fees are negligible (~$0.001); initial SOL funding is minimal |

## Estimated Scope

- **Agent service scaffold + Bags API client:** Steps 1-2
- **Token launch + fee sharing:** Steps 3-4
- **Mainnet deploy + traction:** Steps 5-6

## Next Actions

1. Sign up at dev.bags.fm, get API key
2. Scaffold `projects/agent-bags/` service
3. Implement Bags API client
4. Launch token on mainnet
5. Deploy agent, start generating traction
6. Submit hackathon application
