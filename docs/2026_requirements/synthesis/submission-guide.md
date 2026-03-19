# Synthesis Hackathon Submission Guide

**Deadline:** Mar 22, 2026, 11:59 PM PST
**API Base:** `https://synthesis.devfolio.co`
**Auth:** `Authorization: Bearer sk-synth-6d5c471ccfdc067a2cb919680a13c38d01767ca5d817e442`
**Team UUID:** `56a0c5c0aca54815a64992b661ef593f`

---

## Submission Flow Overview

There is NO Devfolio UI submission. Everything goes through the Synthesis API:

1. Create draft project (`POST /projects`)
2. Iterate on draft (`POST /projects/:uuid`)
3. Self-custody transfer (`POST /participants/me/transfer/init` + `/confirm`)
4. Publish (`POST /projects/:uuid/publish`)

Projects can be updated until the deadline. After deadline, published projects lock.

---

## Step-by-Step

### Step 1: Create Draft Project

```bash
curl -X POST https://synthesis.devfolio.co/projects \
  -H "Authorization: Bearer $SYNTH_API_KEY" \
  -H "Content-Type: application/json" \
  -d @submission-payload.json
```

**Required fields:**

| Field | Value |
|-------|-------|
| `teamUUID` | `56a0c5c0aca54815a64992b661ef593f` |
| `name` | `OBEY Vault Agent` |
| `description` | See below |
| `problemStatement` | See below |
| `repoURL` | `https://github.com/lancekrogers/agent-defi` |
| `trackUUIDs` | Array of track UUIDs (minimum 1) |
| `conversationLog` | Content from `/conversationLog.json` |
| `submissionMetadata` | See below |

**Optional fields:**

| Field | Value |
|-------|-------|
| `deployedURL` | Dashboard URL if available |
| `videoURL` | Video demo link (add before final publish) |
| `pictures` | Screenshots array |
| `coverImageURL` | Project cover image |

**Response:** Returns `projectUUID` and `slug` — save these for updates.

---

### Step 2: Self-Custody Transfer

All team members must complete this before publishing.

**2a. Initiate transfer:**

```bash
curl -X POST https://synthesis.devfolio.co/participants/me/transfer/init \
  -H "Authorization: Bearer $SYNTH_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"targetOwnerAddress": "0xC71d8A19422C649fe9bdCbF3ffA536326c82b58b"}'
```

Response includes a `transferToken`. Must confirm within 15 minutes.

**2b. Confirm transfer:**

```bash
curl -X POST https://synthesis.devfolio.co/participants/me/transfer/confirm \
  -H "Authorization: Bearer $SYNTH_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "transferToken": "<token from init response>",
    "targetOwnerAddress": "0xC71d8A19422C649fe9bdCbF3ffA536326c82b58b"
  }'
```

---

### Step 3: Update Draft (iterate as needed)

```bash
curl -X POST https://synthesis.devfolio.co/projects/$PROJECT_UUID \
  -H "Authorization: Bearer $SYNTH_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"videoURL": "https://...", "trackUUIDs": [...]}'
```

Only include fields you want to change.

---

### Step 4: Publish

```bash
curl -X POST https://synthesis.devfolio.co/projects/$PROJECT_UUID/publish \
  -H "Authorization: Bearer $SYNTH_API_KEY"
```

**Pre-publish requirements:**
- All team members in self-custody
- Project has `name` and at least one `trackUUID`
- Returns `status: "publish"` and auto-generated URL slug

---

## Track UUIDs

| Track | UUID | Prize | Effort |
|-------|------|-------|--------|
| Let the Agent Cook | `10bd47fac07e4f85bda33ba482695b24` | $8,000 | Core |
| Agents With Receipts (ERC-8004) | `3bf41be958da497bbb69f1a150c76af9` | $8,004 | Core |
| Agentic Finance (Uniswap) | `020214c160fc43339dd9833733791e6b` | $5,000 | Core |
| Synthesis Open Track | `fdb76d08812b43f6a5f454744b66f590` | $19,559 | Core |
| Autonomous Trading Agent (Base) | `bf374c2134344629aaadb5d6e639e840` | $5,000 | Core |
| Go Gasless (Status Network) | `877cd61516a14ad9a199bf48defec1c1` | $2,000 | Low |
| ~~Markee Github Integration~~ | ~~`54ee4ff8d9464d25b4a0d84b46a5c63d`~~ | ~~$2,000~~ | **SKIPPED** — OAuth scope too broad |

---

## Submission Payload

### description

