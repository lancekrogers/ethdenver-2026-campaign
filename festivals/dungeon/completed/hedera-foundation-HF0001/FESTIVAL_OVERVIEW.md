# Festival Overview: Hedera Foundation

## Problem Statement

**Current State:** The agent-coordinator project has no Hedera integration layer. Agents cannot communicate via HCS, transfer tokens via HTS, or maintain liveness via the Schedule Service. There is no coordinator logic to orchestrate task assignment, monitoring, or payment settlement through native Hedera services.

**Desired State:** A complete Hedera foundation layer in Go that allows agents to publish plans, assign tasks, monitor progress, and settle payments using HCS, HTS, and the Schedule Service -- with zero Solidity. The coordinator drives a full cycle from plan creation through task assignment, result collection, and token-based payment.

**Why This Matters:** This is the core submission for Hedera Track 3 ($5k, 3 winners) at ETHDenver 2026. It proves that autonomous agent coordination can run entirely on native Hedera services, differentiating from EVM-based approaches and demonstrating Hedera's unique capabilities for agent-to-agent workflows.

## Scope

### In Scope

- HCS topic creation, message publishing, and subscription
- HTS token creation and transfer between agent accounts
- Schedule Service heartbeat on a configurable interval
- Coordinator logic: task assignment, progress monitoring, quality gates, payment flow
- Shared daemon client package (consumer of the obey daemon API)
- Full demonstration cycle: festival plan -> HCS task assignment -> result collection -> HTS payment
- Integration with Hedera testnet for development and demo

<!-- Add more items as needed -->

### Out of Scope

- Building or modifying the obey daemon itself (external dependency, consumed only)
- Any Solidity or EVM smart contracts
- Frontend or UI components
- Hedera mainnet deployment
- Multi-tenancy or production-grade access control

<!-- Add more items as needed -->

## Planned Phases

### 001_IMPLEMENT

Build the full Hedera integration layer and coordinator logic. This phase covers HCS topic and message operations, HTS token creation and transfers, Schedule Service heartbeat, the coordinator orchestration engine (task assignment, monitoring, quality gates, payment), and the shared daemon client package. All code is Go, all Hedera interaction uses native services.

<!-- Add more phases as they're planned -->

## Notes

- The obey daemon must be available as an external dependency before implementation begins. Agents are consumers of the daemon API, not builders.
- All Hedera operations target testnet during development. Mainnet is not in scope for the hackathon.
- The project targets Hedera Track 3 at ETHDenver 2026. Judging criteria likely favor clean native-service usage over EVM bridging.
- Architecture decisions should favor simplicity and demonstrability given the hackathon context.
