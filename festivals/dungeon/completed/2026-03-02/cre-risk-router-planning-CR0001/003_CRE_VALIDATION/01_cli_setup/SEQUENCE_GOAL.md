---
fest_type: sequence
fest_id: 01_cli_setup
fest_name: cli setup
fest_parent: 001_CRE_VALIDATION
fest_order: 1
fest_status: pending
fest_created: 2026-03-01T17:42:39.554743-07:00
fest_tracking: true
---

# Sequence Goal: 01_cli_setup

**Sequence:** 01_cli_setup | **Phase:** 001_CRE_VALIDATION | **Status:** Pending | **Created:** 2026-03-01T17:42:39-07:00

## Sequence Objective

**Primary Goal:** Install the CRE CLI, authenticate with Chainlink, create a minimal hello-world CRE workflow, and pass a dry-run simulation.

**Contribution to Phase Goal:** Validates the first half of the CRE toolchain (CLI install, auth, basic workflow creation, simulation). This must succeed before attempting EVM writes in the next sequence.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **CRE CLI installed**: `cre --version` returns a valid version string
- [ ] **Authentication complete**: `cre whoami` returns authenticated user identity after `cre login` and any required key linking
- [ ] **Hello-world workflow**: Minimal Go CRE workflow with cron trigger that logs a string, including `go.mod`, `workflow.go`, and `config.json`
- [ ] **Dry-run simulation**: `cre workflow simulate .` passes without errors on the hello-world workflow

### Quality Standards

- [ ] **Reproducibility**: All commands are documented with exact syntax and expected output
- [ ] **Clean execution**: No warnings or errors in simulation output

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_install_cre_cli | Install CRE CLI and verify version | Provides the CLI tool needed for all subsequent tasks |
| 02_authenticate | Run CRE auth flow and verify identity | Unlocks simulation and deployment capabilities |
| 03_hello_world_workflow | Create minimal cron-triggered Go workflow | Provides a working workflow to test simulation against |
| 04_dry_run_simulation | Run `cre workflow simulate .` on hello-world | Proves the full CLI-to-simulation pipeline works |

## Dependencies

### Prerequisites (from other sequences)

- None: This is the first sequence in the first phase

### Provides (to other sequences)

- Validated CRE CLI and auth flow: Used by 02_evm_validation
- Hello-world workflow template: Used by 02_evm_validation as base for EVM write addition

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| CRE CLI installation fails or is unavailable | Low | High | Check official Chainlink docs, try alternative install methods |
| Auth requires linked key or special access | Med | Med | Document exact auth requirements, try `cre account link-key` |
| Simulation fails on hello-world workflow | Med | High | Debug error output, check CRE SDK docs for correct workflow structure |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: CRE CLI installed and authenticated
- [ ] **Milestone 2**: Hello-world workflow compiles and has valid structure
- [ ] **Milestone 3**: Dry-run simulation passes clean

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
