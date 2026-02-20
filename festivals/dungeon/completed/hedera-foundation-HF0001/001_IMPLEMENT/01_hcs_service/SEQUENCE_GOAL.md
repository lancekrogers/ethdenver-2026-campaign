---
fest_type: sequence
fest_id: 01_hcs_service
fest_name: hcs_service
fest_parent: 001_IMPLEMENT
fest_order: 1
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 01_hcs_service

**Sequence:** 01_hcs_service | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Build a complete HCS (Hedera Consensus Service) package that provides topic creation, message publishing, and message subscription with context-aware streaming for the agent-coordinator project.

**Contribution to Phase Goal:** This sequence delivers the foundational communication layer that all other sequences depend on. HCS is the backbone for agent-to-agent messaging -- the coordinator uses it to assign tasks, agents use it to report status, and the entire festival protocol flows through HCS topics. Without this package, no other Hedera integration can function.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **HCS Interface Definitions**: Clean Go interfaces for TopicCreator, MessagePublisher, and MessageSubscriber defined in `internal/hedera/hcs/interfaces.go`
- [ ] **Topic Operations**: Working topic creation and management in `internal/hedera/hcs/topic.go` that creates topics on Hedera testnet
- [ ] **Message Publishing**: Context-aware message publishing in `internal/hedera/hcs/publish.go` with serialization and retry logic
- [ ] **Message Subscription**: Streaming message subscription in `internal/hedera/hcs/subscribe.go` with reconnect-on-failure and deserialization
- [ ] **Message Envelope**: A defined message envelope format for festival protocol messages (task assignments, status updates, results)

### Quality Standards

- [ ] **Context Propagation**: All I/O functions accept `context.Context` as first parameter and respect cancellation
- [ ] **Error Wrapping**: All errors wrapped with operational context using the project error framework
- [ ] **Table-Driven Tests**: Unit tests cover happy path, error cases, and context cancellation for every public function
- [ ] **Code Size**: No file exceeds 500 lines, no function exceeds 50 lines
- [ ] **Zero Solidity**: All HCS operations use the native Hedera Go SDK only

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Package can be imported and used by the coordinator sequence

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_link_project.md | Link festival to agent-coordinator project | Enables `fgo` navigation for all subsequent tasks |
| 02_design_hcs_package.md | Design interfaces and message envelope | Establishes the contract all implementations must satisfy |
| 03_implement_topic_ops.md | Implement topic creation/management | Delivers the TopicCreator interface implementation |
| 04_implement_publish.md | Implement message publishing | Delivers the MessagePublisher interface implementation |
| 05_implement_subscribe.md | Implement message subscription | Delivers the MessageSubscriber interface implementation |
| 06_testing_and_verify.md | Test all HCS operations | Quality gate: verifies all implementations work correctly |
| 07_code_review.md | Review code quality and standards | Quality gate: ensures code meets project standards |
| 08_review_results_iterate.md | Address findings and iterate | Quality gate: resolves issues and confirms readiness |

## Dependencies

### Prerequisites (from other sequences)

- None. This is the first sequence and has no dependencies on other sequences.

### Provides (to other sequences)

- **HCS Package**: Used by 04_coordinator for task assignment via HCS messages and progress monitoring via HCS subscriptions
- **Message Envelope Format**: Used by 04_coordinator and 06_integration for structuring protocol messages

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Hedera Go SDK version incompatibility | Low | High | Pin SDK version in go.mod, verify testnet compatibility before starting |
| Testnet rate limiting during development | Medium | Medium | Implement retry with backoff, use mock for unit tests |
| Message ordering assumptions in HCS | Low | Medium | Design envelope format with sequence numbers, document ordering guarantees |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Project linked and HCS interfaces designed and reviewed
- [ ] **Milestone 2**: All three implementations (topic, publish, subscribe) complete and compiling
- [ ] **Milestone 3**: All quality gates passed, package ready for coordinator consumption

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass with `go test ./internal/hedera/hcs/...`
- [ ] Context cancellation tests verify graceful shutdown
- [ ] Mock-based tests verify interface contracts

### Code Review

- [ ] Code review conducted against project standards
- [ ] Review feedback addressed
- [ ] `go vet` and `staticcheck` pass with no warnings

### Iteration Decision

- [ ] Need another iteration? To be determined after code review
- [ ] If yes, new tasks created with specific findings to address
