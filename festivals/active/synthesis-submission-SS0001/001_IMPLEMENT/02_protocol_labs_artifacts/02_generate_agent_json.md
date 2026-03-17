---
fest_type: task
fest_id: 02_generate_agent_json.md
fest_name: generate agent json
fest_parent: 02_protocol_labs_artifacts
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-16T21:39:46.213931-06:00
fest_tracking: true
---

# Task: Generate agent.json Manifest

## Objective

Generate the agent.json manifest file in DevSpot format from existing OBEY agent configuration and deployed contract data.

## Requirements

- [ ] Create agent.json with all required DevSpot fields (from task 01 research)
- [ ] Include real deployed addresses (ERC-8004 identity, ObeyVault, AgentSettlement)
- [ ] Include accurate tool/capability declarations
- [ ] Validate against DevSpot schema

## Implementation

1. Using the schema from task 01 (devspot-schema.md), create the agent.json file
2. Populate with real data:
   - Agent name: "OBEY Agent" (or per DevSpot naming conventions)
   - Operator wallet: Guardian wallet address
   - ERC-8004 identity: `0x0C97820abBdD2562645DaE92D35eD581266CCe70` (Base Sepolia registry)
   - Tools: Uniswap V3 swaps, CRE risk evaluation, Festival orchestration, ERC-8004 registration
   - Tech stack: Go, Solidity, Foundry, Claude claude-opus-4-6
   - Compute constraints: Festival task-based execution (steps, not time)
   - Task categories: DeFi trading, risk evaluation, identity management
3. Include deployed contract addresses from the design spec
4. Save to project root or submission artifacts directory
5. Validate the JSON structure matches DevSpot expectations

## Done When

- [ ] All requirements met
- [ ] agent.json contains all required DevSpot fields with real data
- [ ] All contract addresses and wallet references are accurate
- [ ] JSON is valid and parseable
