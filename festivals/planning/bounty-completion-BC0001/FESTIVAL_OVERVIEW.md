# Festival Overview: Bounty Completion

## Problem Statement

**Current State:** The ETHDenver 2026 multi-agent economy project has 3 Go agents (coordinator on Hedera, inference on 0G, DeFi on Base), a dashboard, Solidity contracts directory, and a Hiero CLI plugin — but key integration points remain as stubs. The Base DeFi agent does not send real transactions, the coordinator's schedule service package exists but is not wired into main.go, the contracts directory has no implemented Solidity files, and the Hiero plugin lacks 0G agent templates. These gaps prevent the project from meeting the qualifying criteria for the bounty tracks it is targeting.

**Desired State:** Every targeted bounty track has a working, demonstrable implementation. Real transactions flow on Base Sepolia, the Hedera coordinator activates its 4th native service, smart contracts compile and pass Forge tests, plugin templates cover 0G and iNFT use cases, and all Docker images build cleanly.

**Why This Matters:** ETHDenver bounty judges evaluate on-chain evidence of functionality. Stub code and placeholder comments do not qualify. Completing these remaining gaps is the difference between a promising prototype and a submittable project that can win across 7 tracks.

## Scope

### In Scope

- Wiring the existing schedule service package into coordinator main.go
- Adding go-ethereum to agent-defi and replacing stub tx signing with real Base Sepolia transactions in executor.go, register.go, and x402.go
- Fetching live Uniswap V3 market data on-chain from agent-defi
- Writing AgentSettlement.sol and ReputationDecay.sol from scratch with Forge tests and a deploy script
- Verifying all Go agents pass `just test`
- Verifying all 6 project READMEs are accurate and complete

### Out of Scope

- New agent features or behavior beyond what is needed to qualify bounties
- Mainnet deployments (testnet only)
- UI/dashboard changes
- Changes to the inference agent (0G) beyond what is already complete
- New bounty tracks not already targeted

## Planned Phases

### 001_IMPLEMENT

Complete all remaining implementation work across 7 sequences: coordinator schedule wiring, Base tx signing, and Solidity contracts implementation. This phase delivers all the on-chain functionality needed to qualify every targeted bounty track.

### 002_REVIEW

Run the full bounty qualification checklist against every targeted track. Verify builds, tests, contracts, READMEs, and on-chain transaction evidence. Identify and fix any remaining gaps before submission.

## Notes

The three Go agents already have their core architecture in place — this festival is focused narrowly on closing the final 20% of implementation gaps. Sequences are designed to be independent so they can be worked in parallel. The contracts work starts from scratch but the scope is intentionally small (two contracts, Forge tests, one deploy script).
