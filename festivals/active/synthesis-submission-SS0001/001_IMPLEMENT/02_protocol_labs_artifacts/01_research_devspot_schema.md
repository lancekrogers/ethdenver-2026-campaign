---
fest_type: task
fest_id: 01_research_devspot_schema.md
fest_name: research devspot schema
fest_parent: 02_protocol_labs_artifacts
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-16T21:39:46.213596-06:00
fest_tracking: true
---

# Task: Research DevSpot Schema Requirements

## Objective

Determine the exact schema requirements for Protocol Labs DevSpot agent.json manifest and agent_log.json execution log so artifacts can be generated correctly.

## Requirements

- [ ] Find the DevSpot schema spec (documentation, examples, or Telegram guidance)
- [ ] Document required fields for agent.json
- [ ] Document required fields and event structure for agent_log.json
- [ ] Note any validation requirements or submission format constraints

## Implementation

1. Start with the bounty description (already saved locally):
   - Read `docs/2026_requirements/synthesis/bounties-agents-optimized.txt` — search for "agent.json" and "agent_log.json"
   - The Protocol Labs "Let the Agent Cook" bounty explicitly lists required fields
2. Check Protocol Labs / DevSpot GitHub repos for schema definitions:
   - `https://github.com/protocol` — look for devspot, agent-manifest, or similar repos
   - `https://github.com/labDAO` — may have agent spec tooling
3. Fetch the ERC-8004 spec for identity fields: `https://eips.ethereum.org/EIPS/eip-8004`
4. From the bounty text, the known required fields for **agent.json** are:
   - `name` — agent name
   - `operator_wallet` — Ethereum address of the operator
   - `erc8004_identity` — on-chain identity address
   - `supported_tools` — array of tool/API names
   - `tech_stack` — frameworks and languages used
   - `compute_constraints` — resource limits
   - `task_categories` — what the agent can do
5. From the bounty text, the known required fields for **agent_log.json** are:
   - `decisions` — timestamped decision entries
   - `tool_calls` — each tool invocation with inputs and outputs
   - `retries` — retry attempts with reasons
   - `failures` — failed operations with error context
   - `final_outputs` — results of the autonomous loop
6. If the schema has additional undocumented fields, check the Synthesis Telegram group (https://nsb.dev/synthesis-updates) for guidance from organizers
7. Document all findings in `workflow/explore/synthesis/devspot-schema.md`

## Done When

- [ ] All requirements met
- [ ] agent.json required fields documented
- [ ] agent_log.json required structure documented
- [ ] Schema reference saved to `workflow/explore/synthesis/devspot-schema.md`
