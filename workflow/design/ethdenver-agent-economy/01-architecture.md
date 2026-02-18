# System Architecture

## Component Map

```
┌─────────────────────────────────────────────────────────────────────┐
│                         OBEY DAEMON                                 │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │ Agent Manager │  │  Task Router │  │ Festival Engine           │  │
│  │              │  │              │  │                          │  │
│  │ Spawn agents │  │ Route tasks  │  │ Phase/Sequence/Task      │  │
│  │ Monitor state│  │ Track deps   │  │ Quality gates            │  │
│  │ Kill agents  │  │ Balance load │  │ Progress tracking        │  │
│  └──────┬───────┘  └──────┬───────┘  └────────────┬─────────────┘  │
│         │                 │                       │                 │
│  ┌──────┴─────────────────┴───────────────────────┴──────────────┐  │
│  │                    LLM Provider Layer                          │  │
│  │   Claude  │  GPT  │  DeepSeek  │  Ollama  │  (any provider)  │  │
│  └───────────────────────────────────────────────────────────────┘  │
└──────────────┬────────────────┬────────────────┬────────────────────┘
               │                │                │
    ┌──────────▼──────┐ ┌──────▼───────┐ ┌──────▼───────┐
    │  HEDERA LAYER   │ │  0G LAYER    │ │  BASE LAYER  │
    │                 │ │              │ │              │
    │  Coordinator    │ │  Inference   │ │  DeFi Agent  │
    │  Agent          │ │  Agent       │ │              │
    └─────────────────┘ └──────────────┘ └──────────────┘
```

## Agent Definitions

### Coordinator Agent (Hedera)

**Runtime**: obey daemon agent (Go)
**LLM**: Claude (best for planning and coordination)
**Hedera SDK**: `@hashgraph/sdk` (JS/TS) or `hedera-sdk-py` (Python) — choose based on Agent Kit compatibility

**Responsibilities**:

1. Create and manage festival plans (task structures for multi-agent work)
2. Publish festival plans to HCS topic (immutable record)
3. Assign tasks to specialist agents via HCS messages
4. Monitor agent progress via HCS message subscriptions
5. Manage HTS fungible token for inter-agent payments
6. Manage HTS NFTs for agent reputation/identity
7. Use Schedule Service to create recurring heartbeat checks

**Hedera Operations (native SDK only)**:

```
HCS Operations:
  - TopicCreateTransaction → create festival topic
  - TopicMessageSubmitTransaction → publish plan, progress, results
  - TopicMessageQuery (mirror node) → subscribe to agent messages

HTS Operations:
  - TokenCreateTransaction → create agent payment token
  - TokenMintTransaction → mint reputation tokens
  - TransferTransaction → pay agents for completed tasks
  - TokenAssociateTransaction → onboard new agents

Schedule Service Operations:
  - ScheduleCreateTransaction → schedule heartbeat checks
  - ScheduleSignTransaction → multi-agent approval flows

Account Operations:
  - AccountCreateTransaction → create agent accounts
  - AccountUpdateTransaction → rotate keys
```

**Native capabilities used**: HCS + HTS + Schedule Service + Account Management = **4 native services** (Track 3 requires minimum 2)

### Inference Agent (0G)

**Runtime**: obey daemon agent (Go/TS)
**LLM**: Self-hosted via 0G Compute (the point is decentralized inference)

**Responsibilities**:

1. Accept inference requests from Coordinator (via HCS)
2. Route inference jobs to 0G Compute (decentralized GPU marketplace)
3. Store model weights and agent memory on 0G Storage
4. Maintain ERC-7857 iNFT representing agent identity/intelligence
5. Update iNFT metadata as agent learns (dynamic metadata)
6. Report results back to Coordinator via HCS

**0G Operations**:

```
0G Compute:
  - Connect to broker via @0glabs/0g-serving-broker
  - Submit inference requests
  - Handle escrow-based payment flow

0G Storage:
  - Upload agent memory/knowledge base
  - Upload/download model artifacts
  - Store inference results for audit

0G Chain (EVM):
  - Deploy ERC-7857 iNFT contract
  - Mint agent iNFT with encrypted metadata
  - Update metadata on learning events
  - TEE oracle handles metadata transfer on sale

0G DA:
  - Data availability for inference audit trail
```

