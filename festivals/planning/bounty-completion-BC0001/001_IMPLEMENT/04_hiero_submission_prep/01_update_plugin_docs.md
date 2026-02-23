---
fest_type: task
fest_id: 01_update_plugin_docs.md
fest_name: update plugin docs
fest_parent: 04_hiero_submission_prep
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.794206-07:00
fest_tracking: true
---

# Task: Update Hiero Plugin Documentation

## Objective

Add the two 0G templates (`0g-agent`, `0g-inft-build`) to the hiero-plugin README's templates table and update `docs/submission.md` to include the PR link (once created in task 03).

## Requirements

- [ ] `projects/hiero-plugin/README.md` templates table lists all 5 templates: `hedera-smart-contract`, `hedera-dapp`, `hedera-agent`, `0g-agent`, `0g-inft-build`
- [ ] `projects/hiero-plugin/docs/usage-guide.md` includes usage examples for the 0G templates

## Implementation

### Step 1: Update README templates table

In `projects/hiero-plugin/README.md`, find the templates table (currently lists 3 Hedera templates). Add two rows:

| Template | Description |
|----------|-------------|
| `0g-agent` | Go agent scaffold with 0G Compute, Storage, and EVM client stubs |
| `0g-inft-build` | ERC-7857 iNFT minting scaffold with AES-256-GCM encryption and 0G DA publisher |

### Step 2: Update usage-guide.md

In `projects/hiero-plugin/docs/usage-guide.md`, add a section for 0G templates:

```markdown
### 0G Agent Template

\`\`\`bash
hcli camp init my-0g-agent --template 0g-agent
\`\`\`

Creates a Go project with 0G Compute broker, Storage client, and chain connection pre-configured for Galileo testnet.

### 0G iNFT Build Template

\`\`\`bash
hcli camp init my-inft --template 0g-inft-build
\`\`\`

Creates a Go project for minting ERC-7857 iNFTs with encrypted metadata (AES-256-GCM) and 0G DA integration.
```

## Done When

- [ ] All requirements met
- [ ] README shows 5 templates and usage-guide has working examples for all 5