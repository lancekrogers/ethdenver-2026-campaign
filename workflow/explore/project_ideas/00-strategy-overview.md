# ETHDenver 2026 - Project Ideas Strategy Overview

## Bounty Landscape Summary

| Sponsor | Total Pool | Highest Single Prize | Competition Level |
|---------|-----------|---------------------|-------------------|
| **Hedera** | **$25,000** | $10,000 (Killer App) + 3 more tracks | Medium-High |
| **ZeroG (0G)** | $25,000 | $7,000/track ($5k+$2k), $4k tooling | Medium |
| **Kite/Bass (Base)** | $25,000 | $3,000 | High |
| **ADI Chain** | $25,000 | $3,000 | Medium-Low |
| **Canton Network** | $15,000 | $5,000 (1st place privacy) | Low |
| **Quicknote** | $2,000 | $1,000 | Low |
| **Track Prizes** | TBD | Per track | Varies |

## Project Ideas Ranked by Expected Value

### Tier 1: Highest Expected Value

| # | Project | Primary Bounty | Max Potential | Complexity |
|---|---------|---------------|---------------|------------|
| 06 | [Cross-Chain Agent Swarm](06-cross-chain-agent-swarm.md) | Multi-sponsor | **$22,250+** | Very High |
| 01 | [Hedera Agentic Commerce](01-hedera-agentic-commerce-network.md) | Hedera (all 4 tracks) | **$25,000** | Medium-High |
| 02 | [0G iNFT Agent Marketplace](02-zerog-inft-agent-marketplace.md) | 0G (2 tracks) | **$14,000** | High |

### Tier 2: Strong Value / Lower Risk

| # | Project | Primary Bounty | Max Potential | Complexity |
|---|---------|---------------|---------------|------------|
| 05 | [0G Fine-Tuning Marketplace](05-zerog-decentralized-fine-tuning.md) | 0G inference track | **$11,000** | High |
| 04 | [Canton Privacy Portfolio](04-canton-privacy-ai-portfolio.md) | Canton $5k 1st | **$5,000+** | Medium |
| 07 | [Canton Dev Tooling](07-canton-ai-dev-tooling.md) | Canton DevX $7k | **$7,000** | Medium |

### Tier 3: Supplementary / Lower Stakes

| # | Project | Primary Bounty | Max Potential | Complexity |
|---|---------|---------------|---------------|------------|
| 09 | [Base Security Agent](09-base-adversarial-security-agent.md) | Kite/Bass $3k + zkDepth | **$3,000+** | Medium |
| 03 | [Base DeFi Agent](03-base-autonomous-defi-agent.md) | Kite/Bass $3k | **$3,000+** | Medium |
| 08 | [ADI Creative Studio](08-adi-chain-ai-creative-studio.md) | ADI $3-6k | **$6,000** | Low-Medium |

> **Note**: #09 replaces #03 as the preferred Base submission. DeFi yield bots are saturated; a security agent is far more differentiated.

## Recommended Strategy

### Option A: "Hedera Sweep" (HIGHEST EXPECTED VALUE)
Build the Hedera Agentic Commerce Network (#01) targeting ALL 4 Hedera tracks from a single project. One project, $25k potential. Use native SDKs only (no Solidity), include HIP-1215 automation, ship a Hiero CLI plugin. Add Canton Dev Tooling (#07) as a secondary for $7k more. **Total potential: $32k.**

### Option B: "Cross-Chain Agent Swarm" (Aggressive)
Build the Cross-Chain Agent Swarm (#06) and submit chain-specific components to each sponsor bounty. This requires the most work but maximizes breadth at $22k+.

### Option C: "0G Deep Dive" (Focused)
Build the 0G iNFT Marketplace (#02) targeting two 0G tracks simultaneously ($14k), or the Fine-Tuning Marketplace (#05, $11k). 0G has novel tech (ERC-7857) that fewer teams will know. Add the Security Agent on Base (#09) as a secondary.

### Option D: "Quantity Play" (Diversified)
Build 2-3 simpler projects targeting different sponsors: Base Security Agent (#09) + Canton Privacy (#04) + ADI Creative (#08). Lower individual prizes but higher probability of winning something.

## Avoid Building These (Saturated/Table Stakes in 2026)

- **Basic yield optimization agents** - Hundreds exist. Unless architecture is genuinely novel, skip.
- **GPT-wrapper trading bots** - DeFAI space is saturated with these.
- **Token launchpads for agents** - Virtuals, arc.fun already dominate.
- **Generic agent frameworks** - ElizaOS, Virtuals GAME, OpenClaw exist. Don't build another.
- **AI-generated NFT art minting** - Was novel in 2024, not 2026.
- **Basic chatbot interfaces to DeFi** - Intent-based execution is shipping from major wallets already.

## Novel Gaps Worth Targeting

- **Adversarial agent defense** - Agents that find/defend against exploits (Anthropic SCONE-bench showed AI can exploit contracts for $1.22 each)
- **Cross-framework agent interop** - ElizaOS/Virtuals/OpenClaw agents can't talk to each other
- **Agent liability/insurance** - No protocol for insuring autonomous agent actions
- **Privacy-preserving agent memory** - ZK proofs for agent state (prove what you know without revealing it)
- **Composable agent "organs"** - npm-style marketplace for agent cognitive modules
- **Agent debugging/observability** - "Datadog for on-chain AI agents" doesn't exist
- **Human-agent labor coordination** - OpenClaw/Moltbook pattern at protocol level

## Transcript Corrections

The bounty reveal transcript had garbled audio. Corrected names:

| Transcript | Actual | Notes |
|-----------|--------|-------|
| "Hideira" | **Hedera** | Hashgraph network |
| "Kanto Network" | **Canton Network** | Digital Asset's privacy blockchain |
| "ERC-821" | **ERC-8021** | Builder Codes (onchain attribution) |
| "X42" | **x402** | HTTP-native payment protocol |
| "EIP-8004" | **ERC-8004** | Trustless Agents standard (correct) |
| "Biddathon" | **BUIDLathon** | ETHDenver hackathon |
| "Biddub" | **BUIDL Hub** | Venue name |

## Key Insights

1. **AI agents are the dominant theme** - every bounty either requires or rewards AI agent integration
2. **OpenClaw is the runtime** - Hedera's $10k bounty explicitly requires it, and it's the viral framework of early 2026
3. **Self-sustaining agents** are the Base/Kite/Bass requirement - agents that earn their own revenue
4. **ERC-8004 + x402 + ERC-8021** is the Base stack: identity + payments + attribution
5. **0G's ERC-7857** is a unique primitive no other chain has - strong differentiator for iNFT agents
6. **Canton has lowest competition** - Daml barrier means fewer teams will build there
7. **Multi-chain is the narrative** - judges love ambitious cross-chain stories
8. **Public dashboard is mandatory** - every bounty requires a user-facing interface
9. **UCP (Universal Commerce Protocol)** - Google's agentic commerce standard, bonus points on Hedera bounty
