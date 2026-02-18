---
fest_type: task
fest_id: 02_polish_readme.md
fest_name: polish_readme
fest_parent: 06_hedera_track4_package
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Polish Hiero-Plugin README

**Task Number:** 02 | **Sequence:** 06_hedera_track4_package | **Autonomy:** medium

## Objective

Polish the hiero-plugin `README.md` to serve as the primary submission document for the Hedera Track 4 ($5k) developer tooling bounty. Focus on plugin installation, command usage, and template showcase.

## Requirements

- [ ] Project overview explaining what the hiero-plugin provides to the Hiero CLI ecosystem
- [ ] Installation instructions (step-by-step for adding the plugin to Hiero CLI)
- [ ] Command usage documentation with examples and expected output
- [ ] Template showcase showing the templates the plugin provides
- [ ] Bounty alignment section mapping features to Hedera Track 4 requirements
- [ ] README saved at `projects/hiero-plugin/README.md`

## Implementation

### Step 1: Read the existing README

```bash
cd $(fgo) && cat README.md
```

### Step 2: Write the project overview

Explain:

- What the hiero-plugin is (a plugin for the Hiero CLI that adds commands and templates)
- What problem it solves (simplifies Hedera development by providing scaffolding, boilerplate, and project templates)
- Who it is for (developers building on Hedera who use the Hiero CLI)

### Step 3: Write installation instructions

Step-by-step:

1. Prerequisites (Hiero CLI version, Go version if building from source)
2. Install from release (download binary, add to plugin directory)
3. Install from source (`go install` or build steps)
4. Verify installation (`hiero plugin list` or equivalent)

### Step 4: Document commands

For each command the plugin provides, include:

- **Command syntax**: The full command with all flags
- **Description**: What the command does
- **Example**: A real usage example with expected output
- **Flags**: Description of each flag

Format example:

```
## Commands

### `hiero <plugin-command> <subcommand>`

Description of what this command does.

**Usage:**
```bash
hiero <plugin-command> <subcommand> --flag value
```

**Example:**
```bash
$ hiero <plugin-command> <subcommand> --name my-project
Created project "my-project" at ./my-project/
```

**Flags:**
| Flag | Description | Default |
|------|-------------|---------|
| --name | Project name | required |
```

### Step 5: Showcase templates

For each template the plugin provides:

- Template name and description
- What it generates (directory structure, files)
- When to use it (use case)
- Example of generated output (tree view or key files)

### Step 6: Write bounty alignment section

Map features to Hedera Track 4 requirements:

| Hedera Track 4 Requirement | How This Plugin Meets It |
|---------------------------|--------------------------|
| Developer tooling | Plugin extends Hiero CLI with new commands and templates |
| Hiero ecosystem | Built as a native Hiero CLI plugin following plugin API |
| [additional requirements] | [additional mappings] |

## Done When

- [ ] README has all required sections
- [ ] Installation instructions are tested and work
- [ ] Every command is documented with usage and examples
- [ ] Templates are showcased with generated output examples
- [ ] Bounty alignment maps to Hedera Track 4 requirements
- [ ] All links verified valid
