---
fest_type: sequence
fest_id: 01_drift_client
fest_name: drift_client
fest_parent: 001_DRIFT_BET_AGENT
fest_order: 1
fest_status: pending
fest_created: 2026-03-13T02:20:31.072306-06:00
fest_tracking: true
---

# Sequence Goal: 01_drift_client

**Sequence:** 01_drift_client | **Phase:** 001_DRIFT_BET_AGENT | **Status:** Pending | **Created:** 2026-03-13T02:20:31-06:00

## Sequence Objective

**Primary Goal:** Implement a Go HTTP client for the Drift BET API that satisfies the MarketAdapter interface, enabling the agent to discover markets, place orders, track positions, and settle resolved markets on Solana.

**Contribution to Phase Goal:** The Drift client is the agent's connection to the prediction market. Without it, the agent cannot discover markets, execute trades, or track positions. Every other sequence in this phase depends on a working Drift client.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Drift API research document**: Complete mapping of Drift BET API endpoints, authentication method, market data format, order request/response format, position queries, and settlement flow
- [ ] **DriftBETAdapter Go package**: HTTP client implementing MarketAdapter interface (ListMarkets, GetMarket, GetOrderBook, PlaceOrder, CancelOrder, GetPositions, RedeemPosition, GetPositionValue)
- [ ] **Test suite**: Unit tests with mock HTTP responses covering all adapter methods, plus integration test runnable against Drift devnet

### Quality Standards

- [ ] **Context propagation**: All HTTP calls accept and respect context.Context for cancellation
- [ ] **Error handling**: All errors wrapped with operation context (e.g., "drift: list markets: %w")

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_drift_api_research.md | Research Drift BET API endpoints, auth, data formats | Provides specification for client implementation |
| 02_drift_http_client.md | Implement Go HTTP client for Drift BET MarketAdapter | Core deliverable: working adapter for all market operations |
| 03_drift_client_tests.md | Unit tests with mocks + devnet integration test | Validates correctness of all adapter methods |
| 04_testing.md | Quality gate: run full test suite | Ensures all tests pass before review |
| 05_review.md | Quality gate: code review | Validates code quality and design |
| 06_iterate.md | Quality gate: address review feedback | Resolves any issues found in review |
| 07_fest_commit.md | Quality gate: commit completed work | Finalizes sequence deliverables |

## Dependencies

### Prerequisites (from other sequences)

- None (this is the first sequence in the first phase)

### Provides (to other sequences)

- DriftBETAdapter package: Used by 02_analysis_pipeline (market data normalization) and 03_agent_loop (trade execution, position tracking)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Drift BET API documentation is incomplete or inaccurate | Med | High | Test against devnet early; inspect SDK source code (TypeScript/Python) for undocumented behavior |
| Drift BET market liquidity too low for meaningful testing | Low | Med | Focus on highest-volume markets; use devnet for integration tests |
| Go HTTP client needs Solana transaction signing for orders | Med | Med | Use existing Solana Go SDK for signing; wrap in adapter |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: API research complete with documented endpoint mapping
- [ ] **Milestone 2**: HTTP client compiles and handles ListMarkets + GetMarket
- [ ] **Milestone 3**: Full MarketAdapter implementation with passing test suite

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
