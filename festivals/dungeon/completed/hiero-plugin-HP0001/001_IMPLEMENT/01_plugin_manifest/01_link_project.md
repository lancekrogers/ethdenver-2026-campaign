---
fest_type: task
fest_id: 01_link_project.md
fest_name: link_project
fest_parent: 01_plugin_manifest
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Link Project

**Task Number:** 01 | **Sequence:** 01_plugin_manifest | **Autonomy:** medium

## Objective

Link the hiero-plugin festival to the hiero-plugin project so that `fgo` (festival go) navigation works for all subsequent tasks. This must be the very first task executed in the entire festival because every other task references files and packages inside the hiero-plugin project, and `fgo` shortcuts depend on this link being established.

## Requirements

- [ ] The hiero-plugin project exists at `projects/hiero-plugin/` (relative to the campaign root)
- [ ] The festival is linked to the project using `fest link`
- [ ] `fgo` navigation resolves correctly after linking
- [ ] The link is verified by navigating to the project root

## Implementation

### Step 1: Verify the project exists

Before linking, confirm the hiero-plugin project directory exists. From the campaign root at `/Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/`:

```bash
ls -la projects/hiero-plugin/
```

You should see a Node.js project structure (package.json, src/, etc.) or at minimum an initialized directory. If the directory does not exist, stop and escalate -- the project must be created or cloned first.

### Step 2: Link the festival to the project

Run the `fest link` command, providing the absolute path to the hiero-plugin project:

```bash
fest link /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/hiero-plugin
```

This command registers the project path in the festival metadata so that `fgo` and other fest navigation commands know where to find source code.

### Step 3: Verify the link works

After linking, verify that `fgo` navigation resolves:

```bash
fgo
```

This should navigate you to the hiero-plugin project root. You should see the Node.js project files (package.json, src/ directory, etc.).

### Step 4: Verify Node.js project setup

Confirm the Node.js project is properly initialized:

```bash
cd $(fgo) && cat package.json
```

Note the package name and version -- you will need this for the plugin manifest in subsequent tasks. If package.json does not exist, initialize the project:

```bash
cd $(fgo) && npm init -y
```

### Step 5: Verify TypeScript setup

Check if TypeScript is configured:

```bash
cd $(fgo) && ls tsconfig.json
```

If TypeScript is not set up, note this for the next task -- the manifest implementation task will need to establish the TypeScript configuration.

## Done When

- [ ] `fest link` completes without errors
- [ ] `fgo` navigates to the hiero-plugin project root
- [ ] The Node.js project is initialized with a package.json
- [ ] You can confirm the project directory structure is ready for development
