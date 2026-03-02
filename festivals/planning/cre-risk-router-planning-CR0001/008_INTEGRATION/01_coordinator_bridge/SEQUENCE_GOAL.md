---
fest_type: sequence
fest_id: 01_coordinator_bridge
fest_name: coordinator bridge
fest_parent: 006_INTEGRATION
fest_order: 1
fest_status: pending
fest_created: 2026-03-01T17:45:43.65284-07:00
fest_tracking: true
---

# Sequence Goal: 01_coordinator_bridge

**Sequence:** 01_coordinator_bridge | **Phase:** 006_INTEGRATION | **Status:** Pending | **Created:** 2026-03-01T17:45:43-07:00

## Sequence Objective

**Primary Goal:** Add a CRE Risk Router HTTP client to agent-coordinator that checks trade risk before task assignment, denying assignments that fail risk evaluation.

**Contribution to Phase Goal:** Provides the bridge between the existing agent economy and the CRE Risk Router, demonstrating that the workflow operates inside a production-like multi-agent system.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **client.go**: HTTP client in `agent-coordinator/internal/chainlink/cre/` that sends `RiskRequest` to CRE Risk Router and receives `RiskDecision`
- [ ] **models.go**: `RiskRequest` and `RiskDecision` type definitions matching the CRE workflow types
- [ ] **assign.go integration**: If CRE client is configured and decision is denied, publish a `quality_gate` event instead of assigning the task

### Quality Standards

- [ ] **Backwards compatible**: Coordinator works normally when CRE client is not configured
- [ ] **Proper error handling**: HTTP client has timeout, error wrapping, and graceful degradation

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_cre_client | Implement HTTP client and models in agent-coordinator | Provides the communication bridge |
| 02_wire_assign | Wire CRE check into assign.go task assignment flow | Integrates risk checking into live task flow |

## Dependencies

### Prerequisites (from other sequences)

- 005_SUBMISSION complete: P0 submission stable and published
- CRE Risk Router deployed and accessible via HTTP

### Provides (to other sequences)

- CRE-aware task assignment: Used by 02_agent_signals for end-to-end integration proof

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Agent-coordinator API changes break integration | Low | Med | Pin to current API version; use interface abstraction |
| CRE Risk Router HTTP endpoint format changes | Low | Low | Models match the same spec both projects use |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: CRE client and models implemented and compiling
- [ ] **Milestone 2**: assign.go wired with CRE check
- [ ] **Milestone 3**: Integration tested with denied and approved scenarios

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

- [ ] Need another iteration? TBD after execution
- [ ] If yes, new tasks created: TBD
