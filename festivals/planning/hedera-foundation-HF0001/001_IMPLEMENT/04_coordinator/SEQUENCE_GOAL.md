---
fest_type: sequence
fest_id: 04_coordinator
fest_name: coordinator
fest_parent: 001_IMPLEMENT
fest_order: 4
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 04_coordinator

**Sequence:** 04_coordinator | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Build the coordinator engine that orchestrates the full task lifecycle: reading a festival plan, assigning tasks to agents via HCS, monitoring agent progress, enforcing quality gates, and triggering HTS token payments upon task completion.

**Contribution to Phase Goal:** This is the central intelligence of the system. The coordinator is the component that ties HCS, HTS, and the Schedule Service together into a coherent workflow. It is the "brain" that drives the demo cycle: plan -> assign -> monitor -> gate -> pay. Without the coordinator, the individual Hedera service packages are useful but disconnected.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Coordinator Architecture**: Components defined in `internal/coordinator/` with clear separation of concerns
- [ ] **Task Assignment**: Festival plan parser and HCS-based task assignment in `internal/coordinator/assign.go`
- [ ] **Progress Monitor**: HCS subscription-based progress tracking with quality gate enforcement in `internal/coordinator/monitor.go`
- [ ] **Payment Flow**: HTS token transfer triggered by task completion in `internal/coordinator/payment.go`
- [ ] **State Machine**: Task lifecycle state machine (pending -> assigned -> in_progress -> review -> complete -> paid)

### Quality Standards

- [ ] **Context Propagation**: All coordinator operations accept and respect context
- [ ] **Error Wrapping**: All errors include task ID, agent ID, and operation context
- [ ] **Dependency Injection**: Coordinator depends on HCS/HTS/Schedule interfaces, not concrete types
- [ ] **Table-Driven Tests**: Coverage for assignment, monitoring, gate enforcement, and payment
- [ ] **Code Size**: Files under 500 lines, functions under 50 lines

### Completion Criteria

- [ ] All tasks in sequence completed
- [ ] Quality gates passed
- [ ] Coordinator can drive a simulated full cycle in tests

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_design_coordinator.md | Design architecture and state machine | Establishes the coordinator's component structure |
| 02_implement_task_assignment.md | Parse plan and assign via HCS | Delivers plan-to-assignment workflow |
| 03_implement_progress_monitor.md | Monitor status and enforce gates | Delivers progress tracking and quality enforcement |
| 04_implement_payment_flow.md | Trigger HTS payments | Delivers the completion-to-payment workflow |
| 05_testing_and_verify.md | Test coordinator operations | Quality gate |
| 06_code_review.md | Review code quality | Quality gate |
| 07_review_results_iterate.md | Address findings | Quality gate |

## Dependencies

### Prerequisites (from other sequences)

- **01_hcs_service**: MessagePublisher and MessageSubscriber interfaces for task assignment and status monitoring
- **02_hts_service**: TokenTransfer interface for payment settlement
- **03_schedule_service**: HeartbeatRunner interface for agent liveness checks

### Provides (to other sequences)

- **Coordinator Engine**: Used by 06_integration for the full E2E cycle test
- **Task State Machine**: Referenced by integration tests for state verification

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Complex state machine with edge cases | High | High | Keep states minimal (6 states), test all transitions |
| Festival plan format not yet defined | Medium | Medium | Define a simple JSON/YAML plan format in this sequence |
| Coordinator coupling to Hedera packages | Medium | High | Strict DI -- coordinator depends only on interfaces |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Architecture designed with component interfaces and state machine
- [ ] **Milestone 2**: Task assignment and progress monitor implemented
- [ ] **Milestone 3**: Payment flow complete, all quality gates passed

## Quality Gates

### Testing and Verification

- [ ] Unit tests with mock HCS/HTS/Schedule interfaces
- [ ] State machine transition tests cover all valid and invalid transitions

### Code Review

- [ ] DI verified (no concrete Hedera types in coordinator)
- [ ] State machine correctness verified
- [ ] `go vet` and `staticcheck` clean

### Iteration Decision

- [ ] Need another iteration? To be determined after code review
