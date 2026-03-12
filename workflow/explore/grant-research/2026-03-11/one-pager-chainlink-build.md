# Chainlink BUILD Program Application — One-Pager

**Project:** CRE Risk Router — Runtime Risk Controls for Autonomous Agents
**Applicant:** Lance Rogers
**Date:** 2026-03-11
**Target Program:** Chainlink BUILD Program

---

## Problem

Autonomous AI agents are generating trade signals and executing DeFi transactions without systematic risk evaluation. An agent can execute trades on stale market data, take positions far beyond safe exposure, or continue trading during oracle outages. There is no decentralized, auditable way to prove that a risk evaluation occurred before execution — and no way to enforce guardrails without centralized trust.

---

## Solution

**CRE Risk Router** is a Chainlink Runtime Environment (CRE) workflow that evaluates trade signals through 8 sequential risk gates. Every decision — approved or denied — is recorded on-chain as an immutable receipt via DON consensus. No trade executes without proof of evaluation.

---

## CRE Integration (Deep, Not Surface-Level)

| CRE Capability | How We Use It |
|----------------|---------------|
| **cron-trigger@1.0.0** | Fires every 5 minutes for periodic risk sweeps |
| **Go WASM (wasip1)** | All gate logic compiled to WASM for deterministic CRE execution |
| **GenerateReport** | Packages RiskDecision for DON consensus signing |
| **WriteReport** | DON-verified write to chain via KeystoneForwarder |
| **evm-write** | On-chain receipt storage through `IReceiver` interface |
| **Chainlink Price Feeds** | Oracle health validation (latestRoundData 5-tuple) in Gate 5 |

**This is not a wrapper around Chainlink data feeds.** The entire risk pipeline runs as a CRE workflow — from trigger through evaluation to on-chain write — with no external orchestration.

---

## The 8 Risk Gates

```
Trade Signal
    |
    v
[1] Hold Signal Filter ──── deny hold signals (fast-path)
    |
[2] Signal Confidence ───── require >= 0.6
    |
[3] Risk Score Ceiling ──── reject if > 75
    |
[4] Signal Staleness ────── reject if > 300s old
    |
[5] Oracle Health ────────── validate Chainlink latestRoundData 5-tuple
    |                         (positive answer, non-zero updatedAt,
    |                          answeredInRound >= roundID, fresh within 3600s)
    |
[6] Price Deviation ──────── reject if market vs oracle > 500 BPS (5%)
    |
[7] Position Sizing ──────── constrain by volatility + risk score (never denies)
    |
[8] Agent Heartbeat ──────── circuit breaker if agent stale (optional)
    |
    v
RiskDecision → ABI encode → DON consensus → on-chain receipt
```

First hard-deny gate to fail **short-circuits** the pipeline. Fail-closed: if the CRE workflow is unreachable, no trade executes.

---

## On-Chain Evidence

**Contract:** `RiskDecisionReceipt.sol` deployed on Ethereum Sepolia at `0x9C7Aa5502ad229c80894E272Be6d697Fd02001d7`

| Feature | Detail |
|---------|--------|
| **Interface** | CRE `IReceiver` — receives DON-forwarded reports via KeystoneForwarder |
| **Stored per decision** | runId, decisionHash, approved/denied, maxPositionUsd, maxSlippageBps, ttlSeconds, chainlinkPrice |
| **Replay protection** | Duplicate prevention per runId |
| **Expiry** | TTL-based via `isDecisionValid()` |
| **Counters** | On-chain `totalApproved()` and `totalDecisions()` |
| **Events** | `DecisionRecorded` for off-chain indexing |
| **Detection** | ERC165 interface support |