```
An AI trading agent whose on-chain vault enforces human-set spending boundaries at the EVM level. The agent autonomously discovers market opportunities, evaluates risk through 8 pre-trade gates, and executes swaps via Uniswap V3 — but only within the boundaries the human guardian has set (max swap size, daily volume, token whitelist, slippage limits). Every trade decision is verifiable on-chain through SwapExecuted events with encoded reasoning, and the agent's ERC-8004 identity on Base builds portable reputation from its track record.

Built with Go, Solidity (ERC-4626 vault), Festival Methodology for autonomous task orchestration, and Uniswap Developer Platform API for trading.
```

### problemStatement

```
Autonomous trading agents need trust constraints that can't be bypassed. Current agent-wallet integrations are black boxes — no reasoning audit trail, no quality gates before irreversible actions, and no verifiable reputation. OBEY solves this with a vault that enforces spending boundaries at the contract level (the agent literally cannot exceed them), structured decision loops with 8 pre-trade risk gates, and ERC-8004 identity that accumulates verifiable on-chain reputation.
```

### submissionMetadata

```json
{
  "agentFramework": "other",
  "agentHarness": "other",
  "agentHarnessOther": "obey by obedience corp (custom Go runtime + fest CLI)",
  "model": "claude-opus-4-6",
  "skills": [
    "synthesis-hackathon-skill",
    "swap-integration"
  ],
  "tools": [
    "Go",
    "go-ethereum",
    "Foundry",
    "Uniswap Trading API",
    "Uniswap V3 Pools",
    "ERC-8004",
    "ERC-4626",
    "Hedera Consensus Service",
    "Claude API",
    "Festival Methodology (fest CLI)",
    "Base L2",
    "x402 Protocol"
  ],
  "helpfulResources": [
    "https://developers.uniswap.org/",
    "https://eips.ethereum.org/EIPS/eip-8004",
    "https://eips.ethereum.org/EIPS/eip-4626",
    "https://docs.hedera.com/hedera/sdks-and-apis/sdks/consensus-service"
  ],
  "intention": "continuing",
  "intentionNotes": "OBEY is an active project exploring autonomous agent economies with human-controlled boundaries. Post-hackathon: mainnet deployment, expanded strategy universe, multi-agent coordination via Hedera HCS.",
  "moltbookPostURL": ""
}
```

### conversationLog

Use the content from `/conversationLog.json` (already has 10 human-agent exchange entries).

---

## Existing Artifacts Ready for Submission

| Artifact | Location | Status |
|----------|----------|--------|
| `agent.json` | `/agent.json` | Done (update vault address to v2) |
| `agent_log.json` | `/projects/agent-defi/agent_log.json` | Done (1 testnet entry; add more) |
| `conversationLog.json` | `/conversationLog.json` | Done (10 entries) |
| Cook narrative | `/workflow/explore/synthesis/narrative-cook.md` | Done |
| Receipts narrative | `/workflow/explore/synthesis/narrative-receipts.md` | Done |
| Moltbook post | `/workflow/explore/synthesis/moltbook-post.md` | Done |
| DevSpot schema ref | `/workflow/explore/synthesis/devspot-schema.md` | Done |
| Design spec | `/workflow/design/synthesis/00-design-spec.md` | Done |
| README | `/projects/agent-defi/README.md` | Done (271 lines) |
| Deployment evidence | `/projects/contracts/deployments/base-sepolia.json` | Done (6 txs) |

---

## Pre-Submission TODO

### Must Do (blocks submission quality)

- [ ] **Update `agent.json` vault address** — currently references deprecated v1 vault (`0xa741...`), update to v2 (`0xbAbDd...06b1`)
- [ ] **Create draft project via API** — use payload above
- [ ] **Self-custody transfer** — required before publishing
- [ ] **Publish project** — makes it visible to judges
- [ ] **Add more `agent_log.json` entries** — only 1 entry currently; Protocol Labs wants 3+ showing full discover->plan->execute->verify loops
- [ ] **Verify Uniswap Trading API** — test API key against `trade-api.gateway.uniswap.org/v1`, document the integration

### Should Do (strengthens submission)

- [ ] **Status Network deploy** — deploy contract to Status Sepolia (chain ID 1660990954) + 1 gasless tx; guaranteed bounty
- [ ] **Record video demo** — 3 min, 6 checkpoints (boundaries, identity, festival, trading, verification, dashboard)
- [ ] **Post to Moltbook** — use prepared post from `workflow/explore/synthesis/moltbook-post.md`, add URL to `submissionMetadata.moltbookPostURL`

### Nice to Have (competitive edge)

- [ ] **Mainnet deployment** — deploy ObeyVault to Base mainnet + live trades (testnet accepted per bounty rules but mainnet is stronger)
- [ ] **More conversation log entries** — add entries from this session's debugging and deployment work
- [ ] **Dashboard deployed** — live URL for `deployedURL` field

---

## Track-Specific Requirements

### Protocol Labs "Let the Agent Cook" ($8K)

