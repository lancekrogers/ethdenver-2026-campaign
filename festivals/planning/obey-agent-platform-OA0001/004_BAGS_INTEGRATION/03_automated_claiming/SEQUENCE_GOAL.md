---
fest_type: sequence
fest_id: 03_automated_claiming
fest_name: automated_claiming
fest_parent: 004_BAGS_INTEGRATION
fest_order: 3
fest_status: pending
fest_created: 2026-03-13T02:20:39.86488-06:00
fest_tracking: true
---

# Sequence Goal: 03_automated_claiming

**Sequence:** 03_automated_claiming | **Phase:** 004_BAGS_INTEGRATION | **Status:** Pending | **Created:** 2026-03-13T02:20:39-06:00

## Sequence Objective

**Primary Goal:** Build a periodic service that automatically claims accumulated OBEY token fees every 6 hours and reports token metrics (volume, fees, holders) via HCS for dashboard display and coordination visibility.

**Contribution to Phase Goal:** Without automated claiming, fees accumulate uncollected on Bags. This service ensures revenue flows to the platform treasury on a regular cadence and provides metrics for monitoring token health and hackathon traction reporting.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Claim loop service**: Runs every 6 hours, checks for claimable positions, generates and submits claim transactions, distributes to treasury wallet, logs success/failure
- [ ] **Metrics reporter**: Tracks OBEY token volume, cumulative fee revenue, holder count, and pool depth — reports via HCS messages for dashboard consumption

### Quality Standards

- [ ] **Reliability**: Service handles transient Bags API and Solana RPC failures with retry logic
- [ ] **Observability**: Each claim cycle logs: claimable amount, claim tx hash, success/failure, cumulative totals

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_claim_loop.md | Periodic fee claiming service every 6 hours | Automates revenue collection |
| 02_metrics_reporting.md | Track volume, fees, holders — report via HCS | Provides token health visibility |
| 03_testing.md | Quality gate: run full test suite | Validates claiming and reporting |
| 04_review.md | Quality gate: code review | Validates service reliability |
| 05_iterate.md | Quality gate: address review feedback | Resolves issues |
| 06_fest_commit.md | Quality gate: commit completed work | Finalizes deliverables |

## Dependencies

### Prerequisites (from other sequences)

- 01_bags_client: Fee claiming client for Bags API operations
- 02_token_launch: Live OBEY token with mint address for claiming

### Provides (to other sequences)

- Fee revenue metrics: Used by 003_LANDING_PAGE (dashboard can display token revenue)
- HCS metrics messages: Consumed by coordinator for platform-wide reporting

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Claim transactions fail silently | Low | Med | Verify on-chain balance after each claim; alert on discrepancy |
| Service crashes between claim cycles | Low | Low | Run as supervised process; missed claims accumulate and are caught next cycle |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Claim loop executes first successful fee claim
- [ ] **Milestone 2**: Metrics reporter publishes token data via HCS
- [ ] **Milestone 3**: Service runs for 48 hours with successful claims

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
