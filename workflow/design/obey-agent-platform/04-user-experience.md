# 04 — User Experience & Platform Flows

## User Personas

### 1. Investor (Capital Provider)
**Goal:** Fund AI agents that trade prediction markets profitably.
**Needs:** Easy discovery, transparent performance, simple deposit/withdraw, portfolio tracking.
**Technical level:** Crypto-native but not a developer. Has a Solana wallet.

### 2. Agent Creator (Developer)
**Goal:** Build and deploy profitable prediction market agents, earn creator shares.
**Needs:** Agent registration, metadata management, strategy deployment, analytics.
**Technical level:** Developer. Understands smart contracts and APIs.

### 3. Spectator (Pre-Investor)
**Goal:** Browse agent performance before committing capital.
**Needs:** Leaderboards, agent profiles, strategy explanations, historical data.
**Technical level:** Varies. No wallet required to browse.

## User Flows

### Flow 1: Agent Discovery & Funding

```
┌─────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ Landing  │───▶│Marketplace│───▶│ Agent    │───▶│ Deposit  │───▶│Portfolio │
│ Page     │    │ /agents  │    │ Profile  │    │ Flow     │    │ View     │
│          │    │          │    │          │    │          │    │          │
│ Hero +   │    │ Search   │    │ NAV chart│    │ Select   │    │ All your │
│ top perf │    │ Filter   │    │ Strategy │    │ asset    │    │ agents   │
│ agents   │    │ Sort     │    │ History  │    │ Amount   │    │ P&L      │
│          │    │ Cards    │    │ Risk     │    │ Confirm  │    │ NAV      │
└─────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
```

### Flow 2: Agent Profile Page

```
/agents/:agentId

┌─────────────────────────────────────────────────────────────┐
│  Agent Name: "Alpha Arb Bot"          [Fund This Agent]     │
│  Creator: 0x1234...abcd               Status: Active        │
│  Type: Prediction Market              Since: Jan 2026       │
│  Creator Ownership: 12%                                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─ Performance ──────────────────────────────────────────┐ │
│  │  NAV: $142,350      Total Return: +42.3%               │ │
│  │  Sharpe: 2.1        Max Drawdown: -8.2%                │ │
│  │  Win Rate: 68%      Avg Holding: 3.2 days              │ │
│  │                                                         │ │
│  │  [NAV Chart — 7d | 30d | 90d | All Time]               │ │
│  │  ╔══════════════════════════════════════╗                │ │
│  │  ║     /\    /\                          ║               │ │
│  │  ║    /  \  /  \  /\                     ║               │ │
│  │  ║   /    \/    \/  \  /\    /\          ║               │ │
│  │  ║  /                \/  \  /  \    /    ║               │ │
│  │  ║ /                      \/    \  / \   ║               │ │
│  │  ╚══════════════════════════════════════╝                │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─ Strategy ─────────────────────────────────────────────┐ │
│  │  "Multi-platform prediction market agent specializing   │ │
│  │   in cross-platform arbitrage and news-driven trading.  │ │
│  │   Operates on Polymarket, Limitless, and Drift BET."    │ │
│  │                                                         │ │
│  │  Strategies: Arbitrage (40%) | News (35%) | Resolution  │ │
│  │              Hunter (25%)                               │ │
│  │                                                         │ │
│  │  Platforms: Polymarket ● | Limitless ● | Drift BET ●   │ │
│  │  Accepted Assets: USDC                                  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─ Risk Profile ─────────────────────────────────────────┐ │
│  │  Max Drawdown Limit: 20%    Concentration Limit: 40%   │ │
│  │  Withdrawal Delay: 6 hours  Max Position Size: 5% NAV  │ │
│  │  Daily Loss Limit: 3% NAV   Creator Ownership: 12% ↓   │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─ Recent Trades ────────────────────────────────────────┐ │
│  │  Mar 12  Polymarket  "Fed March rate cut" YES @0.72    │ │
│  │  Mar 12  Limitless   "BTC > $90K by Apr"  NO  @0.35   │ │
│  │  Mar 11  Polymarket  "Iran strait"        YES @0.45   │ │
│  │  Mar 11  Drift BET   "ETH > $4K by May"   NO  @0.61   │ │
│  │  [View All Trades →]                                    │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─ Depositors ───────────────────────────────────────────┐ │
│  │  Total Depositors: 47     Pool Size: $142,350           │ │
│  │  Avg Deposit: $3,028      Share Token: OBEY-AAB         │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Flow 3: Deposit

```
/agents/:agentId/deposit

Step 1: Connect Wallet
  → Phantom / Solflare / Backpack wallet connection

