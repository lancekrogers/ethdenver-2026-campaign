---
fest_type: sequence
fest_id: 03_obey_daemon_runtime
fest_name: obey daemon runtime
fest_parent: 001_IMPLEMENT
fest_order: 3
fest_status: completed
fest_created: 2026-03-18T07:27:08.294896-06:00
fest_updated: 2026-03-19T02:14:01.995082-06:00
fest_tracking: true
fest_working_dir: projects/agent-defi
---


# Sequence Goal: 03_obey_daemon_runtime

**Sequence:** 03_obey_daemon_runtime | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-03-18

## Sequence Objective

**Primary Goal:** Extend the obey integration so each runtime-created ritual also creates a real daemon-backed session with dynamic festival IDs and workdir binding.

**Contribution to Phase Goal:** This sequence proves the agent is actually running through the obey daemon instead of following a deterministic shortcut inside the trading loop.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Extended session wrapper**: Support for `--workdir`, dynamic festival IDs, and reusable session metadata in the obey client path.
- [ ] **Daemon preflight**: Checks and logging that prove the runtime can reach the daemon and create a real session before each cycle.
- [ ] **Runtime verification path**: Observable evidence that provider, model, session ID, and ritual run binding are real.

### Quality Standards

- [ ] **Real daemon dependency**: Session creation and messaging go through the live obey daemon path.
- [ ] **Non-deterministic execution proof**: Provider/model/session data is logged so the runtime claim is demonstrable.

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_extend_obey_session_wrapper.md | Add the missing session-creation options the runtime needs. | Lets later sequences start real sessions in ritual workdirs. |
| 02_add_daemon_preflight_and_logging.md | Add explicit daemon availability checks and log the session metadata that matters. | Makes failures visible and keeps the runtime honest. |
| 03_bind_session_to_ritual_workdir.md | Ensure each session is bound to the live ritual run path and festival ID. | Connects the agent runtime to the active ritual run instead of to a generic project context. |
| 04_verify_non_deterministic_runtime.md | Prove the runtime is agent-driven and not a local deterministic branch. | Supports the core submission claim for Protocol Labs. |

## Dependencies

### Prerequisites (from other sequences)

- 01_ritual_contract: known ritual contract and workdir expectations.

### Provides (to other sequences)

- A real daemon-backed ritual session path: Used by 04_ritual_decision_loop and 06_end_to_end_verification

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Daemon session creation is flaky or under-instrumented | Med | High | Fail closed, log all key metadata, and verify session creation independently before cycle execution. |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Session wrapper extended
- [ ] **Milestone 2**: Daemon preflight active
- [ ] **Milestone 3**: Non-deterministic session path verified

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