---
fest_type: sequence
fest_id: 01_project_scaffold
fest_name: project scaffold
fest_parent: 002_FOUNDATION
fest_order: 1
fest_status: pending
fest_created: 2026-03-01T17:43:24.919226-07:00
fest_tracking: true
---

# Sequence Goal: 01_project_scaffold

**Sequence:** 01_project_scaffold | **Phase:** 002_FOUNDATION | **Status:** Pending | **Created:** 2026-03-01T17:43:24-07:00

## Sequence Objective

**Primary Goal:** Create the CRE Risk Router project structure with all configuration files, directory layout, and build tooling.

**Contribution to Phase Goal:** Provides the scaffolded project that the contract sequence builds on top of, and that all subsequent phases use as the development workspace.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Project submodule**: Created via `camp project new cre-risk-router` with private GitHub repo at `github.com/lancekrogers/cre-risk-router` set as remote
- [ ] **Directory structure**: Matches spec Section 3 exactly, including `contracts/evm/src/`, `test/`, `scenarios/`, `demo/`
- [ ] **Config files**: `go.mod`, `config.json` with all Config fields and defaults per spec Section 5, `secrets.yaml` declarations, `.env.example` template
- [ ] **Justfile**: Build/simulate/test/deploy recipes (`just simulate`, `just broadcast`, `just test`, `just deploy`)

### Quality Standards

- [ ] **Spec compliance**: Directory layout and config fields match spec Sections 3 and 5 exactly
- [ ] **Build readiness**: `go build` succeeds on the scaffolded project (even if workflow is stub)

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_init_project | Create submodule, GitHub repo, scaffold directory structure and config files | Provides the complete project structure |
| 02_justfile | Create justfile with build/simulate/test/deploy recipes | Provides standard build and run commands |

## Dependencies

### Prerequisites (from other sequences)

- 001_CRE_VALIDATION/02_evm_validation: Testnet selection, SDK import paths, EVM write patterns documented

### Provides (to other sequences)

- Scaffolded project with config and build tooling: Used by 02_contract for contract development and all later phases

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| `camp project new` fails or is unavailable | Low | Low | Fall back to manual project creation with `go mod init` |
| Config field defaults are wrong | Low | Med | Cross-reference every default against spec Section 5 |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Project submodule created with GitHub remote
- [ ] **Milestone 2**: Full directory structure and config files in place
- [ ] **Milestone 3**: Justfile with working recipes

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
