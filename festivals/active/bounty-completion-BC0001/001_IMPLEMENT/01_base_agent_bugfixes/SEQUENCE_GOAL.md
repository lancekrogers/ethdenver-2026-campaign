---
fest_type: sequence
fest_id: 01_base_agent_bugfixes
fest_name: base agent bugfixes
fest_parent: 001_IMPLEMENT
fest_order: 1
fest_status: pending
fest_created: 2026-02-21T17:48:25.975071-07:00
fest_tracking: true
---

# Sequence Goal: 01_base_agent_bugfixes

**Sequence:** 01_base_agent_bugfixes | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-21T17:48:25-07:00

## Sequence Objective

**Primary Goal:** Fix five bugs in the Base DeFi agent that prevent it from demonstrating self-sustaining autonomous trading on Base Sepolia — the core requirement for the Base bounty track.

**Contribution to Phase Goal:** The Base agent already sends real signed transactions, but its trading strategy is broken (always sells), x402 payments are implemented but never called, ERC-8021 attribution has an encoding bug, P&L numbers are fictional, and ERC-8004 identity reads are stubbed. Fixing these makes the agent demonstrably self-sustaining with accurate on-chain evidence.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Working mean reversion strategy**: `GetMarketState` returns a real windowed moving average instead of `price * 0.98`, and the strategy correctly triggers both buy and sell signals
- [ ] **x402 payment integration**: The trading loop calls `a.payment.Pay()` or `a.payment.HandlePaymentRequired()` for data/compute costs before executing trades
- [ ] **Accurate P&L tracking**: Gas costs read from actual transaction receipts, revenue calculated from actual trade output vs input
- [ ] **ERC-8004 identity decoding**: `GetIdentity` ABI-decodes the on-chain response instead of returning a hardcoded stub

### Quality Standards

- [ ] **Tests pass**: `cd projects/agent-defi && just test` passes with no failures
- [ ] **Strategy correctness**: Unit test proves buy signals fire when price < MA and sell signals fire when price > MA

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_fix_strategy_moving_average | Replace hardcoded moving average with real windowed TWAP | Strategy produces correct buy/sell signals |
| 02_wire_x402_into_trading_loop | Call x402 payment protocol during trade execution | Agent pays for data/compute, demonstrating x402 usage |
| 03_fix_pnl_accuracy | Use real gas costs and trade deltas for P&L | Dashboard and HCS show real self-sustainability metrics |
| 04_fix_getidentity_decode | ABI-decode the on-chain identity response | ERC-8004 identity reads reflect actual on-chain state |

## Dependencies

### Prerequisites (from other sequences)

- None — this sequence has no dependencies on other sequences

### Provides (to other sequences)

- Working Base agent with accurate P&L: Used by 06_doc_accuracy (README must reflect real behavior)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Uniswap V3 pool has no liquidity on Base Sepolia | Medium | High | Verify pool exists before testing; use a known active pair |
| Moving average window needs historical data that doesn't exist on first run | Low | Medium | Seed with current price and grow window over time |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Mean reversion strategy produces correct signals in unit tests
- [ ] **Milestone 2**: ERC-8021 and x402 are working in the trading loop
- [ ] **Milestone 3**: P&L report shows real numbers from actual trade execution

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete
- [ ] Strategy unit test confirms correct buy/sell signal logic

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed
- [ ] Standards compliance verified

### Iteration Decision

- [ ] Need another iteration? No
- [ ] If yes, new tasks created: N/A
