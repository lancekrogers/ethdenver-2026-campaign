# ETHDenver 2026 Bounties & Criteria

> Compiled from Devfolio bounty pages and bounty reveal transcript. Transcript names corrected where audio was garbled.

## Quick Reference

| Sponsor | Total Pool | Tracks | Top Single Prize |
|---------|-----------|--------|-----------------|
| [Hedera](#hedera) | **$25,000** | 4 | $10,000 |
| [0G Labs](#0g-labs) | **$25,000** | 4 | $7,000 |
| [Base (Kite/Bass)](#base-kitebass) | **$25,000** | 1 | $3,000 |
| [ADI Chain](#adi-chain) | **$25,000** | 2 | $3,000 |
| [Canton Network](#canton-network) | **$15,000** | 2 | $5,000 |
| [Quicknote](#quicknote) | **$2,000** | 2 | $1,000 |
| **Total Sponsor Prizes** | **$117,000** | | |

## Submission Requirements (All Sponsors)

Unless stated otherwise, every submission requires:

- Public GitHub repository
- Live demo URL (or runnable CLI/Docker environment)
- Video walkthrough under 3 minutes
- Comprehensive README with setup instructions

---

## Hedera

**Total: $25,000 across 4 tracks**

> Transcript listed as "Hideira". Hedera DevDay: Feb 17, 2026 (day before on-site hackathon).

### Track 1: Killer App for the Agentic Society — $10,000

**Winners:** 1

**What they want:** An agent-native application built for a society of OpenClaw agents where commerce, coordination, or value exchange happens autonomously. The app must prioritize agents as primary users, not humans using agents as tools.

**Requirements:**

- Build on OpenClaw runtime (Node.js agent framework, 60k+ GitHub stars)
- Demonstrate autonomous or semi-autonomous agent behavior
- Create clear value in multi-agent environments
- Use Hedera EVM, Token Service (HTS), or Consensus Service (HCS)
- UI designed for humans *observing* agents — the product is not human-operated
- Interface must show agent flow steps and states

**Bonus:** Use UCP (Universal Commerce Protocol) to standardize agent-to-agent commerce.

**Key tech:**

- OpenClaw: local agent runtime bridging LLMs to 50+ integrations
- Hedera Agent Kit JS (`npm install hedera-agent-kit`) — LangChain, Vercel AI, ElizaOS, MCP Server integrations
- UCP: Google's open standard for agentic commerce (REST/JSON-RPC, A2A, MCP support)

### Track 2: On-Chain Automation — $5,000

**Winners:** 2 ($3,000 + $2,000)

**What they want:** Applications that use Hedera's protocol-level smart contract automation (HIP-1215). Smart contracts scheduling their own future executions — on-chain cron jobs with no off-chain keepers.

**Requirements:**

- Working testnet app creating and executing scheduled transactions
- Scheduling must initiate FROM smart contracts (not external triggers)
- Focus on DeFi automation or business finance flows
- Include edge case handling and observability

**Key tech:**

- HIP-1215: Generalized Scheduled Contract Calls — contracts schedule any contract call via Hedera Schedule Service
- HIP-755: Schedule Service System Contract — EVM access to native scheduling
- `hasScheduleCapacity(uint256 expiry, uint256 gasLimit)` view function for finding available execution windows
- Use cases: DeFi liquidations, token vesting, vault health monitoring, DAO treasury actions

### Track 3: "No Solidity Allowed" — $5,000

**Winners:** 3 ($2,500 / $1,500 / $1,000)

**What they want:** Applications built entirely with Hedera's native SDKs — zero Solidity, zero EVM contracts.

**Requirements:**

- Must use at least TWO native Hedera capabilities (e.g., HTS + HCS)
- Zero Solidity or EVM contracts allowed
- Working testnet app
- Clear security model with proper key handling

**Available SDKs:** JavaScript/TypeScript (`@hashgraph/sdk`), Java, Go, Python (`hedera-sdk-py`), Rust, C

**Native services (no Solidity needed):**

- Hedera Token Service (HTS): create/manage tokens at protocol level
- Hedera Consensus Service (HCS): timestamped, ordered message logs
- Hedera File Service: decentralized file storage
- Hedera Schedule Service: transaction scheduling
- Account management: native account creation, key rotation, multi-sig

### Track 4: Best Hiero CLI Plugin — $5,000

**Winners:** 2 ($2,500 each)

**What they want:** A plugin for the Hiero CLI (formerly Hedera CLI, now under Linux Foundation Decentralized Trust).

**Requirements:**

- Submit a PR to the [hiero-cli repo](https://github.com/hiero-ledger/hiero-cli)
- Follow existing Node.js plugin architecture (see `PLUGIN_ARCHITECTURE_GUIDE.md`)
- Must be useful beyond the hackathon
- Include PR link, demo video, usage documentation

**Judging criteria:** Developer value, code quality, architecture fit, usability, lasting impact.

---

## 0G Labs

**Total: $25,000 across 4 tracks**

> 0G is a modular AI-native L1 with four layers: Chain (EVM), Storage, Compute, and Data Availability. Aristotle Mainnet live since Sept 2025.

### Judging Criteria (All Tracks)

| Criterion | Weight |
|-----------|--------|
| **0G Utilization** | 30% — How meaningfully 0G technologies are integrated |
| **User Value** | 25% — Real problem-solving and workflow enablement |
| **Composability** | 20% — Potential for integration with other protocols/systems |
| Code quality, innovation, execution, market validation | 25% |

### Track 1: Best DeFAI Application — $7,000

**Winners:** 2 ($5,000 + $2,000)

**What they want:** A functional DeFi product (swap, lend, borrow, stake, LP, vault) where AI materially enhances the workflow — not merely a conversational chatbot.

**Requirements:**

- AI must deliver structured decisions and automation while maintaining user control
- Safety measures: confirmations, limits, explainability, simulation
- End-to-end demonstration scenario
- Risk explanations justifying AI recommendations

### Track 2: Best Use of AI Inference or Fine-Tuning — $7,000

**Winners:** 2

**What they want:** Projects that leverage 0G Compute for decentralized AI inference or fine-tuning.

**Key tech:**

- 0G Compute: decentralized GPU marketplace with broker-based provider matching
- Fine-Tuning CLI: full lifecycle — upload dataset to 0G Storage, submit training job, monitor, download model
- Provider runs in Confidential Virtual Machine (CVM) with TEE attestation
- Escrow-based payment: funds release after customer acknowledges delivery
- TypeScript SDK: `@0glabs/0g-serving-broker`

### Track 3: Best Use of On-Chain Agent (iNFT) — $7,000

**Winners:** 2

**What they want:** Projects using ERC-7857 Intelligent NFTs — AI agents tokenized as NFTs with encrypted, dynamic metadata.

**Key tech:**

- ERC-7857: 0G's custom NFT standard for AI agents
- iNFT metadata = agent's "intelligence" (model weights, memory, behavior)
- Encrypted metadata transferred via TEE oracle during sales
- Dynamic metadata updates as agents learn
- Docs: `docs.0g.ai/build-with-0g/inft`

### Track 4: Best Developer Tooling or Education — $4,000

**Winners:** 1

**What they want:** Tools that improve the 0G developer experience or educational resources.

### 0G Developer Resources

| Layer | SDK/Tool |
|-------|---------|
| **Storage** | Go: `github.com/0gfoundation/0g-storage-client` / TS: `@0glabs/0g-ts-sdk` |
| **Compute** | TS: `@0glabs/0g-serving-broker` / Starter: `0g-compute-ts-starter-kit` |
| **Fine-tuning** | CLI tool for full training lifecycle |
| **iNFT** | ERC-7857 contracts on 0G Chain |
| **Chain** | Standard EVM (Solidity) |

GitHub: [github.com/0gfoundation](https://github.com/0gfoundation) (99 repos)

**Tip:** Projects that use ALL four layers (Chain + Storage + Compute + DA) score highest on the 30% utilization criterion.

---

## Base (Kite/Bass)

**Total: $25,000 shared pool**

> Two sponsors (Kite and Bass) share this pool for self-sustaining AI agents on Base.

**Prize distribution:** 6 × $3,000 + 19 × $1,000

**What they want:** Fully autonomous AI agents that pay for their own compute on Base mainnet.

**Requirements:**

- Self-sustaining: agent earns revenue exceeding its operational costs
- Fully autonomous on Base mainnet with minimal human loop
- Public performance dashboard with clear analytics UI
- Must use all three standards:

| Standard | Actual Name | Purpose |
|----------|------------|---------|
| ERC-8004 | Trustless Agents | On-chain identity (NFT), reputation registry, validation registry |
| x402 | HTTP Payment Protocol | Agent pays for compute/APIs via HTTP 402 + USDC on Base |
| ERC-8021 | Builder Codes | On-chain transaction attribution via calldata suffix |

**Key tech:**

- Coinbase AgentKit (`coinbase-agentkit`) — framework-agnostic AI agent toolkit
- Coinbase Agentic Wallets (launched Feb 12, 2026) — autonomous wallets with spend limits
- Gasless trading on Base via Smart Account (AA) infrastructure
- ERC-8004 contracts: [github.com/erc-8004/erc-8004-contracts](https://github.com/erc-8004/erc-8004-contracts)
- x402 protocol: [github.com/coinbase/x402](https://github.com/coinbase/x402) — 1,000 free txns/month via facilitator
- Builder Codes: [github.com/base/builder-codes](https://github.com/base/builder-codes)

**What judges look for:**

1. Genuine autonomy — no human triggering actions
2. Economic sustainability — revenue demonstrably exceeds costs
3. ERC-8021 attribution on every transaction
4. ERC-8004 identity with accumulating reputation
5. x402 payment flows for compute without human wallet management
6. Public dashboard with real-time P&L, trade history, reputation, operational metrics

---

## ADI Chain

**Total: $25,000**

> EVM-equivalent L2 (ZK Sync based). Middle East ecosystem access.

**Prize distribution:** 6 × $3,000 (defined challenges) + 19 × $1,000 (creativity)

**What they want:** Any project built on ADI mainnet. Challenge themes TBD on Prizes page; creative projects also qualify.

**Requirements:**

- Build and deploy on ADI mainnet
- Standard EVM tooling works (Hardhat, Foundry, etc.)

---

## Canton Network

**Total: $15,000 across 2 tracks**

> Transcript listed as "Kanto Network". Canton is a privacy-first public blockchain for institutional finance. Uses Daml smart contract language. Backed by JPMorgan, DTCC, DRW Trading.

### Track 1: Best Privacy-Focused dApp — $8,000

**Winners:** 3 ($5,000 / $2,000 / $1,000)

**What they want:** Applications demonstrating privacy-focused functionality using Canton's selective disclosure model.

**Requirements:**

- Working dApp with Daml smart contracts
- Privacy as a core feature (selective disclosure), not an afterthought
- Clear use case showing who sees what and why

**Canton's privacy model:**

- Sub-transaction level privacy: each party sees only their relevant data
- Need-to-know basis enforced at the smart contract level
- Proof-of-Stakeholder consensus: only involved parties validate
- Selective disclosure to regulators without exposing commercial data

**Potential use cases:** Private voting, compliant token transfers, supply chain provenance, credential verification, multi-party trade settlement.

### Track 2: Dev Tooling & DevX Accelerator — $7,000

**Winners:** 8 (approximately $875 each)

**What they want:** Tools that improve Canton developer experience.

**Gaps to fill:** Testing frameworks, IDE tooling, CLI tools, debugging/transaction visualization, documentation generators, migration tools, template libraries, monitoring/observability.

**Key resources:**

- [CN Quickstart](https://github.com/digital-asset/cn-quickstart): Bootstrap a Canton app
- Daml SDK (v2.10.3)
- Go SDK with codegen, Python bindings, JS/TS frontend support
- Canton Console: built-in interactive REPL
- Docs: [docs.digitalasset.com](https://docs.digitalasset.com/) and [docs.sync.global](https://docs.sync.global/)

---

## Quicknote

**Total: $2,000 across 2 streams**

| Stream | Prize |
|--------|-------|
| Hyperlid Core | $1,000 |
| Monad Streams | $1,000 |

**What they want:** Dashboards or alerting systems using Quicknote's real-time data pipeline as the primary data source.

---

## Competition Tracks (Judged by E10)

Separate from sponsor bounties. Finalists present on-stage Feb 21. Top 2 teams per track get a celebrity judge showcase with an extra prize.

| Track | Focus |
|-------|-------|
| **Etherspace Devtopia** | NFTs, tokenomics |
| **zkDepth** | Security, ZK technology |
| **New France Village** | DeFi, institutional primitives |
| **Prosperity** | Governance, public goods, CIPs |
| **Future Llama** | Frontier AI research |

---

## Key Dates

| Date | Event |
|------|-------|
| Feb 12–17 | Online build phase (mentor booking open) |
| Feb 17 | Hedera DevDay |
| Feb 18 | Check-in 9 AM at BUIDL Hub, Denver |
| Feb 18–20 | On-site build + AI Agent Workshops |
| **Feb 21 @ 2 PM** | **Judging + AI Agent Demo Day (live on stage)** |

## Transcript Name Corrections

| Transcript Audio | Actual Name |
|-----------------|-------------|
| "Hideira" | **Hedera** |
| "Kanto Network" | **Canton Network** |
| "ERC-821" | **ERC-8021** (Builder Codes) |
| "X42" | **x402** (HTTP payment protocol) |
| "Biddathon" | **BUIDLathon** |
| "Biddub" | **BUIDL Hub** |
| "Hyro CLI" | **Hiero CLI** |
