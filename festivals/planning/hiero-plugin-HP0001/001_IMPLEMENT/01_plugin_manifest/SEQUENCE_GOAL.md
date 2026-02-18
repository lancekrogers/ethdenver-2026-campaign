---
fest_type: sequence
fest_id: 01_plugin_manifest
fest_name: plugin_manifest
fest_parent: 001_IMPLEMENT
fest_order: 1
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 01_plugin_manifest

**Sequence:** 01_plugin_manifest | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Research the Hiero CLI plugin registration API, create the plugin manifest that registers the `camp` command namespace, and implement camp binary discovery so the plugin can invoke camp commands.

**Contribution to Phase Goal:** This sequence lays the foundation for the entire plugin. Without understanding the Hiero CLI plugin API and creating a valid manifest, no commands can be registered. Without camp binary discovery, no commands can execute. Every subsequent sequence depends on the plugin being properly registered and camp being invocable.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Festival Linked**: The hiero-plugin project is linked to this festival via `fest link`
- [ ] **Plugin API Research**: Comprehensive research notes documenting how Hiero CLI plugins register, what hooks exist, how commands are added, and the manifest format
- [ ] **Plugin Manifest**: A manifest file (plugin.json or equivalent) that registers the `camp` namespace with the Hiero CLI, including plugin metadata (name, version, description, author) and command registration for init, status, and navigate
- [ ] **Camp Binary Discovery**: A `src/camp.ts` module that detects camp on PATH, provides clear error messages if missing, and exposes a generic `execCamp(args)` helper for spawning camp with proper argument passing

### Quality Standards

- [ ] **Plugin Registration**: The manifest passes any Hiero CLI validation checks
- [ ] **Error Messages**: Clear, actionable error messages when camp binary is not found
- [ ] **Clean Code**: All code passes ESLint and follows Node.js best practices
- [ ] **Research Quality**: Plugin API research is thorough enough to inform all subsequent sequences

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Plugin can be loaded by the Hiero CLI (even if commands are stubs)

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_link_project.md | Link festival to hiero-plugin project | Enables `fgo` navigation for all subsequent tasks |
| 02_research_plugin_api.md | Research Hiero CLI plugin registration API | Establishes understanding of plugin contract and capabilities |
| 03_implement_manifest.md | Create plugin manifest and registration entry point | Registers the camp namespace with Hiero CLI |
| 04_implement_camp_discovery.md | Implement camp binary discovery and invocation helper | Provides the foundation for all camp command execution |
| 05_testing_and_verify.md | Test manifest loading and camp discovery | Quality gate: verifies plugin loads and camp invocation works |
| 06_code_review.md | Review code quality and standards | Quality gate: ensures code meets project standards |
| 07_review_results_iterate.md | Address findings and iterate | Quality gate: resolves issues and confirms readiness |

## Dependencies

### Prerequisites (from other sequences)

- None. This is the first sequence and has no dependencies on other sequences or other festivals.

### Provides (to other sequences)

- **Plugin Manifest**: Used by 02_camp_commands to register specific subcommands under the camp namespace
- **Camp Discovery Module**: Used by 02_camp_commands for all camp binary invocations
- **Plugin API Research**: Informs command implementation patterns in 02_camp_commands

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Hiero CLI plugin API is undocumented or in flux | Medium | High | Check GitHub repo, source code, and existing plugins for examples |
| Plugin manifest format differs from expectations | Low | Medium | Research thoroughly before implementing; validate early |
| Camp binary not available on all developer machines | High | Low | Provide clear install instructions and graceful error handling |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Project linked and plugin API research complete
- [ ] **Milestone 2**: Plugin manifest created and camp discovery module implemented
- [ ] **Milestone 3**: All quality gates passed, plugin loads in Hiero CLI

## Quality Gates

### Testing and Verification

- [ ] Plugin manifest validates against Hiero CLI expectations
- [ ] Camp discovery correctly detects presence/absence of camp binary
- [ ] execCamp helper successfully invokes camp with arguments
- [ ] Error messages are clear when camp is missing

### Code Review

- [ ] Code review conducted against project standards
- [ ] Review feedback addressed
- [ ] ESLint passes with no warnings

### Iteration Decision

- [ ] Need another iteration? To be determined after code review
- [ ] If yes, new tasks created with specific findings to address
