# Festival Overview: synthesis-submission

## Problem Statement

**Current State:** OBEY's infrastructure (ObeyVault, agent-defi, festival methodology, ERC-8004) is fully built and deployed to testnets. However, the Synthesis hackathon requires specific submission artifacts (agent.json, agent_log.json, conversationLog), mainnet deployments, and API submissions to qualify for bounties.

**Desired State:** All required artifacts generated, mainnet deployments live, and submissions sent to Protocol Labs (both tracks), Uniswap, Status Network, Markee, and the Open Track.

**Why This Matters:** ~$50K in bounty exposure across 6+ tracks. The infrastructure exists — this festival is about packaging and presenting it correctly.

## Scope

### In Scope

- Protocol Labs artifact generation (agent.json, agent_log.json in DevSpot format)
- Verify Uniswap Developer Platform API integration path
- Base mainnet vault deployment + live trades
- Status Network Sepolia deployment + gasless tx
- Markee GitHub integration on festival repo
- Repo cleanup + make public
- Video demo production
- Submission API calls to all target tracks
- ConversationLog capture throughout

### Out of Scope

- New agent features or contract modifications
- MetaMask Delegation integration (stretch — separate festival if time permits)
- Locus integration (stretch — separate festival if time permits)
- ERC-8183 research (stretch — separate festival if time permits)
- Changes to ObeyVault contract logic
- Changes to trading strategy

## Planned Phases

### 001_IMPLEMENT

All submission work in a single phase with ordered sequences. Sequences are ordered by dependency and priority:

1. **Verify Uniswap API** — go/no-go on Uniswap bounty (blocks mainnet deployment)
2. **Protocol Labs artifacts** — agent.json + agent_log.json (blocks submission)
3. **Mainnet deployment** — source USDC, deploy vault, live trades (blocks demo)
4. **Low-effort bounties** — Status Network + Markee (independent, no blockers)
5. **Repo cleanup** — remove secrets, make public (blocks Uniswap submission)
6. **Submission packaging** — video, conversationLog, Moltbook, API submissions

## Notes

- Design spec: `workflow/explore/synthesis/00-project-design.md`
- Prize catalog: `docs/2026_requirements/synthesis/prize-catalog.md`
- Bounty details: `docs/2026_requirements/synthesis/bounties-agents-optimized.txt`
- Synthesis API key: stored in memory (reference_synthesis_hackathon.md)
- Existing ObeyVault deployment: Base Sepolia `0xa7412780435905728260d5eaA59786e4a3C07e7E`
