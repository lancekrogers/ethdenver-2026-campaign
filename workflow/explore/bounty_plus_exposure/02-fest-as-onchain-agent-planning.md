# Festival Methodology as On-Chain Agent Planning Protocol

## Dual Purpose

| Axis | Score | Why |
|------|-------|-----|
| **Bounty** | High | Targets Hedera $10k (Killer App) + $5k (No Solidity) + 0G Dev Tooling $4k |
| **Exposure** | Maximum | fest IS the product being demonstrated. Direct product-market fit signal. |

## Concept

Port the Festival Methodology to an on-chain protocol where AI agents use festival-structured plans to coordinate complex multi-step tasks. Agents create festivals (plans), break them into phases and sequences, track progress via Hedera Consensus Service, and use scheduled contracts for automated phase transitions.

The core insight: **autonomous AI agents need structured planning just like human teams do.** The Festival Methodology - designed for human-AI collaboration - becomes the coordination protocol for agent-to-agent collaboration.

This is the most direct exposure play possible: the hackathon project IS a demonstration that the festival methodology works for agent coordination.

## How It Works

### Festival Methodology → Agent Protocol Mapping

| Festival Concept | On-Chain Agent Equivalent |
|-----------------|--------------------------|
| **Festival** | A complex multi-agent task (e.g., "audit and optimize a DeFi protocol") |
| **Phase** | Major milestone with quality gates (e.g., "Phase 1: Research", "Phase 2: Execute") |
| **Sequence** | Ordered set of tasks within a phase (e.g., "scan contracts", "identify risks") |
| **Task** | Atomic unit of work assigned to a specific agent |
| **Quality Gate** | On-chain validation that a phase completed successfully before proceeding |
| **fest status** | HCS topic showing real-time progress of all agents |
| **fest validate** | Smart contract that verifies phase completion criteria |

### Agent Coordination Flow

```
Agent A creates a Festival on Hedera:
  "Audit Protocol X and optimize gas usage"
        │
        ▼
Festival plan published to HCS topic (immutable record)
  Phase 1: Analysis (assigned to Agent B - security specialist)
  Phase 2: Optimization (assigned to Agent C - gas optimizer)
  Phase 3: Verification (assigned to Agent D - test runner)
        │
        ▼
Agent B starts Phase 1, publishes progress to HCS
  Sequence 1.1: Fetch contract source ✓
  Sequence 1.2: Run static analysis ✓
  Sequence 1.3: Identify vulnerabilities ✓
  → Quality Gate: "Found 3 issues, severity scores attached"
        │
        ▼
Scheduled contract (HIP-1215) checks gate criteria
  → Gate passes → Phase 2 auto-starts
        │
        ▼
Agent C begins optimization work...
  (same pattern: sequences, progress, gates)
        │
        ▼
All phases complete → Festival marked done on-chain
  Full audit trail on HCS, payments via HTS
```

### The Observer Dashboard

A web UI that mirrors `fest status` and `fest tui` but for on-chain agent festivals:

- Real-time festival progress visualization (phases, sequences, tasks)
- Agent assignment and status tracking
- Quality gate results and phase transitions
- Full HCS message history (immutable audit trail)
- Payment flows between agents (HTS)

**This dashboard IS a demonstration of what festui could look like in production.**

## Technical Architecture

### On-Chain Components (Hedera - NO Solidity)

1. **Festival Registry (HCS)**
   - Each festival is a dedicated HCS topic
   - Plan structure published as the first message
   - Progress updates published as subsequent messages
   - Immutable, timestamped, ordered audit trail

2. **Agent Registry (HTS)**
   - Each agent is an HTS NFT with capabilities metadata
   - Reputation tracked via HTS token balances
   - Agents stake reputation tokens to accept tasks

3. **Quality Gates (Scheduled Contracts - HIP-1215)**
   - Phase transition criteria defined in festival plan
   - Scheduled contract checks gate conditions at specified times
   - Auto-advances to next phase when gate passes
   - Alerts coordinator agent if gate fails

4. **Payment Settlement (HTS)**
   - Agents earn HTS fungible tokens for completed tasks
   - Payment escrowed at festival creation
   - Released per-phase as quality gates pass

### Off-Chain Components

5. **fest CLI Integration**
   - `fest create` generates both local festival AND on-chain HCS topic
   - `fest status` reads from both local state and HCS
   - `fest validate` checks both local structure and on-chain gate results
   - Seamless bridge between developer experience and on-chain coordination

6. **OpenClaw Skills**
   - `hedera-festival-skill`: OpenClaw plugin that lets agents create/join/execute festivals
   - Agents discover available festivals, claim tasks, publish progress
   - Uses Hedera Agent Kit under the hood

## Demo Scenario

**Live on stage:**

1. Show a real festival plan (the one we used to build THIS project)
2. "Now watch what happens when we put this on-chain for agents"
3. Agent A creates a festival: "Analyze ETH/USDC liquidity on Base"
4. Three specialist agents claim tasks from different phases
5. Watch progress flow through the festival in real-time (HCS messages)
6. Quality gate passes → next phase auto-starts (HIP-1215 scheduled contract)
7. Festival completes → agents paid via HTS
8. "This is the Festival Methodology. We use it to plan our human work. Now agents use it to plan theirs."

## Bounty Targets

| Bounty | Angle |
|--------|-------|
| **Hedera Track 1** ($10k) | Agent-native app: agents coordinate via festival protocol on Hedera |
| **Hedera Track 3** ($5k) | No Solidity - all native HCS + HTS + Schedule Service |
| **0G Dev Tooling** ($4k) | fest CLI as developer tool for managing agent workflows (if ported to 0G) |
| **Future Llama** | Structured agent coordination protocol = frontier AI research |

**Total potential: $15k-$19k**

## Exposure Value

This is the **maximum exposure** play because:

1. **fest IS the product**: The hackathon project directly demonstrates fest methodology
2. **Product-market fit signal**: If agents benefit from structured planning, so do AI dev teams
3. **"Eat your own cooking"**: We used fest to plan the build, AND the build demonstrates fest
4. **Narrative power**: "We built a planning system for AI agents, using our planning system for AI agents"
5. **Concrete next step**: "Want to try this? `pip install fest` / `go install fest`"
6. **Workshop topic**: "The Festival Methodology: Structured Planning for Autonomous Agent Systems"
7. **Open source story**: fest is open source - developers can start using it immediately

## Risk Assessment

- **Medium complexity**: HCS + HTS + scheduled contracts is well-documented territory
- **Novel angle**: Nobody has put a structured planning methodology on-chain for agents
- **Clear narrative**: Easy to explain, easy to demo
- **Double exposure**: fest CLI + on-chain protocol = two things to show
