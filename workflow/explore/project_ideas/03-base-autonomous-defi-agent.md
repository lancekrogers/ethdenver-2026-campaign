# Self-Sustaining Autonomous DeFi Agent on Base

## Target Bounties

| Bounty | Prize | Fit |
|--------|-------|-----|
| **Kite/Bass (Base) - Self-Sustaining Agent** | Up to $3k (top tier from $25k pool) | PRIMARY - exact match |
| **New France Village Track** | Track prize | DeFi primitives |
| **Future Llama Track** | Track prize | Frontier AI |

**Total potential: $3k sponsor bounty + track prizes**

## Concept

A fully autonomous DeFi agent deployed on Base mainnet that sustains itself financially by executing profitable trading strategies. The agent monitors market conditions, identifies opportunities (arbitrage, yield optimization, liquidation), executes trades, and pays for its own compute and gas from profits. It uses ERC-8004 for trustless on-chain identity, x402 protocol for autonomous payments, and exposes a public performance dashboard via Builder Codes.

This is the "autonomous agent that pays for compute" the Kite/Bass bounty explicitly demands.

## Architecture

### Core Components

1. **Agent Identity (ERC-8004 Trustless Agents)**
   - Agent minted as ERC-721 NFT in Identity Registry with unique `agentId`
   - Metadata stored on-chain: capabilities, wallet address (via `setAgentWallet` with EIP-712 sig)
   - Reputation Registry: `giveFeedback(agentId, score, tags, ...)` accumulates onchain reputation
   - Validation Registry: enables verification of agent's work (supports zkML, TEE, stake-secured models)
   - Co-authored by MetaMask, Ethereum Foundation, Google, Coinbase - live on mainnet Jan 29, 2026

2. **Strategy Engine**
   - Multi-strategy portfolio: arbitrage, yield farming, liquidation protection
   - Real-time market data ingestion via on-chain oracles + off-chain feeds
   - AI-powered decision making: when to enter/exit positions, risk management
   - Adaptive: learns from past performance to refine strategies

3. **Autonomous Payment System (x402)**
   - Agent pays for inference API calls via x402 protocol
   - Gas costs covered from trading profits
   - Budget management: reserves X% of profits for operational costs
   - Auto-scales inference spending based on market volatility (more compute when markets are active)

4. **Builder Codes Integration (ERC-8021)**
   - Registered on base.dev with Builder Code (random string e.g. `k3p9da`)
   - ERC-8021 appends 16-byte marker + schema ID + entity code to transaction calldata
   - EVM safely ignores suffix - zero execution impact, full attribution
   - Builder Code is an ERC-721 NFT with payout address for potential rewards
   - Currently supports Smart Account (AA) transactions (aligns with Agentic Wallet)

5. **Public Performance Dashboard**
   - Real-time P&L tracking
   - Trade history with reasoning explanations
   - Compute cost breakdown (inference, gas, data feeds)
   - Self-sustainability score: ratio of revenue to costs
   - Agent state machine visualization

### Financial Loop

```
Market Opportunity Detected
        │
        ▼
AI Inference (paid via x402)
   "Should I trade? What parameters?"
        │
        ▼
Trade Execution (gas from agent wallet)
        │
        ▼
Profit/Loss Realized
        │
        ├──> Reserve for compute costs (20%)
        ├──> Reserve for gas (10%)
        └──> Compound remaining (70%)
        │
        ▼
Agent Self-Sustains → Repeats
```

## Technical Stack

- **Chain**: Base mainnet (Chain ID 8453)
- **Identity**: ERC-8004 Trustless Agents (Identity + Reputation + Validation registries)
- **Payments**: x402 HTTP-native payment protocol (Coinbase, 1k free txns/month via facilitator)
- **Attribution**: ERC-8021 Builder Codes (onchain transaction attribution via calldata suffix)
- **Wallet**: Coinbase AgentKit + Agentic Wallets (launched Feb 12, 2026 - gasless AA support)
- **DeFi**: Uniswap v4, Aave, Aerodrome, Morpho on Base
- **AI**: Claude/GPT for strategy decisions, paid via x402 micropayments
- **Frontend**: Next.js performance dashboard + Cookie DAO APIs for agent analytics
- **Monitoring**: Subgraph or direct RPC reads for on-chain event indexing

### Key Standard Details (corrected from transcript)

| Transcript Name | Actual Standard | Purpose |
|----------------|----------------|---------|
| "ERC-821" | **ERC-8021** | Builder Codes - calldata suffix for onchain attribution |
| "EIP-8004" | **ERC-8004** | Trustless Agents - identity NFT, reputation, validation registries |
| "X42" | **x402** | HTTP 402 payment protocol - agent pays for compute via USDC |

### Reference Implementations

- [ERC-8004 contracts](https://github.com/erc-8004/erc-8004-contracts)
- [x402 protocol](https://github.com/coinbase/x402)
- [Coinbase AgentKit](https://github.com/coinbase/agentkit)
- [Builder Codes](https://github.com/base/builder-codes)

## Strategy Details

### Arbitrage Module
- Cross-DEX price monitoring on Base (Uniswap, Aerodrome, BaseSwap)
- Flash loan arbitrage for zero-capital opportunities
- MEV-aware: uses private mempools where available

### Yield Optimization Module
- Auto-compounds yield farming positions
- Moves liquidity between protocols based on APY + risk scoring
- Exits positions when risk exceeds AI-calculated thresholds

### Liquidation Module
- Monitors lending protocol health factors
- Executes liquidations when profitable after gas costs
- Profits flow back to agent's operational budget

## Why This Wins

1. **Exact bounty match**: Self-sustaining, pays for compute, autonomous on Base mainnet
2. **Uses all required primitives**: ERC-8004, x402, Builder Codes
3. **Minimal human loop**: Fully autonomous after deployment
4. **Clear analytics**: Dashboard shows self-sustainability metrics judges can evaluate
5. **Practical value**: Actually generates real returns demonstrating viability
6. **Coinbase ecosystem alignment**: Uses their agentic wallet infrastructure

## Demo Scenario

1. Deploy agent live with seed capital
2. Show agent detecting an arbitrage opportunity
3. Watch it request AI inference (visible x402 payment)
4. Execute trade on-chain (visible Builder Code attribution)
5. Display dashboard showing: trade profit, compute cost, net gain
6. Show cumulative self-sustainability score trending positive

## Risk Assessment

- **Low-medium risk**: Base ecosystem is mature, tools are production-ready
- **Medium complexity**: Multi-strategy DeFi + AI orchestration
- **Competitive**: Many teams will target this bounty
- **Differentiator**: Multi-strategy approach + polished dashboard + real profitability
