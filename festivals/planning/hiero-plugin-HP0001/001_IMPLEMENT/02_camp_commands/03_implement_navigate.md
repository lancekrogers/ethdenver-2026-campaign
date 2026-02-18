---
fest_type: task
fest_id: 03_implement_navigate.md
fest_name: implement_navigate
fest_parent: 02_camp_commands
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Navigate Command

**Task Number:** 03 | **Sequence:** 02_camp_commands | **Autonomy:** medium

## Objective

Implement the `hiero camp navigate` command that provides fuzzy-find navigation within the camp workspace. This command calls `camp navigate` to let users quickly jump to projects and directories within their workspace, or implements a simple built-in fuzzy finder that lists projects and lets users select one.

## Requirements

- [ ] Command handler created at `src/commands/navigate.ts`
- [ ] Calls `camp navigate` if the camp binary supports it natively
- [ ] Falls back to a simple project listing with selection if camp navigate is not available
- [ ] Accepts an optional search query as a positional argument for filtering
- [ ] Displays project paths with clear formatting
- [ ] Outputs the selected project path to stdout so it can be used with `cd`

## Implementation

### Step 1: Create the navigate command handler

Create `src/commands/navigate.ts`:

```typescript
// src/commands/navigate.ts

import chalk from "chalk";
import { execCamp, CampResult } from "../camp";

/**
 * Arguments for the camp navigate command.
 */
export interface NavigateArgs {
  /** Optional search query to filter projects */
  query?: string;
  /** List mode: just print all project paths without interactive selection */
  list?: boolean;
}
```

### Step 2: Implement argument parsing

```typescript
/**
 * Parse raw CLI arguments into NavigateArgs.
 *   hiero camp navigate
 *   hiero camp navigate my-app
 *   hiero camp navigate --list
 */
export function parseNavigateArgs(args: string[]): NavigateArgs {
  let query: string | undefined;
  let list = false;

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === "--list" || arg === "-l") {
      list = true;
    } else if (!arg.startsWith("--") && !query) {
      query = arg;
    }
  }

  return { query, list };
}
```

### Step 3: Try native camp navigate first

Attempt to use camp's built-in navigate command:

```typescript
/**
 * Try to use camp's native navigate command.
 * Returns null if camp doesn't support navigate.
 */
async function tryCampNavigate(query?: string): Promise<CampResult | null> {
  const campArgs = ["navigate"];
  if (query) {
    campArgs.push(query);
  }

  try {
    const result = await execCamp(campArgs);
    // If camp returns a successful result, it supports navigate
    return result;
  } catch (error) {
    // If camp navigate is not a recognized command, fall back
    if (
      error instanceof Error &&
      error.name === "CampNotFoundError"
    ) {
      throw error; // Re-throw: camp itself is missing
    }
    return null; // camp exists but doesn't support navigate
  }
}
```

### Step 4: Implement fallback fuzzy finder

If camp does not support a native navigate command, provide a built-in fuzzy finder using the project list:

