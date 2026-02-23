---
fest_type: festival
fest_id: BC0001
fest_name: bounty-completion
fest_status: active
fest_created: 2026-02-21T16:42:29.553073-07:00
fest_updated: 2026-02-23T13:15:31.71425-07:00
fest_tracking: true
---


# Bounty Completion

**Status:** Planned | **Created:** 2026-02-21T16:42:29-07:00

## Festival Objective

**Primary Goal:** Close remaining implementation gaps across the ETHDenver multi-agent economy project so every targeted bounty track has qualifying on-chain evidence of functionality.

**Vision:** The 3 Go agents (coordinator, DeFi, inference), Solidity contracts, and Hiero CLI plugin form a working agent economy. Bugs in the DeFi agent are fixed, the missing ERC-7857 iNFT contract is implemented, 0G session auth is wired, HIP-1215 scheduling is added to contracts, and all documentation is accurate. The project is ready for bounty judge evaluation across all targeted tracks.

## Success Criteria

### Functional Success

- [ ] Base DeFi agent's mean-reversion strategy uses real moving averages (not hardcoded `price * 0.98`)
- [ ] x402 payment is wired into the trading cycle (not dead code)
- [ ] ERC-7857 iNFT contract implemented, compiling, and passing Forge tests
- [ ] 0G inference broker constructs signed Bearer tokens for session auth
- [ ] 0G inference agent constructs signed Bearer tokens for session auth
- [ ] AgentSettlement.sol and ReputationDecay.sol have HIP-1215 scheduling functions
- [ ] Docker healthchecks report all 4 services as healthy
- [ ] All project READMEs have accurate, copy-paste-ready instructions

### Quality Success

- [ ] All Go agents pass `just test` with no failures
- [ ] `forge test` passes for all contracts including new tests
- [ ] Hiero plugin passes `npm test` with 0 failures

## Progress Tracking

### Phase Completion

- [ ] 001_IMPLEMENT: Fix bugs, implement missing contracts, wire auth, polish system
- [ ] 002_REVIEW: Verify bounty qualification

## Complete When

- [ ] All phases completed
- [ ] Every targeted bounty track meets its qualifying criteria