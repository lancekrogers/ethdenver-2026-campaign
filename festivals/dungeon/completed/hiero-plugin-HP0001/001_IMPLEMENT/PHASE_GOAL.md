---
fest_type: phase
fest_id: 001_IMPLEMENT
fest_name: IMPLEMENT
fest_parent: hiero-plugin-HP0001
fest_order: 1
fest_status: pending
fest_created: 2026-02-18T13:40:57.647618-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 001_IMPLEMENT

**Phase:** 001_IMPLEMENT | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Deliver a working Hiero CLI plugin that registers the `hiero camp` command namespace with init, status, and navigate subcommands wrapping the camp binary.

**Context:** This is the sole implementation phase for the hiero-plugin festival. The scope is focused enough to combine plugin API research, implementation, and submission prep into a single phase. No prior planning phase is needed since the plugin API can be researched inline during implementation.

## Required Outcomes

Deliverables this phase must produce:

- [ ] Plugin manifest file that registers with the Hiero CLI plugin system
- [ ] `hiero camp init` command that initializes a camp workspace with Hedera project templates
- [ ] `hiero camp status` command that displays project status across the workspace
- [ ] `hiero camp navigate` command that provides fuzzy-find navigation within camp
- [ ] Hedera scaffold templates bundled with the plugin (smart contract, dApp starter, etc.)
- [ ] Submission package ready for Hedera Track 4 bounty (PR or standalone)

## Quality Standards

Quality criteria for all work in this phase:

- [ ] All commands execute correctly when invoked through the Hiero CLI
- [ ] Plugin passes Hiero CLI plugin validation and registration checks
- [ ] Error messages are clear and actionable when camp binary is missing or commands fail
- [ ] Code follows Node.js best practices with ESLint-clean output
- [ ] Submission meets all Hedera Track 4 bounty requirements

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_plugin_manifest | Research Hiero plugin API and create manifest | Plugin manifest and registration |
| 02_camp_commands | Implement init, status, and navigate subcommands | Three working CLI commands |
| 03_templates | Bundle Hedera scaffold templates for camp init | Template files for Hedera projects |
| 04_submission | Package and prepare bounty submission | PR-ready or standalone submission |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_plugin_manifest
- [ ] 02_camp_commands
- [ ] 03_templates
- [ ] 04_submission

## Notes

- The camp binary must be available on PATH for the plugin commands to function. The plugin should detect its absence and provide a clear installation message.
- Hiero CLI plugin API research happens at the start of this phase since no separate planning phase exists.
- Node.js runtime aligns with the Hiero CLI ecosystem.
- No external festival dependencies; this can proceed fully in parallel with all other festivals.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
