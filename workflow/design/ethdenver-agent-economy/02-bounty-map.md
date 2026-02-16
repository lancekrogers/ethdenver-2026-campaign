# Bounty Map — What Satisfies What

## Critical Constraint

**Track 2 (On-Chain Automation) and Track 3 (No Solidity) are mutually exclusive.** Track 2 requires Solidity contracts. Track 3 forbids them. We submit separate components to each.

- **Primary submission**: The agent economy (no Solidity) → Track 3
- **Secondary submission**: Automation contracts → Track 2
- **Separate submission**: Hiero CLI plugin → Track 4

---

## Hedera Track 3: "No Solidity Allowed" — $5,000

**Prize**: 3 winners ($2,500 / $1,500 / $1,000)

**What we submit**: The core agent economy — Coordinator Agent managing Inference and DeFi agents via native Hedera services.

### Requirement Checklist

| Requirement | How We Satisfy It |
|-------------|-------------------|
| At least TWO native capabilities | HCS + HTS + Schedule Service + Accounts = **4** |
| Zero Solidity or EVM contracts | All Hedera interactions use `@hashgraph/sdk` natively |
| Working testnet app | Full agent economy running on Hedera testnet |
| Clear security model | Per-agent accounts, key rotation, multi-sig for large transfers |

### Native Services Used

1. **HCS (Hedera Consensus Service)**
   - Festival plan publication (immutable agent task structures)
   - Inter-agent messaging (task assignments, progress updates, results)
   - Audit trail (every agent action recorded with consensus timestamp)

2. **HTS (Hedera Token Service)**
   - Fungible token for agent-to-agent payments
   - NFTs for agent identity/reputation
   - Escrow pattern: coordinator holds funds, releases per completed task

3. **Hedera Schedule Service**
   - Recurring heartbeat transactions (agent liveness checks)
   - Scheduled settlement cycles (batch payment processing)
   - Deferred multi-sig approvals

4. **Account Management**
   - Unique account per agent (proper identity isolation)
   - Key rotation via SDK
   - Multi-sig configuration for high-value operations

---

## Hedera Track 4: Best Hiero CLI Plugin — $5,000

**Prize**: 2 winners ($2,500 each)

**What we submit**: `hiero camp` — a Hiero CLI plugin that brings camp workspace management to Hedera development.

### Requirement Checklist

| Requirement | How We Satisfy It |
|-------------|-------------------|
| PR to hiero-cli repo | Submitted following PLUGIN_ARCHITECTURE_GUIDE.md |
| Node.js plugin architecture | Plugin wraps camp Go binary, exposes Node.js interface |
| Useful beyond hackathon | Camp is a general-purpose workspace tool; Hedera templates are reusable |
| PR link + demo video + docs | All included |

### Plugin Commands

```bash
hiero camp init <name>              # Initialize Hedera campaign workspace
hiero camp init <name> --template agent-economy  # With agent project template
hiero camp add-project <name>       # Add a new project to workspace
hiero camp status                   # Show workspace status + project health
hiero camp navigate <project>       # Jump to project directory
```

### Judging Criteria Alignment

| Criterion | Our Score |
|-----------|----------|
| **Developer value** | High — every Hedera dev needs workspace management |
| **Code quality** | High — camp is mature Go software, plugin follows Hiero conventions |
| **Architecture fit** | High — follows existing plugin patterns exactly |
| **Usability** | High — `hiero camp init` is one command to a full workspace |
| **Lasting impact** | High — useful for any Hedera project, not just hackathon |

---

## Hedera Track 2: On-Chain Automation — $5,000 (OPTIONAL)

**Prize**: 2 winners ($3,000 + $2,000)

**What we submit**: Solidity contracts that use HIP-1215 for automated agent economy operations.

### Requirement Checklist

| Requirement | How We Satisfy It |
|-------------|-------------------|
| Working testnet app | Contracts deployed and executing scheduled calls |
| Scheduling from smart contracts | Uses HIP-755 System Contract to access Schedule Service |
| DeFi automation or business finance | Agent settlement and reputation management |
| Edge case handling + observability | Error recovery, event logs, dashboard integration |

### Contracts

**AgentSettlement.sol**
- Accumulates pending payments between agents
- Schedules batch settlement every N minutes via HIP-1215
- Uses `hasScheduleCapacity()` to find available execution windows
- Emits events for dashboard observability

**ReputationDecay.sol**
- Tracks agent activity timestamps
- Schedules periodic reputation score decay for inactive agents
- Agents must complete tasks to maintain reputation
- Creates incentive for continuous participation

### Build Priority

This is the **lowest priority** component. Build only if Tracks 3 and 4 are solid and time remains.

---

## 0G Track 2: Best Use of AI Inference — $7,000

**Prize**: 2 winners

**What we submit**: The Inference Agent — uses 0G Compute for decentralized AI inference, orchestrated by obey daemon.

### Requirement Checklist

| Requirement | How We Satisfy It |
|-------------|-------------------|
| Leverage 0G Compute | Agent routes all inference through 0G Compute broker |
| Decentralized inference | Provider matching via broker, CVM with TEE attestation |
| Escrow-based payment | Standard 0G Compute payment flow |

### 0G Utilization (30% of judging)

