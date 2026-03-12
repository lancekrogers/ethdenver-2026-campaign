# Base Builder Grant Application — One-Pager

**Project:** Obey Agent Economy — Autonomous DeFi Agent on Base
**Applicant:** Lance Rogers
**Date:** 2026-03-11
**Target Program:** Base Builder Grants (Retroactive) + Builder Rewards

---

## Problem

AI agents are entering DeFi, but they operate as anonymous black boxes. There's no on-chain identity proving an agent is who it claims to be, no attribution linking transactions back to the builder who deployed the agent, and no native payment protocol for agents to autonomously pay for services. Agents today are pseudonymous wallets with no accountability layer.

---

## Solution

An autonomous DeFi trading agent built natively on Base, integrating three emerging Base-aligned standards to create an accountable, self-sustaining agent:

| Standard | How We Use It |
|----------|---------------|
| **ERC-8004 (Trustless Agent Identity)** | Registers verifiable on-chain identity before any trading. Proves agent provenance — who built it, when it was deployed, what it's authorized to do. |
| **ERC-8021 (Builder Codes)** | Appends 20-byte builder attribution code to every transaction's calldata (24 bytes total). Every swap, every payment — traceable to the builder. |
| **x402 (HTTP Payment Protocol)** | Agent autonomously handles payment-gated resources. Parses HTTP 402 invoices, validates amount/expiry, submits on-chain USDC payment, retries with proof. Machine-to-machine payments without human intervention. |

---

## What It Does

### Trading
- **Strategy:** Mean reversion on USDC/WETH via Uniswap V3 on Base Sepolia
- **Execution:** `exactInputSingle` swaps through Uniswap V3 SwapRouter
- **Logic:** Buys 2% below 30-period moving average, sells 2% above. Confidence scales with deviation; position sizes proportionally.
- **Economics:** ~$12–$16 net profit per trade at 2% threshold ($1,000 position): $20 revenue − $3 Uniswap fee − $0.01 gas − $1–5 slippage

### Autonomous Operations
- **3 concurrent loops:** Trading (60s), P&L reporting (5m), health heartbeat (30s)
- **Self-sustaining:** Agent covers its own gas and operational costs from trading profits
- **Risk-gated:** Integrates with CRE Risk Router — no trade executes without passing 8 risk gates

### Coordination
- **Receives tasks** via Hedera Consensus Service (HCS)
- **Reports results** (P&L, trade outcomes) back via HCS
- **Quality-gated payments** — only gets paid after coordinator validates results

---

## Base-Native Integration Depth

```
[ERC-8004] Register agent identity on Base
        |
        v
[Coordinator assigns DeFi task via HCS]
        |
        v
[CRE Risk Router] — 8 risk gates, DON-verified decision
        |
        v (approved)
[Uniswap V3 SwapRouter] — exactInputSingle on Base Sepolia
        |
  [ERC-8021] — Builder code appended to calldata
        |
        v
[x402] — Agent pays for any gated services autonomously
        |
        v
[P&L Report] — Revenue, costs, net profit, win rate → HCS
```

**Contract Addresses (Base Sepolia — Chain ID 84532):**
- USDC: `0x036CbD53842c5426634e7929541eC2318f3dCF7e`
- WETH: `0x4200000000000000000000000000000000000006`
- Uniswap V3 SwapRouter: Base Sepolia deployment

---

## What's Built

- **Go agent** (`agent-defi`) — fully implemented, tested, running
- **ERC-8004 identity registration** — `internal/base/identity/register.go`
- **ERC-8021 builder attribution** — appended to every transaction
- **x402 payment handling** — autonomous invoice parsing, validation, payment, retry
- **Uniswap V3 trading** — `internal/base/trading/executor.go` with real swap execution
- **Mean reversion strategy** — configurable thresholds, position sizing, confidence scaling
- **P&L tracking** — revenue, costs, net profit, win rate, self-sustaining status
- **Dashboard panel** — Real-time DeFi P&L visualization with trade history and tx hashes
- **Risk integration** — Fail-closed connection to CRE Risk Router

---

## Why This Matters for Base

1. **Demonstrates the agent identity stack** — ERC-8004 + ERC-8021 + x402 working together in a real application, not a demo
2. **Self-sustaining economics** — Agent covers its own costs, proving Base is viable for autonomous agent operations
3. **Builder attribution on every tx** — ERC-8021 creates traceable, accountable agent transactions on Base
4. **Blueprint for other builders** — Architecture shows how to build accountable, risk-controlled DeFi agents on Base

---

## Metrics

| Metric | Value |
|--------|-------|
| Base standards integrated | 3 (ERC-8004, ERC-8021, x402) |
| Trading pair | USDC/WETH on Uniswap V3 |
| Concurrent loops | 3 (trading, P&L, heartbeat) |
| Risk gates before execution | 8 (via CRE Risk Router) |
| Estimated profit per trade | $12–$16 net |
| Chain | Base Sepolia (84532) |

---

## What's Next

1. **Base mainnet deployment** — Migrate from Sepolia with real capital
2. **Multi-pair trading** — Expand beyond USDC/WETH to additional Uniswap V3 pools
3. **Agent registry** — On-chain directory of ERC-8004 registered agents on Base
4. **x402 service mesh** — Agent-to-agent payments for inference, data, and compute services
5. **Open-source template** — Reusable Base DeFi agent framework for other builders

---

## Team

**Lance Rogers** — Full-stack engineer. Built multi-agent economy across 4 chains (Hedera, 0G, Base, Ethereum). Deep integration with Base-native standards (ERC-8004, ERC-8021, x402) and Uniswap V3.

---

## Links

- **GitHub:** github.com/lancekrogers
- **Base Sepolia contracts:** Trading on chain ID 84532
- **Related:** CRE Risk Router on Sepolia ([`0x9C7Aa...`](https://sepolia.etherscan.io/address/0x9C7Aa5502ad229c80894E272Be6d697Fd02001d7)) provides risk controls for this agent

---

## Ask

**Builder Grant:** 3–5 ETH retroactive grant for shipped Base-native agent with 3 standard integrations

**Builder Rewards:** Enrollment in weekly builder rewards program via builderscore.xyz

**Longer term:** Base Batches consideration for full-time founder track if agent economics prove out on mainnet
