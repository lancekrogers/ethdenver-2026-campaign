# Festival Overview: Chain Agents

## Problem Statement

**Current State:** The hedera-foundation festival delivers the coordinator agent with HCS messaging and HTS payment infrastructure, but the system has no specialized workers to assign tasks to. Without an inference agent and a DeFi agent, the coordinator has nothing to orchestrate and the autonomous economy cannot function.

**Desired State:** Two specialized agents -- an inference agent running on 0G for decentralized GPU compute and a DeFi agent operating on Base for autonomous trading -- complete the three-agent autonomous economy. The coordinator assigns tasks, the inference agent executes AI workloads and mints provenance artifacts, and the DeFi agent generates revenue that exceeds its costs, all communicating through HCS.

**Why This Matters:** This festival delivers the core value proposition of the hackathon submission: a self-sustaining multi-agent economy where AI agents coordinate, compute, and trade across multiple chains. It targets three separate bounty tracks (0G Track 2 at $7k, 0G Track 3 at $7k, Base at $3k+) and demonstrates the full system working end-to-end.

## Scope

### In Scope

- agent-inference (Go): 0G Compute broker integration for decentralized GPU inference
- agent-inference (Go): 0G Storage for agent memory and result persistence
- agent-inference (Go): ERC-7857 iNFT minting with encrypted metadata on 0G Chain
- agent-inference (Go): 0G DA integration for inference audit trail
- agent-inference (Go): HCS message handling for receiving tasks and reporting results
- agent-defi (Go): ERC-8004 identity registration on Base
- agent-defi (Go): x402 payment protocol implementation for machine-to-machine payments
- agent-defi (Go): ERC-8021 builder attribution codes
- agent-defi (Go): Autonomous trading strategy execution on Base
- agent-defi (Go): HCS message handling for receiving tasks and reporting P&L
- Integration testing across all three agents (coordinator, inference, DeFi)

<!-- Add more items as needed -->

### Out of Scope

- Coordinator agent logic (handled by hedera-foundation festival)
- HCS topic creation and HTS token infrastructure (handled by hedera-foundation festival)
- Obey daemon internals
- Frontend or UI for monitoring agents
- Production deployment infrastructure
- Advanced trading strategies beyond MVP demonstration

<!-- Add more items as needed -->

## Planned Phases

### 001_IMPLEMENT

Build both agents in parallel sequence groups and verify cross-agent integration. The inference sequence group covers 0G Compute, Storage, iNFT minting, DA integration, and HCS communication. The DeFi sequence group covers ERC-8004 identity, x402 payments, ERC-8021 attribution, trading execution, and HCS communication. Once both are complete, an integration verification sequence confirms the full three-agent cycle works end-to-end.

<!-- Add more phases as they're planned -->

## Notes

- Hard dependency on hedera-foundation festival (HF0001) completing first -- HCS messaging and HTS payments must be operational before this festival can begin integration testing.
- Both agents are Go projects that consume the shared daemon client package from the coordinator.
- The inference and DeFi sequence groups can be developed in parallel since they are independent until integration verification.
- 0G SDK and Base SDK compatibility should be validated early in the implementation phase.
- The DeFi agent must demonstrate net-positive economics (revenue > costs) to qualify for the Base self-sustaining agent bounty.
