# Obey-Orchestrated Cross-Chain Agent Swarm

## Dual Purpose

| Axis | Score | Why |
|------|-------|-----|
| **Bounty** | Very High | Targets Hedera $25k (all 4 tracks) + 0G $7k + Base $3k |
| **Exposure** | Very High | Obey daemon IS the orchestration layer. Camp/fest managed the build. |

## Concept

Build the cross-chain agent swarm (from project_ideas/06) but **use the obey platform as the actual orchestration layer**. Instead of using a generic framework, the swarm coordinator IS an obey daemon instance managing specialized agents across chains.

The meta-narrative: "We built an AI agent orchestration system. Then we used it to orchestrate AI agents across 4 blockchains. Then we won the hackathon."

## How Obey Tooling Integrates

### obey daemon = Swarm Coordinator

Instead of building a custom swarm coordinator on Hedera, the obey daemon IS the coordinator:

- **Agent orchestration**: daemon manages the lifecycle of chain-specific agents
- **Hierarchical execution**: Executive agent (daemon) delegates to specialist agents (DeFi on Base, inference on 0G, etc.)
- **Provider agnostic**: Different agents can use Claude, GPT, DeepSeek - whatever's best for their task
- **Deterministic workflows**: Festival-defined task sequences ensure reproducible agent behavior

The daemon connects to Hedera via the Agent Kit as its blockchain layer, giving agents:
- HCS for inter-agent messaging (immutable audit trail)
- HTS for agent payments and reputation tokens
- Scheduled contracts for automated heartbeats

### fest = How We Built It

The festival methodology defines the entire hackathon build:

```
Festival: ETHDenver Cross-Chain Agent Swarm
├── Phase 1: Foundation (Feb 12-14)
│   ├── Sequence 1.1: Infrastructure setup
│   ├── Sequence 1.2: Obey daemon configuration
│   └── Sequence 1.3: Chain connection adapters
├── Phase 2: Agent Development (Feb 15-17)
│   ├── Sequence 2.1: Base DeFi agent
│   ├── Sequence 2.2: 0G inference agent
│   └── Sequence 2.3: Hedera coordination layer
├── Phase 3: Integration (Feb 18-19)
│   ├── Sequence 3.1: Cross-chain communication
│   └── Sequence 3.2: Dashboard + monitoring
└── Phase 4: Polish (Feb 20-21)
    ├── Sequence 4.1: Testing + hardening
    └── Sequence 4.2: Demo preparation
```

This IS the fest methodology in action. Every task is tracked, every phase has gates, every sequence has quality checks.

### camp = How We Organized It

The campaign structure manages the entire hackathon workspace:

```
ethdenver2026/                    # Campaign root
├── projects/
│   ├── swarm-coordinator/        # Obey daemon + Hedera integration
│   ├── base-agent/               # Self-sustaining DeFi agent
│   ├── zerog-agent/              # Inference agent on 0G
│   └── dashboard/                # Unified monitoring UI
├── festivals/
│   └── active/
│       └── cross-chain-swarm/    # The festival plan
└── workflow/
    └── design/                   # Architecture docs
```

Navigation via `cgo` makes multi-project work seamless.

## Architecture

```
┌─────────────────────────────────────────────────┐
│              OBEY DAEMON (Coordinator)            │
│   Hierarchical agent orchestration engine         │
│   Provider-agnostic (Claude, GPT, DeepSeek)      │
├─────────────────────────────────────────────────┤
│           Hedera Layer (HCS + HTS + HSS)         │
│   Agent messaging / payments / automation         │
├──────────┬──────────────┬───────────────────────┤
│   BASE   │      0G      │    (+ more chains)    │
│  Agent   │    Agent     │                       │
│          │              │                       │
│ DeFi     │ Inference    │                       │
│ Trading  │ Fine-tuning  │                       │
│ x402     │ iNFT mgmt    │                       │
└──────────┴──────────────┴───────────────────────┘
```

## Demo Day Script (2 minutes)

**[0:00-0:20] The Hook**
"We built an AI agent swarm that operates across 4 blockchains simultaneously. But the real story isn't the swarm - it's what we used to build it."

**[0:20-0:50] The Swarm Demo**
Show the dashboard: agents on Base trading, agents on 0G running inference, coordination flowing through Hedera. Real transactions happening live.

**[0:50-1:20] The Meta Reveal**
"The orchestration layer you're seeing isn't a hackathon prototype. It's Obedience Corp's obey daemon - our production agent orchestration engine. We didn't build a coordinator for this project. We used the one we already have."

**[1:20-1:40] The Tooling Story**
"We planned this entire project using our fest CLI" - flash the festival plan. "We organized across 4 codebases using our camp CLI" - flash the campaign structure. "And we orchestrated the agents using our daemon" - flash the agent dashboard.

**[1:40-2:00] The Close**
"Obedience Corp: AI that does what you want, the way you want it done. The swarm is the demo. The tooling is the product."

## Bounty Targets

| Bounty | Submission Angle |
|--------|-----------------|
| **Hedera Track 1** ($10k) | Obey daemon + OpenClaw agents coordinating via HCS/HTS with UCP |
| **Hedera Track 2** ($5k) | Scheduled contracts for agent heartbeats and auto-settlement |
| **Hedera Track 3** ($5k) | Native SDKs only - no Solidity |
| **Hedera Track 4** ($5k) | Hiero CLI plugin: `hiero swarm` commands for managing agent networks |
| **0G Best Agent** ($7k) | iNFT-based inference agent on full 0G stack |
| **Base Self-Sustaining** ($3k) | DeFi agent with ERC-8004 + x402 + ERC-8021 |
| **Future Llama Track** | Frontier AI: multi-chain hierarchical agent orchestration |

**Total potential: $35k+**

## Risk & Feasibility

- **High complexity, but modular** - each chain agent works independently
- **Obey daemon is real software** - not vaporware, reduces coordinator build time to near zero
- **Fest methodology handles the planning** - 5-day build is well-structured
- **Camp handles the workspace** - multi-project navigation is solved

## Exposure Value

- **Direct product demo**: Every judge and attendee sees obey daemon in action
- **"Built with" story**: fest + camp are visible in the workflow
- **Workshop potential**: "How to orchestrate AI agents across blockchains with Obey"
- **Hiring signal**: Shows the team can build serious infrastructure
- **Investor signal**: Shows the product works on a real, complex use case
