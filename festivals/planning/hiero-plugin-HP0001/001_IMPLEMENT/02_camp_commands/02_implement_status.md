---
fest_type: task
fest_id: 02_implement_status.md
fest_name: implement_status
fest_parent: 02_camp_commands
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Status Command

**Task Number:** 02 | **Sequence:** 02_camp_commands | **Autonomy:** medium

## Objective

Implement the `hiero camp status` command that shows project status across the camp workspace. This command calls `camp project list` and `camp status` to gather workspace information, then formats the output with colors for terminal readability.

## Requirements

- [ ] Command handler created at `src/commands/status.ts`
- [ ] Calls `camp project list` to get all projects in the workspace
- [ ] Calls `camp status` to get overall workspace status
- [ ] Formats output with colors using chalk or similar library
- [ ] Handles the case where no workspace is initialized
- [ ] Handles the case where the workspace has no projects

## Implementation

### Step 1: Install chalk for terminal colors

```bash
cd $(fgo) && npm install chalk@4
```

Use chalk v4 (CommonJS) for compatibility with the current TypeScript configuration. If using ESM, use chalk v5.

### Step 2: Create the status command handler

Create `src/commands/status.ts`:

```typescript
// src/commands/status.ts

import chalk from "chalk";
import { execCamp, CampResult } from "../camp";

/**
 * Arguments for the camp status command.
 */
export interface StatusArgs {
  /** Show verbose output with additional details */
  verbose?: boolean;
  /** Filter to a specific project */
  project?: string;
}
```

### Step 3: Implement argument parsing

```typescript
/**
 * Parse raw CLI arguments into StatusArgs.
 *   hiero camp status
 *   hiero camp status --verbose
 *   hiero camp status --project my-app
 */
export function parseStatusArgs(args: string[]): StatusArgs {
  let verbose = false;
  let project: string | undefined;

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === "--verbose" || arg === "-v") {
      verbose = true;
    } else if (arg === "--project" && i + 1 < args.length) {
      project = args[++i];
    }
  }

  return { verbose, project };
}
```

### Step 4: Implement workspace status fetching

Fetch status data from camp by calling the appropriate camp subcommands:

```typescript
/**
 * Fetch the list of projects in the camp workspace.
 */
async function fetchProjectList(): Promise<CampResult> {
  return execCamp(["project", "list"]);
}

/**
 * Fetch overall workspace status.
 */
async function fetchWorkspaceStatus(): Promise<CampResult> {
  return execCamp(["status"]);
}
```

### Step 5: Implement output formatting

Format the camp output with colors and structure:

```typescript
/**
 * Format the status output for terminal display.
 */
function formatStatusOutput(
  projectListResult: CampResult,
  statusResult: CampResult,
  verbose: boolean
): string {
  const lines: string[] = [];

  // Header
  lines.push(chalk.bold.cyan("=== Hedera Camp Workspace Status ==="));
  lines.push("");

  // Overall status
  if (statusResult.exitCode === 0 && statusResult.stdout.trim()) {
    lines.push(chalk.bold("Workspace:"));
    const statusLines = statusResult.stdout.trim().split("\n");
    for (const line of statusLines) {
      lines.push(`  ${line}`);
    }
    lines.push("");
  }

  // Project list
  if (projectListResult.exitCode === 0 && projectListResult.stdout.trim()) {
    lines.push(chalk.bold("Projects:"));
    const projects = projectListResult.stdout.trim().split("\n");
    for (const project of projects) {
      const trimmed = project.trim();
      if (trimmed) {
        lines.push(`  ${chalk.green("*")} ${trimmed}`);
      }
    }
    lines.push("");
    lines.push(
      chalk.dim(`${projects.filter((p) => p.trim()).length} project(s) total`)
    );
  } else {
    lines.push(chalk.yellow("No projects found in workspace."));
    lines.push(
      chalk.dim("Run 'hiero camp init <name>' to create a project.")
    );
  }

  if (verbose) {
    lines.push("");
    lines.push(chalk.dim("--- Raw camp output ---"));
    if (statusResult.stdout) {
      lines.push(statusResult.stdout);
    }
    if (projectListResult.stdout) {
      lines.push(projectListResult.stdout);
    }
  }

  return lines.join("\n");
}
```

### Step 6: Implement the main handler

Tie everything together in the exported handler:

```typescript
/**
 * Execute the hiero camp status command.
 * Shows project status across the camp workspace with formatted output.
 */
export async function handleStatus(args: string[]): Promise<void> {
  const parsed = parseStatusArgs(args);

  // Fetch both status and project list
  let projectListResult: CampResult;
  let statusResult: CampResult;

  try {
    [projectListResult, statusResult] = await Promise.all([
      fetchProjectList(),
      fetchWorkspaceStatus(),
    ]);
  } catch (error) {
    if (error instanceof Error && error.name === "CampNotFoundError") {
      throw error; // Let the plugin framework handle this
    }
    console.error(chalk.red("Failed to get workspace status."));
    console.error(
      chalk.dim(
        "Make sure you are in a camp workspace directory, or run 'hiero camp init' first."
      )
    );
    process.exitCode = 1;
    return;
  }

  // Check if workspace is not initialized
  if (
    statusResult.exitCode !== 0 &&
    statusResult.stderr.includes("not a camp workspace")
  ) {
    console.error(chalk.yellow("No camp workspace found in current directory."));
    console.error(
      chalk.dim("Run 'hiero camp init <name>' to create a workspace.")
    );
    process.exitCode = 1;
    return;
  }

  // Filter to specific project if requested
  if (parsed.project) {
    const projectResult = await execCamp([
      "project",
      "status",
      parsed.project,
    ]);
    if (projectResult.exitCode !== 0) {
      console.error(
        chalk.red(`Project '${parsed.project}' not found in workspace.`)
      );
      process.exitCode = 1;
      return;
    }
    console.log(
      chalk.bold.cyan(`=== Project: ${parsed.project} ===`)
    );
    console.log(projectResult.stdout);
    return;
  }

  // Format and print the full status
  const output = formatStatusOutput(
    projectListResult,
    statusResult,
    parsed.verbose ?? false
  );
  console.log(output);
}
```

### Step 7: Wire the handler into the plugin entry point

Update `src/index.ts` to use the real status handler:

```typescript
import { handleStatus } from "./commands/status";

// In the plugin command registration, replace the stub:
{
  name: "camp status",
  description: "Show project status across the camp workspace",
  handler: handleStatus,
}
```

### Step 8: Verify the command compiles

```bash
cd $(fgo) && npx tsc --noEmit
```

## Done When

- [ ] `src/commands/status.ts` exists with complete implementation
- [ ] Calls `camp project list` and `camp status` to gather workspace information
- [ ] Output is formatted with colors using chalk
- [ ] `--verbose` flag shows additional detail including raw camp output
- [ ] `--project` flag filters to a specific project
- [ ] Handles uninitialized workspace with helpful message
- [ ] Handles empty workspace (no projects) with helpful message
- [ ] Handler is wired into the plugin entry point
- [ ] TypeScript compiles without errors
