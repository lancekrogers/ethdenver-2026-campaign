---
fest_type: phase
fest_id: 002_REVIEW
fest_name: REVIEW
fest_parent: bounty-completion-BC0001
fest_order: 2
fest_status: pending
fest_created: 2026-02-21T16:44:00.366437-07:00
fest_phase_type: review
fest_tracking: true
---

# Phase Goal: 002_REVIEW

**Phase:** 002_REVIEW | **Status:** Pending | **Type:** Review

## Review Objective

**Primary Goal:** Verify that every targeted ETHDenver bounty track meets its qualifying criteria by running the full bounty checklist against builds, tests, contracts, READMEs, and on-chain transaction evidence.

**Context:** Phase 001_IMPLEMENT completed the remaining implementation gaps — coordinator schedule wiring, real Base Sepolia transactions in agent-defi, and two Solidity contracts. This review phase validates that the implementation actually qualifies under each bounty track's judging criteria. Any gaps found here must be returned to implementation tasks before the festival can be marked complete.

## What's Being Reviewed

Items that must pass this review:

- Hedera Track 3: Coordinator uses all 4 native Hedera services (HCS, HTS, Schedule, Accounts)
- Hedera Track 4: Multi-agent economy demonstrated with real value exchange
- Base Agent bounty: agent-defi sends real signed transactions on Base Sepolia
- 0G Track 2: Inference agent integrated with 0G storage and compute
- 0G Track 3: Hiero plugin templates for 0G agent and iNFT use cases
- Contracts (Hedera Track 2): AgentSettlement.sol and ReputationDecay.sol pass Forge tests
- All 6 project READMEs: Accurate setup instructions with correct commands

## Review Criteria

Criteria each item must meet:

- [ ] `just build` passes for all three Go agents (coordinator, inference, defi)
- [ ] `just test` passes with no failures for all three Go agents
- [ ] `forge build` passes with no warnings for both contracts
- [ ] `forge test` passes with no failures for both contracts
- [ ] agent-defi executor.go sends real transactions visible on Base Sepolia testnet explorer
- [ ] agent-defi register.go sends real registration tx visible on Base Sepolia testnet explorer
- [ ] agent-defi x402.go sends real payment tx visible on Base Sepolia testnet explorer
- [ ] Coordinator logs show schedule service heartbeat running
- [ ] Coordinator uses HCS (topic messages), HTS (token transfers), Schedule (scheduled txs), and Accounts (balance queries)
- [ ] Both contracts deployed to Hedera testnet EVM with verified addresses
- [ ] All 6 READMEs include: prerequisites, environment setup, build command, run command
- [ ] Docker images for all three agents build successfully

## Stakeholder Sign-off

| Stakeholder | Role | Status | Date |
|-------------|------|--------|------|
| Lance | Festival Planner | [ ] Approved | |

## Approval Gates

Gates that must pass before review completion:

- [ ] All `just test` runs exit 0 across all Go agents
- [ ] `forge test` exits 0 with all test cases passing
- [ ] At least one real on-chain tx hash available per agent-defi signing stub (executor, register, x402)
- [ ] Coordinator schedule service heartbeat confirmed in logs or via Hedera testnet explorer
- [ ] Both contracts have verified testnet deployment addresses documented

## Go/No-Go Decision

**Decision:** [ ] GO / [ ] NO-GO

**Conditions for GO:**
- [ ] All review criteria passed
- [ ] All stakeholder sign-offs received
- [ ] All approval gates satisfied

**If NO-GO, actions required:**
- Document blockers
- Return to relevant implementation tasks
- Schedule re-review

## Notes

This review phase does not require a full re-run of all sequences. It focuses on spot-checking the qualifying criteria for each bounty track. If a gap is found, create a targeted fix task rather than re-running an entire sequence. The goal is submission readiness, not perfection — if a bounty track qualifies under its stated criteria, it passes.

---

*Review phases validate completed work. All sign-offs required before marking complete.*
