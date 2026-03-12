# Obey Agent Economy: Decentralized Inference Pipeline on 0G

> **Category:** Guild on 0G 2.0
> **Copy-paste this into hall.0g.ai after creating an account**
> **✅ Evidence compiled 2026-03-11 — All contract addresses and tx hashes verified on-chain**

---

## 1) Project Overview and Objectives

**What we're building:** Obey Agent Economy is a multi-agent system where autonomous AI agents coordinate work, execute inference, trade on DeFi, and settle payments — all with on-chain provenance. The inference agent is built natively on all four 0G services: Compute, Storage, Chain, and Data Availability.

**What's already built:**
- **agent-inference** (Go): Full 7-stage pipeline — receive task → discover providers → execute inference → store result → mint iNFT → publish audit trail → report result
- **agent-coordinator** (Go): Multi-agent orchestration with quality gates and payment settlement
- **agent-defi** (Go): Autonomous DeFi trading on Base with risk controls
- **cre-risk-router** (Go/WASM): Chainlink CRE risk evaluation with on-chain receipts (live on Ethereum Sepolia)
- **contracts** (Solidity): AgentINFT (ERC-7857), ReputationDecay, AgentSettlement — 39 passing Foundry tests
- **dashboard** (Next.js): Real-time operational visibility across all agents
- **hiero-plugin** (TypeScript): Developer tooling with `0g-agent` and `0g-inft-build` templates

**Objectives for this grant:**
1. Deploy all 0G contracts to mainnet and execute full pipeline end-to-end
2. Complete session-based inference execution with live GPU providers
3. Open-source the inference agent as a reusable framework for other 0G builders
4. Build multi-provider load balancing across GPU providers registered on 0G Compute

---

## 2) Technical Architecture and Implementation Plan

### Architecture

```
Task Assignment (Hedera Consensus Service)
        │
        ▼
┌─────────────────────────────────────────────┐
│           agent-inference (Go)               │
│                                              │
│  Stage 1: Receive task via HCS subscription  │
│  Stage 2: Discover providers on 0G Compute   │
│  Stage 3: Execute inference via REST API     │
│  Stage 4: Store result on 0G Storage         │
│  Stage 5: Mint ERC-7857 iNFT on 0G Chain    │
│  Stage 6: Publish audit trail on 0G DA       │
│  Stage 7: Report result back via HCS         │
└─────────────────────────────────────────────┘
```

### 0G Service Integration Detail

**0G Compute:** On-chain provider discovery via `InferenceServing` contract at `0xa79F4c8311FF93C06b8CfB403690cc987c93F91E`. Calls `getAllServices(offset, limit)` with pagination (max 50 per page). ABI decodes 11-field Service struct per provider. Routes inference via OpenAI-compatible REST at `/v1/proxy/chat/completions`. Results cached 5 minutes. Live testing discovered 4 active providers running models from 7B to 27B parameters.

**0G Storage:** Persists inference results with SHA-256 data root anchoring via Flow contract at `0x22E03a6A89B950F1c82ec5e74F8eCa321a105296`. Every result gets a verifiable content ID anchored on-chain before upload to storage nodes.

**0G Chain (Galileo):** Mints ERC-7857 iNFTs containing AES-256-GCM encrypted inference metadata (model config, memory, knowledge base, strategy weights). Only the owner can decrypt via TEE oracle on transfer. Token metadata includes result hash, storage reference, and agent address.

**0G Data Availability:** Publishes immutable audit events to a dedicated DA namespace via DA Entrance at `0xE75A073dA5bb7b0eC622170Fd268f35E675a957B`. Each event contains agent ID, task ID, job ID, storage content ID, iNFT token ID, and timestamp.

### Implementation Plan (8 weeks)

- **W1-2:** Deploy AgentINFT to mainnet, complete session auth with providers, execute first end-to-end inference pipeline
- **W3-4:** Multi-provider load balancing, parallel on-chain operations (storage + iNFT + DA concurrent), throughput optimization
- **W5-6:** Open-source framework extraction — reusable Go SDK for 0G Compute discovery, Storage anchoring, iNFT minting, DA submission
- **W7-8:** Documentation, integration guide, example projects, community outreach

---

## 3) How We'll Integrate with 0G Infrastructure

| 0G Service | Current Integration | Grant Enables |
|------------|-------------------|---------------|
| **Compute** | Provider discovery + endpoint probing working on Galileo | Session auth + live inference + multi-provider routing |
| **Storage** | Flow contract integration with SHA-256 anchoring | Mainnet deployment + redundancy |
| **Chain** | AgentINFT.sol (ERC-7857) with encrypted metadata — 9 passing tests | Mainnet contract deployment + iNFT marketplace |
| **DA** | DA Entrance integration with audit event serialization | Mainnet deployment + batch submission optimization |

**We are one of the few projects using all 4 0G services in a single pipeline.** Most applicants use 1-2.

### On-Chain Evidence (Galileo Testnet)

