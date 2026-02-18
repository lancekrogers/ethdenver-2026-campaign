---
fest_type: task
fest_id: 02_prepare_submission.md
fest_name: prepare_submission
fest_parent: 04_submission
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Prepare Submission

**Task Number:** 02 | **Sequence:** 04_submission | **Autonomy:** medium

## Objective

Prepare the Hedera Track 4 bounty submission package. Verify all bounty requirements are met, create a clear demonstration flow showing all three commands working end-to-end, and package everything needed for submission (PR to Hiero CLI repo or standalone submission through the ETHDenver portal).

## Requirements

- [ ] Review and document all Hedera Track 4 bounty requirements
- [ ] Verify each requirement is met by the plugin implementation
- [ ] Create a demo script that walks through all three commands
- [ ] Prepare the submission format (PR description or portal submission)
- [ ] Verify the plugin installs cleanly from a fresh environment
- [ ] Create a short project summary for the submission

## Implementation

### Step 1: Review Hedera Track 4 bounty requirements

Research the exact requirements for Hedera Track 4 ($5k bounty for developer tooling). Check:

1. The ETHDenver 2026 bounty board or Devfolio page
2. The Hedera/Hiero bounty description
3. Any specific submission format requirements

Document each requirement and map it to the plugin's implementation:

| Bounty Requirement | How Our Plugin Meets It | Evidence |
|--------------------|------------------------|----------|
| Developer tooling for Hedera ecosystem | Plugin extends Hiero CLI with workspace management | Plugin manifest, three commands |
| Functional implementation | All three commands work end-to-end | Test suite, demo script |
| Open source | Apache-2.0 license, public repository | LICENSE file, GitHub repo |
| Documentation | README, usage guide, architecture doc | docs/ directory |

### Step 2: Create the demo script

Create a `demo.sh` script at the project root that demonstrates the full plugin workflow:

```bash
#!/usr/bin/env bash
# hiero-plugin-camp Demo Script
# Demonstrates all three camp commands through the Hiero CLI

set -e

echo "=== hiero-plugin-camp Demo ==="
echo ""

# Step 1: Show available templates
echo "--- Step 1: Initialize a Hedera project ---"
echo "Running: hiero camp init demo-project --template hedera-smart-contract"
hiero camp init demo-project --template hedera-smart-contract
echo ""

# Step 2: Check workspace status
echo "--- Step 2: Check workspace status ---"
echo "Running: hiero camp status"
cd demo-project
hiero camp status
echo ""

# Step 3: Navigate the workspace
echo "--- Step 3: Navigate the workspace ---"
echo "Running: hiero camp navigate demo"
hiero camp navigate demo
echo ""

# Cleanup
echo "--- Demo Complete ---"
echo "Cleaning up demo project..."
cd ..
rm -rf demo-project
echo "Done! All three commands demonstrated successfully."
```

Make the script executable:

```bash
cd $(fgo) && chmod +x demo.sh
```

### Step 3: Test clean installation

Verify the plugin installs and works from a clean environment:

```bash
# Build the plugin
cd $(fgo) && npm run build

# Pack it (simulates npm install)
cd $(fgo) && npm pack

# Install from the tarball in a temp location
cd /tmp && npm install -g $(fgo)/hiero-plugin-camp-*.tgz

# Verify the plugin is discoverable
hiero plugin list  # (or equivalent Hiero CLI command)

# Run the demo
cd /tmp && bash $(fgo)/demo.sh

# Cleanup
npm uninstall -g hiero-plugin-camp
```

Document any issues found during clean installation and fix them.

### Step 4: Prepare the submission description

Write the submission description that will go on the ETHDenver portal or as a PR description. Save to `docs/submission.md`:

**Project Name:** hiero-plugin-camp

**Track:** Hedera Track 4 - Developer Tooling

**Summary:** (2-3 sentences describing what the plugin does and why it matters)

**What It Does:**
- Extends the Hiero CLI with camp workspace management commands
- Provides `hiero camp init` for project initialization with Hedera templates
- Provides `hiero camp status` for workspace overview
- Provides `hiero camp navigate` for fuzzy-find project navigation
- Bundles three Hedera-specific scaffold templates (smart contract, dApp, agent)

**How It Works:**
- Plugin registers with Hiero CLI through the standard plugin manifest
- Commands invoke the camp binary for workspace operations
- Templates provide ready-to-use Hedera project scaffolds with testnet configuration

**Technical Stack:**
- TypeScript, Node.js
- Hiero CLI plugin API
- Camp binary integration
- Hedera SDK (in templates)

**Demo:**
Link to demo video or instructions for running demo.sh

**Repository:** Link to GitHub repository

### Step 5: Verify submission completeness

Run through the final checklist:

- [ ] Repository is public on GitHub
- [ ] README.md is at the root and renders well on GitHub
- [ ] LICENSE file is present (Apache-2.0)
- [ ] All source code compiles without errors
- [ ] All tests pass
- [ ] Demo script runs successfully
- [ ] Documentation is complete and accurate
- [ ] No secrets, credentials, or personal data in the repository
- [ ] .gitignore excludes node_modules, dist, .env
- [ ] Package.json has correct metadata

### Step 6: Prepare PR (if submitting as PR to Hiero CLI)

If the submission is a PR to the Hiero CLI repository:

1. Fork the Hiero CLI repo
2. Create a branch: `feat/camp-plugin`
3. Add the plugin code in the appropriate directory
4. Write a PR description using the submission description from Step 4
5. Reference the bounty in the PR description

If submitting standalone through the portal:

1. Ensure the GitHub repo link is ready
2. Fill in the submission form with the description from Step 4
3. Include the demo video link or demo.sh instructions

## Done When

- [ ] All Hedera Track 4 bounty requirements are documented and verified as met
- [ ] Demo script (`demo.sh`) exists and runs successfully end-to-end
- [ ] Plugin installs cleanly from a fresh environment
- [ ] Submission description written and saved to `docs/submission.md`
- [ ] Repository is ready for public viewing (clean, documented, no secrets)
- [ ] Submission format is prepared (PR or portal submission ready)
- [ ] Final checklist is fully checked off
