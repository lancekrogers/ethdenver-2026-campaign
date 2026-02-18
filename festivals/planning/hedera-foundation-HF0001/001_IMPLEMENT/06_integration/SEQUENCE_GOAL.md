---
fest_type: sequence
fest_id: 06_integration
fest_name: integration
fest_parent: 001_IMPLEMENT
fest_order: 6
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 06_integration

**Sequence:** 06_integration | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Set up Hedera testnet accounts for all agents, run an end-to-end integration test covering the full festival cycle (plan -> HCS task assignment -> result collection -> HTS payment), and finalize the codebase for submission.

**Contribution to Phase Goal:** This is the capstone sequence. It proves that all individual packages (HCS, HTS, Schedule, Coordinator, Daemon Client) work together as a cohesive system. The E2E test is the primary demonstration artifact for the Hedera Track 3 bounty submission. The fest commit task finalizes the festival and prepares the codebase for delivery.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Testnet Accounts**: Three Hedera testnet accounts configured (coordinator + 2 agents) with HBAR funded
- [ ] **Environment Config**: `.env.example` documenting all required environment variables
- [ ] **E2E Integration Test**: Full cycle test in `internal/integration/e2e_test.go` that exercises the complete workflow
- [ ] **Festival Commit**: Final `fest commit` and `camp p commit` executed

### Quality Standards

- [ ] **Testnet Verification**: All accounts funded and operational on testnet
- [ ] **Full Cycle**: E2E test covers plan creation -> HCS assignment -> status updates -> quality gate -> HTS payment
- [ ] **Reproducibility**: Another developer can run the E2E test with the documented setup
- [ ] **Clean Codebase**: All tests pass, linting clean, no TODO items blocking submission

### Completion Criteria

- [ ] All tasks completed
- [ ] Quality gates passed
- [ ] Festival committed and pushed
- [ ] Ready for Hedera Track 3 bounty submission

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_setup_testnet.md | Set up testnet accounts and environment | Provides the infrastructure for E2E testing |
| 02_integration_test.md | Write and run the E2E test | Proves the full cycle works |
| 03_fest_commit.md | Final fest commit and push | Finalizes the festival for submission |
| 04_testing_and_verify.md | Verify E2E test passes | Quality gate |
| 05_code_review.md | Final code review | Quality gate |
| 06_review_results_iterate.md | Final iteration | Quality gate |

## Dependencies

### Prerequisites (from other sequences)

- **01_hcs_service**: HCS package complete (topic, publish, subscribe)
- **02_hts_service**: HTS package complete (token create, transfer)
- **03_schedule_service**: Schedule package complete (heartbeat)
- **04_coordinator**: Coordinator engine complete (assign, monitor, gate, pay)
- **05_daemon_client**: Daemon client package complete

### Provides (to other sequences)

- None. This is the final sequence.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Testnet instability during E2E test | Medium | High | Add retry logic, document flaky test handling |
| Account funding via faucet takes time | Low | Medium | Set up accounts early, have backup accounts |
| Integration issues between packages | Medium | High | Use mock fallbacks, test incrementally |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Testnet accounts created and funded
- [ ] **Milestone 2**: E2E test passes end-to-end
- [ ] **Milestone 3**: Festival committed and pushed

## Quality Gates

### Testing and Verification

- [ ] E2E test passes on testnet
- [ ] All unit tests still pass across all packages

### Code Review

- [ ] Final review of integration test and environment setup
- [ ] All packages reviewed in previous sequences

### Iteration Decision

- [ ] Need another iteration? To be determined
