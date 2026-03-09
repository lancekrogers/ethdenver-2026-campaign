# 01 — Risk Router as a Service

## Description

Sell CRE risk evaluation as a paid API. Other agents or protocols submit trade parameters, get back an approve/deny decision with position constraints and on-chain DON consensus receipts. Payment via x402 (machine-to-machine, per-request).

## What Exists Today

The CRE Risk Router is fully implemented:

- **8-gate pipeline** in `pkg/riskeval/risk.go` — hold signal filter, signal confidence, risk ceiling, staleness, oracle health, price deviation, position sizing, heartbeat
- **Bridge HTTP server** at `cmd/bridge/` — `POST /evaluate-risk` returns structured decisions with denial codes
- **On-chain receipts** — `RiskDecisionReceipt.sol` deployed at `0x9C7Aa5502ad229c80894E272Be6d697Fd02001d7` on Sepolia, with DON consensus via KeystoneForwarder
- **x402 payment protocol** already implemented in `agent-defi/internal/base/payment/x402.go` — invoice, pay, verify flow on Base Sepolia

The bridge API is a working HTTP server. Adding x402 gating means: wrap the `/evaluate-risk` endpoint to require payment before evaluation.

## Capital Required

Near zero.

- Deploy bridge to a $5/mo VPS or free tier (Railway, Fly.io)
- CRE WASM workflow runs on Chainlink DON (no hosting cost to us)
- On-chain receipt writes cost gas on Sepolia (free) or Ethereum mainnet (~$0.50-2.00 per write at current gas)

Mainnet deployment of the receipt contract would cost a one-time deploy fee (~$20-50 in ETH gas) plus per-receipt gas.

## Revenue Model

Per-request fee via x402:

| Tier | Price | What You Get |
|------|-------|-------------|
| Basic | $0.01-0.05 | 8-gate evaluation, JSON response |
| Premium | $0.10-0.50 | Evaluation + on-chain DON receipt |
| Bulk | Custom | Dedicated bridge instance, SLA |

At $0.05/request with 1,000 requests/day = $50/day = $1,500/month.

## Moat

- **8-gate pipeline** is more thorough than simple threshold checks — signal confidence, oracle health, price deviation, position sizing all in sequence
- **DON consensus receipts** provide cryptographic proof of the risk decision — no other risk API offers this
- **On-chain evidence** — decisions are recorded in an immutable contract, useful for compliance and audit
- **Denial reason codes** are specific and actionable (10 distinct codes), not generic pass/fail

## Blockers

### Hard Blockers

1. **No demand signal yet.** Zero external agents have called this API. The entire market of "agents that need pre-trade risk evaluation from a third party" may not exist at meaningful scale today.

2. **CRE mainnet costs.** The DON consensus flow is free on testnet but Chainlink CRE pricing for mainnet is unclear. If per-report costs are $1+, the $0.05 API price doesn't work without subsidizing the on-chain portion.

3. **Gate 5 is mocked.** Price deviation check skips in the CRE WASM workflow because CRE v1.2.0 lacks HTTP fetch. The bridge uses a hardcoded $2000 oracle price. This undermines the "production-grade risk evaluation" pitch.

### Soft Blockers

4. **Oracle data source.** Bridge currently uses mock oracle data. Connecting to live Chainlink feeds for multiple pairs requires configuration work and potentially API costs.

5. **Multi-chain support.** Currently evaluates on one chain (Sepolia). Real demand would require supporting Base, Arbitrum, Polygon feeds.

6. **Marketing.** Agent builders need to know this exists. No distribution channel established.

## Honest Assessment

The technology is real and the API is functional. The fundamental question is whether any agent builder will pay for external risk evaluation when they can build their own threshold checks in 50 lines of code.

The moat is the DON consensus receipt — no one else offers cryptographic proof that a risk check happened, signed by a decentralized oracle network. This matters for regulated contexts, fund compliance, and audit trails. But the buyers who care about compliance and audit trails are institutional, and they don't buy from a solo developer's API.

**Verdict: Viable if demand exists, but demand is unproven. Worth deploying as a free/cheap API to generate usage data and test whether anyone cares.**