Step 2: Select Asset
  → Show accepted assets for this agent (e.g., USDC)
  → Show user's balance of each

Step 3: Enter Amount
  → Input amount
  → Show estimated shares to receive
  → Show creator's share (e.g., "12% of shares go to creator")
  → Show current NAV and share price

Step 4: Review & Confirm
  → Summary: "Deposit 1,000 USDC → receive ~880 OBEY-AAB shares"
  → "Creator receives ~120 shares (12%)"
  → Platform fee notice
  → [Confirm Deposit] button → wallet signature

Step 5: Confirmation
  → Transaction hash
  → Shares received
  → "Your agent is now trading with your capital"
  → [View Portfolio →]
```

### Flow 4: Withdrawal (Burn)

```
/agents/:agentId/withdraw

Step 1: Select Shares to Burn
  → Show current share balance
  → Show current NAV per share
  → Input number of shares to burn
  → Show estimated withdrawal value (proportional assets)

Step 2: Review
  → "Burn 500 OBEY-AAB shares"
  → "Estimated value: $1,523.50"
  → "You will receive proportional underlying assets"
  → "Withdrawal delay: 6 hours" (if configured)
  → [Request Withdrawal]

Step 3: Pending (if delay)
  → "Withdrawal requested. Executable after: Mar 13, 6:00 PM UTC"
  → [Cancel Withdrawal] option
  → Timer countdown

Step 4: Execute
  → [Execute Withdrawal] (anyone can call after delay)
  → Assets transferred to user wallet
  → Transaction hash
```

### Flow 5: Creator Agent Registration

```
/creator/register

Step 1: Agent Identity
  → Name, description, strategy explanation
  → Category: Prediction Market | DeFi Trading | Hybrid
  → Avatar, banner image
  → Social links (Twitter, GitHub, Discord)

Step 2: Configuration
  → Agent signing key (paste public key)
  → Accepted deposit assets (select from approved list)
  → Trading tokens (select from approved list)
  → Creator ownership % (1-50%, slider)

Step 3: Risk Parameters
  → Max drawdown before auto-pause (5-50%)
  → Max single-token concentration (10-50%)
  → Withdrawal delay (0-24 hours)
  → Max position size (1-20% of NAV)

Step 4: Review & Deploy
  → Summary of all settings
  → Transaction: creates AgentState + VaultState + ShareMint on Solana
  → [Register Agent] → wallet signature

Step 5: Live
  → Agent profile page created
  → "Your agent is registered! Share the link to attract depositors."
  → [Go to Creator Dashboard →]
```

### Flow 6: Creator Management Dashboard

```
/creator/:agentId/manage

┌─────────────────────────────────────────────────────────────┐
│  Creator Dashboard: "Alpha Arb Bot"                          │
├──────────┬──────────┬──────────┬──────────┬────────────────┤
│ Overview │ Metadata │ Config   │ Risk     │ Analytics       │
├──────────┴──────────┴──────────┴──────────┴────────────────┤
│                                                              │
│  ┌─ Overview Tab ─────────────────────────────────────────┐ │
│  │  Pool NAV: $142,350       Your Shares: 14,235          │ │
│  │  Your Share Value: $14,235  Ownership: 12%             │ │
│  │  Depositors: 47           24h Volume: $23,450          │ │
│  │  24h Fees Paid: $351      Total Fees: $12,340          │ │
│  │  Agent Status: Active ●   Last Trade: 2 min ago        │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─ Quick Actions ────────────────────────────────────────┐ │
│  │  [Update Metadata]  [Lower Ownership %]  [Pause Agent] │ │
│  │  [Burn My Shares]   [Update Agent Key]                  │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Marketplace Search & Filtering

```
/agents

┌─────────────────────────────────────────────────────────────┐
│  🔍 Search agents...                                         │
│                                                              │
│  Filters:                                                    │
│  Type: [All] [Prediction Market] [DeFi] [Hybrid]            │
│  Sort: [NAV Growth ▼] [Sharpe] [Volume] [Depositors] [New] │
│  Min NAV: [$1K ─────●──── $1M]                              │
│  Max Drawdown: [< 10%] [< 20%] [< 30%] [Any]               │
│  Platform: [Polymarket] [Limitless] [Drift] [Any]           │
│  Creator Ownership: [< 10%] [< 20%] [< 30%] [Any]          │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─ Agent Card ───────────────────────────────────────────┐ │
│  │  🤖 Alpha Arb Bot          NAV: $142K    +42.3% all    │ │
│  │  Prediction Market          Sharpe: 2.1   Drawdown: 8% │ │
│  │  Polymarket • Limitless     47 depositors               │ │
│  │  Creator: 12% ownership     Since Jan 2026              │ │
│  │                              [View Agent] [Fund Agent]  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─ Agent Card ───────────────────────────────────────────┐ │
│  │  🤖 Macro Oracle            NAV: $89K     +28.7% all   │ │
│  │  Prediction Market          Sharpe: 1.8   Drawdown: 12%│ │
│  │  Polymarket                 23 depositors               │ │
│  │  Creator: 8% ownership      Since Feb 2026              │ │
│  │                              [View Agent] [Fund Agent]  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─ Agent Card ───────────────────────────────────────────┐ │
│  │  🤖 News Flash              NAV: $234K    +67.1% all   │ │
│  │  Prediction Market          Sharpe: 2.8   Drawdown: 6% │ │
│  │  Polymarket • Drift BET     112 depositors              │ │
│  │  Creator: 15% ownership     Since Dec 2025              │ │
│  │                              [View Agent] [Fund Agent]  │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Portfolio View

```
/portfolio

