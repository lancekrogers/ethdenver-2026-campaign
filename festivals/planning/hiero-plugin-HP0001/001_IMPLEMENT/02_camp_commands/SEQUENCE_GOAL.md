---
fest_type: sequence
fest_id: 02_camp_commands
fest_name: camp_commands
fest_parent: 001_IMPLEMENT
fest_order: 2
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 02_camp_commands

**Sequence:** 02_camp_commands | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Implement the three core camp subcommands -- `hiero camp init`, `hiero camp status`, and `hiero camp navigate` -- as full command handlers that invoke the camp binary through the discovery module built in sequence 01.

**Contribution to Phase Goal:** These three commands are the entire functional surface of the plugin. They transform the hiero-plugin from a registered shell into a working tool that Hedera developers can use. Without these commands, the plugin manifest and camp discovery module serve no purpose. Each command maps directly to a camp binary operation and provides Hedera-specific defaults and formatting.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Init Command**: `src/commands/init.ts` implementing `hiero camp init` that initializes a camp workspace with Hedera-specific configuration, accepts project name and template selection, and calls `camp init` with appropriate flags
- [ ] **Status Command**: `src/commands/status.ts` implementing `hiero camp status` that shows project status across the workspace by calling `camp project list` and `camp status`, with formatted and colorized output
- [ ] **Navigate Command**: `src/commands/navigate.ts` implementing `hiero camp navigate` that provides fuzzy-find navigation within the camp workspace by calling `camp navigate` or implementing a simple fuzzy finder

### Quality Standards

- [ ] **Consistent Pattern**: All three commands follow the same structural pattern for argument parsing, camp invocation, output formatting, and error handling
- [ ] **Error Handling**: Each command provides clear error messages for all failure modes (missing camp, invalid arguments, camp command failures)
- [ ] **Hedera Defaults**: Init command defaults to Hedera testnet configuration
- [ ] **Clean Output**: Status and navigate commands format output with colors for terminal readability
- [ ] **Code Size**: No file exceeds 500 lines, no function exceeds 50 lines

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] All three commands can be invoked through the plugin entry point

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_implement_init.md | Implement hiero camp init command | Delivers workspace initialization with Hedera templates |
| 02_implement_status.md | Implement hiero camp status command | Delivers workspace status reporting |
| 03_implement_navigate.md | Implement hiero camp navigate command | Delivers workspace navigation |
| 04_testing_and_verify.md | Test all three commands | Quality gate: verifies all commands work correctly |
| 05_code_review.md | Review code quality and standards | Quality gate: ensures code meets project standards |
| 06_review_results_iterate.md | Address findings and iterate | Quality gate: resolves issues and confirms readiness |

## Dependencies

### Prerequisites (from other sequences)

- **01_plugin_manifest**: Plugin entry point (`src/index.ts`) and camp discovery module (`src/camp.ts`) must be complete. The commands will import `execCamp` from `src/camp.ts` and will be wired into the plugin registration in `src/index.ts`.

### Provides (to other sequences)

- **03_templates**: The init command provides the template selection UI that sequence 03 will populate with Hedera-specific templates
- **04_submission**: All three commands are the primary deliverables demonstrated in the bounty submission

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Camp binary argument format changes | Low | Medium | Use camp --help to verify expected arguments before implementation |
| Terminal color formatting inconsistencies | Low | Low | Use a color library (chalk) with fallback to plain text |
| Camp workspace not initialized before status/navigate | Medium | Low | Detect uninitialized workspace and provide helpful error message |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Init command complete and working
- [ ] **Milestone 2**: Status and navigate commands complete and working
- [ ] **Milestone 3**: All quality gates passed, commands ready for template integration

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass with `npx jest`
- [ ] Each command handles missing camp binary gracefully
- [ ] Each command handles invalid arguments gracefully
- [ ] Output formatting is correct in terminal

### Code Review

- [ ] Code review conducted against project standards
- [ ] Review feedback addressed
- [ ] ESLint passes with no warnings
- [ ] All three commands follow consistent patterns

### Iteration Decision

- [ ] Need another iteration? To be determined after code review
- [ ] If yes, new tasks created with specific findings to address
