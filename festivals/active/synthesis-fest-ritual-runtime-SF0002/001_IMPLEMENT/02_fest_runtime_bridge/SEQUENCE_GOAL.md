---
fest_type: sequence
fest_id: 02_fest_runtime_bridge
fest_name: fest runtime bridge
fest_parent: 001_IMPLEMENT
fest_order: 2
fest_status: completed
fest_created: 2026-03-18T07:26:47.280702-06:00
fest_updated: 2026-03-19T02:05:14.998249-06:00
fest_tracking: true
fest_working_dir: projects/agent-defi
---


# Sequence Goal: 02_fest_runtime_bridge

**Sequence:** 02_fest_runtime_bridge | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-03-18

## Sequence Objective

**Primary Goal:** Add a thin runtime bridge in agent-defi that invokes the real fest CLI, creates ritual runs, inspects run state, and resolves ritual artifact paths.

**Contribution to Phase Goal:** This sequence gives the vault runtime an authentic way to interact with fest without copying fest logic into Go.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **CLI contract map**: A documented mapping of the exact fest commands, arguments, and JSON responses used by the runtime.
- [ ] **Ritual run bridge**: Code that executes `fest ritual run --json` from the campaign root and captures the created run metadata.
- [ ] **Inspection helpers**: Status and artifact-location helpers that bound runtime waiting and failure handling.

### Quality Standards

- [ ] **No fest reimplementation**: The bridge only orchestrates CLI calls and parses results; workflow semantics remain in fest.
- [ ] **Fail-closed behavior**: Missing binaries, bad JSON, or absent artifacts stop the cycle cleanly.

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_map_fest_cli_command_contract.md | Confirm the exact runtime command surface the Go bridge will use. | Reduces integration risk before code changes begin. |
| 02_implement_ritual_run_invocation.md | Create the code path that starts a ritual run from the campaign root. | Enables a live active-run festival to exist for each cycle. |
| 03_add_run_inspection_and_timeouts.md | Add bounded status inspection and timeout handling around ritual completion. | Prevents the runtime from hanging forever on incomplete runs. |
| 04_resolve_artifact_paths.md | Locate and validate the artifact paths emitted by the ritual run. | Lets later sequences parse results and update evidence reliably. |

## Dependencies

### Prerequisites (from other sequences)

- 01_ritual_contract: a stable ritual contract and known artifact layout.

### Provides (to other sequences)

- A real fest bridge for runtime orchestration: Used by 04_ritual_decision_loop and 06_end_to_end_verification

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| fest JSON output or path assumptions drift from the actual CLI | Med | High | Base the bridge on verified commands and handle parse failures explicitly. |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: CLI contract documented
- [ ] **Milestone 2**: Ritual run creation wired into Go
- [ ] **Milestone 3**: Status and artifact resolution validated

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