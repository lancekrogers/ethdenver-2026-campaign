---
fest_type: task
fest_id: 04_implement_camp_discovery.md
fest_name: implement_camp_discovery
fest_parent: 01_plugin_manifest
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Camp Discovery

**Task Number:** 04 | **Sequence:** 01_plugin_manifest | **Autonomy:** medium

## Objective

Implement the camp binary discovery and invocation module. This module detects whether the `camp` CLI binary is available on the system PATH, provides clear error messages with installation instructions when it is missing, and exposes a generic `execCamp(args)` helper function that all command implementations will use to spawn camp processes with proper argument passing and output handling.

## Requirements

- [ ] Module created at `src/camp.ts`
- [ ] Function to check if camp binary exists on PATH
- [ ] Clear, actionable error message when camp is not found, including installation instructions
- [ ] Generic `execCamp(args)` function that spawns camp with arguments and returns output
- [ ] Proper handling of stdout, stderr, and exit codes from camp process
- [ ] Timeout handling for camp commands that hang
- [ ] TypeScript types for camp execution results

## Implementation

### Step 1: Define types for camp execution

Create `src/camp.ts` with the types that represent camp execution results:

```typescript
// src/camp.ts

import { execFile } from "child_process";
import { promisify } from "util";
import { existsSync } from "fs";
import { resolve } from "path";

const execFileAsync = promisify(execFile);

/**
 * Result of executing a camp command.
 */
export interface CampResult {
  /** Standard output from camp */
  stdout: string;
  /** Standard error from camp */
  stderr: string;
  /** Exit code (0 = success) */
  exitCode: number;
}

/**
 * Options for camp execution.
 */
export interface CampExecOptions {
  /** Working directory for the camp command */
  cwd?: string;
  /** Timeout in milliseconds (default: 30000) */
  timeout?: number;
  /** Environment variables to pass to camp */
  env?: Record<string, string>;
}
```

### Step 2: Implement camp binary detection

Add a function that checks whether camp is available on the system PATH:

```typescript
/**
 * Check if the camp binary is available on the system PATH.
 * Returns the resolved path to camp if found, null otherwise.
 */
export async function findCampBinary(): Promise<string | null> {
  try {
    // Use 'which' on macOS/Linux, 'where' on Windows
    const command = process.platform === "win32" ? "where" : "which";
    const { stdout } = await execFileAsync(command, ["camp"]);
    const campPath = stdout.trim().split("\n")[0];
    if (campPath && existsSync(campPath)) {
      return campPath;
    }
    return null;
  } catch {
    return null;
  }
}
```

### Step 3: Implement the error message for missing camp

Create a function that returns a clear, actionable error message:

```typescript
/**
 * Error class for when camp binary is not found.
 */
export class CampNotFoundError extends Error {
  constructor() {
    super(
      [
        "The 'camp' binary was not found on your system PATH.",
        "",
        "Camp is a workspace management CLI required by this plugin.",
        "",
        "To install camp:",
        "  1. Visit: https://github.com/your-org/camp/releases",
        "  2. Download the binary for your platform",
        "  3. Place it in a directory on your PATH (e.g., /usr/local/bin/)",
        "  4. Verify installation: camp --version",
        "",
        "If camp is installed but not on PATH, add its directory to your PATH:",
        '  export PATH="$PATH:/path/to/camp/directory"',
      ].join("\n")
    );
    this.name = "CampNotFoundError";
  }
}
```

### Step 4: Implement the execCamp helper

Create the main execution function that all command handlers will use:

