# 11 — Fast-Path MVP (Revenue in Days)

## Why This Document Exists

The full platform design (docs 01-10) is the target architecture. With the AI development system we have, the entire existing OBEY Agent Economy (coordinator, trading agent, inference agent, dashboard, contracts, hiero plugin) was built in a few working days. The full platform build should follow the same pace.

**The MVP proves one thing: users will deposit real money into AI agents that trade prediction markets.**

## What We Ship in ~3 Days

### Day 1-2: Prediction Market Agent on Drift BET

**Why Drift BET first (not Polymarket):**
- Solana-native — no bridges, no cross-chain risk
- USDC stays on Solana — same chain as future vault contracts
- Pyth oracles for resolution — infrastructure we already need
- Drift SDK exists (TypeScript/Python) — accessible from Go via HTTP
- No bridge latency (instant, not 15 minutes)
- We need Solana presence anyway (Bags integration)

**Agent v1 — "OBEY Predictor":**

```go
// Simplified agent — single strategy, single platform
type PredictorAgent struct {
    drift       *DriftClient      // Drift BET HTTP API
    llm         *AnthropicClient  // Claude for analysis
    wallet      solana.PrivateKey // agent's Solana wallet
    config      AgentConfig
}

func (a *PredictorAgent) Run(ctx context.Context) {
    ticker := time.NewTicker(15 * time.Minute)
    for {
        select {
        case <-ticker.C:
            // 1. Get active BET markets from Drift
            markets := a.drift.GetBETMarkets(ctx)

            // 2. LLM analysis — which markets are mispriced?
            signals := a.analyzeMarkets(ctx, markets)

            // 3. Execute best signals
            for _, signal := range signals {
                a.executeTrade(ctx, signal)
            }

            // 4. Check for resolved markets, collect winnings
            a.settleResolved(ctx)

            // 5. Report NAV
            a.reportNAV(ctx)
        }
    }
}
```

**Deliverable:** Agent running on mainnet, trading Drift BET markets with platform capital ($5K-$10K seed).

### Day 2-3: Deposit System (Smart But Simple)

**Not a full vault contract.** A simple, auditable SPL token-based system:

```
How it works:
1. Platform deploys a share token mint: OBEY-PRED (SPL token)
2. Users send USDC to the agent's public deposit address (a PDA we control)
3. Backend mints OBEY-PRED shares proportional to deposit / NAV
4. Agent trades with pooled USDC
5. Users burn OBEY-PRED → receive proportional USDC back

Security:
  - Deposit address is a PDA (no private key exposure)
  - Share mint authority is a PDA (only program can mint/burn)
  - Simple Anchor program: ~200 LOC (deposit + burn + NAV update)
  - No trade execution through contract (agent trades directly — MVP tradeoff)
  - NAV updated by agent (verified against Drift API by backend)
```

**This is NOT the full vault contract.** It's a minimal deposit/withdraw program that proves the user flow works. The full vault with trade routing, concentration limits, and anti-gaming comes in Phase 2.

```rust
// MVP Anchor program — ~200 lines
#[program]
pub mod obey_mvp_vault {
    pub fn initialize(ctx: Context<Initialize>, agent_wallet: Pubkey) -> Result<()>
    pub fn deposit(ctx: Context<Deposit>, amount: u64) -> Result<()>
    pub fn request_withdrawal(ctx: Context<RequestWithdraw>, shares: u64) -> Result<()>
    pub fn execute_withdrawal(ctx: Context<ExecuteWithdraw>) -> Result<()>
    pub fn update_nav(ctx: Context<UpdateNAV>, new_nav: u64) -> Result<()>
}

// deposit: transfer USDC to vault PDA, mint shares
// withdrawal: burn shares, transfer proportional USDC from vault PDA
// update_nav: admin-only, sets current NAV (verified off-chain against Drift)
```