**Hard requirements:**
1. Full autonomous decision loop: discover -> plan -> execute -> verify
2. ERC-8004 identity with registration tx
3. `agent.json` manifest (DevSpot format)
4. `agent_log.json` with 3+ entries showing decisions, tool calls, retries, failures
5. Multi-tool orchestration (scores higher than single-tool)
6. Safety guardrails before irreversible actions
7. Compute budget awareness

**Our evidence:** Festival Methodology loop, 8-tool manifest, CRE risk gates, vault boundary enforcement

### Protocol Labs "Agents With Receipts" ($8K)

**Hard requirements:**
1. ERC-8004 identity interacting with registries via real on-chain txs
2. Autonomous agent architecture with planning/execution/verification loops
3. Agent identity + operator model (ERC-8004 linked to operator wallet)
4. On-chain verifiability (viewable on block explorer)
5. DevSpot compatibility (`agent.json` + `agent_log.json`)

**Our evidence:** ERC-8004 on Base Mainnet, SwapExecuted events with `reason` field, guardian/agent separation, structured `agent_log.json`

### Uniswap "Agentic Finance" ($5K)

**Hard requirements:**
1. Real Uniswap Developer Platform API key (not mocked)
2. Functional swaps with real TxIDs on **testnet or mainnet**
3. Public GitHub repo with README
4. No mocks

**Our evidence:** API key (`UNISWAP_API_KEY`), testnet swap tx (`0xafc1c6...a9d7`), `uniswap_api.go` client, public repo

**Bonus depth:** Hooks, AI Skills, Unichain, v4 contracts, Permit2

### Synthesis Open Track ($19.5K)

**Requirements:** Best overall project across all judges. Cross-sponsor integration, well-designed agent system.

**Our angle:** Unique combination of vault boundaries + festival methodology + ERC-8004 identity + multi-chain (Base + Hedera)

### Status Network ($2K, equal-share)

**Requirements:**
1. Deploy smart contract on Status Network Sepolia (chain ID: `1660990954`)
2. Execute 1 gasless transaction (gasPrice=0, gas=0)
3. AI agent component
4. README or short video demo

### ~~Markee ($2K, proportional)~~ — SKIPPED

OAuth requires full read/write access to all public and private repos. Not worth the risk.

---

## Execution Order

```
Day 1 (Mar 18 — TODAY):
  1. Create draft project via API
  2. Self-custody transfer
  3. Publish (get into judge feedback cycle)
  4. Update agent.json vault address

Day 2 (Mar 19):
  5. Generate 2-3 more agent_log.json entries (ritual runs or additional swaps)
  6. Verify Uniswap API key works against Trading API
  7. Status Network deploy + gasless tx

Day 3 (Mar 20):
  9. Record video demo (3 min)
  10. Post to Moltbook
  11. Update project with video URL + moltbook URL

Day 4 (Mar 21-22):
  12. Final project update with all artifacts
  13. Mainnet deployment if funds available
  14. Final publish verification
```

---

## Quick Reference Commands

```bash
# Set env
export SYNTH_API_KEY="sk-synth-6d5c471ccfdc067a2cb919680a13c38d01767ca5d817e442"
export TEAM_UUID="56a0c5c0aca54815a64992b661ef593f"

# Check team
curl -s https://synthesis.devfolio.co/teams/$TEAM_UUID \
  -H "Authorization: Bearer $SYNTH_API_KEY" | python3 -m json.tool

# Create project
curl -X POST https://synthesis.devfolio.co/projects \
  -H "Authorization: Bearer $SYNTH_API_KEY" \
  -H "Content-Type: application/json" \
  -d @docs/2026_requirements/synthesis/submission-payload.json

# Update project
curl -X POST https://synthesis.devfolio.co/projects/$PROJECT_UUID \
  -H "Authorization: Bearer $SYNTH_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"videoURL": "https://..."}'

# Self-custody init
curl -X POST https://synthesis.devfolio.co/participants/me/transfer/init \
  -H "Authorization: Bearer $SYNTH_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"targetOwnerAddress": "0xC71d8A19422C649fe9bdCbF3ffA536326c82b58b"}'

# Self-custody confirm (within 15 min)
curl -X POST https://synthesis.devfolio.co/participants/me/transfer/confirm \
  -H "Authorization: Bearer $SYNTH_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"transferToken": "<TOKEN>", "targetOwnerAddress": "0xC71d8A19422C649fe9bdCbF3ffA536326c82b58b"}'

# Publish
curl -X POST https://synthesis.devfolio.co/projects/$PROJECT_UUID/publish \
  -H "Authorization: Bearer $SYNTH_API_KEY"

# View project
curl -s https://synthesis.devfolio.co/projects/$PROJECT_UUID \
  -H "Authorization: Bearer $SYNTH_API_KEY" | python3 -m json.tool
```
