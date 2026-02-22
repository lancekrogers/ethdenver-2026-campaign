---
fest_type: sequence
fest_id: 01_coordinator_schedule_wiring
fest_name: coordinator schedule wiring
fest_parent: bounty-completion-BC0001
fest_order: 1
fest_status: pending
fest_created: 2026-02-21T16:42:51.953973-07:00
fest_tracking: true
---

# Sequence Goal: 01_coordinator_schedule_wiring

**Sequence:** 01_coordinator_schedule_wiring | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-21T16:42:51-07:00

## Sequence Objective

**Primary Goal:** Wire the existing schedule service package into coordinator main.go to activate the 4th Hedera native service and start the heartbeat goroutine.

**Contribution to Phase Goal:** The coordinator already implements HCS, HTS, and Accounts. Adding the schedule service brings the total to 4 Hedera native services, strengthening the Hedera Track 3 bounty qualification. This is the smallest change in the phase — approximately 12 lines added to one file — but it is a qualifying requirement.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Schedule service instantiation**: `ScheduleService` created in coordinator main.go using `schedule.NewScheduleService(hederaClient)`
- [ ] **Heartbeat runner started**: `HeartbeatRunner` created with `schedule.NewHeartbeat(hederaClient, scheduleSvc, cfg)` and launched as goroutine
- [ ] **Four Hedera native services active**: Coordinator uses HCS, HTS, Schedule, and Accounts concurrently at runtime

### Quality Standards

- [ ] **Build passes**: `just build` exits 0 with no errors after changes
- [ ] **Context propagation**: Heartbeat goroutine respects context cancellation and exits cleanly on shutdown

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_wire_schedule_service.md | Import schedule package and wire ScheduleService + HeartbeatRunner into main.go | Delivers all three required deliverables |
| 02_testing.md | Verify coordinator compiles and schedule service starts correctly | Confirms sequence goal is met |
| 03_review.md | Code review of changes to main.go | Ensures quality standards are met |
| 04_iterate.md | Address any review feedback | Final iteration gate |
| 05_fest_commit.md | Commit and record completion | Marks sequence done |

## Dependencies

### Prerequisites (from other sequences)

- None: This sequence is standalone and can be started immediately

### Provides (to other sequences)

- Hedera Track 3 qualification strengthened: Provides the 4th native service evidence needed for bounty review (002_REVIEW)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Schedule package API differs from expected | Low | Med | Read internal/hedera/schedule package source before wiring |
| HeartbeatConfig field names differ | Low | Low | Check struct definition in schedule package before writing main.go code |
| Heartbeat goroutine not cleaning up on shutdown | Med | Low | Pass ctx from main; goroutine selects on ctx.Done() |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Schedule package imported and ScheduleService instantiated without compile errors
- [ ] **Milestone 2**: HeartbeatRunner started as goroutine, coordinator starts without panics
- [ ] **Milestone 3**: `just build` passes and coordinator log shows schedule service running

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
