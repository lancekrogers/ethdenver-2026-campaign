# 05 — Bags.fm Integration & Token Strategy

## Why Bags

1. **Hackathon eligibility** — $10K-$100K grant, AI Agents track
2. **Revenue stream** — 1% perpetual creator fee on all token trading volume
3. **User acquisition** — Bags community exposure, marketplace listing
4. **Token utility** — OBEY token creates a flywheel: platform success → token value → more users

## OBEY Token on Bags

### Token Design

| Property | Value |
|----------|-------|
| Name | OBEY Agent Economy |
| Symbol | OBEY |
| Chain | Solana (Meteora DBC launch) |
| Creator Fee | 1% of all trading volume |
| Launch Platform | Bags.fm |

### Fee Sharing Configuration

The 1% creator fee on every OBEY token trade is split:

| Recipient | Share (bps) | Purpose |
|-----------|-------------|---------|
| Platform Treasury | 4000 (40%) | Operational costs, development |
| Agent Performance Pool | 3000 (30%) | Rewards for top-performing agents |
| Community/Holders | 2000 (20%) | Incentivize holding (Bags dividends to top 100) |
| Creator (Lance) | 1000 (10%) | Founder share |

### Token Utility

The OBEY token serves three functions within the platform:

1. **Governance Signal** — Token holders vote on platform parameters (approved tokens, fee rates, agent approvals). Not binding governance initially, but weighted sentiment.

2. **Agent Staking** — Agent creators stake OBEY tokens when registering agents. Stake is slashable if agent violates rules (e.g., attempted unauthorized transfers). Higher stake = higher trust signal on marketplace.

3. **Fee Discounts** — Users holding OBEY tokens get reduced platform fees (1.5% → 1% for holders above threshold). Incentivizes token demand.

### Launch Strategy

```
Phase 1: Token Creation
  → Create OBEY token via Bags API
  → Upload metadata (logo, description, links)
  → Configure fee sharing (4 recipients)
  → Launch on Meteora DBC

Phase 2: Initial Liquidity
  → Provide initial SOL/OBEY liquidity
  → Token trades on bonding curve
  → Community discovers via Bags marketplace

Phase 3: Migration
  → Bonding curve reaches threshold
  → Auto-migrates to Meteora DAMM v2 pool
  → Full AMM trading begins
  → Top 100 holders receive dividends (24hr cycles)

Phase 4: Platform Integration
  → OBEY staking for agent registration
  → Fee discounts for holders
  → Agent Performance Pool distributions
```

## Bags Agent Integration

### Platform Agent on Bags

The platform itself runs a Bags-native agent:

```go
type BagsAgent struct {
    apiClient    *bags.Client       // Bags REST API
    jwt          string             // 365-day Moltbook JWT
    wallets      []bags.Wallet      // Solana wallets
    tokenMint    string             // OBEY token mint address
}

// Agent capabilities
func (a *BagsAgent) ClaimFees(ctx context.Context) error {
    // Get claimable positions
    positions, _ := a.apiClient.GetClaimablePositions(ctx)

    // Generate claim transactions
    txs, _ := a.apiClient.GetClaimTransactionsV3(ctx, a.tokenMint)

    // Sign and submit
    for _, tx := range txs {
        signed := a.signTransaction(tx)
        a.apiClient.SendTransaction(ctx, signed)
    }

    // Report to coordinator via HCS
    return nil
}

func (a *BagsAgent) MonitorTokenMetrics(ctx context.Context) {
    // Track: volume, holders, fees collected, pool depth
    pool, _ := a.apiClient.GetPoolByMint(ctx, a.tokenMint)
    lifetime, _ := a.apiClient.GetTokenLifetimeFees(ctx, a.tokenMint)
    // Report metrics to dashboard
}
```

### Bags API Integration Points

| Flow | Bags API Calls | Frequency |
|------|---------------|-----------|
| Token launch | createTokenInfo → createFeeShare → createLaunchTx → sendTx | Once |
| Fee claiming | getClaimablePositions → getClaimTxV3 → sendTx | Every 6 hours |
| Metrics | getPoolByMint, getTokenLifetimeFees, getTokenClaimStats | Every 5 min |
| Trading | getTradeQuote → createSwapTx → sendTx | As needed |

### Hackathon Submission Strategy

**Qualification checkboxes:**

- [x] Have a Bags token — OBEY token launched on Bags
- [x] Use the Bags API — Agent auth, token launch, fee claiming, trading
- [x] Release a fee sharing app — Platform distributes creator fees to multiple parties

**Traction signals for judges:**

| Signal | How We Generate It |
|--------|-------------------|
| GitHub Stars | Open source everything, good README |
| DAU | Dashboard with live agent metrics |
| MRR | Platform fees from prediction market trades |
| Market Cap | OBEY token on Bags with real trading |
| Volume | Agent trades + user token trading |
| Active Traders | Platform depositors + OBEY holders |
| Revenue | Verifiable on-chain fee claiming |

**Application narrative:**
"We built a platform where AI agents autonomously trade prediction markets across Polymarket, Limitless, and Drift. Users fund agents through smart contract custody on Solana. The platform takes 1-2% of every trade. Our OBEY token on Bags shares platform revenue with token holders. Everything is on-chain, verifiable, and live on mainnet."