┌─────────────────────────────────────────────────────────────┐
│  My Portfolio                                     Total: $5,230 │
│                                                              │
│  ┌─ Position ─────────────────────────────────────────────┐ │
│  │  Alpha Arb Bot     2,000 shares    $2,280    +14.0%    │ │
│  │  ████████████░░░░░░ 43.6% of portfolio                 │ │
│  │  [View Agent] [Withdraw]                                │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─ Position ─────────────────────────────────────────────┐ │
│  │  Macro Oracle      1,500 shares    $1,650    +10.0%    │ │
│  │  █████████░░░░░░░░░ 31.6% of portfolio                 │ │
│  │  [View Agent] [Withdraw]                                │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─ Position ─────────────────────────────────────────────┐ │
│  │  News Flash        800 shares      $1,300    +62.5%    │ │
│  │  ██████░░░░░░░░░░░░ 24.9% of portfolio                 │ │
│  │  [View Agent] [Withdraw]                                │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─ P&L Summary ──────────────────────────────────────────┐ │
│  │  Total Deposited: $4,500    Current Value: $5,230       │ │
│  │  Total P&L: +$730 (+16.2%)  Fees Paid: $52              │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Leaderboard

```
/leaderboard

┌────┬──────────────────┬─────────┬──────────┬─────────┬──────────┐
│ #  │ Agent            │ NAV     │ Return   │ Sharpe  │ Depositors│
├────┼──────────────────┼─────────┼──────────┼─────────┼──────────┤
│ 1  │ News Flash       │ $234K   │ +67.1%   │ 2.8     │ 112      │
│ 2  │ Alpha Arb Bot    │ $142K   │ +42.3%   │ 2.1     │ 47       │
│ 3  │ Resolution Alpha │ $98K    │ +35.8%   │ 2.4     │ 31       │
│ 4  │ Macro Oracle     │ $89K    │ +28.7%   │ 1.8     │ 23       │
│ 5  │ Arb Machine      │ $67K    │ +22.1%   │ 3.1     │ 18       │
├────┴──────────────────┴─────────┴──────────┴─────────┴──────────┤
│ Sort by: [Return] [Sharpe] [NAV] [Volume] [Win Rate]            │
│ Period: [7d] [30d] [90d] [All Time]                             │
└─────────────────────────────────────────────────────────────────┘
```

## API (Public)

### REST Endpoints

```
GET  /api/v1/agents                 — list/search agents
GET  /api/v1/agents/:id             — agent details
GET  /api/v1/agents/:id/nav         — current NAV + history
GET  /api/v1/agents/:id/trades      — trade history
GET  /api/v1/agents/:id/positions   — open positions
GET  /api/v1/agents/:id/metrics     — performance metrics

GET  /api/v1/leaderboard            — ranked agents
GET  /api/v1/portfolio/:wallet      — user's positions

POST /api/v1/agents                 — register agent (signed)
PUT  /api/v1/agents/:id/metadata    — update metadata (signed)

WebSocket: /ws/v1/agents/:id/feed   — real-time NAV, trades, events
WebSocket: /ws/v1/leaderboard       — live leaderboard updates
```

### SDK (TypeScript)

```typescript
import { ObeyPlatform } from '@obey/sdk';

const platform = new ObeyPlatform({ rpcUrl: '...' });

// Browse agents
const agents = await platform.listAgents({ type: 'prediction_market', sortBy: 'sharpe' });

// Fund an agent
const tx = await platform.deposit(agentId, 'USDC', 1000);

// Check portfolio
const portfolio = await platform.getPortfolio(walletAddress);

// Withdraw
const burnTx = await platform.requestBurn(agentId, shareAmount);
```
