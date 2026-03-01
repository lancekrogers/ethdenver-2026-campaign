# Chainlink Convergence Design Pack (Claude)

## Purpose

This design pack supplements and refines the Codex design (`../codex/`) with concrete CRE workflow architecture, critical corrections, and a sharpened submission strategy for the Chainlink Convergence Hackathon.

**Deadline:** March 8, 2026, 11:59 PM ET

## Key Corrections from Codex Design

The Codex design is conceptually strong but has several gaps that must be addressed:

1. **CRE is not a CLI wrapper** - The Codex design treats CRE as a command you shell out to (`cre simulate ...`). In reality, CRE workflows are standalone Go programs with `InitWorkflow()`, proper triggers, capabilities, and targets. We need to build an actual CRE workflow, not wrap a CLI call.

2. **On-chain write must be on a CRE-supported EVM testnet** - The Codex design puts `ChainlinkWorkflowReceipt.sol` on Hedera EVM. But the hackathon requires on-chain writes on CRE-supported testnets. We need to deploy on a standard EVM testnet (Sepolia, Base Sepolia, Arbitrum Sepolia, etc.) that CRE supports.

3. **The workflow IS the submission** - The CRE workflow itself is the deliverable. It must be simulatable from a clean clone with `cre workflow simulate`. The surrounding agent economy is context and demo material, but the CRE workflow is what judges evaluate.

4. **Missing `cre workflow simulate --broadcast`** - Simulation with `--broadcast` flag is what produces the actual on-chain tx hash. This must be explicitly planned.

## Document Map

| File | Purpose |
|------|---------|
| `01-architecture.md` | CRE workflow architecture and integration design |
| `02-cre-workflow-spec.md` | Concrete CRE workflow specification in Go |
| `03-on-chain-contracts.md` | Smart contract design for CRE-supported testnet |
| `04-integration-bridge.md` | How CRE workflow connects to existing agent economy |
| `05-submission-strategy.md` | Narrative, evidence, and submission packaging |

## Submission Theme

**Project:** `CRE Risk Router for Autonomous Agent Economy`

**Primary hashtag:** `#cre-ai`

**Pitch:** An AI-powered CRE workflow that acts as a risk decision layer for autonomous DeFi agents. The workflow ingests market data and AI inference signals via HTTP, evaluates risk through on-chain price feeds, and writes approved/denied trade decisions on-chain as immutable receipts. Autonomous agents in the Obey Agent Economy consume these decisions before executing trades.