```typescript
/**
 * Simple fuzzy match: check if all characters in the query
 * appear in the target string in order.
 */
function fuzzyMatch(query: string, target: string): boolean {
  const lowerQuery = query.toLowerCase();
  const lowerTarget = target.toLowerCase();
  let qi = 0;

  for (let ti = 0; ti < lowerTarget.length && qi < lowerQuery.length; ti++) {
    if (lowerTarget[ti] === lowerQuery[qi]) {
      qi++;
    }
  }

  return qi === lowerQuery.length;
}

/**
 * Highlight matching characters in the target string.
 */
function highlightMatch(query: string, target: string): string {
  if (!query) return target;

  const lowerQuery = query.toLowerCase();
  const lowerTarget = target.toLowerCase();
  let qi = 0;
  let result = "";

  for (let ti = 0; ti < target.length; ti++) {
    if (qi < lowerQuery.length && lowerTarget[ti] === lowerQuery[qi]) {
      result += chalk.bold.yellow(target[ti]);
      qi++;
    } else {
      result += target[ti];
    }
  }

  return result;
}

/**
 * Fallback navigate using project list and fuzzy filtering.
 */
async function fallbackNavigate(query?: string): Promise<void> {
  // Get project list from camp
  const projectResult = await execCamp(["project", "list"]);

  if (projectResult.exitCode !== 0) {
    console.error(chalk.red("Failed to list projects."));
    console.error(
      chalk.dim(
        "Make sure you are in a camp workspace. Run 'hiero camp init' first."
      )
    );
    process.exitCode = 1;
    return;
  }

  // Parse project list (one project per line)
  const projects = projectResult.stdout
    .trim()
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.length > 0);

  if (projects.length === 0) {
    console.error(chalk.yellow("No projects found in workspace."));
    console.error(
      chalk.dim("Run 'hiero camp init <name>' to create a project.")
    );
    process.exitCode = 1;
    return;
  }

  // Filter by query if provided
  let filtered = projects;
  if (query) {
    filtered = projects.filter((p) => fuzzyMatch(query, p));
  }

  if (filtered.length === 0) {
    console.error(
      chalk.yellow(`No projects matching '${query}' found.`)
    );
    console.error(chalk.dim("Available projects:"));
    for (const project of projects) {
      console.error(chalk.dim(`  ${project}`));
    }
    process.exitCode = 1;
    return;
  }

  // If exactly one match, output its path directly
  if (filtered.length === 1) {
    console.log(filtered[0]);
    return;
  }

  // Multiple matches: list them with highlighting
  console.error(
    chalk.bold.cyan("=== Camp Workspace Navigation ===")
  );
  console.error("");

  for (let i = 0; i < filtered.length; i++) {
    const display = query
      ? highlightMatch(query, filtered[i])
      : filtered[i];
    console.error(`  ${chalk.dim(`[${i + 1}]`)} ${display}`);
  }

  console.error("");
  console.error(
    chalk.dim(
      "Tip: Use a more specific query to narrow results, " +
      "e.g., 'hiero camp navigate my-app'"
    )
  );

  // Output the first match to stdout for piping
  console.log(filtered[0]);
}
```

### Step 5: Implement the main handler

```typescript
/**
 * Execute the hiero camp navigate command.
 * Provides fuzzy-find navigation within the camp workspace.
 */
export async function handleNavigate(args: string[]): Promise<void> {
  const parsed = parseNavigateArgs(args);

  // List mode: just output all project paths
  if (parsed.list) {
    const projectResult = await execCamp(["project", "list"]);
    if (projectResult.exitCode === 0) {
      console.log(projectResult.stdout.trim());
    } else {
      console.error(chalk.red("Failed to list projects."));
      process.exitCode = 1;
    }
    return;
  }

  // Try native camp navigate first
  const nativeResult = await tryCampNavigate(parsed.query);
  if (nativeResult !== null) {
    if (nativeResult.exitCode === 0) {
      console.log(nativeResult.stdout.trim());
    } else {
      console.error(nativeResult.stderr);
      process.exitCode = nativeResult.exitCode;
    }
    return;
  }

  // Fall back to built-in fuzzy finder
  await fallbackNavigate(parsed.query);
}
```

### Step 6: Wire the handler into the plugin entry point

Update `src/index.ts` to use the real navigate handler:

```typescript
import { handleNavigate } from "./commands/navigate";

// In the plugin command registration, replace the stub:
{
  name: "camp navigate",
  description: "Navigate within the camp workspace using fuzzy search",
  handler: handleNavigate,
}
```

### Step 7: Verify the command compiles

```bash
cd $(fgo) && npx tsc --noEmit
```

### Step 8: Manual test

Test the navigate command manually:

```bash
# List mode
cd $(fgo) && npx ts-node -e "
  const { handleNavigate } = require('./src/commands/navigate');
  handleNavigate(['--list']);
"

# With a query
cd $(fgo) && npx ts-node -e "
  const { handleNavigate } = require('./src/commands/navigate');
  handleNavigate(['my-app']);
"
```

## Done When

- [ ] `src/commands/navigate.ts` exists with complete implementation
- [ ] Tries camp native navigate first, falls back to built-in fuzzy finder
- [ ] Fuzzy matching correctly filters project list by query
- [ ] Matching characters are highlighted in output
- [ ] Single match outputs the path directly to stdout (pipe-friendly)
- [ ] Multiple matches show numbered list with highlighting
- [ ] `--list` flag outputs all project paths without filtering
- [ ] Handles empty workspace and no-match cases gracefully
- [ ] Handler is wired into the plugin entry point
- [ ] TypeScript compiles without errors
