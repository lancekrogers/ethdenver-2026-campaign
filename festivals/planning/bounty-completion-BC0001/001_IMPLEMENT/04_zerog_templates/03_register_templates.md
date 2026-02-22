---
fest_type: task
fest_id: 03_register_templates.md
fest_name: register templates
fest_parent: 04_0g_templates
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:54.688238-07:00
fest_tracking: true
---

# Task: Register 0G Templates in the Hiero Plugin

## Objective

Register the `0g-agent` and `0g-inft-build` templates in the hiero-plugin's template registry (manifest and/or command handler) so that `hiero camp init --template 0g-agent` and `hiero camp init --template 0g-inft-build` scaffold the correct project directories.

## Requirements

- [ ] `projects/hiero-plugin/templates/manifest.json` (or equivalent registry file) includes entries for `0g-agent` and `0g-inft-build`
- [ ] The `camp init` command handler recognizes `0g-agent` and `0g-inft-build` as valid template names
- [ ] Running `hiero camp init --template 0g-agent --name my-project` creates a `my-project/` directory populated from the template
- [ ] Running `hiero camp init --template 0g-inft-build --name my-inft` creates a `my-inft/` directory populated from the template
- [ ] Existing templates are not broken by this change (run full test suite after)

## Implementation

### Step 1: Find the template registry

Read the existing template registration mechanism in `projects/hiero-plugin/`:

```bash
# Find manifest or registry files
find projects/hiero-plugin/ -name "manifest.json" -o -name "registry.go" -o -name "templates.go"
```

Read whichever file lists the existing templates (e.g., `hedera-agent`, `hedera-consensus`). Understand the exact data structure before making any changes.

### Step 2: Examine the `camp init` command handler

Find the command handler for `camp init`:

```bash
grep -r "camp init\|CampInit\|camp_init\|templateName" projects/hiero-plugin/cmd/ projects/hiero-plugin/internal/
```

Read the handler to understand how template names map to template directories and how file copying is performed.

### Step 3: Update `manifest.json`

If the plugin uses a JSON manifest file, add two entries following the existing format. Example — adapt to the actual schema:

```json
{
  "templates": [
    {
      "name": "0g-agent",
      "description": "Go agent scaffold for 0G Compute, Storage, and EVM chain interactions",
      "path": "templates/0g-agent",
      "tags": ["0g", "compute", "storage", "go"]
    },
    {
      "name": "0g-inft-build",
      "description": "ERC-7857 iNFT minter with AES-256-GCM encryption and 0G DA storage",
      "path": "templates/0g-inft-build",
      "tags": ["0g", "inft", "erc7857", "da", "go"]
    }
  ]
}
```

### Step 4: Update the Go registry (if templates are registered in Go code)

If templates are registered in Go (e.g., a `var templates = []Template{...}` slice), add entries for both new templates:

```go
{
    Name:        "0g-agent",
    Description: "Go agent scaffold for 0G Compute, Storage, and EVM chain interactions",
    Path:        "templates/0g-agent",
    Tags:        []string{"0g", "compute", "storage"},
},
{
    Name:        "0g-inft-build",
    Description: "ERC-7857 iNFT minter with AES-256-GCM encryption and 0G DA storage",
    Path:        "templates/0g-inft-build",
    Tags:        []string{"0g", "inft", "erc7857", "da"},
},
```

### Step 5: Rebuild the plugin binary

```bash
cd projects/hiero-plugin && just build
```

Fix any compilation errors before proceeding.

### Step 6: Smoke-test the registration

```bash
# Verify both templates appear in the list
./bin/hiero camp list

# Scaffold 0g-agent into a temp directory
./bin/hiero camp init --template 0g-agent --name /tmp/test-0g-agent
ls /tmp/test-0g-agent/

# Scaffold 0g-inft-build into a temp directory
./bin/hiero camp init --template 0g-inft-build --name /tmp/test-0g-inft
ls /tmp/test-0g-inft/
```

Verify that each temp directory contains the expected files from the template (cmd/, internal/, go.mod, Justfile).

### Step 7: Run the full test suite

```bash
cd projects/hiero-plugin && just test
```

Fix any test failures caused by the registration changes. If tests assert a specific number of registered templates, update that count.

## Done When

- [ ] All requirements met
- [ ] `hiero camp init --template 0g-agent` produces a valid project directory
- [ ] `hiero camp init --template 0g-inft-build` produces a valid project directory
- [ ] `just test` exits 0 with no failures in the hiero-plugin
