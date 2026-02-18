---
fest_type: task
fest_id: 01_link_project.md
fest_name: link_project
fest_parent: 01_data_layer
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Link Project

**Task Number:** 01 | **Sequence:** 01_data_layer | **Autonomy:** medium

## Objective

Link the dashboard festival to the dashboard project so that `fgo` (festival go) navigation works for all subsequent tasks. This must be the very first task executed in the entire festival because every other task references files and directories inside the dashboard project, and `fgo` shortcuts depend on this link being established.

## Requirements

- [ ] The dashboard project exists at `projects/dashboard/` (relative to the campaign root)
- [ ] The festival is linked to the project using `fest link`
- [ ] `fgo` navigation resolves correctly after linking
- [ ] The link is verified by navigating to the project root

## Implementation

### Step 1: Verify the project exists

Before linking, confirm the dashboard project directory exists. From the campaign root at `/Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/`:

```bash
ls -la projects/dashboard/
```

You should see a Next.js project structure (package.json, tsconfig.json, src/, next.config.js or next.config.ts, etc.). If the directory does not exist, stop and escalate -- the project must be created or cloned first.

### Step 2: Link the festival to the project

Run the `fest link` command, providing the absolute path to the dashboard project:

```bash
fest link /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/dashboard
```

This command registers the project path in the festival metadata so that `fgo` and other fest navigation commands know where to find source code.

### Step 3: Verify the link works

After linking, verify that `fgo` navigation resolves:

```bash
fgo
```

This should navigate you to the dashboard project root. You should see the Next.js project files (package.json, src/ directory, etc.).

### Step 4: Verify Next.js and TypeScript setup

Confirm the project has TypeScript strict mode enabled:

```bash
cd $(fgo) && cat tsconfig.json
```

Verify that `"strict": true` is set in the compilerOptions. If it is not, add it -- TypeScript strict mode is a requirement for this project.

### Step 5: Verify dependencies are installed

Check that node_modules exist and core dependencies are present:

```bash
cd $(fgo) && ls node_modules/.package-lock.json 2>/dev/null || npm install
```

If dependencies are not installed, run `npm install` to install them.

### Step 6: Verify the project builds

Run a build check to confirm the project compiles:

```bash
cd $(fgo) && npx tsc --noEmit
```

This must pass with zero errors. If there are errors, fix them before proceeding.

## Done When

- [ ] `fest link` completes without errors
- [ ] `fgo` navigates to the dashboard project root
- [ ] `tsconfig.json` has `"strict": true` in compilerOptions
- [ ] `npm install` has been run and node_modules exist
- [ ] `npx tsc --noEmit` passes with zero errors
- [ ] You can run `npm run dev` and the Next.js dev server starts
