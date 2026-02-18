---
fest_type: task
fest_id: 01_implement_init.md
fest_name: implement_init
fest_parent: 02_camp_commands
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Init Command

**Task Number:** 01 | **Sequence:** 02_camp_commands | **Autonomy:** medium

## Objective

Implement the `hiero camp init` command that initializes a new camp workspace with Hedera-specific configuration. This command accepts a project name and optional template selection, calls `camp init` with appropriate flags, and sets up default Hedera testnet configuration for the new workspace.

## Requirements

- [ ] Command handler created at `src/commands/init.ts`
- [ ] Accepts `--name` or positional argument for project name
- [ ] Accepts `--template` flag for template selection (defaults available)
- [ ] Calls `camp init` with the project name and any additional flags
- [ ] Sets up Hedera testnet as the default network configuration
- [ ] Provides progress feedback during initialization
- [ ] Handles all error cases with clear messages

## Implementation

### Step 1: Create the commands directory

```bash
cd $(fgo) && mkdir -p src/commands
```

### Step 2: Define the command interface

Create `src/commands/init.ts` with the argument types and command handler:

```typescript
// src/commands/init.ts

import { execCamp, CampResult } from "../camp";

/**
 * Arguments for the camp init command.
 */
export interface InitArgs {
  /** Project name for the new workspace */
  name: string;
  /** Template to use for scaffolding (optional) */
  template?: string;
  /** Working directory to initialize in (defaults to current directory) */
  directory?: string;
}
```

### Step 3: Implement argument parsing

Parse the raw CLI arguments into the `InitArgs` structure. The Hiero CLI may pass arguments in a specific format based on the plugin API. Adapt the parsing to match:

```typescript
/**
 * Parse raw CLI arguments into InitArgs.
 * Supports both positional and flag-based arguments:
 *   hiero camp init my-project
 *   hiero camp init --name my-project --template hedera-dapp
 */
export function parseInitArgs(args: string[]): InitArgs {
  let name = "";
  let template: string | undefined;
  let directory: string | undefined;

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === "--name" && i + 1 < args.length) {
      name = args[++i];
    } else if (arg === "--template" && i + 1 < args.length) {
      template = args[++i];
    } else if (arg === "--directory" && i + 1 < args.length) {
      directory = args[++i];
    } else if (!arg.startsWith("--") && !name) {
      name = arg;
    }
  }

  if (!name) {
    throw new Error(
      "Project name is required.\n\nUsage:\n  hiero camp init <project-name> [--template <template>]\n\nExamples:\n  hiero camp init my-hedera-app\n  hiero camp init my-dapp --template hedera-dapp"
    );
  }

  return { name, template, directory };
}
```

### Step 4: Implement the init handler

Build the camp init arguments and invoke camp:

```typescript
/**
 * List of available Hedera templates.
 * These are populated in sequence 03_templates.
 */
const HEDERA_TEMPLATES = [
  "hedera-smart-contract",
  "hedera-dapp",
  "hedera-agent",
];

/**
 * Execute the hiero camp init command.
 * Initializes a new camp workspace with Hedera-specific configuration.
 */
export async function handleInit(args: string[]): Promise<void> {
  const parsed = parseInitArgs(args);

  console.log(`Initializing Hedera camp workspace: ${parsed.name}`);

  // Build camp init arguments
  const campArgs = ["init", parsed.name];

  // Add template flag if specified
  if (parsed.template) {
    if (!HEDERA_TEMPLATES.includes(parsed.template)) {
      console.warn(
        `Warning: '${parsed.template}' is not a known Hedera template.\n` +
        `Available templates: ${HEDERA_TEMPLATES.join(", ")}\n` +
        `Proceeding anyway in case this is a custom template.`
      );
    }
    campArgs.push("--template", parsed.template);
  }

  // Execute camp init
  const result: CampResult = await execCamp(campArgs, {
    cwd: parsed.directory,
  });

  if (result.exitCode !== 0) {
    console.error(`Failed to initialize workspace:\n${result.stderr}`);
    process.exitCode = result.exitCode;
    return;
  }

  // Print camp output
  if (result.stdout) {
    console.log(result.stdout);
  }

  // Set up Hedera testnet defaults
  await configureHederaDefaults(parsed.name, parsed.directory);

  console.log(`\nWorkspace '${parsed.name}' initialized successfully.`);
  console.log("Default network: Hedera Testnet");
  console.log(`\nNext steps:`);
  console.log(`  cd ${parsed.name}`);
  console.log(`  hiero camp status`);
}
```

### Step 5: Implement Hedera default configuration

After camp init succeeds, write Hedera-specific defaults:

```typescript
/**
 * Configure Hedera testnet defaults for the new workspace.
 * Creates or updates configuration files with Hedera testnet settings.
 */
async function configureHederaDefaults(
  projectName: string,
  directory?: string
): Promise<void> {
  const projectDir = directory
    ? `${directory}/${projectName}`
    : projectName;

  // Set Hedera testnet as default network via camp config
  try {
    await execCamp(
      ["config", "set", "network", "hedera-testnet"],
      { cwd: projectDir }
    );
  } catch {
    // Non-fatal: camp may not support config set yet
    // The workspace is still usable without this default
    console.warn(
      "Note: Could not set default network configuration. " +
      "You can configure Hedera testnet manually."
    );
  }
}
```

### Step 6: Wire the handler into the plugin entry point

Update `src/index.ts` to use the real init handler instead of the stub:

```typescript
import { handleInit } from "./commands/init";

// In the plugin command registration, replace the stub:
{
  name: "camp init",
  description: "Initialize a camp workspace with Hedera project templates",
  handler: handleInit,
}
```

### Step 7: Verify the command compiles

```bash
cd $(fgo) && npx tsc --noEmit
```

Fix any type errors before proceeding.

## Done When

- [ ] `src/commands/init.ts` exists with complete implementation
- [ ] Argument parsing handles `--name`, `--template`, `--directory`, and positional name
- [ ] Missing project name produces a clear usage message
- [ ] Camp init is invoked with correct arguments
- [ ] Hedera testnet defaults are configured after successful init
- [ ] Success output includes next-step instructions
- [ ] Error cases produce clear, actionable messages
- [ ] Handler is wired into the plugin entry point
- [ ] TypeScript compiles without errors
