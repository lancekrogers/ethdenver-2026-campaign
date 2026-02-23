# Festival Overview: Bounty Completion

## Problem Statement

**Current State:** The ETHDenver 2026 multi-agent economy project has 3 Go agents, a React dashboard, Solidity contracts, and a Hiero CLI plugin. The core architecture works — agents communicate over HCS, the coordinator orchestrates via Hedera native services, and the inference agent discovers 0G providers on-chain. However, specific bugs and missing features block bounty qualification:

1. **DeFi agent bugs**: Mean-reversion strategy uses hardcoded `price * 0.98` instead of real moving averages. The x402 payment module is fully implemented but never called in the trading loop. ERC-8021 attribution builder stores bytes as ASCII string instead of hex-decoded bytes. GetIdentity returns hardcoded stub. P&L tracking uses stubbed gas cost.
2. **Missing ERC-7857 contract**: 0G Track 3 ($3k) requires an iNFT (ERC-7857) contract — none exists in the contracts directory.
3. **Missing 0G session auth**: The inference agent discovers providers but can't authenticate inference requests — no signed Bearer token construction exists in the broker.
4. **No HIP-1215 integration**: Contracts don't use Hedera's native scheduled transactions, missing a key differentiator for Hedera Track 1.
5. **Infrastructure gaps**: Docker compose lacks healthchecks, coordinator's HCS topic key config is incomplete.
6. **Stale documentation**: READMEs reference old env vars and missing setup steps.

**Desired State:** Every bug is fixed, every missing feature is implemented, infrastructure works end-to-end, and documentation is accurate. Bounty judges can clone the repo, follow the README, and see a working multi-agent economy.

**Why This Matters:** ETHDenver bounty judges evaluate on-chain evidence and working demos. Bugs that produce wrong outputs and missing authentication that returns 401 errors will immediately disqualify tracks. These are the final implementation gaps between a promising prototype and a submittable project.

## Scope

### In Scope

- Fixing 4 specific bugs in agent-defi (strategy, x402, identity, P&L)
- Implementing ERC-7857 iNFT Solidity contract with Forge tests
- Adding 0G Compute session auth (signed Bearer tokens) to inference agent
- Polishing hiero-plugin submission materials (docs, tests, demo script)
- Adding coordinator topic key config and Docker healthchecks
- Auditing and fixing all 6 project READMEs
- Adding HIP-1215 scheduling to existing Solidity contracts

### Out of Scope

- New agent features beyond what is needed to qualify bounties
- Mainnet deployments (testnet only)
- UI/dashboard changes
- New bounty tracks not already targeted
- Rewriting working code that already meets bounty criteria

## Planned Phases

### 001_IMPLEMENT

Complete all remaining implementation work across 7 sequences: base agent bugfixes, ERC-7857 iNFT contract, 0G compute session auth, hiero submission prep, system polish, doc accuracy, and HIP-1215 contract scheduling. This phase delivers all the code changes and documentation needed to qualify every targeted bounty track.

### 002_REVIEW

Run the full bounty qualification checklist against every targeted track. Verify builds, tests, contracts, READMEs, and on-chain transaction evidence. Identify and fix any remaining gaps before submission.

## Notes

The three Go agents already have their core architecture in place — this festival is focused on closing specific bugs and missing features, not building new systems. Sequences 01-03 are the highest priority (they unblock the most bounty tracks). Sequences 04-07 are polish and infrastructure. Sequence 06 (doc accuracy) should run last since earlier sequences change code that READMEs reference.
