# OBEY Agent Economy — On-Chain Business Platform

## One-Liner

A permissionless on-chain platform where anyone can create AI agents, fundraise capital from users, and let agents autonomously operate within smart contract custody — agents execute but can never extract, users burn shares to exit at NAV, and the platform takes 1-2% of every transaction.

## Vision

This isn't a separate product — it's what the OBEY Agent Economy becomes as a real business. The entire coordination layer (HCS, identity, inference, trading) stays. What gets added is a **fundraising and custody mechanism** that turns agent creation into a launchpad: creators deploy agents, raise capital from backers, and agents operate autonomously within the constraints of the platform contracts.

The economy we already built — coordinator, trading agents, inference agents, identity, payments — is the runtime. This platform is the **business layer on top**.

## How It Works End-to-End

### 1. Agent Creation + Fundraising

A creator deploys an agent to the platform:

```
createAgent(
  agentAddr,           // the agent's signing address
  ownerPct,            // creator's ownership share (e.g., 15%)
  agentType,           // trading | inference | general
  acceptedAssets[],    // whitelisted deposit tokens (e.g., [USDC, ETH, WBTC])
  metadata             // name, description, strategy, links, socials
)
```

This registers the agent on-chain and creates:
- An **isolated fund pool** (smart contract vault) for that agent
- A **share token** (ERC-20) unique to that agent
- A **fundraising page** on the platform
- An **accepted assets list** configured by the creator

**Fundraising is open immediately.** Users deposit accepted assets to the agent's pool and receive share tokens proportional to their contribution. The creator's ownership % means they receive that percentage of all new share tokens minted — their upside for building the agent.

The creator can **lower** their ownership percentage over time (never raise) as a trust signal to attract more capital.

### 2. Creator Management Dashboard

Creators have full management access to their registered agents:

- **Update metadata** — name, description, strategy explanation, social links, avatar, banner
- **Update agent contract** — change the agent's signing address (with timelock, see below)
- **Configure accepted assets** — add or remove tokens users can deposit
- **Adjust ownership %** — lower only, never raise
- **Set risk parameters** — max drawdown, position limits, lock-up periods
- **View analytics** — pool NAV, depositor count, trade history, P&L

#### Agent Contract Updates (Timelock)

Changing an agent's signing address is a sensitive operation — it changes who can execute trades. To protect depositors:

```
proposeAgentUpdate(agentId, newAgentAddr)
  → starts a timelock (e.g., 48-72 hours)
  → emits event so depositors can see the pending change
  → depositors can burn shares and exit during the window

executeAgentUpdate(agentId)
  → only after timelock expires
  → new agent address takes over execution rights
```

### 3. User Experience — Discovery + Funding

#### Agent Discovery
Users browse and search registered agents on the platform:

- **Search & filter** by agent type, accepted assets, historical performance, pool size, creator ownership %, age
- **Agent profile pages** — strategy description, metadata, trade history, NAV chart, depositor count, creator info
- **Leaderboards** — top performers by NAV growth, Sharpe ratio, volume, depositor count
- **Risk indicators** — drawdown history, position concentration, creator ownership %

#### Depositing
- User selects an agent from the marketplace
- Deposits any of the agent's **accepted assets**
- Receives share tokens at current NAV
- Multiple users can fund the same agent
- Share tokens are transferable (secondary market possible)

#### Withdrawing
- User burns share tokens → receives proportional share of pool NAV
- Withdrawal paid in the pool's underlying assets (proportional basket)
- No gatekeeper, no approval needed — contract enforces the math
- Exit anytime (or optional creator-set lock-up periods)

### 4. Agent Operations (The Economy)

Once funded, agents operate within the existing OBEY economy:

- **Trading agents** execute swaps, manage positions — all through the platform contract (funds never leave custody)
- **Inference agents** route AI workloads, earn fees for compute services
- **Coordinator** assigns tasks, collects reports via HCS
- **x402 payments** let agents pay for off-chain services (data feeds, compute, signals)
- **ERC-8004 identity** gives agents verifiable on-chain presence

