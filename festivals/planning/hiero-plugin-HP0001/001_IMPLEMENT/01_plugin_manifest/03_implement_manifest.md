---
fest_type: task
fest_id: 03_implement_manifest.md
fest_name: implement_manifest
fest_parent: 01_plugin_manifest
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Manifest

**Task Number:** 03 | **Sequence:** 01_plugin_manifest | **Autonomy:** medium

## Objective

Create the plugin manifest file and entry point that registers the `camp` command namespace with the Hiero CLI. This is the core registration mechanism that tells the Hiero CLI about the plugin's existence, its commands, and how to load them.

## Requirements

- [ ] Plugin manifest file created (plugin.json or equivalent format discovered in research)
- [ ] Plugin entry point created at `src/index.ts` that exports the plugin registration
- [ ] Plugin metadata included: name (`hiero-plugin-camp`), version, description, author
- [ ] Command registration for three subcommands: `camp init`, `camp status`, `camp navigate`
- [ ] TypeScript project properly configured with tsconfig.json
- [ ] Package.json updated with correct fields for Hiero CLI plugin discovery
- [ ] Plugin compiles without errors

## Implementation

### Step 1: Set up TypeScript configuration

Navigate to the project and create the TypeScript configuration:

```bash
cd $(fgo)
```

Create `tsconfig.json` with Node.js-appropriate settings:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

### Step 2: Install development dependencies

```bash
cd $(fgo) && npm install --save-dev typescript @types/node
```

If the Hiero CLI provides a plugin SDK or type definitions, install those as well:

```bash
# Install Hiero CLI plugin types if available (check research notes)
# npm install --save-dev @hiero/plugin-sdk  (or equivalent)
```

### Step 3: Create the plugin manifest

Based on the research from task 02, create the manifest file. The format will depend on research findings, but a typical plugin.json might look like:

```json
{
  "name": "hiero-plugin-camp",
  "version": "1.0.0",
  "description": "Hiero CLI plugin that provides camp workspace management commands for Hedera developers",
  "author": "ETHDenver 2026 Team",
  "commands": {
    "camp": {
      "description": "Camp workspace management for Hedera projects",
      "subcommands": {
        "init": {
          "description": "Initialize a camp workspace with Hedera project templates",
          "args": [],
          "options": {}
        },
        "status": {
          "description": "Show project status across the camp workspace",
          "args": [],
          "options": {}
        },
        "navigate": {
          "description": "Navigate within the camp workspace using fuzzy search",
          "args": [],
          "options": {}
        }
      }
    }
  }
}
```

Adjust this format to match what the research revealed about the Hiero CLI plugin manifest format.

### Step 4: Create the plugin entry point

Create `src/index.ts` as the main plugin entry point. This file should export whatever the Hiero CLI expects for plugin registration:

```typescript
// src/index.ts
// The exact structure depends on research findings.
// This is a starting pattern -- adapt to match the Hiero CLI plugin contract.

export interface CampPlugin {
  name: string;
  version: string;
  description: string;
  commands: CommandDefinition[];
}

export interface CommandDefinition {
  name: string;
  description: string;
  handler: (args: string[]) => Promise<void>;
}

// Plugin registration export
export const plugin: CampPlugin = {
  name: "hiero-plugin-camp",
  version: "1.0.0",
  description: "Camp workspace management for Hedera developers",
  commands: [
    {
      name: "camp init",
      description: "Initialize a camp workspace with Hedera project templates",
      handler: async (args: string[]) => {
        // Stub -- implemented in 02_camp_commands sequence
        console.log("camp init: not yet implemented");
      },
    },
    {
      name: "camp status",
      description: "Show project status across the camp workspace",
      handler: async (args: string[]) => {
        // Stub -- implemented in 02_camp_commands sequence
        console.log("camp status: not yet implemented");
      },
    },
    {
      name: "camp navigate",
      description: "Navigate within the camp workspace using fuzzy search",
      handler: async (args: string[]) => {
        // Stub -- implemented in 02_camp_commands sequence
        console.log("camp navigate: not yet implemented");
      },
    },
  ],
};

export default plugin;
```

### Step 5: Update package.json

Update the project's package.json with the fields required for Hiero CLI plugin discovery:

```json
{
  "name": "hiero-plugin-camp",
  "version": "1.0.0",
  "description": "Hiero CLI plugin providing camp workspace management for Hedera developers",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "lint": "eslint src/",
    "test": "jest"
  },
  "keywords": ["hiero", "hiero-plugin", "hedera", "camp", "workspace"],
  "author": "ETHDenver 2026 Team",
  "license": "Apache-2.0"
}
```

Add any Hiero-specific fields that the research identified (e.g., `"hiero"` config block, plugin discovery keywords, etc.).

### Step 6: Verify the plugin compiles

Build the TypeScript to confirm everything compiles:

```bash
cd $(fgo) && npx tsc --noEmit
```

Fix any type errors before proceeding.

### Step 7: Verify plugin structure

Confirm the project structure looks correct:

```bash
cd $(fgo) && find . -not -path './node_modules/*' -not -path './dist/*' -type f | sort
```

Expected structure:

```
./package.json
./plugin.json (or equivalent)
./src/index.ts
./tsconfig.json
```

## Done When

- [ ] TypeScript is configured with tsconfig.json
- [ ] Plugin manifest file exists with correct metadata and command definitions
- [ ] `src/index.ts` exports the plugin registration with stub command handlers
- [ ] Package.json has correct fields for Hiero CLI plugin discovery
- [ ] `npx tsc --noEmit` succeeds with no errors
- [ ] The plugin structure follows the pattern identified in plugin API research
