---
fest_type: task
fest_id: 02_register_agent.md
fest_name: 02_register_agent
fest_parent: 04_deploy_integrate
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-13T19:25:34.265703-06:00
fest_updated: 2026-03-15T19:51:36.521002-06:00
fest_tracking: true
---


# Task: Register Agent via Synthesis API

## Objective

Register the OBEY Vault Agent with ERC-8004 identity via the Synthesis API and securely store the returned credentials.

## Dependencies

- None. This can be done in parallel with `05_deploy_sepolia`.
- Optionally uses the Go client from `03_identity/01_synthesis_client.md`, but curl works fine.

## Context

- This is a **MANUAL** task — requires a human to provide their real email and review the response.
- Production API: `https://synthesis.devfolio.co`
- The registration mints an ERC-8004 agent identity NFT on Base.

## Step 1: Register via curl

Run the following command, replacing `<email>` with your real email:

```bash
curl -X POST https://synthesis.devfolio.co/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "OBEY Vault Agent",
    "description": "DeFi trading agent with on-chain vault custody on Base. Trades via Uniswap V3 within human-defined spending boundaries.",
    "agentHarness": "claude-code",
    "model": "claude-sonnet-4-6",
    "humanInfo": {
      "fullName": "Lance Rogers",
      "email": "<email>",
      "background": "Builder",
      "cryptoExperience": "yes",
      "aiAgentExperience": "yes",
      "codingComfort": 9,
      "problemStatement": "Building autonomous DeFi agents with transparent on-chain vault management"
    }
  }'
```

Expected response (201 Created):

```json
{
  "participantId": "...",
  "teamId": "...",
  "name": "OBEY Vault Agent",
  "apiKey": "sk-synth-...",
  "registrationTxn": "https://basescan.org/tx/0x..."
}
```

## Step 2: Save credentials securely

1. Save the `apiKey` to your `.env` file (DO NOT commit):
```bash
echo 'SYNTHESIS_API_KEY=sk-synth-...' >> projects/agent-defi/.env
```

2. Record the remaining artifacts in `workflow/design/synthesis/deployment.md`:

```markdown
## Synthesis Registration

- **Participant ID**: `<participantId from response>`
- **Team ID**: `<teamId from response>`
- **Registration TX**: `<registrationTxn from response>`
- **Agent Name**: OBEY Vault Agent
- **Date**: YYYY-MM-DD
```

3. Verify the registration transaction on Basescan by visiting the `registrationTxn` URL.

## Verification Checklist

- [ ] curl returned 201 with a valid response containing `apiKey`
- [ ] `apiKey` stored in `.env` and NOT tracked by git
- [ ] `participantId`, `teamId`, and `registrationTxn` recorded in `workflow/design/synthesis/deployment.md`
- [ ] Registration transaction confirmed on Basescan

## Done When

- [ ] All verification checks pass
- [ ] participantId and registrationTxn recorded in deployment.md
- [ ] apiKey stored securely in .env