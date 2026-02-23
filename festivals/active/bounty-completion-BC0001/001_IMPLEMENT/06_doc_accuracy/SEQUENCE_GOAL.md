---
fest_type: sequence
fest_id: 06_doc_accuracy
fest_name: doc accuracy
fest_parent: 001_IMPLEMENT
fest_order: 6
fest_status: pending
fest_created: 2026-02-21T17:48:56.760376-07:00
fest_tracking: true
---

# Sequence Goal: 06_doc_accuracy

**Sequence:** 06_doc_accuracy | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-21T17:48:56-07:00

## Sequence Objective

**Primary Goal:** Audit and fix all project READMEs so every setup instruction, environment variable, and command is accurate against the current codebase, then add a root-level quickstart that gets judges from `git clone` to running dashboard in under 5 minutes.

**Contribution to Phase Goal:** Bounty judges follow README instructions to evaluate projects. Stale docs with wrong env vars or missing steps cause immediate disqualification. Every README must reflect reality.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Fixed READMEs**: All 6 project READMEs (agent-coordinator, agent-defi, agent-inference, contracts, hiero-plugin, dashboard) have accurate environment variable lists, correct build commands, and working setup steps
- [ ] **Root quickstart**: Root README has a "Quick Start" section that walks a judge from `git clone` through `docker compose up` to seeing the dashboard

### Quality Standards

- [ ] **Copy-paste accuracy**: Every shell command in every README works when copy-pasted into a fresh terminal
- [ ] **Env var completeness**: Every `.env.example` lists all required variables with descriptions

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_fix_all_stale_readmes | Audit and fix all 6 project READMEs against actual code | Judges can follow any project's README successfully |
| 02_add_root_quickstart | Add 5-minute quickstart section to root README | Judges get running demo in minimal time |

## Dependencies

### Prerequisites (from other sequences)

- 01_base_agent_bugfixes: DeFi agent changes affect its README's env vars and build instructions
- 05_system_polish: Docker healthchecks must be in place before documenting `docker compose up` behavior

### Provides (to other sequences)

- Accurate documentation: Final deliverable for judges, no downstream sequences

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Env vars change during earlier sequences | Medium | Medium | Run this sequence last, after all code changes are merged |
| Docker compose quickstart fails on judge's machine | Low | High | Test on a clean checkout with no local state |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: All 6 project READMEs audited and fixed
- [ ] **Milestone 2**: Root quickstart section added and tested end-to-end

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed

### Iteration Decision

- [ ] Need another iteration? No
- [ ] If yes, new tasks created: N/A