The platform contract enforces:
- Agents can only interact with **whitelisted protocols** (DEX routers, lending, etc.)
- **No transfers to arbitrary wallets** — funds stay in the contract or in positions
- **No approve() to non-whitelisted contracts**
- All operations are on-chain and transparent

### 5. Platform Revenue

- **1-2% of every transaction value** — taken on-chain at execution time
- Applies to trades, position entries/exits, fee claims
- Revenue is automatic, perpetual, scales with platform activity
- No manual intervention needed

## Anti-Gaming NAV: The Portfolio Valuation Problem

The biggest attack vector on a vault-and-burn model is **NAV manipulation**: an agent (or its creator) inflates the apparent value of the pool with worthless assets, then burns shares to extract real value from other depositors.

### The Attack

1. Agent creates a random token or buys a micro-cap with no real liquidity
2. Agent uses pool funds to buy a large amount of this token, pumping the price
3. NAV calculation sees "pool holds 1M SCAM tokens worth $10 each" → NAV looks inflated
4. Creator burns shares → withdraws real assets (USDC, ETH) at the inflated NAV
5. SCAM token collapses → remaining depositors hold worthless bags

### Why "Just Use TWAP" Isn't Enough

A patient attacker with a funded agent can sustain price manipulation for hours or days. TWAP makes flash attacks expensive but doesn't stop a slow bleed. If the attacker controls the agent, they're spending pool money to buy junk — the manipulation cost comes from the depositors, not the attacker. The attacker profits by burning their creator shares at the inflated NAV while depositors eat the loss.

**The real defense isn't making manipulation expensive — it's making manipulable assets worthless in the NAV calculation.**

### Primary Defense: Chainlink-Only Valuation

The simplest and strongest rule: **if a token doesn't have a Chainlink price feed, it's worth $0 in the NAV.**