**Trust model for MVP:** Users trust the platform to report accurate NAV. This is acceptable because:
1. All Drift BET trades are on-chain and verifiable
2. NAV can be independently calculated from public Drift positions
3. The full anti-gaming vault replaces this in Phase 2
4. $5K-$50K AUM doesn't justify the complexity of full custody yet

### Day 3-4: Landing Page + Agent Profile

**Single page that does three things:**

1. **Shows the agent's live performance** (NAV chart, trade history, win rate)
2. **Lets users deposit** (connect wallet → approve USDC → receive shares)
3. **Shows the referral code** (share to earn 10% of referred user's fees)

```
obeyplatform.xyz

┌──────────────────────────────────────────────────────────────┐
│                                                               │
│  OBEY AGENT ECONOMY                                          │
│  Fund AI agents that trade prediction markets.               │
│                                                               │
│  ┌─ OBEY Predictor ──────────────────────────────────────┐   │
│  │                                                        │   │
│  │  Live on Solana Mainnet            Status: Trading ●   │   │
│  │                                                        │   │
│  │  NAV: $12,340    Return: +23.4%    Win Rate: 68%       │   │
│  │  Trades: 142     Sharpe: 2.1       Max DD: -6.2%      │   │
│  │                                                        │   │
│  │  [NAV Chart — real-time data from Drift positions]     │   │
│  │  ╔═══════════════════════════════════════════════╗     │   │
│  │  ║        /\    /\                                ║     │   │
│  │  ║       /  \  /  \  /\    /\                     ║     │   │
│  │  ║      /    \/    \/  \  /  \      /\            ║     │   │
│  │  ║     /                \/    \    /  \           ║     │   │
│  │  ║    /                        \  /    \          ║     │   │
│  │  ╚═══════════════════════════════════════════════╝     │   │
│  │                                                        │   │
│  │  Recent Trades:                                        │   │
│  │  Mar 13  "ETH > $4K Apr"  NO @0.62  → Resolved: Won  │   │
│  │  Mar 12  "Fed March cut"  YES @0.71  → Open           │   │
│  │  Mar 12  "BTC > $90K May" NO @0.35   → Open           │   │
│  │                                                        │   │
│  │  Strategy: LLM-powered analysis of prediction markets  │   │
│  │  on Drift BET (Solana). Agent monitors breaking news,  │   │
│  │  parses resolution rules, and identifies mispriced      │   │
│  │  markets 24/7.                                          │   │
│  │                                                        │   │
│  │  [Deposit USDC]              [View All Trades]         │   │
│  │                                                        │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌─ How It Works ──────────────────────────────────────────┐  │
│  │  1. Deposit USDC → receive OBEY-PRED share tokens       │  │
│  │  2. AI agent trades prediction markets on your behalf    │  │
│  │  3. Burn shares anytime → receive your USDC + profits   │  │
│  │  4. Refer friends → earn 10% of their fees forever      │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌─ Your Referral ─────────────────────────────────────────┐  │
│  │  Share your link: obeyplatform.xyz?ref=A1B2C3           │  │
│  │  Earn 10% of platform fees from everyone you refer.     │  │
│  │  [Copy Referral Link]                                    │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Day 4-5: OBEY Token Launch on Bags

In parallel with the above:

```
1. Create OBEY token via Bags API
2. Configure fee sharing (40% treasury, 30% performance, 20% holders, 10% creator)
3. Launch on Meteora DBC
4. Link token to platform: "OBEY token holders get fee discounts"
5. Submit Bags hackathon application
```

## What We Have After ~5 Days

| Asset | Status |
|-------|--------|
| Live agent on Solana mainnet | Trading Drift BET markets |
| Real depositors | USDC deposited, share tokens minted |
| Real revenue | 0.8% of every trade |
| OBEY token on Bags | Generating 1% creator fee revenue |
| Referral system | Users sharing links, earning fees |
| Landing page | Live performance data, deposit flow |
| Bags hackathon submission | With real users, real trades, real revenue |

## What We DON'T Have Yet (Phase 2)

| Feature | Why Not Yet | When |
|---------|-----------|------|
| Full vault contracts | Overkill for <$50K AUM | Week 2 |
| Multi-platform (Polymarket) | Requires bridges | Week 2-3 |
| Marketplace with search | Need >5 agents first | Week 3 |
| Anti-gaming NAV | Full oracle-only NAV comes with vault contracts | Week 2 |
| Concentration limits | Same as above | Week 2 |
| Agent update timelock | Only 1 agent initially | Week 3 |
| Creator registration | We operate all agents initially | Week 3 |

## Phase 2: Full Platform (Week 2-3)

Once MVP validates demand — built in parallel with MVP traction:

```
Week 2:
  - Deploy full vault contracts (Anchor) — doc 02
  - Migrate MVP vault to full vault program
  - Add Polymarket adapter (doc 03) with Wormhole bridge
  - Launch 2 more platform-operated agents
  - Anti-gaming NAV (oracle-only valuation)

Week 3:
  - Open creator registration
  - Launch marketplace UI (doc 04)
  - Creator accelerator: 10 external agents
  - Limitless adapter (Base)

Week 4:
  - Leaderboard + tournaments
  - Community features
  - SDK release
```

## Revenue Projections (Conservative)

```
Week 4 (MVP launch):
  AUM: $10K (seed capital + first deposits)
  Daily volume: $500 (5% turnover)
  Daily revenue: $4 (0.8% fee)
  OBEY token daily volume: $1K → $10/day (1% creator × 40% platform share)

Month 2:
  AUM: $50K (referral growth + accelerator capital)
  Daily volume: $2,500
  Daily revenue: $20
  OBEY token daily volume: $5K → $50/day

Month 3:
  AUM: $200K (marketplace launch, creator agents)
  Daily volume: $10K
  Daily revenue: $80
  OBEY token daily volume: $20K → $200/day

Month 6:
  AUM: $2M (organic growth, 50+ agents)
  Daily volume: $100K
  Daily revenue: $800
  Annual run rate: $292K

Month 12:
  AUM: $10M (market maturity)
  Daily volume: $500K
  Daily revenue: $4,000
  Annual run rate: $1.46M
```

## MVP Technical Stack

| Component | Technology | Effort |
|-----------|-----------|--------|
| Agent | Go (extend agent-defi patterns) | 1.5 weeks |
| Drift BET client | Go HTTP client | 3 days |
| LLM analysis | Claude API (Go client) | 2 days |
| MVP vault program | Anchor (Rust) — ~200 LOC | 3 days |
| Landing page | Next.js (extend dashboard) | 1 week |
| Referral tracking | PostgreSQL + simple API | 2 days |
| OBEY token launch | Bags API (Go client) | 1 day |
| Deployment | Docker on VPS | 1 day |

**Total new code estimate:** ~3,000 LOC (Go agent + Anchor vault + Next.js page)
**Reused code:** ~2,000 LOC (from agent-defi, dashboard, coordinator patterns)

## Risk Mitigation

| MVP Risk | Mitigation |
|----------|-----------|
| Agent loses money | Seed with small capital ($5K), stop-loss at 15% drawdown |
| No deposits | Referral incentives + OBEY airdrop + fee waiver |
| Drift BET low liquidity | Start with highest-volume markets only |
| NAV reporting trust | All positions verifiable on-chain via Drift |
| Smart contract bug | MVP vault is ~200 LOC, extensively tested, admin can pause |
| Bags hackathon rejection | Platform works regardless — hackathon is bonus, not dependency |

## Decision: When to Move to Phase 2

Move to Phase 2 (full vault contracts + multi-platform) when ANY of these are true:

1. AUM exceeds $50K (enough capital to justify custody infrastructure)
2. More than 20 unique depositors (enough users to justify marketplace)
3. Agent demonstrates >15% return in first 30 days (strategy validated)
4. External creator requests agent registration (supply-side demand)

If NONE are true after 60 days, reassess the business model before investing in Phase 2.
