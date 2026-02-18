---
fest_type: sequence
fest_id: 03_integration_verify
fest_name: integration_verify
fest_parent: 001_IMPLEMENT
fest_order: 3
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 03_integration_verify

**Sequence:** 03_integration_verify | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Verify the full three-agent autonomous economy cycle works end-to-end on testnets. Start the coordinator, inference agent, and DeFi agent together and demonstrate: coordinator assigns task via HCS, inference agent executes on 0G, DeFi agent trades on Base, both report results back via HCS, and coordinator triggers HTS payment. Document the results for bounty submissions.

**Contribution to Phase Goal:** This sequence is the capstone that proves the entire system works as a connected autonomous economy. Without successful integration testing, individual agent implementations have no value -- the bounty submissions require demonstrating the complete cycle. This sequence produces the artifacts (logs, screenshots, documentation) needed for ETHDenver submissions.

**Project:** `agent-coordinator` at `projects/agent-coordinator/` (primary, for orchestrating the test)
**Also Involves:** `agent-inference` and `agent-defi` (running as separate processes)

## Success Criteria

### Required Deliverables

- [ ] **Three-Agent Cycle**: Coordinator, inference, and DeFi agents running concurrently on testnets
- [ ] **HCS Communication**: All three agents communicate via HCS topics (task assignment, result reporting, health)
- [ ] **Inference Pipeline**: Coordinator assigns task -> inference agent executes on 0G -> stores result -> mints iNFT -> reports back
- [ ] **DeFi Pipeline**: DeFi agent trades autonomously on Base -> reports P&L -> demonstrates self-sustaining economics
- [ ] **HTS Payment**: Coordinator triggers HTS token payment upon receiving inference results
- [ ] **Documentation**: Full flow documented with logs, screenshots, and timestamps for bounty submissions

### Quality Standards

- [ ] All three agents start and connect without manual intervention
- [ ] HCS messages are delivered and parsed correctly across all agents
- [ ] No crashes, panics, or unhandled errors during the integration test
- [ ] Graceful shutdown works for all three agents

### Completion Criteria

- [ ] Full cycle demonstrated at least once on testnets
- [ ] Results documented and ready for bounty submission review
- [ ] All quality gates passed
- [ ] Festival commit created

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_link_project.md | Unlink agent-defi, link agent-coordinator | Sets up for integration test orchestration |
| 02_three_agent_cycle.md | Run the full three-agent cycle on testnets | Core integration verification |
| 03_document_results.md | Document test results for bounty submissions | Submission-ready artifacts |
| 04_fest_commit.md | Final fest commit for the festival | Persists all work to version control |
| 05_testing_and_verify.md | Verify integration test is repeatable | Quality gate |
| 06_code_review.md | Review integration test setup and documentation | Quality gate |
| 07_review_results_iterate.md | Address any findings | Quality gate |

## Dependencies

### Prerequisites (from other sequences)

- **01_inference_0g**: Inference agent must be complete and buildable
- **02_defi_base**: DeFi agent must be complete and buildable
- **hedera-foundation-HF0001**: Coordinator must have working HCS and HTS

### Provides

- **Integration Test Results**: Documented proof of three-agent cycle for bounty submissions
- **Submission Artifacts**: Logs, screenshots, and documentation for ETHDenver

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Testnet unavailability (Hedera, 0G, or Base) | Medium | High | Test each agent individually first, document partial results |
| HCS message format mismatch between agents | Medium | High | Verify envelope format compatibility before full cycle |
| Timing issues in three-agent coordination | Medium | Medium | Add sufficient delays, use health checks before starting tasks |
| Gas fund depletion on testnets | Low | Medium | Ensure testnet faucets used, pre-fund wallets |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Project linked, all three agent binaries built and ready
- [ ] **Milestone 2**: Three-agent cycle demonstrated on testnets
- [ ] **Milestone 3**: Results documented and fest commit created

## Quality Gates

### Testing and Verification

- [ ] Integration test can be repeated reliably
- [ ] No manual steps required during the test (fully automated)
- [ ] Results are deterministic and documented

### Code Review

- [ ] Integration test scripts are clean and documented
- [ ] Documentation is accurate and complete
- [ ] No secrets exposed in documentation or logs

### Iteration Decision

- [ ] Need another iteration? To be determined
- [ ] If yes, specific issues documented
