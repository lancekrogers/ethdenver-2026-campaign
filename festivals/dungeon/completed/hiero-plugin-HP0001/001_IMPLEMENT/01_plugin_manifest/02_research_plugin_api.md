---
fest_type: task
fest_id: 02_research_plugin_api.md
fest_name: research_plugin_api
fest_parent: 01_plugin_manifest
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Research Plugin API

**Task Number:** 02 | **Sequence:** 01_plugin_manifest | **Autonomy:** medium

## Objective

Research the Hiero CLI plugin registration API to understand how third-party plugins integrate with the CLI. Document the plugin interface, registration mechanism, available hooks, command addition process, and manifest format. This research informs all subsequent implementation tasks.

## Requirements

- [ ] Identify how Hiero CLI discovers and loads plugins
- [ ] Document the plugin manifest format (plugin.json, package.json fields, or other)
- [ ] Understand how plugins register new command namespaces (e.g., `hiero camp`)
- [ ] Identify available lifecycle hooks (init, pre-command, post-command, etc.)
- [ ] Document how plugins expose subcommands and their argument definitions
- [ ] Find at least one example of an existing Hiero CLI plugin for reference
- [ ] Save research notes to `docs/plugin-api-research.md` in the hiero-plugin project

## Implementation

### Step 1: Find the Hiero CLI repository

Search for the Hiero CLI on GitHub. It is part of the Hiero (formerly Hedera) ecosystem:

```bash
# Search GitHub for the Hiero CLI
# Check: https://github.com/hiero-ledger
# Also check: https://github.com/hashgraph
```

Look for repositories named `hiero-cli`, `hiero`, or similar. The Hiero project is the open-source rebrand of Hedera tooling under the Linux Foundation.

### Step 2: Examine the plugin system

Once you find the Hiero CLI repository, look for:

1. **Plugin loader**: Search for files named `plugin.ts`, `plugin-loader.ts`, `extensions.ts`, or similar in the CLI source code
2. **Plugin interface**: Look for TypeScript interfaces or types that define the plugin contract (e.g., `HieroPlugin`, `PluginManifest`, `PluginConfig`)
3. **Plugin directory**: Check if there is a `plugins/` directory or a plugin registry
4. **Package.json fields**: Some CLI tools use package.json fields like `hiero-plugin` or `keywords` for plugin discovery

```bash
# Once you have the repo, search for plugin-related code
# Look at the CLI entry point to understand how plugins are loaded
# Check for any plugin documentation in docs/ or README
```

### Step 3: Study existing plugins

Find any existing plugins for the Hiero CLI:

1. Search GitHub for repositories with `hiero-plugin` in their name
2. Check if the CLI repo has built-in plugins that show the pattern
3. Look at npm for packages with `@hiero/` scope or `hiero-plugin-` prefix
4. If no official plugins exist, examine the plugin interface to understand the expected shape

### Step 4: Document the plugin registration API

For each discovery, document:

- **Discovery mechanism**: How does the CLI find plugins? (npm global install, local directory, config file, etc.)
- **Manifest format**: What fields are required? (name, version, commands, hooks, etc.)
- **Command registration**: How does a plugin add commands? (function exports, command objects, decorator pattern, etc.)
- **Argument definitions**: How are command arguments and flags defined?
- **Lifecycle hooks**: What hooks are available and when do they fire?
- **Error handling**: How should plugins report errors?

### Step 5: Document the CLI command pattern

Understand how existing Hiero CLI commands are structured:

1. Look at a built-in command (e.g., `hiero setup` or `hiero account`)
2. Note the command class/function structure
3. Note how arguments and options are defined
4. Note how output is formatted
5. Note how errors are handled and displayed

### Step 6: Write research notes

Create the research document at `docs/plugin-api-research.md` in the hiero-plugin project:

```bash
cd $(fgo) && mkdir -p docs
```

The document should contain:

1. **Overview**: Brief summary of findings
2. **Plugin Discovery**: How the CLI finds plugins
3. **Manifest Format**: The exact format with all fields documented
4. **Command Registration**: How to register commands with examples
5. **Lifecycle Hooks**: Available hooks and their signatures
6. **Existing Examples**: Links to or descriptions of existing plugins
7. **Implementation Plan**: Recommended approach for the hiero-plugin based on research
8. **Open Questions**: Any unresolved questions or risks

### Step 7: Handle the case where plugin API is immature

If the Hiero CLI plugin system is not yet mature or well-documented:

1. Document what does exist in the source code
2. Identify the most likely integration approach (e.g., npm package with specific exports)
3. Note whether a PR to the Hiero CLI itself might be needed
4. Document alternative approaches (e.g., standalone CLI wrapper that delegates to both hiero and camp)

## Done When

- [ ] The Hiero CLI repository has been located and examined
- [ ] The plugin registration mechanism is understood and documented
- [ ] The manifest format is documented with all required and optional fields
- [ ] At least one example of a plugin (existing or from source code analysis) is documented
- [ ] Research notes are saved to `docs/plugin-api-research.md` in the project
- [ ] Open questions and risks are clearly identified
- [ ] The research provides enough information to implement the manifest in the next task