| 0G Layer | How We Use It |
|----------|--------------|
| **Compute** | All agent inference runs on decentralized GPU providers |
| **Storage** | Agent memory, knowledge base, inference results stored on 0G |
| **Chain** | ERC-7857 iNFT contract (see Track 3 below) |
| **DA** | Inference audit trail published to DA layer |

Using all 4 layers maximizes the 30% utilization score.

---

## 0G Track 3: Best Use of On-Chain Agent (iNFT) — $7,000

**Prize**: 2 winners

**What we submit**: The Inference Agent tokenized as an ERC-7857 iNFT — its intelligence (model weights, memory, behavior config) is the NFT metadata.

### Requirement Checklist

| Requirement | How We Satisfy It |
|-------------|-------------------|
| Uses ERC-7857 | Agent persona minted as iNFT |
| Encrypted metadata | Agent intelligence encrypted, only owner can access |
| TEE oracle for transfers | Standard 0G TEE oracle handles metadata on sale |
| Dynamic metadata | iNFT metadata updates as agent learns from tasks |

### iNFT Design

```
ERC-7857 iNFT: "InferenceAgent #1"
├── Public metadata:
│   ├── name: "InferenceAgent"
│   ├── specialization: "DeFi analysis"
│   ├── reputation_score: 94
│   └── tasks_completed: 127
│
└── Encrypted metadata (owner only):
    ├── model_config: { provider, model, temperature, system_prompt }
    ├── memory: [ recent_interactions ]
    ├── knowledge_base_ref: "0g://storage/<cid>"
    └── strategy_weights: { ... }
```

The iNFT is a **transferable, ownable AI agent**. Buy the NFT, get the agent's intelligence. Sell it, and the TEE oracle securely transfers the encrypted metadata to the new owner.

---

## 0G Track 4: Dev Tooling — $4,000

**Prize**: 1 winner

**What we submit**: fest + camp templates for 0G development — scaffolding tools that help developers start 0G projects quickly.

### What We Build

```bash
# camp template: scaffold a complete 0G agent project
camp init --template 0g-agent

# fest template: pre-built festival plan for 0G projects
fest create --template 0g-inft-build

# Result: structured workspace with build plan
```

### Composability (20% of judging)

camp and fest are protocol-agnostic tools. The 0G templates show how they integrate with 0G's specific stack, but the tools work with any protocol. This is composability by design.

---

## Base: Self-Sustaining AI Agent — $3,000+

**Prize**: 6 x $3,000 + 19 x $1,000

**What we submit**: The DeFi Agent — autonomous trader on Base mainnet that earns revenue exceeding its costs.

### Requirement Checklist

| Requirement | How We Satisfy It |
|-------------|-------------------|
| Self-sustaining | Revenue > operational costs (demonstrated on dashboard) |
| Fully autonomous on Base mainnet | Minimal human loop, agent makes decisions |
| Public performance dashboard | Real-time P&L, trade history, reputation |
| ERC-8004 | Agent registered with Identity + Reputation + Validation registries |
| x402 | Agent pays for compute/data via HTTP 402 + USDC |
| ERC-8021 | Builder code appended to every transaction calldata |

### Self-Sustainability Model

```
Revenue:
  - DEX arbitrage (cross-pool price differences)
  - Yield farming (LP positions in stable pairs)
  - MEV capture (sandwich-resistant strategies)

Costs:
  - x402 payments for data feeds and compute
  - Gas fees (mitigated by Smart Account AA)
  - 0G Compute fees for inference (via Inference Agent)

Target: Revenue > 2x Costs (demonstrable on dashboard)
```

---

## Competition Track: Future Llama

**What we submit**: The project itself — hierarchical multi-chain agent orchestration is frontier AI research.

### Why It Qualifies

- **Novel coordination**: Festival-structured planning for autonomous agents
- **Multi-chain operation**: Agents reason across different blockchain environments
- **Hierarchical control**: Executive agent delegates to specialists with quality gates
- **Self-sustaining economics**: Agents that earn their own operating costs

---

## Submission Summary

| # | Track | Component | Prize | Priority |
|---|-------|-----------|-------|----------|
| 1 | Hedera Track 3 | Agent economy (no Solidity) | $5,000 | **P0** |
| 2 | Hedera Track 4 | `hiero camp` plugin | $5,000 | **P0** |
| 3 | 0G Track 2 | Inference Agent on 0G Compute | $7,000 | **P1** |
| 4 | 0G Track 3 | Agent iNFT (ERC-7857) | $7,000 | **P1** |
| 5 | Base | Self-sustaining DeFi Agent | $3,000 | **P1** |
| 6 | **Hedera Track 1** | **OpenClaw extension (see 06-openclaw-extension.md)** | **$10,000** | **P1+** |
| 7 | 0G Track 4 | fest/camp templates | $4,000 | **P2** |
| 8 | Hedera Track 2 | Automation contracts | $5,000 | **P2** |
| 9 | Future Llama | Full project | TBD | **P2** |

**P0**: Must be rock-solid. These are our best shots.
**P1**: Important, build in parallel with P0.
**P1+**: Build immediately after obey agents work. Additive — no existing work changes.
**P2**: Nice to have. Build if time permits.