Chainlink feeds only exist for assets with:
- Real, deep markets across multiple exchanges
- Decentralized oracle networks aggregating prices from many sources
- Economic incentives that make sustained manipulation prohibitively expensive (you'd need to manipulate the price across every exchange Chainlink aggregates from, simultaneously, for long enough to matter)

No attacker is manipulating the ETH/USD or WBTC/USD Chainlink feed. It's not economically viable.

```
navCalculation:
  nav = 0
  for each token in vault:
    feed = chainlinkRegistry.getFeed(token)
    if feed == address(0):
      continue  // no feed = worth $0, period

    (price, updatedAt) = feed.latestRoundData()
    require(block.timestamp - updatedAt < STALENESS_THRESHOLD, "stale feed")

    nav += vault.balanceOf(token) * price
```

The agent can still hold tokens without Chainlink feeds — they just don't count toward NAV. If the agent swaps ETH for some random token, the NAV drops immediately because those funds are now valued at $0. This makes the manipulation self-defeating: the act of buying junk tokens *lowers* the NAV instead of inflating it.

### Secondary Defense: Approved Token List

Even with Chainlink-only NAV, we don't want agents freely trading into garbage. The agent can only trade tokens on the **platform-approved list**:

- Platform curates a list of tokens that have Chainlink feeds + minimum liquidity
- Creators choose a subset for their agent's trading universe
- Contract enforces: `require(approvedTokens[tokenOut], "token not approved")`
- New tokens added via governance (or automatically when Chainlink adds a feed + liquidity threshold met)

This means the agent literally cannot swap into a manipulable token. The approved list and the Chainlink-only NAV reinforce each other:
- Approved list prevents acquiring junk → Chainlink-only NAV makes junk worthless if somehow acquired
- Belt and suspenders

```
executeTrade(router, tokenIn, tokenOut, calldata):
  require(approvedTokens[tokenOut], "token not approved")
  require(whitelistedRouters[router], "router not whitelisted")
  // platform fee deducted
  // execute trade
  // post-trade: verify concentration limits
```

### Tertiary Defense: Concentration Limits

Even among Chainlink-priced tokens, prevent over-concentration:

```
maxConcentration = 40%  // no single non-base token > 40% of NAV

executeTrade():
  // after trade, check concentration
  for each token in vault:
    if token != baseAsset:  // USDC/ETH exempt
      require(tokenValue / totalNAV <= maxConcentration)
```

This limits damage even if an approved token has a legitimate but sharp price movement.

### Withdrawal Mechanics

Burns pay out the pool's **underlying assets proportionally** — not a single denomination:

```
requestBurn(agentId, shareAmount):
  → user's share percentage = shareAmount / totalShares
  → for each token in vault:
      transferAmount = tokenBalance * sharePercentage
      transfer(token, user, transferAmount)
```

This is critical: the user receives the *actual tokens* the pool holds, not a USD-equivalent. There's no conversion step where NAV inflation matters — you get your proportional slice of the real assets. If the pool holds 60% USDC and 40% ETH, you get 60% USDC and 40% ETH of your share.

**This makes NAV manipulation for withdrawal extraction nearly impossible** because:
- You can't inflate "real asset A" by holding "fake asset B" — you'd just get the fake asset back when you burn
- The only way to steal value is to swap *good* assets for *bad* assets, but the approved token list prevents that
- Even if you somehow did, Chainlink-only NAV means the bad assets are valued at $0, so share price doesn't inflate

### Optional: Withdrawal Delay

For additional protection, a short delay (1-6 hours) between burn request and execution:
- Gives time for monitoring systems to flag suspicious activity
- Platform can pause an agent mid-withdrawal if manipulation is detected
- Not strictly necessary given the above defenses, but useful as a circuit breaker trigger window

### Attack Scenarios vs. Defenses

| Attack | Why It Fails |
|--------|-------------|
| **Create fake token, pump it** | Token not on approved list → agent can't buy it. Even if held, no Chainlink feed → valued at $0 |
| **Buy low-cap approved token to pump** | Approved tokens have Chainlink feeds → manipulating Chainlink requires manipulating every aggregated exchange simultaneously |
| **Concentrate into one volatile token** | Concentration limits cap exposure at 40% |
| **Slowly accumulate manipulation over days** | Chainlink aggregates across exchanges with economic incentives → sustained manipulation costs more than the pool is worth |
| **Burn shares at inflated NAV to extract value** | Burns pay proportional underlying assets, not USD-equivalent → you get back the same tokens the pool holds, no conversion exploit |
| **Sandwich the withdrawal** | Withdrawal delay + Chainlink aggregated pricing → no single-block manipulation possible |

### Why This Is Robust

The defenses aren't independent layers that each need to hold — they form a **closed system**:

1. Agent can only trade approved tokens (contract enforced)
2. Approved tokens all have Chainlink feeds (curation requirement)
3. NAV only counts Chainlink-priced assets (contract enforced)
4. Burns pay proportional underlying assets (no NAV-to-USD conversion exploit)
5. Concentration limits cap single-asset exposure

There is no attack path that doesn't require defeating all five simultaneously. The simplest way to summarize: **the agent can only hold real assets, real assets have real prices, and withdrawals give you the real assets back.**

## Smart Contract Architecture

```
┌──────────────────────────────────────────────────────────┐
│                  AgentPlatform (Core)                      │
│                                                            │
│  • createAgent(addr, ownerPct, type, assets[], metadata)   │
│  • deposit(agentId, asset, amount) → mint shares           │
│  • requestBurn(agentId, amount) → start withdrawal         │
│  • executeBurn(agentId, requestId) → withdraw at NAV       │
│  • platformFeeRate (1-2%)                                  │
│  • whitelistProtocol(addr) / removeProtocol(addr)          │
│  • approveToken(addr) / removeToken(addr)                  │
│                                                            │
├──────────────────────────────────────────────────────────┤
│              AgentVault (Per Agent)                         │
│                                                            │
│  • executeTrade(router, tokenIn, tokenOut, calldata)       │
│  • executeOperation(target, calldata)                      │
│    ├── only callable by registered agent                   │
│    ├── target must be whitelisted protocol                 │
│    ├── tokenOut must be on approved token list             │
│    ├── platform fee deducted on value transfers            │
│    ├── concentration limits enforced post-trade            │
│    └── NO transfer/approve to non-whitelisted addrs        │
│                                                            │
│  • shareToken (ERC-20 per agent)                           │
│  • tieredNAV() → manipulation-resistant valuation          │
│                                                            │
├──────────────────────────────────────────────────────────┤
│              AgentRegistry                                  │
│                                                            │
│  • ERC-8004 identity integration                           │
│  • Agent metadata (type, strategy, links) — updatable      │
│  • Creator ownership tracking + lowerOwnerPct()            │
│  • Accepted assets config — updatable by creator           │
│  • proposeAgentUpdate() / executeAgentUpdate() (timelock)  │
│  • Performance history / metrics                           │
│  • Search index (type, assets, performance, size)          │
│                                                            │
├──────────────────────────────────────────────────────────┤
│              NAV Oracle                                     │
│                                                            │
│  • Tiered asset valuation (Tier 1/2/3)                     │
│  • Chainlink price feeds (Tier 1)                          │
│  • DEX TWAP fallback (Tier 2, discounted)                  │
│  • Liquidity threshold checks                              │
│  • Concentration limit enforcement                         │
│                                                            │
├──────────────────────────────────────────────────────────┤
│              Guards & Restrictions                          │
│                                                            │
│  • Protocol whitelist (approved DEX routers)               │
│  • Token whitelist (approved trading tokens)               │
│  • No transfer() to arbitrary addresses                    │
│  • No approve() to non-whitelisted contracts               │
│  • Concentration limits per token                          │
│  • Calldata validation (block transfer selectors)          │
│  • Re-entrancy protection                                  │
│  • Circuit breakers (max drawdown pause)                   │
│  • Agent update timelock                                   │
│                                                            │
└──────────────────────────────────────────────────────────┘
```

## Share Token Mechanics

### Minting (Deposit)
```
// Multi-asset deposit — value normalized to NAV denomination
depositValue = depositAmount * oraclePrice(depositAsset)

totalSharesForDeposit = depositValue * totalShares / poolNAV

creatorShares = totalSharesForDeposit * creatorPct / 100
userShares    = totalSharesForDeposit - creatorShares

If first deposit (bootstrap):
  totalSharesForDeposit = depositValue (1:1)
```

### Burning (Withdrawal)
```
// User receives proportional basket of pool assets
userSharePct = burnAmount / totalShares

for each token in vault:
  transferAmount = tokenBalance * userSharePct
  transfer(token, user, transferAmount)
```

### NAV Calculation (Manipulation-Resistant)
```
poolNAV = 0
for each token in vault:
  if tier1(token):   // Chainlink feed + liquidity threshold
    poolNAV += balance * chainlinkPrice(token)
  elif tier2(token): // TWAP + partial liquidity
    poolNAV += balance * twapPrice(token) * discountFactor
  else:              // Tier 3 — no reliable price
    poolNAV += 0     // held but valued at zero
```

### Creator Ownership
```
creatorPct can only decrease:
  require(newPct < currentPct)

On each deposit, creator receives creatorPct of new shares.
Creator shares are standard ERC-20 — transferable, burnable at NAV.
```

## Agent Types on the Platform

| Agent Type | What It Does | How It Earns |
|-----------|-------------|-------------|
| **Trading** | Executes swaps, manages positions on DEXes | Trading profits grow pool NAV |
| **Inference** | Routes AI workloads to GPU providers (0G, etc.) | Earns fees for compute brokering |
| **Coordinator** | Assigns tasks, manages agent network | Takes coordination fees |
| **Hybrid** | Trades + runs inference + coordinates | Multiple revenue streams |

All agent types share the same custody model — funds in, operations within contract, burn to exit.

## Creator Management Functions

| Action | Contract Function | Constraints |
|--------|------------------|-------------|
| Update metadata | `updateMetadata(agentId, newMetadata)` | Creator only |
| Update agent address | `proposeAgentUpdate(agentId, newAddr)` | 48-72hr timelock, depositors notified |
| Lower ownership % | `lowerOwnerPct(agentId, newPct)` | New < current, irreversible |
| Add accepted asset | `addAcceptedAsset(agentId, tokenAddr)` | Must be on platform approved list |
| Remove accepted asset | `removeAcceptedAsset(agentId, tokenAddr)` | Creator only, no effect on existing deposits |
| Set risk parameters | `setRiskParams(agentId, params)` | Can only tighten, not loosen |
| Pause agent | `pauseAgent(agentId)` | Creator or circuit breaker |

## User Platform Functions

| Action | How |
|--------|-----|
| **Search agents** | Filter by type, accepted assets, performance, pool size, creator %, age |
| **View agent profile** | Strategy, trade history, NAV chart, depositors, risk metrics |
| **Deposit** | Select agent → choose accepted asset → deposit amount → receive shares |
| **Withdraw** | Burn shares → receive proportional basket of pool assets |
| **Track portfolio** | Dashboard showing all agent shares held, current NAV, P&L |
| **Leaderboards** | Top agents by NAV growth, volume, Sharpe, depositor count |

## Fundraising Mechanics

### How Fundraising Works
1. Creator registers agent with metadata (name, strategy, accepted assets, track record)
2. Agent appears on the platform marketplace with a profile page
3. Users browse, search, filter agents — deposit into ones they like
4. Share tokens are minted on deposit — no ICO, no token sale, just vault shares
5. Agent begins operating once funded (or creator can set a minimum raise)

### What Makes This Different From an ICO
- **No speculative token** — share tokens represent actual NAV of a managed pool
- **Burn = exit at real value** — not at market price of some unrelated token
- **Funds are custody-locked** — agent can't rug, funds stay in contract
- **Performance is transparent** — NAV is on-chain, all trades visible
- **Anti-gaming protections** — tiered valuation, approved tokens, TWAP pricing

### Creator Incentives
- Start with higher ownership % to compensate early risk
- Lower it over time as the agent proves itself → attracts more capital
- Successful agents = growing NAV = creator shares worth more
- Creators can burn shares to take profits, just like any user

## The Full OBEY Stack (What We Already Have)

| Layer | Component | Status | Role in Platform |
|-------|----------|--------|-----------------|
| Identity | ERC-8004 | Built | Agent registration + verification |
| Coordination | HCS (Hedera) | Built | Task assignment, reporting, leaderboard data |
| Trading | agent-defi | Built | Reference trading agent implementation |
| Inference | agent-inference | Built | Reference inference agent, 0G integration |
| Payments | x402 | Built | Agent-to-service payments for off-chain compute |
| Attribution | ERC-8021 | Built | On-chain tx attribution for agents |
| Dashboard | dashboard | Built | Platform UI foundation |
| Contracts | contracts | Built | Foundation for platform contracts |

**What's new:**
- AgentPlatform contract (vault + shares + fees + NAV oracle)
- AgentRegistry with creator management + search
- Anti-gaming valuation layer (tiered pricing, approved tokens, TWAP)
- Marketplace UI (search, agent profiles, deposit/withdraw)
- Creator dashboard (metadata, config, analytics)

## Competitive Landscape

| Project | How We Differ |
|---------|--------------|
| Enzyme Finance | Fund management for humans — no agent-native primitives, no fundraising |
| dHEDGE | Pool vaults with human managers — no autonomous agent execution |
| Numerai | Off-chain ML signals + staking — no on-chain custody or execution |
| Autonolas | Agent framework but no integrated fundraising/custody |
| **OBEY Platform** | **Full stack: agent creation + fundraising + on-chain custody + autonomous execution + anti-gaming NAV + multi-agent economy** |

## Revenue Model

### Platform Revenue (1.5% avg fee)
| Daily Platform Volume | Daily Revenue | Annual Revenue |
|----------------------|--------------|----------------|
| $100K | $1,500 | $547K |
| $1M | $15,000 | $5.5M |
| $10M | $150,000 | $54.7M |

### Revenue Sources
- Trade execution fees (1-2% per trade)
- Agent registration fees (optional, one-time)
- Premium features (advanced analytics, priority execution)

### Growth Flywheel
More agents → more capital raised → more trading volume → more fees → more agents attracted by ecosystem

## Next Steps

1. Validate contract architecture — vault + shares + tiered NAV + guards
2. Decide chain (Base MVP, Solana via Bags later?)
3. Build NAV oracle with tiered valuation + Chainlink feeds
4. Design creator management + marketplace UI
5. Build AgentPlatform contract MVP
6. Deploy reference trading agent on the platform
7. Launch on mainnet with real funds
