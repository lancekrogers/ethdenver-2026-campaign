---
fest_type: task
fest_id: 01_register_agent.md
fest_name: 02_register_agent
fest_parent: 04_deploy_integrate
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:25:34.265703-06:00
fest_tracking: true
---

# Task: Register Agent via Synthesis API

## Objective

Register the OBEY Vault Agent with ERC-8004 identity via the Synthesis API and securely store the returned credentials.

## Requirements

- [ ] POST to https://synthesis.devfolio.co/register with agent metadata (name: "OBEY Vault Agent", agentHarness: "claude-code", model: "claude-sonnet-4-6")
- [ ] Save apiKey securely to .env (DO NOT commit)
- [ ] Record participantId, teamId, and registrationTxn in `workflow/design/synthesis/deployment.md`
- [ ] Can use curl or the Go synthesis client from 03_identity

## Implementation

See implementation plan Task 15 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to modify:**
- `workflow/design/synthesis/deployment.md` (add registration artifacts)

## Done When

- [ ] All requirements met
- [ ] participantId and registrationTxn recorded in deployment.md
- [ ] apiKey stored securely in .env
