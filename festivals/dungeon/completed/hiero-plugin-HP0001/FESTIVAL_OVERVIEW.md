# Festival Overview: hiero-plugin

## Problem Statement

**Current State:** The camp binary provides workspace management (init, status, navigate) but has no integration with the Hiero CLI. Hedera developers cannot access camp functionality through the standard Hiero toolchain.

**Desired State:** A Hiero CLI plugin that wraps the camp binary, exposing workspace management as native `hiero camp` subcommands with Hedera-specific scaffolding templates.

**Why This Matters:** This plugin bridges camp's workspace management into the Hedera ecosystem, qualifying for the Hedera Track 4 developer tooling bounty ($5k, 2 winners). It demonstrates camp's extensibility and provides immediate value to Hedera developers.

## Scope

### In Scope

- Plugin manifest and Hiero CLI registration mechanism
- `hiero camp init` command wrapping camp init with Hedera templates
- `hiero camp status` command wrapping camp status
- `hiero camp navigate` command wrapping camp navigate with fuzzy-find
- Bundled Hedera project scaffold templates
- Submission packaging (PR-ready or standalone)

### Out of Scope

- Modifying the camp binary itself
- Building new camp core features
- Other Hiero CLI plugins beyond the camp integration
- Hedera smart contract development or deployment tooling
- CI/CD pipeline for the plugin

## Planned Phases

### 001_IMPLEMENT

Research the Hiero CLI plugin API, build the plugin manifest, implement all three commands, bundle Hedera scaffold templates, and prepare the bounty submission. This is a single implementation phase since the scope is focused and has no external dependencies.

## Notes

- This is the smallest festival in the campaign with a focused, clear deliverable.
- No dependencies on other festivals; can be built entirely in parallel.
- Node.js is the target runtime to align with the Hiero CLI ecosystem.
- Bounty target: Hedera Track 4 ($5k, 2 winners) for developer tooling.
