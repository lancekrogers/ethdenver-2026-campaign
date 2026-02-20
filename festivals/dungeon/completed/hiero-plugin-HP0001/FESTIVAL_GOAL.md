---
fest_type: festival
fest_id: HP0001
fest_name: hiero-plugin
fest_status: dungeon/completed
fest_created: 2026-02-18T13:40:57.643907-07:00
fest_updated: 2026-02-20T15:55:46.876021-07:00
fest_tracking: true
---



# hiero-plugin

**Status:** Planned | **Created:** 2026-02-18T13:40:57-07:00

## Festival Objective

**Primary Goal:** Build a Hiero CLI plugin that wraps the camp binary to provide Hedera developer workspace management commands.

**Vision:** Hedera developers using the Hiero CLI can run `hiero camp init`, `hiero camp status`, and `hiero camp navigate` to manage their project workspaces. The plugin registers cleanly with Hiero's plugin system, bundles Hedera-specific scaffold templates, and is submission-ready for Hedera Track 4.

## Success Criteria

### Functional Success

- [ ] Plugin manifest and registration integrate correctly with Hiero CLI
- [ ] `hiero camp init` initializes a camp workspace with Hedera project templates
- [ ] `hiero camp status` displays project status across the workspace
- [ ] `hiero camp navigate` provides fuzzy-find navigation within camp
- [ ] Bundled Hedera scaffold templates generate valid project structures

### Quality Success

- [ ] All three commands execute without errors on a fresh install
- [ ] Plugin passes Hiero CLI plugin validation checks
- [ ] Code follows Node.js best practices with clean linting
- [ ] Submission meets Hedera Track 4 bounty requirements

## Progress Tracking

### Phase Completion

- [ ] 001_IMPLEMENT: Build plugin manifest, commands, templates, and prepare submission

## Complete When

- [ ] All phases completed
- [ ] Plugin is PR-ready or standalone submission-ready for Hedera Track 4 ($5k bounty)
- [ ] All three camp subcommands work end-to-end through the Hiero CLI