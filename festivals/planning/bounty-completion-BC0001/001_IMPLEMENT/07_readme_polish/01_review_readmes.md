---
fest_type: task
fest_id: 01_review_readmes.md
fest_name: review readmes
fest_parent: 07_readme_polish
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:54.742857-07:00
fest_tracking: true
---

# Task: Review and Update All 7 Project READMEs

## Objective

Read all seven project READMEs and apply accuracy fixes so that architecture descriptions, setup instructions, environment variables, command names, and bounty context reflect the current state of the codebase.

## Requirements

- [ ] Root `README.md` accurately describes the multi-agent economy architecture and lists all 6 sub-projects with correct descriptions
- [ ] `projects/agent-coordinator/README.md` accurately describes the scheduling logic, Hedera HCS integration, and Base track role
- [ ] `projects/agent-inference/README.md` accurately describes 0G Compute usage, iNFT minting, and Hedera Track 3 role
- [ ] `projects/agent-defi/README.md` accurately describes Base tx signing, DeFi operations, Hedera Track 3 role, and includes the P&L summary for the Base bounty
- [ ] `projects/dashboard/README.md` accurately describes the 5 dashboard panels, mock mode, and how to run
- [ ] `projects/contracts/README.md` accurately describes deployed contract addresses, network, and how to interact
- [ ] `projects/hiero-plugin/README.md` accurately describes all available templates including the 0G templates and the Hedera Track 4 role
- [ ] No stale references to removed features, renamed commands, or old environment variable names in any README

## Implementation

### Step 1: Read all 7 READMEs

Read each README file in full:

```
README.md
projects/agent-coordinator/README.md
projects/agent-inference/README.md
projects/agent-defi/README.md
projects/dashboard/README.md
projects/contracts/README.md
projects/hiero-plugin/README.md
```

Create a mental (or written) list of issues: stale content, missing sections, wrong command names, missing bounty context.

### Step 2: Update root `README.md`

The root README should serve as the entry point for judges. Ensure it includes:

- **Project overview**: 3-agent economy cycle (coordinator schedules, inference runs AI tasks + mints iNFTs, defi executes DeFi swaps)
- **Architecture diagram**: ASCII or Mermaid diagram showing the three agents and their Hedera/0G/Base interactions
- **Sub-project table**: name, description, bounty track(s) for each of the 6 projects
- **Quick-start**: `just demo` to run in mock mode, `just dev` for testnet mode
- **Bounty tracks**: list Hedera Track 3, Hedera Track 4, 0G Track 2, 0G Track 3, 0G Track 4, Base with one-line descriptions

### Step 3: Update coordinator README

Verify these elements are present and accurate:
- What the scheduler does (polls Hedera HCS topic, dispatches tasks to inference and defi)
- Environment variables (`HEDERA_ACCOUNT_ID`, `HEDERA_PRIVATE_KEY`, `INFERENCE_ENDPOINT`, `DEFI_ENDPOINT`)
- Hedera Track 3 and Base bounty role
- `just build`, `just run`, `just test` commands

### Step 4: Update inference README

Verify:
- 0G Compute usage for inference tasks
- iNFT minting via ERC-7857 with 0G DA storage
- Hedera HCS result publishing
- Environment variables (`ZG_RPC_URL`, `ZG_PRIVATE_KEY`, `HEDERA_ACCOUNT_ID`, etc.)
- 0G Track 2 and 0G Track 3 bounty roles

### Step 5: Update agent-defi README

Verify:
- Base tx signing for DeFi swaps
- Hedera HCS trade reporting
- P&L tracking section (should exist per memory — "docs: add P&L summary to agent-defi README for Base bounty")
- Environment variables (`BASE_RPC_URL`, `BASE_PRIVATE_KEY`, `HEDERA_ACCOUNT_ID`, etc.)
- Base bounty and Hedera Track 3 roles

### Step 6: Update dashboard README

Verify:
- Description of all 5 panels
- How to run in mock mode (`just demo` or `MOCK_MODE=true`)
- How to run against live agents
- Screenshot or description of expected UI

### Step 7: Update contracts README

Verify:
- Network: which testnet (Hedera testnet, 0G testnet, Base Sepolia)
- Deployed contract addresses (or note they must be deployed by the developer)
- How to deploy: `just deploy`
- Contract descriptions: ERC-7857 iNFT contract, any coordinator contracts

### Step 8: Update hiero-plugin README

Verify:
- All available templates listed: hedera-agent, hedera-consensus, 0g-agent, 0g-inft-build
- How to install the plugin binary
- How to use `hiero camp init` with each template
- Hedera Track 4 bounty role and 0G Track 4 bounty role

### Step 9: Check cross-references

Verify that links from the root README to sub-project READMEs use the correct relative paths and that any external links (Hedera docs, 0G docs, Base docs, ETHDenver submission page) are valid.

## Done When

- [ ] All requirements met
- [ ] All 7 READMEs reviewed, issues fixed, and no stale content remains
