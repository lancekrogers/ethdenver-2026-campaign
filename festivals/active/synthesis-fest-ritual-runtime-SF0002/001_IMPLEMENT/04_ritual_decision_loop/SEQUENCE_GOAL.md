---
fest_type: sequence
fest_id: 04_ritual_decision_loop
fest_name: ritual decision loop
fest_parent: 001_IMPLEMENT
fest_order: 4
fest_status: pending
fest_created: 2026-03-18T07:27:08.311544-06:00
fest_tracking: true
fest_working_dir: projects/agent-defi
---

# Sequence Goal: 04_ritual_decision_loop

**Sequence:** 04_ritual_decision_loop | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-03-18

## Sequence Objective

**Primary Goal:** Replace direct strategy-only trade decisioning with a ritual-backed flow that consumes `decision.json`, preserves rationale, and only trades on ritual `GO`.

**Contribution to Phase Goal:** This is the sequence that changes the truth of the product story: the ritual becomes the runtime gate, not just documentation around a separate strategy path.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Runner integration**: The vault cycle creates and executes a ritual before trade evaluation proceeds.
- [ ] **Decision parser**: A parser that turns `decision.json` into the runtime signal representation.
- [ ] **Trade gate**: A fail-closed rule that blocks execution when ritual output is missing or negative.

### Quality Standards

- [ ] **Defense in depth**: Risk management remains active after ritual decisioning instead of being removed.
- [ ] **Preserved evidence**: Reason text and guardrail outputs survive into logs and trade metadata.

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_insert_ritual_at_cycle_start.md | Start each cycle by creating and executing a ritual run. | Moves ritual execution onto the critical path of every trade decision. |
| 02_parse_decision_json.md | Convert ritual output into the runtime signal structure. | Allows the existing runtime to consume ritual results cleanly. |
| 03_gate_trades_on_ritual_go.md | Require a successful ritual `GO` before execution can continue. | Prevents synthetic or stale decisions from reaching swap execution. |
| 04_preserve_rationale_and_guardrails.md | Keep explainability and guardrail context in runtime outputs. | Improves Protocol Labs evidence and operational debugging. |

## Dependencies

### Prerequisites (from other sequences)

- 02_fest_runtime_bridge and 03_obey_daemon_runtime: live ritual runs and live sessions must both exist first.

### Provides (to other sequences)

- A truthful ritual-backed runtime decision path: Used by 05_artifact_aggregation and 06_end_to_end_verification

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| The new decision path breaks existing runner behavior or deadlocks on missing outputs | Med | High | Add timeouts, parse checks, and explicit NO_GO handling before enabling swaps. |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Runner starts with ritual execution
- [ ] **Milestone 2**: decision.json parser wired in
- [ ] **Milestone 3**: Trade execution gated on ritual GO

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