**0G layers used**: Chain + Storage + Compute + DA = **all 4 layers** (maximizes 30% utilization criterion)

### DeFi Agent (Base)

**Runtime**: obey daemon agent (Go/TS)
**LLM**: Claude or GPT (best for financial reasoning)

**Responsibilities**:

1. Execute DeFi strategies on Base mainnet (swap, LP, yield)
2. Earn revenue that exceeds operational costs (self-sustaining requirement)
3. Register identity via ERC-8004 (Trustless Agents)
4. Pay for compute/API access via x402 (HTTP payment protocol)
5. Attribute every transaction via ERC-8021 (Builder Codes)
6. Receive strategy recommendations from Inference Agent
7. Report P&L to Coordinator via HCS
8. Maintain public performance dashboard

**Base Operations**:

```
ERC-8004 (Trustless Agents):
  - Identity Registry: register agent NFT
  - Reputation Registry: accumulate reputation from successful trades
  - Validation Registry: validate agent actions

x402 (HTTP Payment Protocol):
  - HTTP 402 responses trigger USDC payments
  - Agent pays for compute, data feeds, API access
  - 1,000 free txns/month via facilitator

ERC-8021 (Builder Codes):
  - Append builder code to calldata of every transaction
  - On-chain attribution for all agent activity

Coinbase AgentKit:
  - Framework for agent wallet management
  - Smart Account (AA) for gasless transactions
  - Agentic Wallet with spend limits
```

## Data Flow

```
                        FESTIVAL PLAN
                    (published to HCS)
                            │
           ┌────────────────┼────────────────┐
           │                │                │
           ▼                ▼                ▼
    ┌──────────┐     ┌──────────┐     ┌──────────┐
    │Coordinator│────▶│Inference │────▶│  DeFi    │
    │  Agent   │     │  Agent   │     │  Agent   │
    └────┬─────┘     └────┬─────┘     └────┬─────┘
         │                │                │
    HCS: task        0G Compute:      Base mainnet:
    assignments      run inference    execute trades
         │                │                │
    HTS: payments    0G Storage:      ERC-8004:
    to agents        store memory     reputation
         │                │                │
    Schedule Svc:    iNFT (7857):     x402: pay
    heartbeats       agent identity   for compute
         │                │                │
         └────────────────┼────────────────┘
                          │
                    ┌─────▼─────┐
                    │ DASHBOARD │
                    │           │
                    │ Festival  │
                    │ progress  │
                    │ HCS feed  │
                    │ HTS flows │
                    │ Base P&L  │
                    │ 0G metrics│
                    └───────────┘
```

### Inter-Agent Communication Protocol

All agent communication flows through HCS (Hedera Consensus Service):

```
Message Format (JSON published to HCS topic):
{
  "type": "task_assignment" | "progress" | "result" | "payment" | "heartbeat",
  "from": "<agent_id>",
  "to": "<agent_id>" | "broadcast",
  "festival": "<festival_id>",
  "phase": 1,
  "sequence": 1,
  "task": 1,
  "payload": { ... },
  "timestamp": "<ISO-8601>"
}
```

HCS provides:

- **Ordering**: Messages are globally ordered (consensus timestamp)
- **Immutability**: Once published, cannot be altered
- **Audit trail**: Full history of all agent interactions
- **Low latency**: ~3-5 second finality

## Technology Stack

