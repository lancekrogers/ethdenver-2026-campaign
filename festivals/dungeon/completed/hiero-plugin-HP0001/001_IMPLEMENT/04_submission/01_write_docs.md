---
fest_type: task
fest_id: 01_write_docs.md
fest_name: write_docs
fest_parent: 04_submission
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Write Documentation

**Task Number:** 01 | **Sequence:** 04_submission | **Autonomy:** medium

## Objective

Write complete documentation for the hiero-plugin project. Create a comprehensive README.md, a detailed usage guide with examples, and an architecture document explaining design decisions. Documentation must be thorough enough that a developer unfamiliar with the project can install, configure, and use the plugin from the docs alone.

## Requirements

- [ ] `README.md` at project root with installation, quick start, and overview
- [ ] `docs/usage-guide.md` with detailed examples for all three commands
- [ ] `docs/architecture.md` with plugin design decisions and component overview
- [ ] All code examples in documentation are tested and working
- [ ] Documentation references correct file paths and package names

## Implementation

### Step 1: Write the README.md

Create or update `README.md` at the project root. Structure it with these sections:

**Header and Badges:**

- Project name: `hiero-plugin-camp`
- One-line description: Hiero CLI plugin for camp workspace management
- Badges: license, Node.js version, Hedera Track 4

**Overview:**

- What the plugin does (2-3 sentences)
- Why it exists (Hedera developer experience)
- What commands it provides (init, status, navigate)

**Quick Start:**

```bash
# Install the plugin
npm install -g hiero-plugin-camp

# Initialize a new Hedera project
hiero camp init my-hedera-app --template hedera-dapp

# Check workspace status
cd my-hedera-app
hiero camp status

# Navigate projects
hiero camp navigate my-app
```

**Prerequisites:**

- Node.js 18+
- Hiero CLI installed
- Camp binary installed and on PATH
- Hedera testnet account (for templates that deploy)

**Installation:**

- Global npm install
- Plugin registration with Hiero CLI
- Verification steps

**Commands:**
Brief description of each command with basic usage. Link to usage guide for details.

| Command | Description |
|---------|-------------|
| `hiero camp init` | Initialize a camp workspace with Hedera templates |
| `hiero camp status` | Show project status across the workspace |
| `hiero camp navigate` | Fuzzy-find navigation within the workspace |

**Templates:**
List the three bundled templates with descriptions:

- `hedera-smart-contract`: Solidity + Hardhat for Hedera
- `hedera-dapp`: React + HashConnect
- `hedera-agent`: Go agent with HCS/HTS

**Development:**

- Clone, install, build, test commands
- Contributing guidelines (brief)

**License:**
Apache-2.0

### Step 2: Write the usage guide

Create `docs/usage-guide.md` with detailed examples for each command:

**hiero camp init:**

- Basic usage: `hiero camp init my-project`
- With template: `hiero camp init my-project --template hedera-dapp`
- With directory: `hiero camp init my-project --directory /path/to/workspace`
- Available templates with descriptions
- Post-init steps (cd, install dependencies, configure .env)
- Example output showing what the command prints

**hiero camp status:**

- Basic usage: `hiero camp status`
- Verbose mode: `hiero camp status --verbose`
- Filter by project: `hiero camp status --project my-app`
- Example output with formatted project listing
- Troubleshooting: "No workspace found" errors

**hiero camp navigate:**

- Basic usage: `hiero camp navigate`
- With search query: `hiero camp navigate my-app`
- List mode: `hiero camp navigate --list`
- Using with cd: `cd $(hiero camp navigate my-app)`
- Example output showing fuzzy matching
- Troubleshooting: no projects found

**Common Workflows:**

- Setting up a new Hedera smart contract project from scratch
- Managing multiple Hedera projects in a workspace
- Quickly switching between projects during development

### Step 3: Write the architecture document

Create `docs/architecture.md` explaining the design:

**Plugin Architecture Overview:**

- Diagram showing: Hiero CLI -> Plugin Manifest -> Command Handlers -> Camp Binary
- Component relationships

**Plugin Registration:**

- How the plugin integrates with Hiero CLI
- Manifest format and what each field means
- Plugin lifecycle (discovery, loading, command routing)

**Camp Binary Integration:**

- Why the plugin wraps camp instead of reimplementing
- Binary discovery mechanism (PATH lookup)
- execCamp helper design (process spawning, output capture, error handling)
- Timeout and buffer limit decisions

**Command Design:**

- Consistent argument parsing pattern across commands
- Error handling strategy (CampNotFoundError, non-zero exits, uninitialized workspace)
- Output formatting approach (chalk for colors, stderr for UI, stdout for pipe-friendly output)

**Template System:**

- Template storage (bundled in `templates/` directory)
- Template metadata format (template.json)
- Variable substitution mechanism
- File copying and name replacement logic

**Design Decisions:**

- Why TypeScript (Hiero CLI ecosystem alignment)
- Why chalk v4 (CommonJS compatibility)
- Why execFile over exec (security: prevents shell injection)
- Why fuzzy matching in navigate (UX: quick project access)

### Step 4: Verify all documentation

After writing all docs, verify:

```bash
# Check all docs exist
cd $(fgo) && ls -la README.md docs/usage-guide.md docs/architecture.md

# Check no broken links or references
cd $(fgo) && grep -r "TODO\|FIXME\|TBD\|PLACEHOLDER" README.md docs/
```

Test all code examples by running them:

```bash
# Quick start example
cd /tmp && hiero camp init doc-test --template hedera-smart-contract
cd /tmp && rm -rf doc-test
```

## Done When

- [ ] `README.md` exists with complete installation, usage, and overview sections
- [ ] `docs/usage-guide.md` exists with detailed examples for all three commands
- [ ] `docs/architecture.md` exists with design decisions and component overview
- [ ] All code examples in documentation have been tested and work
- [ ] No TODO, FIXME, TBD, or placeholder markers in documentation
- [ ] Documentation references correct file paths, commands, and package names
- [ ] A developer unfamiliar with the project could follow the docs to set up and use the plugin
