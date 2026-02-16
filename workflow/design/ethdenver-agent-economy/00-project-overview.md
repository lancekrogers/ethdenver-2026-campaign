# Obey Agent Economy — Project Overview

## One-Liner

An autonomous agent economy orchestrated by the obey daemon, settling on Hedera, with decentralized inference on 0G and self-sustaining trading on Base.

## The Decision

**We do NOT use OpenClaw.** We forfeit Hedera Track 1 ($10k) and use obey daemon agents throughout. Every component of the system is Obedience Corp infrastructure. The demo isn't "we used someone else's framework and added a blockchain." It's "this is our system, running live, doing real work across multiple chains."

Once obey agents work end-to-end, we add OpenClaw as a second agent runtime (see `06-openclaw-extension.md`). This recovers Track 1 AND proves the daemon is runtime-agnostic. No work is forfeited — OpenClaw is purely additive.

## Remaining Bounty Targets

| Sponsor | Track | Prize | Our Angle |
|---------|-------|-------|-----------|
| **Hedera** | Track 3: No Solidity | $5,000 (3 winners) | Agent economy using native HCS + HTS + Schedule Service |
| **Hedera** | Track 4: Hiero CLI Plugin | $5,000 (2 winners) | `hiero camp` — camp as a Hiero plugin |
| **Hedera** | Track 2: On-Chain Automation | $5,000 (2 winners) | Optional: Solidity layer for automated settlement (separate submission) |
| **0G** | Track 2: AI Inference | $7,000 (2 winners) | Agents use 0G Compute for decentralized inference |
| **0G** | Track 3: iNFT | $7,000 (2 winners) | Agent personas tokenized as ERC-7857 iNFTs |
| **0G** | Track 4: Dev Tooling | $4,000 (1 winner) | fest/camp templates for 0G projects |
| **Base** | Self-Sustaining Agent | $3,000+ | DeFi agent with ERC-8004 + x402 + ERC-8021 |
| **Competition** | Future Llama | TBD | Frontier AI: hierarchical multi-chain agent orchestration |
| **Hedera** | Track 1: Killer App | $10,000 (1 winner) | OpenClaw extension after obey agents work (see 06-openclaw-extension.md) |
| | | **$46k-$51k** | |

## What the Project IS

Three specialized AI agents, orchestrated by the obey daemon, operating across three blockchains simultaneously:

### Agent 1: Coordinator (Hedera)
- Runs inside obey daemon as the executive agent
- Publishes festival-structured task plans to HCS (immutable audit trail)
- Manages agent reputation via HTS tokens
- Settles inter-agent payments via HTS
- Uses native Schedule Service for automated heartbeats and settlement cycles
- **Zero Solidity** — all native Hedera SDK operations

### Agent 2: Inference Provider (0G)
- Runs inference jobs on 0G Compute (decentralized GPU marketplace)
- Stores agent memory/knowledge on 0G Storage
- Tokenized as an ERC-7857 iNFT on 0G Chain (transferable agent identity)
- Receives task assignments from the Coordinator via HCS
- Reports results back through HCS, gets paid via HTS

### Agent 3: DeFi Trader (Base)
- Self-sustaining: earns revenue exceeding operational costs
- Registered with ERC-8004 (Trustless Agents — identity + reputation)
- Pays for compute via x402 (HTTP payment protocol)
- Every transaction attributed via ERC-8021 (Builder Codes)
- Receives strategy guidance from Inference Provider
- Executes trades autonomously on Base mainnet

### The Dashboard
- Observer UI showing all three agents operating in real-time
- Festival progress visualization (phases, sequences, tasks flowing through)
- HCS message stream (inter-agent communication)
- HTS payment flows (who paid whom, how much)
- Base P&L (is the DeFi agent profitable?)
- 0G inference metrics (compute usage, model performance)

## Why This Architecture

```
                    ┌──────────────────────────────┐
                    │      OBEY DAEMON             │
                    │   (Executive Orchestrator)    │
                    │                              │
                    │   Festival-planned tasks     │
                    │   Provider-agnostic LLMs     │
                    │   Hierarchical control       │
                    └──────┬───────────┬───────────┘
                           │           │
              ┌────────────┤           ├────────────┐
              │            │           │            │
              ▼            ▼           ▼            ▼
    ┌─────────────┐ ┌───────────┐ ┌─────────┐ ┌──────────┐
    │   HEDERA    │ │    0G     │ │  BASE   │ │DASHBOARD │
    │             │ │           │ │         │ │          │
    │ HCS: comms  │ │ Compute:  │ │ DeFi    │ │ Observer │
    │ HTS: money  │ │  inference│ │ trading │ │ UI       │
    │ Schedule:   │ │ Storage:  │ │ ERC-8004│ │          │
    │  heartbeat  │ │  memory   │ │ x402    │ │ Festivals│
    │             │ │ iNFT:     │ │ ERC-8021│ │ Payments │
    │ NO SOLIDITY │ │  identity │ │         │ │ Metrics  │
    └─────────────┘ └───────────┘ └─────────┘ └──────────┘
```

The obey daemon sits at the top. It doesn't just "connect" to these chains — it RUNS the agents that operate on them. The festival methodology structures their work. Camp organized the build. This is Obedience Corp infrastructure, proven live on stage.

## Track 2 (On-Chain Automation) — Optional Add-On

Track 2 requires Solidity contracts that schedule their own execution via HIP-1215. This is architecturally separate from the No-Solidity core. If time permits, we add a thin Solidity layer:

- `AgentSettlement.sol` — contract that auto-settles accumulated agent payments on a schedule
- `ReputationDecay.sol` — contract that automatically decays inactive agent reputation scores
- Scheduled via HIP-1215 to execute without external triggers

This is a **separate bounty submission** from the No-Solidity agent economy. Same project, different component, different track.

**Important conflict**: Track 2 requires Solidity. Track 3 forbids it. We submit the native agent system to Track 3 and the automation contracts to Track 2 as separate submissions. The core project is the Track 3 entry.

## The Exposure Story

**Demo Day pitch**: "Three AI agents. Three blockchains. One orchestrator. This is Obedience Corp."

**What judges see**: An impressive multi-chain agent economy.

**What developers see**: The tools that built it — camp for workspace management, fest for planning, obey daemon for orchestration.

**What sponsors see**: A team that understands their technology deeply enough to build across it.

**What follows**: "Want to build something like this? Our tools are open source. `brew install obey`."
