---
fest_type: sequence
fest_id: 04_0g_templates
fest_name: 0g templates
fest_parent: bounty-completion-BC0001
fest_order: 4
fest_status: pending
fest_created: 2026-02-21T16:43:00.383028-07:00
fest_tracking: true
---

# Sequence Goal: 04_0g_templates

**Sequence:** 04_0g_templates | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-21T16:43:00-07:00

## Sequence Objective

**Primary Goal:** Create two 0G-specific `camp` templates in the hiero-plugin — `0g-agent` and `0g-inft-build` — and register them so they are usable via `hiero camp init --template <name>`, qualifying the project for the 0G Track 4 Dev Tooling bounty.

**Contribution to Phase Goal:** Adds concrete 0G-integrated scaffold templates to the hiero-plugin, expanding the plugin's dev tooling value beyond Hedera and providing judges with working, runnable starting points that demonstrate 0G Compute, Storage, and DA integration.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **0g-agent template**: Go project scaffold at `projects/hiero-plugin/templates/0g-agent/` with entry point, internal packages for 0G Compute broker stub, Storage client stub, chain client, config loading, and a Justfile with build/run/test/lint recipes.
- [ ] **0g-inft-build template**: ERC-7857 iNFT scaffold at `projects/hiero-plugin/templates/0g-inft-build/` with ABI loader, AES-256-GCM encrypt/decrypt, DA audit publisher stub, config, and Justfile.
- [ ] **Template registration**: Both templates registered in the plugin manifest and command handlers so `hiero camp init --template 0g-agent` and `hiero camp init --template 0g-inft-build` produce working project scaffolds.

### Quality Standards

- [ ] **Idiomatic Go structure**: Each template follows the same module layout as `projects/agent-inference` — `cmd/`, `internal/`, `go.mod`, `Justfile` — so generated projects compile with `just build`.
- [ ] **No hardcoded secrets**: All credentials and RPC endpoints are loaded from environment variables via a config package; no private keys or API keys appear in template source files.

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_create_0g_agent_template | Create the `0g-agent` Go scaffold template directory with all source files | Produces the primary 0G Compute+Storage agent template |
| 02_create_0g_inft_template | Create the `0g-inft-build` ERC-7857 iNFT scaffold template directory | Produces the 0G DA + iNFT minting template |
| 03_register_templates | Register both templates in the plugin manifest and wire command handlers | Makes both templates accessible via `hiero camp init` |

## Dependencies

### Prerequisites (from other sequences)

- None: This sequence is self-contained and can execute in parallel with Seq 01-03.

### Provides (to other sequences)

- 0G template source files and registration: Used by Seq 05 (hiero_plugin_polish) for test coverage and doc updates, and required for 0G Track 4 bounty qualification.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 0G SDK import paths change before final release | Low | Med | Pin to a specific commit hash in go.mod; document the pinned version |
| Template does not compile out of the box due to missing dependencies | Med | High | Run `go build ./...` inside each template directory during task 01 and 02 before marking done |
| Plugin manifest format is different from what is assumed | Low | Med | Read existing manifest entries before adding new ones in task 03 |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: `0g-agent` template directory exists and `go build ./...` succeeds inside it
- [ ] **Milestone 2**: `0g-inft-build` template directory exists and `go build ./...` succeeds inside it
- [ ] **Milestone 3**: `hiero camp init --template 0g-agent` and `hiero camp init --template 0g-inft-build` both scaffold a new project correctly

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
