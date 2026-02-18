---
fest_type: task
fest_id: 03_integrate_with_init.md
fest_name: integrate_with_init
fest_parent: 03_templates
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Integrate Templates with Init Command

**Task Number:** 03 | **Sequence:** 03_templates | **Autonomy:** medium

## Objective

Wire the Hedera scaffold templates into the `hiero camp init` command so that when a user runs `hiero camp init`, they are presented with template selection, the selected template files are copied to the new project directory, and all variable placeholders are substituted with the actual project name and configuration values.

## Requirements

- [ ] Template loading module created at `src/templates.ts`
- [ ] Init command presents template selection when `--template` is not specified
- [ ] Init command accepts `--template <id>` to skip selection
- [ ] Template files are copied to the new project directory
- [ ] All `{{variable}}` placeholders are replaced with actual values
- [ ] File and directory names containing `{{projectName}}` are renamed
- [ ] Template metadata (template.json) is read and used for display

## Implementation

### Step 1: Create the template loading module

Create `src/templates.ts` that handles template discovery, loading, and variable substitution:

```typescript
// src/templates.ts

import * as fs from "fs";
import * as path from "path";

/**
 * Metadata for a scaffold template.
 */
export interface TemplateMetadata {
  id: string;
  name: string;
  description: string;
  language: string;
  tags: string[];
}

/**
 * Variables available for substitution in template files.
 */
export interface TemplateVariables {
  projectName: string;
  projectNamePascal: string;
  description: string;
  author: string;
  year: string;
}
```

### Step 2: Implement template discovery

The templates are bundled with the plugin in the `templates/` directory. Discover them by scanning for `template.json` files:

```typescript
/**
 * Get the path to the templates directory bundled with the plugin.
 */
function getTemplatesDir(): string {
  // Templates are at the package root, sibling to dist/
  return path.resolve(__dirname, "..", "templates");
}

/**
 * List all available templates by reading template.json from each directory.
 */
export function listTemplates(): TemplateMetadata[] {
  const templatesDir = getTemplatesDir();

  if (!fs.existsSync(templatesDir)) {
    return [];
  }

  const entries = fs.readdirSync(templatesDir, { withFileTypes: true });
  const templates: TemplateMetadata[] = [];

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;

    const metadataPath = path.join(templatesDir, entry.name, "template.json");
    if (!fs.existsSync(metadataPath)) continue;

    try {
      const raw = fs.readFileSync(metadataPath, "utf-8");
      const metadata: TemplateMetadata = JSON.parse(raw);
      templates.push(metadata);
    } catch {
      // Skip templates with invalid metadata
      console.warn(`Warning: Could not load template metadata from ${metadataPath}`);
    }
  }

  return templates;
}

/**
 * Get a specific template by ID.
 */
export function getTemplate(id: string): TemplateMetadata | null {
  const templates = listTemplates();
  return templates.find((t) => t.id === id) ?? null;
}
```

### Step 3: Implement variable substitution

Create the function that processes template content and replaces all `{{variable}}` placeholders:

```typescript
/**
 * Convert a string to PascalCase.
 */
function toPascalCase(str: string): string {
  return str
    .split(/[-_\s]+/)
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
    .join("");
}

/**
 * Build the template variables from the project name and optional overrides.
 */
export function buildVariables(
  projectName: string,
  overrides?: Partial<TemplateVariables>
): TemplateVariables {
  return {
    projectName,
    projectNamePascal: toPascalCase(projectName),
    description: `A Hedera project created with hiero camp`,
    author: "Developer",
    year: new Date().getFullYear().toString(),
    ...overrides,
  };
}

/**
 * Replace all {{variable}} placeholders in a string with actual values.
 */
export function substituteVariables(
  content: string,
  variables: TemplateVariables
): string {
  let result = content;
  for (const [key, value] of Object.entries(variables)) {
    const pattern = new RegExp(`\\{\\{${key}\\}\\}`, "g");
    result = result.replace(pattern, value);
  }
  return result;
}
```

### Step 4: Implement template file copying

Create the function that copies all template files to the target directory, performing variable substitution on both file contents and file/directory names:

