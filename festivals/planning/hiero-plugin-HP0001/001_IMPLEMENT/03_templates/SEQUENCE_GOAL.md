---
fest_type: sequence
fest_id: 03_templates
fest_name: templates
fest_parent: 001_IMPLEMENT
fest_order: 3
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 03_templates

**Sequence:** 03_templates | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Design and implement Hedera-specific scaffold templates that bundle with the plugin, and integrate them with the `hiero camp init` command so users can select a template when creating a new workspace.

**Contribution to Phase Goal:** Templates are the value-add that differentiates this plugin from a bare camp wrapper. They give Hedera developers a fast on-ramp by providing pre-configured project scaffolds for common Hedera use cases (smart contracts, dApps, agents). The templates make `hiero camp init` immediately useful for the Track 4 bounty judges by showing concrete Hedera integration.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Template Design Document**: Clear specification of all template structures, files, and configuration
- [ ] **hedera-smart-contract Template**: Complete Solidity + Hardhat scaffold pre-configured for Hedera network deployment
- [ ] **hedera-dapp Template**: Complete React + HashConnect scaffold for building Hedera dApps
- [ ] **hedera-agent Template**: Complete Go agent scaffold with HCS (Hedera Consensus Service) and HTS (Hedera Token Service) integration
- [ ] **Template Integration**: Init command presents template selection and copies template files with variable substitution

### Quality Standards

- [ ] **Template Completeness**: Each template produces a project that compiles/installs without errors
- [ ] **Hedera Configuration**: Each template includes correct Hedera testnet configuration
- [ ] **Documentation**: Each template includes a README with setup instructions specific to Hedera
- [ ] **Variable Substitution**: Project name and configuration values are correctly substituted in generated files
- [ ] **Clean Scaffolds**: No placeholder or TODO markers left in generated project files

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Running `hiero camp init my-app --template hedera-dapp` produces a working project scaffold

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_design_templates.md | Design template structures and file contents | Establishes the blueprint for all three templates |
| 02_implement_templates.md | Create template files in templates/ directory | Delivers the actual scaffold files for all three templates |
| 03_integrate_with_init.md | Wire templates into the init command | Connects templates to the user-facing init flow |
| 04_testing_and_verify.md | Test template generation and integration | Quality gate: verifies templates produce valid projects |
| 05_code_review.md | Review code quality and standards | Quality gate: ensures code meets project standards |
| 06_review_results_iterate.md | Address findings and iterate | Quality gate: resolves issues and confirms readiness |

## Dependencies

### Prerequisites (from other sequences)

- **01_plugin_manifest**: Plugin entry point and camp discovery module must be complete
- **02_camp_commands**: The init command handler must be complete so templates can be integrated into it

### Provides (to other sequences)

- **04_submission**: Complete templates are a key part of the bounty submission demo flow

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Template files become stale if Hedera SDK updates | Medium | Medium | Pin SDK versions in template package.json/go.mod |
| HashConnect integration requires specific wallet setup | Low | Low | Template README documents wallet requirements |
| Go agent template requires Hedera Go SDK familiarity | Low | Low | Include detailed comments and README instructions |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Template designs documented and approved
- [ ] **Milestone 2**: All three template scaffolds created and verified
- [ ] **Milestone 3**: Templates integrated with init command and quality gates passed

## Quality Gates

### Testing and Verification

- [ ] Each template generates a project that installs dependencies successfully
- [ ] Each template includes correct Hedera testnet configuration
- [ ] Variable substitution replaces all placeholders correctly
- [ ] Template selection in init command works for all three templates

### Code Review

- [ ] Code review conducted against project standards
- [ ] Review feedback addressed
- [ ] ESLint passes with no warnings
- [ ] Template files are clean and well-documented

### Iteration Decision

- [ ] Need another iteration? To be determined after code review
- [ ] If yes, new tasks created with specific findings to address
