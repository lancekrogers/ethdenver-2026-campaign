# Hedera Agentic Commerce Network

## Target Bounties

**Hedera's actual pool is $25,000 across 4 tracks (from Devfolio). A single project can stack across all of them.**

| Bounty | Prize | Fit |
|--------|-------|-----|
| **Hedera Track 1: Killer App for Agentic Society** | $10,000 (1 winner) | PRIMARY - exact match |
| **Hedera Track 3: "No Solidity Allowed"** | $5,000 (3 winners) | STACK - build with native SDKs only, no EVM |
| **Hedera Track 2: On-Chain Automation** | $5,000 (2 winners) | STACK - scheduled contracts for agent heartbeats |
| **Hedera Track 4: Hiero CLI Plugin** | $5,000 (2 winners) | STACK - ship CLI plugin as dev interface |
| **Future Llama Track** | Track prize + celebrity judge | Frontier AI research |

**Total potential: Up to $25k across all 4 Hedera tracks + competition track prizes**

### Multi-Track Stacking Strategy
The key insight: one well-architected project qualifies for ALL Hedera tracks if:
1. It uses OpenClaw + UCP for agent commerce (Track 1: $10k)
2. It uses ONLY native Hedera SDKs - HTS, HCS, no Solidity (Track 3: $5k)
3. It includes HIP-1215 scheduled contract calls for automation (Track 2: $5k)
4. It ships a Hiero CLI plugin for managing agent network (Track 4: $5k)

## Concept

An autonomous agent-to-agent commerce network built on Hedera using OpenClaw as the runtime. Agents negotiate, transact, and coordinate economic activity using the Universal Commerce Protocol (UCP) standard, with Hedera providing the settlement layer, identity system, and coordination backbone.

This directly targets Hedera's stated bounty: "an agent-native application designed for a society of OpenClaw agents, where commerce, coordination, or value exchange happens autonomously."

## Architecture

### Core Components

1. **Agent Registry (HTS + HCS)**
   - Each agent mints an HTS NFT representing its identity, capabilities, and reputation score
   - Agent profiles stored on Hedera Consensus Service topics
   - Reputation updated via on-chain attestations after successful transactions

2. **Commerce Engine (UCP on Hedera)**
   - Implements UCP (Google's Universal Commerce Protocol) for standardized agent-to-agent commerce
   - Agents publish service offerings (inference, data processing, research, code generation)
   - Automated price negotiation via HCS message streams
   - Settlement via HBAR or HTS fungible tokens

3. **Autonomous Orchestration (HIP-1215)**
   - Scheduled contract calls for recurring agent tasks (monitoring, rebalancing, reporting)
   - Agents schedule their own future executions at the protocol level
   - No off-chain keepers or bots needed - fully on-chain cron

4. **OpenClaw Integration Layer**
   - OpenClaw skills/plugins that connect to the Hedera Agent Kit
   - Any OpenClaw agent can join the network by installing the Hedera commerce skill
   - Agents bring their own LLM backend (Claude, GPT, DeepSeek, local models)

5. **Observer Dashboard (Human UI)**
   - Real-time visualization of agent-to-agent commerce flows
   - Shows agent states, transaction history, reputation scores, active negotiations
   - "Designed for humans observing agents" - exactly what bounty requires

### Data Flow

```
OpenClaw Agent A                    OpenClaw Agent B
    |                                      |
    |-- publishes service offering -------->|  (HCS topic)
    |                                      |
    |<---- negotiates price/terms ---------|  (HCS messages)
    |                                      |
    |-- accepts, creates escrow ---------->|  (HTS token lock)
    |                                      |
    |<---- delivers work product ----------|  (HCS + 0G storage)
    |                                      |
    |-- releases payment, rates agent ---->|  (HTS transfer + attestation)
    |                                      |
    [Dashboard shows all steps in real-time]
```

## Technical Stack

- **Runtime**: OpenClaw (Node.js agent runtime, 60k+ GitHub stars)
- **Blockchain**: Hedera - **NO SOLIDITY** (native HTS + HCS + Schedule Service only)
- **Agent Kit**: `hedera-agent-kit` v3.7.0 (JS) with LangChain + MCP Server integrations
- **Commerce**: UCP (Universal Commerce Protocol) for agent-to-agent transactions
- **AI Models**: Claude via OpenClaw's model router
- **Frontend**: Next.js dashboard showing agent network activity
- **Automation**: HIP-1215 scheduled contract calls (on-chain cron, no off-chain keepers)
- **CLI**: Hiero CLI plugin for managing agent network from terminal

### How This Hits All 4 Hedera Tracks

| Track | How We Hit It |
|-------|--------------|
| **Track 1 ($10k)**: Killer App | OpenClaw agents + UCP commerce + multi-agent economy |
| **Track 2 ($5k)**: Automation | HIP-1215 scheduled calls for agent heartbeats, auto-settlement, periodic reputation updates |
| **Track 3 ($5k)**: No Solidity | All logic via native HTS (tokens), HCS (messaging), Schedule Service. Zero EVM contracts. |
| **Track 4 ($5k)**: Hiero CLI | Ship a `hiero agent` plugin: `hiero agent register`, `hiero agent list`, `hiero agent fund`, `hiero agent status` |

## Why This Wins

1. **Exact bounty match**: Agent-native app for OpenClaw society with autonomous commerce
2. **Uses UCP**: Bonus points explicitly mentioned in bounty for UCP agent-to-agent commerce
3. **Uses Hedera's unique features**: HTS, HCS, and HIP-1215 scheduled contracts (not just EVM)
4. **Observer UI**: Bounty specifically requires "interface that shows agent flow steps and states"
5. **Leverages viral trend**: OpenClaw + Moltbook ecosystem is the hottest thing in agent space
6. **Novel**: Nobody has built UCP + OpenClaw + Hedera together yet

## Demo Scenario

Live demo showing 3-5 OpenClaw agents:
- **ResearchBot**: Offers web research services for 5 HBAR per query
- **CodeBot**: Offers code review services for 10 HBAR per review
- **AnalystBot**: Needs research + code review, negotiates and purchases from other agents
- **AuditorBot**: Monitors all transactions, publishes reputation attestations
- Dashboard shows the entire economy in real-time with flow diagrams

## Risk Assessment

- **Low risk**: Hedera Agent Kit is mature, OpenClaw is well-documented
- **Medium complexity**: UCP integration is new but spec is public
- **High reward**: $10k single bounty + track eligibility
