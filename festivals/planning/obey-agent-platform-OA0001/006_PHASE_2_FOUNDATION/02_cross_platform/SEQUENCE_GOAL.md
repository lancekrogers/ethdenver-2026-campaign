---
fest_type: sequence
fest_id: 02_cross_platform
fest_name: cross_platform
fest_parent: 006_PHASE_2_FOUNDATION
fest_order: 2
fest_status: pending
fest_created: 2026-03-13T02:20:39.966858-06:00
fest_tracking: true
---

# Sequence Goal: 02_cross_platform

**Sequence:** 02_cross_platform | **Phase:** 006_PHASE_2_FOUNDATION | **Status:** Pending | **Created:** 2026-03-13T02:20:39-06:00

## Sequence Objective

**Primary Goal:** Enable cross-platform prediction market operations: LLM-assisted event matching between Drift BET and Polymarket, an arbitrage strategy that exploits price discrepancies, and a Wormhole bridge manager for Solana-Polygon USDC transfers.

**Contribution to Phase Goal:** Cross-platform arbitrage is a key structural edge that individual traders cannot replicate. Matching the same real-world event across platforms and trading price differences (net of fees and bridge costs) generates low-risk alpha. The bridge manager handles the cross-chain fund movement that makes this possible.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Event matcher**: LLM-assisted matching that detects the same event on Drift BET and Polymarket, scores match confidence, and verifies resolution rule compatibility
- [ ] **Arbitrage strategy**: ArbitrageScanner strategy implementing the Strategy interface — detects price discrepancies, calculates net edge after platform fees and bridge costs, generates paired buy/sell signals
- [ ] **Bridge manager**: Solana-Polygon Wormhole bridge client for USDC transfers — batch bridging ($5K chunks), working capital management, status tracking, and in-transit NAV accounting

### Quality Standards

- [ ] **Edge calculation**: Net edge accounts for platform fees on both sides + bridge cost + slippage estimate; only signals with >3% net edge pass
- [ ] **Bridge tracking**: All in-transit funds tracked with status and included in NAV calculation

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_event_matcher.md | LLM-assisted cross-platform event matching with confidence scoring | Identifies arbitrage opportunities |
| 02_arbitrage_strategy.md | ArbitrageScanner: detect discrepancies, calculate net edge, execute | Generates low-risk trading signals |
| 03_bridge_manager.md | Wormhole bridge for Solana-Polygon USDC transfers | Enables cross-chain fund movement |
| 04_testing.md | Quality gate: run full test suite | Validates matching, strategy, and bridge |
| 05_review.md | Quality gate: code review | Validates edge calculation and bridge safety |
| 06_iterate.md | Quality gate: address review feedback | Resolves issues |
| 07_fest_commit.md | Quality gate: commit completed work | Finalizes deliverables |

## Dependencies

### Prerequisites (from other sequences)

- 01_polymarket_adapter: Polymarket MarketAdapter for market data and trading
- 001_DRIFT_BET_AGENT/01_drift_client: Drift BET MarketAdapter for market data and trading

### Provides (to other sequences)

- ArbitrageScanner strategy: Integrated into agent strategy roster
- Bridge manager: Used by 03_full_vault (vault tracks cross-chain assets)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Event matching produces false positives (different events matched) | Med | High | Require resolution rule compatibility check; minimum 0.9 confidence threshold |
| Bridge delays cause stale arbitrage (prices converge before funds arrive) | Med | Med | Hold working capital on Polygon; only bridge in large batches |
| Wormhole bridge downtime | Low | High | Track bridge status; pause cross-chain strategy during outages |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Event matcher identifies equivalent markets across platforms
- [ ] **Milestone 2**: Arbitrage strategy generates signals with accurate net edge
- [ ] **Milestone 3**: Bridge manager successfully transfers USDC between Solana and Polygon

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete
- [ ] Performance benchmarks met

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed
- [ ] Standards compliance verified

### Iteration Decision

- [ ] Need another iteration? No
- [ ] If yes, new tasks created: N/A
