---
fest_type: task
fest_id: 01_readme.md
fest_name: readme
fest_parent: 01_documentation
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:45:12.176881-07:00
fest_tracking: true
---

# Task: readme

## Objective

Write the project README.md with project description, setup instructions (under 5 commands), simulation commands, and architecture overview of the 8 risk gates.

## Requirements

- [ ] Project description explaining the CRE Risk Router purpose and architecture (Req P0.17)
- [ ] Setup instructions: clone-to-simulate in under 5 commands
- [ ] Simulation commands with expected output format
- [ ] Architecture overview of the 8 risk gates and data flow
- [ ] No placeholder text or TODO markers

## Implementation

1. **Create `README.md`** at `projects/cre-risk-router/README.md` with sections:

   - **Title and Description**: CRE Risk Router -- AI-powered risk decision layer for autonomous DeFi agents
   - **Architecture**: Data flow diagram (HTTP POST -> parse -> fetch -> evaluate 8 gates -> write receipt -> return decision)
   - **Risk Gates**: Table of all 8 gates with name, type, and description
   - **Quick Start**: Under 5 commands (git clone, install CRE CLI, configure .env, cre workflow simulate .)
   - **Simulation Commands**: `just simulate` (dry-run), `just broadcast` (on-chain write)
   - **Scenarios**: Reference to `scenarios/` directory with expected outcomes
   - **Configuration**: Key config fields and their defaults
   - **Contract**: RiskDecisionReceipt.sol address and testnet info

2. **A judge should be able to go from `git clone` to seeing simulation output** following only the README.

## Done When

- [ ] All requirements met
- [ ] README enables clone-to-simulate in under 5 commands
- [ ] All 8 gates documented with names and purposes