| Layer                | Technology                                       | Language                                    |
| -------------------- | ------------------------------------------------ | ------------------------------------------- |
| **Orchestrator**     | obey daemon                                      | Go                                          |
| **Agent runtime**    | obey daemon agents                               | Go (with TS adapters where SDKs require it) |
| **Hedera SDK**       | `@hashgraph/sdk`                                 | TypeScript                                  |
| **0G SDKs**          | `@0glabs/0g-ts-sdk`, `@0glabs/0g-serving-broker` | TypeScript                                  |
| **Base/EVM**         | ethers.js + Coinbase AgentKit                    | TypeScript                                  |
| **Dashboard**        | Next.js                                          | TypeScript/React                            |
| **Hiero CLI Plugin** | Node.js (wrapping camp Go binary)                | Node.js                                     |
| **Planning**         | fest CLI                                         | Go                                          |
| **Workspace**        | camp CLI                                         | Go                                          |
| **Build system**     | just (modular justfiles)                         | -                                           |

## Project Structure (camp campaign)

```
ethdenver2026/
├── projects/
│   ├── agent-coordinator/        # Obey daemon + Hedera integration
│   │   ├── cmd/                  # Entry point
│   │   ├── internal/
│   │   │   ├── hedera/           # HCS, HTS, Schedule Service adapters
│   │   │   ├── festival/         # On-chain festival protocol
│   │   │   └── agents/           # Agent lifecycle management
│   │   ├── justfile
│   │   └── go.mod
│   │
│   ├── agent-inference/          # 0G inference agent
│   │   ├── src/
│   │   │   ├── compute/          # 0G Compute broker integration
│   │   │   ├── storage/          # 0G Storage client
│   │   │   ├── inft/             # ERC-7857 iNFT management
│   │   │   └── agent/            # Agent logic
│   │   ├── justfile
│   │   └── package.json
│   │
│   ├── agent-defi/               # Base DeFi agent
│   │   ├── src/
│   │   │   ├── strategy/         # Trading strategy engine
│   │   │   ├── identity/         # ERC-8004 registration
│   │   │   ├── payments/         # x402 integration
│   │   │   ├── attribution/      # ERC-8021 builder codes
│   │   │   └── agent/            # Agent logic
│   │   ├── justfile
│   │   └── package.json
│   │
│   ├── dashboard/                # Observer UI
│   │   ├── src/
│   │   │   ├── components/
│   │   │   │   ├── FestivalView/ # Festival progress visualization
│   │   │   │   ├── HCSFeed/      # Real-time HCS message stream
│   │   │   │   ├── PaymentFlow/  # HTS payment visualization
│   │   │   │   ├── BasePnL/      # DeFi agent P&L
│   │   │   │   └── InferenceMetrics/ # 0G compute stats
│   │   │   └── pages/
│   │   ├── justfile
│   │   └── package.json
│   │
│   ├── hiero-plugin/             # Hiero CLI camp plugin
│   │   ├── src/
│   │   │   └── index.js          # Plugin manifest + commands
│   │   ├── justfile
│   │   └── package.json
│   │
│   └── contracts/                # Optional: Track 2 Solidity automation
│       ├── src/
│       │   ├── AgentSettlement.sol
│       │   └── ReputationDecay.sol
│       ├── justfile
│       └── foundry.toml
│
├── festivals/
│   └── active/
│       └── ethdenver-agent-economy/  # The build plan (fest managed)
│
├── workflow/
│   ├── design/                   # This directory
│   └── explore/                  # Research and ideas
│
├── docs/
│   └── 2026_requirements/        # Bounty requirements
│
├── justfile                      # Root justfile (imports project justfiles)
└── CLAUDE.md
```

## Security Model

### Hedera Key Management

- Each agent gets its own Hedera account with dedicated key pair
- Coordinator account holds escrow funds
- Multi-sig required for large transfers (coordinator + agent)
- Key rotation scheduled via Schedule Service
- Testnet keys stored in environment variables, never committed

### 0G Security

- TEE attestation for compute providers (CVM verification)
- Encrypted iNFT metadata — only owner can read agent intelligence
- TEE oracle handles metadata transfer during iNFT sale

### Base Security

- Agentic Wallet with spend limits (Coinbase infrastructure)
- Smart Account (AA) for gasless execution
- Builder code attribution creates transparent audit trail

### General

- All secrets in `.env` files, gitignored
- Testnet only for hackathon (no real funds at risk)
- Dashboard is read-only (observes, never acts)