All transactions verified on [chainscan.0g.ai](https://chainscan.0g.ai). Wallet: `0x38CB2E2eeb45E6F70D267053DcE3815869a8C44d`

| Operation | Transaction | Contract |
|-----------|-------------|----------|
| AgentSettlement deploy | [`0x5a028b3f...`](https://chainscan.0g.ai/tx/0x5a028b3fafd2179c3a453dd3f12b0cead16d86e3810e76b4776478dc06350c58) | `0x437c2bf7a00da07983bc1ecaa872d9e2b27a3d40` |
| ReputationDecay deploy | [`0x30f03a17...`](https://chainscan.0g.ai/tx/0x30f03a1777ab8bb0c106260891ec69eb0c0226eaf9243b0456552825698ed89b) | `0xbdcdbfd93c4341dfe3408900a830cbb0560a62c4` |
| AgentINFT (ERC-7857) deploy | [`0x929d4a74...`](https://chainscan.0g.ai/tx/0x929d4a74fd6a25ed34e1762181ba842edfa20f76b476a6adc1290db5175a88f4) | `0x17f41075454cf268d0672dd24efbea29ef2dc05b` |
| 0G Compute (InferenceServing) | — (system contract) | `0xa79F4c8311FF93C06b8CfB403690cc987c93F91E` |
| 0G Storage (Flow) | — (system contract) | `0x22E03a6A89B950F1c82ec5e74F8eCa321a105296` |
| 0G DA (DA Entrance) | — (system contract) | `0xE75A073dA5bb7b0eC622170Fd268f35E675a957B` |

Additionally, the same system is live across 3 other chains:
- **Base Sepolia:** 4 contracts deployed + ERC-8004 identity registration ([`0x9b31bd78...`](https://sepolia.basescan.org/tx/0x9b31bd785dd7b12649d9d12379546c268aea1da6e0060777bed6276cf8e4002a))
- **Hedera Testnet:** 70+ transactions — HCS messaging, token transfers, scheduled payments ([mirror node](https://testnet.mirrornode.hedera.com/api/v1/transactions?account.id=0.0.7974114&limit=25&order=desc))
- **Ethereum Sepolia:** CRE risk router with DON consensus ([tx1](https://sepolia.etherscan.io/tx/0xea6784a79fd108cfb4fc07127ab19b2c9f2a90867fcccc47b339e685fe3169c4), [tx2](https://sepolia.etherscan.io/tx/0x0c72922fd8e31f859dc5ce30364d87e86c939f7c2a2282899db11b65242dabd1))

### Developer Tooling

The `hiero-plugin` ships two 0G templates that scaffold new projects for other 0G builders:
- `0g-agent` — Go agent with 0G Compute inference, session auth, and DA integration
- `0g-inft-build` — ERC-7857 iNFT minting with AES-256-GCM encrypted metadata on 0G Chain

---

## 4) Team Background and Experience

- Full-stack engineer with production experience in Go, Solidity, TypeScript, and distributed systems
- Built the entire multi-chain agent system spanning 4 blockchains (Hedera, 0G, Base, Ethereum) as a solo builder
- Deep integration with Chainlink CRE (Runtime Environment) — live on-chain risk decisions on Ethereum Sepolia with DON consensus
- Hedera native services (HCS, HTS, HIP-1215) for inter-agent messaging and payment settlement
- Base Sepolia DeFi integration (Uniswap V3, ERC-8004, x402, ERC-8021)
- Created developer tooling (hiero-plugin) with 5 ecosystem templates and 38 passing tests
- All code follows production patterns: context propagation, proper error handling, table-driven tests, dependency injection

---

## 5) Funding Requirements and Milestones

**Requested grant:** $40K (plus gas credits if available)

**Use of funds:**
- 60% Engineering (mainnet deployment, session auth, multi-provider routing, SDK extraction)
- 20% Infrastructure (RPC endpoints, GPU provider sessions, storage nodes)
- 10% Security & QA (contract audit, integration testing, monitoring)
- 10% Documentation & community (guides, examples, outreach)

**Milestones:**

| Milestone | Week | Deliverable | Verification |
|-----------|------|-------------|--------------|
| M1 | 2 | Full pipeline on Galileo with tx evidence | 4+ chainscan transaction links |
| M2 | 4 | Multi-provider routing + parallel ops | Throughput benchmarks, provider selection logs |
| M3 | 6 | Open-source Go SDK for 0G services | Public GitHub repo, README, examples |
| M4 | 8 | Documentation + integration guide | Published docs, 1 community tutorial |

---

## Links

- **GitHub:** [github.com/lancekrogers](https://github.com/lancekrogers)
- **0G Contracts (Galileo):**
  - InferenceServing: `0xa79F4c8311FF93C06b8CfB403690cc987c93F91E`
  - Flow Contract: `0x22E03a6A89B950F1c82ec5e74F8eCa321a105296`
  - DA Entrance: `0xE75A073dA5bb7b0eC622170Fd268f35E675a957B`
- **Related evidence (other chains):**
  - CRE Risk Router on Sepolia: [tx 1](https://sepolia.etherscan.io/tx/0xea6784a79fd108cfb4fc07127ab19b2c9f2a90867fcccc47b339e685fe3169c4), [tx 2](https://sepolia.etherscan.io/tx/0x0c72922fd8e31f859dc5ce30364d87e86c939f7c2a2282899db11b65242dabd1)