```typescript
/** Default timeout for camp commands: 30 seconds */
const DEFAULT_TIMEOUT = 30_000;

/**
 * Execute a camp command with the given arguments.
 *
 * @param args - Arguments to pass to the camp binary (e.g., ["init", "--name", "my-project"])
 * @param options - Execution options (cwd, timeout, env)
 * @returns CampResult with stdout, stderr, and exitCode
 * @throws CampNotFoundError if camp is not on PATH
 */
export async function execCamp(
  args: string[],
  options: CampExecOptions = {}
): Promise<CampResult> {
  // First verify camp is available
  const campPath = await findCampBinary();
  if (!campPath) {
    throw new CampNotFoundError();
  }

  const { cwd, timeout = DEFAULT_TIMEOUT, env } = options;

  try {
    const { stdout, stderr } = await execFileAsync(campPath, args, {
      cwd,
      timeout,
      env: env ? { ...process.env, ...env } : undefined,
      maxBuffer: 10 * 1024 * 1024, // 10MB buffer
    });

    return {
      stdout: stdout.toString(),
      stderr: stderr.toString(),
      exitCode: 0,
    };
  } catch (error: unknown) {
    // Handle exec errors (non-zero exit, timeout, etc.)
    if (error && typeof error === "object" && "killed" in error) {
      const execError = error as {
        stdout?: string;
        stderr?: string;
        code?: number;
        killed?: boolean;
      };

      if (execError.killed) {
        return {
          stdout: execError.stdout?.toString() ?? "",
          stderr: `Camp command timed out after ${timeout}ms`,
          exitCode: 124, // Standard timeout exit code
        };
      }

      return {
        stdout: execError.stdout?.toString() ?? "",
        stderr: execError.stderr?.toString() ?? "",
        exitCode: execError.code ?? 1,
      };
    }

    // Re-throw unexpected errors
    throw error;
  }
}
```

### Step 5: Add a convenience function for checking camp version

Add a quick health-check function:

```typescript
/**
 * Check if camp is installed and return its version.
 * Returns null if camp is not available.
 */
export async function getCampVersion(): Promise<string | null> {
  try {
    const result = await execCamp(["--version"]);
    if (result.exitCode === 0) {
      return result.stdout.trim();
    }
    return null;
  } catch {
    return null;
  }
}

/**
 * Ensure camp is available, throwing a descriptive error if not.
 * Call this at plugin initialization to fail fast.
 */
export async function ensureCampAvailable(): Promise<void> {
  const campPath = await findCampBinary();
  if (!campPath) {
    throw new CampNotFoundError();
  }
}
```

### Step 6: Export all public API

Ensure all public functions and types are properly exported from the module. The complete `src/camp.ts` should export:

- `CampResult` interface
- `CampExecOptions` interface
- `CampNotFoundError` class
- `findCampBinary()` function
- `execCamp()` function
- `getCampVersion()` function
- `ensureCampAvailable()` function

### Step 7: Verify the module compiles

```bash
cd $(fgo) && npx tsc --noEmit
```

Fix any type errors. Ensure the module can be imported from `src/index.ts`:

```typescript
// Add to src/index.ts
export { execCamp, ensureCampAvailable, getCampVersion } from "./camp";
```

### Step 8: Manual smoke test

If camp is installed on your system, verify the module works:

```bash
cd $(fgo) && npx ts-node -e "
  const { getCampVersion } = require('./src/camp');
  getCampVersion().then(v => console.log('camp version:', v));
"
```

If camp is NOT installed, verify the error message is clear:

```bash
cd $(fgo) && npx ts-node -e "
  const { ensureCampAvailable } = require('./src/camp');
  ensureCampAvailable().catch(e => console.log(e.message));
"
```

## Done When

- [ ] `src/camp.ts` exists with all functions implemented
- [ ] `findCampBinary()` correctly detects camp on PATH
- [ ] `CampNotFoundError` provides clear installation instructions
- [ ] `execCamp()` spawns camp with proper argument passing and handles stdout/stderr/exit codes
- [ ] Timeout handling works for long-running camp commands
- [ ] The module compiles without TypeScript errors
- [ ] Functions are exported from `src/index.ts`
- [ ] Manual smoke test confirms basic functionality