```typescript
/**
 * Copy a template to the target directory, substituting variables in
 * file contents and file/directory names.
 */
export function copyTemplate(
  templateId: string,
  targetDir: string,
  variables: TemplateVariables
): void {
  const templatesDir = getTemplatesDir();
  const templateDir = path.join(templatesDir, templateId);

  if (!fs.existsSync(templateDir)) {
    throw new Error(`Template '${templateId}' not found at ${templateDir}`);
  }

  // Create target directory
  fs.mkdirSync(targetDir, { recursive: true });

  // Recursively copy all files except template.json
  copyDirectoryRecursive(templateDir, targetDir, variables);
}

/**
 * Recursively copy a directory, substituting variables in file contents
 * and names. Skips template.json metadata files.
 */
function copyDirectoryRecursive(
  srcDir: string,
  destDir: string,
  variables: TemplateVariables
): void {
  const entries = fs.readdirSync(srcDir, { withFileTypes: true });

  for (const entry of entries) {
    // Skip template metadata file
    if (entry.name === "template.json") continue;

    // Substitute variables in the file/directory name
    const destName = substituteVariables(entry.name, variables);
    const srcPath = path.join(srcDir, entry.name);
    const destPath = path.join(destDir, destName);

    if (entry.isDirectory()) {
      fs.mkdirSync(destPath, { recursive: true });
      copyDirectoryRecursive(srcPath, destPath, variables);
    } else {
      // Read file content, substitute variables, write to destination
      const content = fs.readFileSync(srcPath, "utf-8");
      const substituted = substituteVariables(content, variables);
      fs.writeFileSync(destPath, substituted, "utf-8");
    }
  }
}
```

### Step 5: Implement template selection display

Create a function that displays available templates for user selection:

```typescript
import chalk from "chalk";

/**
 * Display available templates to the user.
 */
export function displayTemplateList(templates: TemplateMetadata[]): void {
  console.log(chalk.bold.cyan("Available Hedera Templates:"));
  console.log("");

  for (let i = 0; i < templates.length; i++) {
    const t = templates[i];
    console.log(`  ${chalk.bold(`[${i + 1}]`)} ${chalk.green(t.name)}`);
    console.log(`      ${chalk.dim(t.description)}`);
    console.log(`      ${chalk.dim(`Language: ${t.language}`)}`);
    console.log("");
  }
}
```

### Step 6: Update the init command to use templates

Modify `src/commands/init.ts` to integrate the template system:

1. Import the template functions:
   ```typescript
   import {
     listTemplates,
     getTemplate,
     buildVariables,
     copyTemplate,
     displayTemplateList,
   } from "../templates";
   ```

2. In `handleInit`, after camp init succeeds, apply the selected template:
   - If `--template` was specified, look it up directly
   - If no template was specified, display the template list and use the first one or prompt
   - Call `copyTemplate` with the project directory and variables
   - Log which template was applied

3. Update the success message to mention the template that was used

### Step 7: Export template functions from the plugin

Update `src/index.ts` to export template functions for potential programmatic use:

```typescript
export { listTemplates, getTemplate } from "./templates";
```

### Step 8: Verify the integration compiles and works

```bash
cd $(fgo) && npx tsc --noEmit
```

Manual smoke test:

```bash
cd $(fgo) && npx ts-node -e "
  const { listTemplates } = require('./src/templates');
  const templates = listTemplates();
  console.log('Found templates:', templates.map(t => t.id));
"
```

Test the full flow:

```bash
cd /tmp && npx ts-node -e "
  const { handleInit } = require('$(fgo)/src/commands/init');
  handleInit(['test-project', '--template', 'hedera-dapp']);
"
```

Verify the generated project has substituted variables:

```bash
cat /tmp/test-project/package.json | grep test-project
```

## Done When

- [ ] `src/templates.ts` exists with template discovery, loading, and variable substitution
- [ ] `listTemplates()` correctly discovers all three templates from the `templates/` directory
- [ ] `copyTemplate()` copies all files and substitutes all `{{variable}}` placeholders
- [ ] File and directory names with variables are correctly renamed
- [ ] `template.json` metadata files are not copied to generated projects
- [ ] Init command integrates template selection and applies the chosen template
- [ ] Running `hiero camp init my-app --template hedera-dapp` produces a complete project
- [ ] All variable placeholders are replaced in the generated project (no `{{` remaining)
- [ ] TypeScript compiles without errors
