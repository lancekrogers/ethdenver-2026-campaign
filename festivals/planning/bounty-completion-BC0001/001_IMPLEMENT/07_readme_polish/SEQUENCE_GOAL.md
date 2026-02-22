---
fest_type: sequence
fest_id: 07_readme_polish
fest_name: readme polish
fest_parent: bounty-completion-BC0001
fest_order: 7
fest_status: pending
fest_created: 2026-02-21T16:43:00.431067-07:00
fest_tracking: true
---

# Sequence Goal: 07_readme_polish

**Sequence:** 07_readme_polish | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-21T16:43:00-07:00

## Sequence Objective

**Primary Goal:** Review and update all seven project READMEs — root plus agent-coordinator, agent-inference, agent-defi, dashboard, contracts, and hiero-plugin — so they are accurate, consistent, and ready for public judging, with verified quick-start instructions.

**Contribution to Phase Goal:** READMEs are the first thing judges read; stale architecture diagrams, broken setup commands, or missing bounty context will undermine confidence in the entire submission even if the underlying code is solid.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **All 7 READMEs reviewed and updated**: Each README accurately describes the current architecture, setup steps, environment variables, and bounty context. No stale references to removed features or old command names.
- [ ] **Quick-start instructions verified**: Every quick-start section in every README has been walked through step-by-step and confirmed to produce the stated result without manual intervention beyond what is documented.

### Quality Standards

- [ ] **Consistency across READMEs**: All READMEs use the same environment variable naming conventions, the same `just` command names, and link to each other where appropriate.
- [ ] **Bounty context visible**: Each relevant README (coordinator, inference, defi, hiero-plugin) explicitly calls out the bounty track it supports (Hedera Track 3/4, 0G Track 2/3/4, Base) so judges can map the code to the submission.

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_review_readmes | Read all 7 READMEs and apply accuracy fixes | Eliminates stale content and ensures architecture descriptions match the current codebase |
| 02_verify_quickstarts | Walk through each README's quick-start commands and fix any that fail | Guarantees judges can successfully run the project from documentation alone |

## Dependencies

### Prerequisites (from other sequences)

- Seq 01 (coordinator_schedule_wiring): Coordinator logic must be final before its README is updated.
- Seq 02 (base_tx_signing): agent-defi logic must be final before its README is updated.
- Seq 03 (contracts_implementation): Contract addresses and ABI details must be final.
- Seq 04 (0g_templates): hiero-plugin README must reference the 0G templates.
- Seq 05 (hiero_plugin_polish): hiero-plugin docs must be updated before the root README references them.
- Seq 06 (docker_verify): Docker quick-start must work before it is documented in READMEs.

### Provides (to other sequences)

- Polished, verified READMEs: Required by the submission phase (004_SUBMIT) for final review and public release.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Quick-start command relies on a secret or external service that is not available in CI | Med | Med | Document the dependency clearly and provide a mock fallback command where possible |
| README content drifts from code during parallel seq work | Med | Low | Run README review as the final sequence after all implementation sequences complete |
| Broken links to submodule paths or external docs | Low | Low | Use relative paths for intra-repo links; verify external URLs during review |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: All 7 READMEs read, issues catalogued, and fixes applied
- [ ] **Milestone 2**: Quick-start for each project walked through and verified or fixed
- [ ] **Milestone 3**: All READMEs committed and cross-references between projects checked

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
