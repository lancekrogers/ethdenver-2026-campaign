---
fest_type: sequence
fest_id: 03_schedule_service
fest_name: schedule_service
fest_parent: 001_IMPLEMENT
fest_order: 3
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 03_schedule_service

**Sequence:** 03_schedule_service | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Build a Schedule Service package that implements a configurable heartbeat mechanism using Hedera's native Schedule Service, demonstrating agent liveness for the agent-coordinator project.

**Contribution to Phase Goal:** The heartbeat is the liveness signal in the agent coordination protocol. The coordinator uses it to detect unresponsive agents and reassign tasks. This is also one of the three Hedera native services (HCS, HTS, Schedule Service) required for the Track 3 bounty submission, proving we use the full breadth of Hedera's capabilities without Solidity.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Schedule Interface Definitions**: Clean Go interfaces for ScheduleCreator and HeartbeatRunner defined in `internal/hedera/schedule/interfaces.go`
- [ ] **Heartbeat Implementation**: Working heartbeat transaction via Hedera Schedule Service in `internal/hedera/schedule/heartbeat.go`
- [ ] **Configurable Interval**: Heartbeat interval is configurable, not hardcoded

### Quality Standards

- [ ] **Context Propagation**: All I/O functions accept `context.Context` and respect cancellation for graceful shutdown
- [ ] **Error Wrapping**: All errors wrapped with operational context
- [ ] **Table-Driven Tests**: Unit tests cover happy path, error cases, and context cancellation
- [ ] **Code Size**: No file exceeds 500 lines, no function exceeds 50 lines

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Heartbeat can be started and stopped cleanly via context cancellation

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_design_schedule_package.md | Design interfaces and config | Establishes the heartbeat contract |
| 02_implement_heartbeat.md | Implement heartbeat via Schedule Service | Delivers the core heartbeat functionality |
| 03_testing_and_verify.md | Test all schedule operations | Quality gate: verifies implementation |
| 04_code_review.md | Review code quality | Quality gate: ensures standards compliance |
| 05_review_results_iterate.md | Address findings | Quality gate: resolves issues |

## Dependencies

### Prerequisites (from other sequences)

- **01_hcs_service**: Hedera Go SDK available in go.mod, project linked

### Provides (to other sequences)

- **Heartbeat Runner**: Used by 04_coordinator for agent liveness monitoring
- **Schedule Patterns**: Referenced by 06_integration for E2E testing

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Schedule Service API differences from HCS/HTS | Medium | Medium | Study SDK docs for ScheduleCreateTransaction before implementation |
| Testnet schedule expiration behavior | Low | Medium | Test with short intervals, document expiration semantics |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Schedule interfaces designed
- [ ] **Milestone 2**: Heartbeat implementation complete and compiling
- [ ] **Milestone 3**: All quality gates passed

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Context cancellation stops the heartbeat cleanly

### Code Review

- [ ] Standards compliance verified
- [ ] `go vet` and `staticcheck` clean

### Iteration Decision

- [ ] Need another iteration? To be determined after code review
