# Obey-Powered Hedera Agent Commerce Network

## Dual Purpose

| Axis | Score | Why |
|------|-------|-----|
| **Bounty** | Very High | Targets all 4 Hedera tracks ($25k) |
| **Exposure** | Very High | obey daemon orchestrates the agents, fest planned the build, camp organized the workspace |

## Concept

This is idea #01 from project_ideas (Hedera Agentic Commerce Network) but executed WITH Obedience Corp tooling as the backbone. The obey daemon runs the agent coordinator, fest defines the agent task plans, and the whole thing demonstrates Obedience Corp's value proposition live on stage.

**The pitch**: "This agent economy runs on Hedera for settlement and trust. But the orchestration? That's Obedience Corp."

## Key Difference from project_ideas/01

| Aspect | Original Idea | This Version |
|--------|--------------|-------------|
| **Coordinator** | Custom OpenClaw runtime | **obey daemon** managing OpenClaw agents |
| **Planning** | Ad-hoc agent task allocation | **Festival-structured** task plans on HCS |
| **Workspace** | Generic project structure | **camp campaign** with multi-project navigation |
| **Agent lifecycle** | Custom | **obey daemon** agent orchestration (create, configure, run, monitor) |
| **Build process** | Unstructured hackathon sprint | **fest-planned** 5-day build with phases and gates |

## How Obey Components Map

### obey daemon → Agent Coordinator

```
obey daemon
├── Manages agent lifecycle (spawn, configure, monitor, stop)
├── Routes messages between agents (coordinator pattern)
├── Selects appropriate LLM per agent (Claude for analysis, GPT for coding, etc.)
├── Enforces hierarchical execution (executive → specialists)
└── Connects to Hedera via Agent Kit for:
    ├── HCS message publishing (agent-to-agent comms)
    ├── HTS token management (payments, reputation)
    └── Scheduled contracts (automated heartbeats, settlements)
```

### fest → Agent Task Plans (On-Chain)

Agent tasks are structured as festival sequences:

```
Festival: "Process Research Query for Client Agent"
├── Phase 1: Intake
│   ├── Task 1.1.1: Validate query parameters
│   └── Task 1.1.2: Check client reputation (ERC-equivalent on HTS)
├── Phase 2: Execution
│   ├── Task 2.1.1: Perform web research
│   ├── Task 2.1.2: Analyze results
│   └── Task 2.1.3: Generate report
├── Phase 3: Delivery
│   ├── Task 3.1.1: Publish results to HCS
│   └── Task 3.1.2: Collect payment via HTS
└── Quality Gate: Client satisfaction attestation
```

Published to HCS → immutable record of agent work plans.

### camp → Hackathon Workspace

```
ethdenver2026/
├── projects/
│   ├── agent-coordinator/    # obey daemon + Hedera integration
│   ├── agent-services/       # Specialist agent definitions
│   ├── commerce-protocol/    # UCP + HTS payment flows
│   ├── hiero-plugin/         # hiero camp CLI plugin
│   └── dashboard/            # Observer UI
├── festivals/
│   └── active/
│       └── hedera-commerce/  # The build plan
└── workflow/
    └── design/              # Architecture decisions
```

## Technical Stack

- **Agent Orchestration**: obey daemon (Go)
- **Agent Runtime**: OpenClaw with Hedera skills
- **Blockchain**: Hedera (HCS, HTS, HSS - NO Solidity)
- **Agent Kit**: hedera-agent-kit v3.7.0 (JS) with MCP Server
- **Commerce**: UCP (Universal Commerce Protocol)
- **Planning**: fest CLI → on-chain festival protocol on HCS
- **Workspace**: camp campaign with multi-project structure
- **CLI**: Hiero CLI plugin (`hiero camp`, `hiero agent`)
- **Dashboard**: Next.js observer UI showing agent states, HCS messages, HTS flows
- **Build System**: Modular justfiles per project

## Bounty Stacking (All 4 Hedera Tracks)

| Track | How We Hit It | Obey Integration |
|-------|--------------|------------------|
| **Track 1** ($10k): Killer App | OpenClaw agents + UCP commerce + agent economy | obey daemon IS the coordinator |
| **Track 2** ($5k): Automation | HIP-1215 for heartbeats, auto-settlement, phase transitions | fest quality gates trigger scheduled contracts |
| **Track 3** ($5k): No Solidity | All native HCS + HTS + Schedule Service | Entire stack avoids EVM |
| **Track 4** ($5k): Hiero CLI | `hiero camp` + `hiero agent` plugins | camp CLI wrapped as Hiero plugin |

## Demo Day Script

**[0:00-0:15] Hook**
"Three AI agents just completed a $50 research contract on Hedera in under 30 seconds. Autonomously."

**[0:15-0:45] Live Demo**
Show the dashboard. ResearchBot, AnalystBot, WriterBot coordinating a task. HCS messages flowing. HTS payments settling. Festival progress advancing through phases.

**[0:45-1:15] The Infrastructure**
"Behind this is Obedience Corp's obey daemon - hierarchical agent orchestration. Each agent is managed like an employee: assigned tasks, monitored, paid. The task plans? Festival Methodology - structured planning for autonomous agents, tracked immutably on Hedera Consensus Service."

**[1:15-1:40] Developer Story**
"We built this in 5 days. Our camp CLI organized 5 codebases. Our fest CLI planned every phase. Our daemon orchestrated the agents. These are open-source tools you can use today."

**[1:40-2:00] Close**
"Hedera provides trust and settlement. Obedience Corp provides orchestration and planning. Together: an autonomous agent economy."

## Exposure Matrix

| Touchpoint | What We Show |
|-----------|-------------|
| **Demo Day stage** | obey daemon running live agent economy |
| **GitHub repo** | camp structure + fest plan visible in README |
| **Dashboard** | Festival progress visualization (festui-style) |
| **Hiero CLI PR** | camp plugin submitted to Hedera's own repo |
| **Sponsor conversation** | "We orchestrate AI agents. Here's proof." |
| **Other hackers** | "We used fest to plan this whole build" |
| **Post-hackathon blog** | "How Obedience Corp tools helped us win ETHDenver" |

## Risk Assessment

- **Medium-high complexity**: Multi-track stacking requires hitting all 4 track requirements
- **Strong mitigation**: Each track component is modular and independently testable
- **obey daemon dependency**: Need the daemon to be stable enough for live demo
- **Very high reward**: $25k Hedera + track prizes + maximum exposure for Obedience Corp