**Live Transactions:**
- CRE Broadcast: [`0xea6784a...`](https://sepolia.etherscan.io/tx/0xea6784a79fd108cfb4fc07127ab19b2c9f2a90867fcccc47b339e685fe3169c4)
- Direct Evidence: [`0x0c72922...`](https://sepolia.etherscan.io/tx/0x0c72922fd8e31f859dc5ce30364d87e86c939f7c2a2282899db11b65242dabd1)
- On-chain state: `getRunCount() = 1`, `totalApproved() = 1`, `totalDecisions() = 1`

---

## What's Built

- **CRE workflow** — Go compiled to WASM (wasip1), runs in CRE runtime
- **8 configurable risk gates** with thresholds in `config.staging.json`
- **RiskDecisionReceipt.sol** — Deployed, verified, with real transactions
- **HTTP bridge** — `/evaluate-risk` endpoint for external integration
- **Full Foundry test suite** — Contract tests passing
- **Simulation + broadcast** — Both `cre workflow simulate` and `--broadcast` working
- **Integration with agent-coordinator** — Fail-closed: denied or unreachable = task rejected

---

## Why BUILD (Not Just Grants)

CRE Risk Router isn't a one-time project — it's infrastructure that grows with CRE:

1. **Early CRE adopter** — We've already built a non-trivial CRE workflow and can provide ongoing feedback
2. **Composable** — Any agent builder can plug in the risk router as a pre-execution gate
3. **Expanding use cases** — Cross-chain risk evaluation, multi-oracle aggregation, portfolio-level risk
4. **Developer advocacy** — We've documented the full CRE experience including pain points and suggestions (WASM compilation, ABI encoding, DON consensus flow documentation)

We want long-term partnership, not a one-time check.

---

## What's Next (BUILD Support Enables)

1. **Mainnet deployment** — Move from Sepolia to Ethereum mainnet (or supported L2)
2. **Multi-oracle aggregation** — Evaluate risk across multiple Chainlink price feeds simultaneously
3. **Cross-chain risk evaluation** — Extend to evaluate signals on Arbitrum, Base, Polygon via CCIP
4. **Dynamic gate configuration** — On-chain governance for risk threshold updates
5. **Risk Router SDK** — Reusable Go library for other CRE builders to add risk gates
6. **Production documentation** — Integration guides, architecture docs, deployment runbooks

---

## CRE Developer Feedback (Already Provided)

**What worked well:**
- `cron-trigger@1.0.0` — Easy to configure, worked as documented
- `evm-write` via DON consensus — Powerful trust model for on-chain writes
- Go WASM compilation — Clean once configured, deterministic execution is compelling
- Staging vs production config separation via `--target` flags

**What was challenging:**
- WASM compilation setup required trial and error around Go build tags
- ABI encoding for `evm-write` needed careful type alignment (more examples would help)
- DON consensus flow documentation could be more detailed
- Error messages during simulation could be more descriptive

**Suggestions:**
- `cre workflow validate` command for pre-simulation schema checking
- More end-to-end examples: Go WASM → on-chain write with real ABI encoding
- Local simulation mode without RPC connectivity for faster iteration

---

## Team

**Lance Rogers** — Full-stack engineer. Built multi-agent system across 4 chains. Early CRE adopter with production workflow, on-chain evidence, and detailed developer feedback.

---

## Links

- **GitHub:** [github.com/lancekrogers/cre-risk-router](https://github.com/lancekrogers/cre-risk-router) (public)
- **Contract:** [`0x9C7Aa5502ad229c80894E272Be6d697Fd02001d7`](https://sepolia.etherscan.io/address/0x9C7Aa5502ad229c80894E272Be6d697Fd02001d7) on Sepolia
- **KeystoneForwarder:** `0x15fC6ae953E024d975e77382eEeC56A9101f9F88`

---

## Ask

**BUILD Program membership** with focus on:
- Early access to CRE updates and new capabilities
- Technical expert access for mainnet deployment and cross-chain expansion
- Co-marketing: case study on CRE-based risk infrastructure for autonomous agents
- Ecosystem connections with DeFi protocols that need agent risk controls
