---
fest_type: sequence
fest_id: 01_ritual_contract
fest_name: ritual contract
fest_parent: 001_IMPLEMENT
fest_order: 1
fest_status: completed
fest_created: 2026-03-18T07:26:58.681068-06:00
fest_updated: 2026-03-19T01:56:39.95712-06:00
fest_tracking: true
fest_working_dir: festivals/ritual/agent-market-research-RI-AM0001
---


# Sequence Goal: 01_ritual_contract

**Sequence:** 01_ritual_contract | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-03-18

## Sequence Objective

**Primary Goal:** Harden the campaign-side ritual so an obey-driven agent can execute it unattended and always emit the required machine-readable artifacts.

**Contribution to Phase Goal:** This sequence establishes the contract every later runtime sequence depends on. Without a reliable ritual workflow and artifact shape, the runtime bridge cannot truthfully consume or verify results.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Ritual audit**: A written gap analysis comparing the current ritual template to the runtime spec and identifying missing outputs or ambiguous steps.
- [ ] **Artifact contract**: Explicit `decision.json` and `agent_log_entry.json` output requirements wired into the ritual workflow.
- [ ] **Autonomous workflow updates**: Task instructions tightened so the ritual can complete through unattended `fest next` execution for both `GO` and `NO_GO` outcomes.

### Quality Standards

- [ ] **Explicit output paths**: Every expected artifact path is named directly in the ritual tasks and results directories.
- [ ] **No human-only blockers**: The ritual has no mandatory interactive steps that would break daemon-driven execution.

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_audit_current_ritual_template.md | Audit the existing ritual template and record the runtime gaps. | Produces the ritual contract inputs used by sequences 02, 03, and 04. |
| 02_define_artifact_contract.md | Specify the exact decision and log artifact contract the runtime will consume. | Makes runtime parsing and verification deterministic without making the agent deterministic. |
| 03_tighten_unattended_workflow.md | Rewrite ritual tasks so an agent can complete them unattended through fest. | Turns the ritual into a real runtime dependency instead of a planning artifact. |
| 04_validate_go_and_no_go_paths.md | Verify that both positive and negative outcomes complete successfully and write artifacts. | Prevents runtime dead-ends when the agent decides not to trade. |

## Dependencies

### Prerequisites (from other sequences)

- None. This is the entry sequence for the implementation phase.

### Provides (to other sequences)

- A hardened ritual template and artifact contract: Used by 02_fest_runtime_bridge, 03_obey_daemon_runtime, and 04_ritual_decision_loop

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| The ritual still contains ambiguous or human-centric instructions | Med | High | Update every blocking task now and verify the instructions from an agent-execution perspective. |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Gap analysis complete
- [ ] **Milestone 2**: Artifact contract explicit in ritual files
- [ ] **Milestone 3**: Ritual supports both GO and NO_GO outcomes unattended

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete
- [ ] Performance benchmarks met or explicitly waived for non-runtime sequences

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed
- [ ] Standards compliance verified

### Iteration Decision

- [ ] Need another iteration? No
- [ ] If yes, new tasks created: N/A