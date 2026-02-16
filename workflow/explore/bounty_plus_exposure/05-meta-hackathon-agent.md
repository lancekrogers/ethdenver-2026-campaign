# The Meta-Hackathon Agent: AI That Plans & Builds Hackathon Projects

## Dual Purpose

| Axis | Score | Why |
|------|-------|-----|
| **Bounty** | Medium | Targets 0G Dev Tooling $4k + Hedera Hiero CLI $5k + Future Llama track |
| **Exposure** | MAXIMUM | The entire product IS fest + camp + obey working together |

## Concept

Build an autonomous AI agent that can plan, scaffold, and partially build hackathon projects using the Festival Methodology, camp CLI, and obey daemon. Feed it a bounty description, and it:

1. Creates a festival plan (phases, sequences, tasks)
2. Scaffolds a camp workspace with project structure
3. Generates starter code for each project component
4. Orchestrates specialist agents to build different parts
5. Tracks progress and publishes updates

**The ultimate "eating your own cooking" demo**: An AI agent that uses Obedience Corp tools to help other developers win hackathons.

## Why This Is Maximum Exposure

This is the rarest kind of marketing: a product demo that is ITSELF a useful product. Every developer at ETHDenver faces the same problem: "I have a bounty to target and 5 days to build. How do I organize this?"

Our answer: "Let our agent plan it for you using Festival Methodology."

The meta angle: **We used this agent to plan and build itself.**

## How It Works

### Input
```
"I want to build a self-sustaining DeFi agent on Base targeting
the Kite/Bass bounty. I know Solidity and TypeScript. I have
5 days to build."
```

### Output

1. **Festival Plan** (via fest CLI):
   ```
   Festival: Base DeFi Agent
   ├── Phase 1: Setup (Day 1)
   │   ├── 1.1: Initialize workspace with camp
   │   ├── 1.2: Set up Base development environment
   │   └── 1.3: Deploy ERC-8004 identity contract
   ├── Phase 2: Core Agent (Days 2-3)
   │   ├── 2.1: Implement strategy engine
   │   ├── 2.2: Integrate x402 payment system
   │   └── 2.3: Add ERC-8021 builder code attribution
   ├── Phase 3: Dashboard (Day 4)
   │   └── 3.1: Build performance dashboard
   └── Phase 4: Polish (Day 5)
       ├── 4.1: Testing and hardening
       └── 4.2: Demo preparation
   ```

2. **Camp Workspace** (via camp CLI):
   ```
   base-defi-agent/
   ├── projects/
   │   ├── contracts/     # Solidity contracts
   │   ├── agent/         # Agent runtime
   │   └── dashboard/     # Next.js frontend
   ├── festivals/
   │   └── active/
   │       └── base-defi-agent/  # The plan
   └── justfile          # Build commands
   ```

3. **Starter Code**: Generated scaffolding for each component

4. **Progress Tracking**: Agent monitors your git commits against the festival plan and suggests what to work on next

### On-Chain Component (for bounty eligibility)

The agent itself runs on-chain:
- Festival plans published to Hedera HCS (immutable planning audit trail)
- Or to 0G Storage (decentralized plan storage)
- Agent uses 0G Compute for code generation inference
- Progress attestations on-chain

## Technical Architecture

```
User: "Plan a project for [bounty description]"
        │
        ▼
Meta-Agent (obey daemon orchestrating)
├── PlannerAgent (Claude): Analyzes bounty, creates festival plan
│   └── fest create → festival structure
├── ScaffoldAgent (Claude): Generates camp workspace
│   └── camp init → project structure + justfiles
├── CoderAgent (Claude): Generates starter code per component
│   └── Writes to camp project directories
└── TrackerAgent: Monitors progress, suggests next steps
    └── fest status → progress updates
```

## Bounty Targets

| Bounty | Angle |
|--------|-------|
| **0G Dev Tooling** ($4k) | AI-powered project planning tool for 0G developers |
| **Hedera Hiero CLI** ($5k) | Hiero plugin that plans Hedera projects |
| **Future Llama Track** | Meta-AI: an agent that plans agent projects |

## Demo Scenario

Live on stage at Demo Day:

1. "I'm going to build a hackathon project. Right now. In 60 seconds."
2. Feed the agent a bounty description
3. Watch it generate a festival plan in real-time
4. Watch it scaffold a workspace with camp
5. Watch it generate starter code
6. "I just went from bounty description to buildable project in under a minute."
7. "This is what Obedience Corp tools do: turn intent into execution."

## Exposure Value

- **Viral potential**: "AI that plans your hackathon project" is inherently shareable
- **Live demo at the venue**: Other hackers can try it during the event
- **Every user becomes a camp/fest user**: The tool installs and uses our CLIs
- **Post-event utility**: Tool is useful beyond ETHDenver (any hackathon, any project)
- **Content marketing**: "We built an AI that uses our tools to help you build" is great for blog/social

## Risk Assessment

- **Medium complexity**: The agent itself is straightforward if camp/fest CLIs are solid
- **Demo risk**: Live code generation can be unpredictable (mitigate with pre-cached examples)
- **Lower bounty ceiling**: Dev tooling prizes are smaller than agent-economy prizes
- **But maximum exposure**: This is the idea most likely to generate user signups
