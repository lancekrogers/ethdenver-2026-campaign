# Base Builder Grant — Self-Nomination Content

> Track: External Proof. Keep claims tied to the concrete Base Sepolia evidence referenced in this file.

## Short Version (For Nomination Form)

**Project:** Obey Agent Economy — Autonomous DeFi Agent on Base

**One-liner:** Autonomous trading agent integrating ERC-8004 identity, ERC-8021 builder attribution, and x402 machine payments — trading Uniswap V3 on Base Sepolia with Chainlink CRE risk controls.

**What's shipped:**
- 4 Base Sepolia contract deployments from our wallet (identity, settlement, reputation, iNFT)
- ERC-8004 identity registration tx already executed on Base Sepolia
- ERC-8004: Verifiable on-chain agent identity before any trading
- x402: Agent autonomously pays for services (HTTP 402 → on-chain USDC → receipt)
- ERC-8021: Every transaction attributed to builder via calldata suffix
- Uniswap V3 mean reversion strategy (USDC/WETH)
- 8-gate risk evaluation via Chainlink CRE before every trade
- Testnet economics and P&L tracking implemented in code

**Tech:** Go, go-ethereum, Base Sepolia (chain ID 84532), 40+ passing tests

**GitHub:** [LINK]

**Evidence:** [BASESCAN TX LINKS]

**Twitter/Farcaster:** [HANDLES]

---

## Detailed Version (If Form Allows More)

### What We Built

An autonomous DeFi trading agent that demonstrates how AI agents can operate on Base with **accountability, attribution, and autonomy** using three emerging standards:

**ERC-8004 (Trustless Agent Identity):** Before the agent executes any trade, it registers a verifiable on-chain identity on Base Sepolia. This proves provenance — who built the agent, when it was deployed, and what it's authorized to do. No more anonymous wallets running DeFi strategies without accountability.

**x402 (HTTP Payment Protocol):** The agent autonomously handles payment-gated resources. When it encounters an HTTP 402 response, it parses the invoice, validates the amount and expiry, submits an on-chain USDC payment on Base, and retries with proof of payment. Machine-to-machine payments with no human in the loop. 445 lines of real implementation.

**ERC-8021 (Builder Codes):** Every transaction the agent makes — every swap, every payment — has a 20-byte builder attribution code appended to the calldata. Every trade is traceable back to the builder. On-chain accountability for autonomous agents.

**Trading:** Mean reversion strategy on USDC/WETH via Uniswap V3 SwapRouter on Base Sepolia. Buys 2% below 30-period moving average, sells 2% above. Confidence scales with price deviation. The economics model and P&L reporting are implemented; additional live trade evidence is still being collected.

**Risk Controls:** Every trade signal passes through 8 risk gates via Chainlink CRE (Runtime Environment) before execution. Oracle health, price deviation, position sizing, agent heartbeat. First denial = no trade. Fail-closed.

**Economics:** The agent is designed for self-funded operation and tracks gas, service costs, and P&L in code. The strongest public evidence today is the Base deployment and identity-registration activity; more live trading and payment evidence is still worth collecting.

### Why This Matters for Base

1. **Early adopter of 3 Base-aligned standards** — ERC-8004, ERC-8021, x402 have very few live implementations. This project demonstrates all three working together.
2. **Blueprint for accountable agents on Base** — As AI agents enter DeFi, they need identity, attribution, and autonomous payments. This is the pattern.
3. **Implemented agent economics** — Shows how a Base-native agent can track and manage operating costs, identity, attribution, and payments together.
4. **Open source** — Other builders can use this as a reference implementation.

### Technical Details

| Spec | Detail |
|------|--------|
| Language | Go |
| Chain | Base Sepolia (84532) |
| DEX | Uniswap V3 SwapRouter |
| Token pair | USDC (0x036CbD5...) → WETH (0x420000...) |
| Standards | ERC-8004, ERC-8021, x402 |
| Risk layer | Chainlink CRE (8 gates, DON consensus) |
| Tests | 40+ passing (unit + integration) |
| Code quality | Context propagation, error wrapping, DI, table-driven tests |
