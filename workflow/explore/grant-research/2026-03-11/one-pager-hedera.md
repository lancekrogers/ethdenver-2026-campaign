# Hedera Foundation / Hashgraph Association Grant Application — One-Pager

> Track: External Proof. Keep claims tied to deployed topics, transactions, or code paths.

**Project:** Obey Agent Economy — Multi-Agent Coordination on Hedera
**Applicant:** Lance Rogers
**Date:** 2026-03-11
**Target Program:** Hedera Foundation Proposal Grant / Hashgraph Association Enablement Program

---

## Problem

Autonomous AI agents need a coordination layer that is fast, cheap, auditable, and doesn't require heavy EVM smart contracts. Existing agent frameworks use centralized message queues (Redis, Kafka) or expensive L1 transactions for inter-agent communication. This creates opacity, single points of failure, and high operational costs that prevent agent economies from scaling.

---

## Solution

A multi-agent orchestration system built **entirely on native Hedera services** — no Solidity smart contracts required for coordination, messaging, or settlement.

| Hedera Service | How We Use It |
|----------------|---------------|
| **HCS (Hedera Consensus Service)** | Inter-agent messaging backbone. Two topics: Task Topic (`0.0.7999404`) for assignments, Status Topic (`0.0.7999405`) for updates. 8 message types flow through HCS. |
| **HTS (Hedera Token Service)** | AGNT fungible token for agent payment settlement. 100 AGNT per completed task, transferred from treasury to agent accounts. |
| **Schedule Service (HIP-1215)** | Deferred settlement via scheduled transactions. Heartbeat mechanism using zero-value HBAR transfers for liveness monitoring. |
| **Account Management** | Per-agent testnet accounts with ED25519 key pairs. Coordinator creates and manages agent identities. |

---

## Architecture

```
Festival Task Plan (fest CLI)
        |
        v
  [Coordinator] — Reads tasks, publishes to HCS Task Topic
        |
        v
  [HCS] ──────→ [agent-inference] (0G compute)
    |──────────→ [agent-defi] (Base trading)
    |
    v
  [HCS Status Topic] ← Results from all agents
        |
        v
  [Quality Gates] — Validates results before payment
        |
        v
  [HTS Settlement] — AGNT token transfer via HIP-1215 scheduled tx
        |
        v
  [Hedera Mirror Node] → [Dashboard] (real-time observation)
```

**8 HCS Message Types:** `task_assignment`, `status_update`, `task_result`, `pnl_report`, `heartbeat`, `quality_gate`, `payment_settled`, `risk_check_requested`

---

## What's Built

### Core Agent Coordinator
- **Go agent** (`agent-coordinator`) — fully implemented orchestration brain
- Reads festival-structured task plans, publishes to HCS, assigns to specialized agents
- Monitors progress via HCS status topic, enforces quality gates before payment
- Settles payments in AGNT (HTS) tokens via HIP-1215 scheduled transactions
- Heartbeat monitoring via zero-value HBAR scheduled transfers

### Smart Contracts (Solidity on Hedera EVM)
- **AgentSettlement.sol** — Batch payment settlement with replay protection via taskId mapping + HIP-1215 deferred execution
- **ReputationDecay.sol** — Per-agent reputation with configurable linear time-decay (1 point/hour default), lazily applied, decay scheduled via HIP-1215
- **34 passing Foundry tests**

### Developer Tooling (hiero-plugin)
- **Hiero CLI plugin** extending `hcli` with campaign workspace commands
- **3 Hedera templates** shipped:
  - `hedera-smart-contract` — Hardhat + Solidity + Hedera testnet config
  - `hedera-dapp` — Vite + React + HashConnect wallet integration
  - `hedera-agent` — Go agent with HCS messaging and HTS operations
- **37 passing tests**

### Multi-Agent Ecosystem
- 3 specialized agents all use HCS for coordination:
  - `agent-coordinator` — orchestration + settlement (100% Hedera)
  - `agent-inference` — receives tasks via HCS, reports results via HCS
  - `agent-defi` — receives tasks via HCS, reports P&L via HCS

### Operational Dashboard
- Real-time HCS Feed panel showing all consensus messages
- Agent Activity panel with heartbeat monitoring
- Festival View showing task progress
- Data sourced from Hedera Mirror Node REST API

---

## Differentiation

| Factor | Us | Typical Hedera Project |
|--------|-----|----------------------|
| Hedera services used | HCS + HTS + Schedule Service + Accounts | 1-2 services |
| Architecture | "No Solidity" coordination — pure native services | EVM-first with Hedera as afterthought |
| Agent count | 3 autonomous agents coordinating via HCS | Single application |
| Developer tooling | Ships hiero-plugin with 3 templates for ecosystem | No tooling contribution |
| Settlement model | Quality-gated HTS payments via HIP-1215 | Simple token transfers |
| Reputation | On-chain time-decaying reputation with scheduled decay | No reputation system |

---

## What's Next (Grant Funding Enables)

1. **Mainnet migration** — Move from testnet to Hedera mainnet with production accounts and real AGNT token
2. **Agent marketplace** — HCS-based discovery protocol where agents advertise capabilities and bid on tasks
3. **Cross-agent reputation network** — Expand ReputationDecay to a shared reputation graph across agent providers
4. **hiero-plugin expansion** — Additional templates: `hedera-marketplace`, `hedera-reputation`, `hedera-multi-agent`
5. **SDK extraction** — Extract HCS messaging patterns into a reusable Go SDK for other Hedera agent builders
6. **Documentation + tutorials** — Comprehensive guides for building multi-agent systems on Hedera native services

---

## Hedera Track Alignment

This project directly demonstrates two Hedera hackathon tracks:
- **Track 3: "No Solidity Allowed"** — Coordination layer uses HCS + HTS with zero EVM contracts
- **Track 4: "Developer Tooling"** — hiero-plugin ships production templates

The grant would fund the transition from hackathon demonstration to production infrastructure that other Hedera builders can use.

---

## Team

**Lance Rogers** — Full-stack engineer specializing in distributed systems and blockchain infrastructure. Built multi-agent coordination across 4 chains (Hedera, 0G, Base, Ethereum). Deep experience with Go, Solidity, Hedera SDK, and autonomous agent architecture.

---

## Links

- **GitHub:** github.com/lancekrogers
- **Hedera Testnet Resources:**
  - HCS Task Topic: `0.0.7999404`
  - HCS Status Topic: `0.0.7999405`
  - AGNT Token: Created via HTS on testnet
- **Contracts:** Deployed via Foundry to Hedera testnet (`https://testnet.hashio.io/api`)

---

## Ask

**Hedera Foundation:** $50K–$100K for mainnet migration + SDK extraction + documentation
**Hashgraph Association:** $250K–$500K for full agent marketplace + reputation network + ecosystem tooling

**Milestones:**
1. Mainnet deployment + production accounts — 3 weeks
2. HCS messaging SDK extraction + docs — 4 weeks
3. Agent marketplace protocol on HCS — 6 weeks
4. Reputation network expansion — 4 weeks
5. Additional hiero-plugin templates + tutorials — 3 weeks
