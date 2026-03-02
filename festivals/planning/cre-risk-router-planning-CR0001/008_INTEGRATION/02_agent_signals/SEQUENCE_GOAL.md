---
fest_type: sequence
fest_id: 02_agent_signals
fest_name: agent signals
fest_parent: 006_INTEGRATION
fest_order: 2
fest_status: pending
fest_created: 2026-03-01T17:45:43.67276-07:00
fest_tracking: true
---

# Sequence Goal: 02_agent_signals

**Sequence:** 02_agent_signals | **Phase:** 006_INTEGRATION | **Status:** Pending | **Created:** 2026-03-01T17:45:43-07:00

## Sequence Objective

**Primary Goal:** Add structured signal fields to inference agent task results, CRE constraint enforcement to DeFi agent trading strategy, and new HCS message types for CRE events.

**Contribution to Phase Goal:** Completes the end-to-end integration between the agent economy and CRE Risk Router by ensuring agents produce the exact input format CRE expects and enforce the constraints CRE returns.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Inference signal fields**: `signal` (buy|sell|hold), `signal_confidence` (0.0-1.0), `risk_score` (0-100), `explanation_hash` added to inference agent task result payload
- [ ] **DeFi execution guard**: CRE constraint enforcement in agent-defi trading strategy -- caps position/slippage to CRE limits when present, falls back to local strategy when absent
- [ ] **HCS message types**: `cre_simulation`, `cre_decision`, `cre_execution_receipt` message types added following existing HCS message patterns

### Quality Standards

- [ ] **Backwards compatibility**: All changes are optional; agents work without CRE configured
- [ ] **Signal field types**: Fields match the exact types the CRE workflow `RiskRequest` expects as input

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_inference_fields | Add structured signal fields to inference task results | Produces CRE-compatible input from inference agent |
| 01_defi_guard | Add CRE constraint enforcement to DeFi trading strategy | Enforces CRE decision constraints on execution |
| 02_hcs_messages | Add CRE-related HCS message types | Enables on-chain audit trail for CRE events |

## Dependencies

### Prerequisites (from other sequences)

- 01_coordinator_bridge: CRE client in agent-coordinator provides the integration point

### Provides (to other sequences)

- Complete agent economy integration: Final deliverable backing the "real agent economy" competitive claim

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Inference agent task result format is tightly coupled | Med | Med | Add fields as optional, zero-value means absent |
| DeFi agent strategy interface changes | Low | Med | Use optional constraint struct, nil means no CRE |
| HCS message type registry conflicts | Low | Low | Follow existing registration pattern in codebase |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Inference fields and DeFi guard implemented (parallel group 01)
- [ ] **Milestone 2**: HCS message types added (group 02)
- [ ] **Milestone 3**: All changes tested for backwards compatibility

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
