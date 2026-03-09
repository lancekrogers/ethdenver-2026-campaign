# 04 — Hackathon Bounties

## Description

Continue entering hackathons and ecosystem bounty programs using the existing codebase. The Obey Agent Economy already integrates Chainlink, Hedera, 0G, and Base — all of which run regular developer programs with cash prizes.

## What Exists Today

The codebase already covers multiple ecosystem tracks:

| Ecosystem | Integration | Bounty Evidence |
|-----------|-------------|-----------------|
| **Chainlink** | CRE Risk Router (WASM workflow + 8-gate pipeline), DON consensus receipts, on-chain contract at `0x9C7Aa5502ad229c80894E272Be6d697Fd02001d7` | Block Magic submission published on Moltbook |
| **Hedera** | Agent Coordinator with HCS messaging (topics `0.0.7999404`, `0.0.7999405`), HTS payments (AGNT token), Schedule Service heartbeats, Hiero Plugin with 5 templates | Hiero Plugin targets Track 4: Developer Tooling ($5k) |
| **0G** | Agent Inference — GPU provider discovery from `InferenceServing` contract on Galileo, DA anchoring, ERC-7857 iNFT minting with AES-256-GCM encryption | 0G integration across inference pipeline |
| **Base** | Agent DeFi — Uniswap V3 execution, x402 machine-to-machine payments, ERC-8004 identity, ERC-8021 builder attribution | Base Sepolia deployment |

## Capital Required

Zero.

Hackathon entry is free. All infrastructure runs on testnets. Submissions use existing code with incremental additions per hackathon requirements.

## Revenue Model

Prize money per submission:

| Source | Typical Range | Frequency |
|--------|--------------|-----------|
| Chainlink hackathons (Block Magic, etc.) | $500-$25,000 | 2-3x/year |
| Hedera developer bounties | $1,000-$10,000 | Ongoing |
| 0G ecosystem grants | $2,000-$15,000 | Quarterly |
| Base/Coinbase builder programs | $1,000-$10,000 | Ongoing |
| ETHGlobal / ETHDenver | $500-$50,000 | 2-4x/year |
| Devfolio / miscellaneous | $500-$5,000 | Frequent |

Conservative estimate: 1 win per quarter at $3,000 average = $12,000/year.
Optimistic estimate: 2 wins per quarter at $5,000 average = $40,000/year.

## Moat

- **Existing multi-chain codebase.** Most hackathon entries start from zero. We start with working infrastructure across 4 ecosystems.
- **On-chain evidence.** Contract deployments, broadcast transactions, and DON receipts are already on-chain — judges can verify.
- **Incremental effort.** Each new submission builds on the same core. A Hedera bounty submission can reuse the coordinator + HCS code with minimal additions.
- **Template system.** The Hiero Plugin's 5 templates mean new projects can be scaffolded quickly for ecosystem-specific requirements.

## Blockers

### Hard Blockers

1. **Time investment.** Each submission requires time for: reading requirements, adapting code, writing documentation, recording demos, and submitting. Even with existing code, a quality submission takes 1-3 focused days.

2. **Competition.** Hackathons are zero-sum. Other teams also have strong submissions. Win rate is realistically 10-25% per submission for top-tier prizes.

3. **Hackathon fatigue.** Judges see the same patterns. Submitting the same project repeatedly (even evolved) risks "seen it before" bias.

### Soft Blockers

4. **ETHDenver deadline miss.** The existing `monetization-exploration.md` notes that hackathon deadlines were missed. This signals a pattern risk — the codebase is complex enough that last-mile polish for submissions gets squeezed.

5. **Judging criteria variance.** Some hackathons favor novelty, others favor completeness, others favor live demos. Hard to optimize for all.

## Honest Assessment

This is the **lowest-risk, most immediately actionable** revenue path. The codebase is real, the integrations are real, and the incremental cost per submission is low.

The math works: if you submit to 8-10 bounties per year and win 2-3 at $3k-$10k each, that's $6k-$30k. Not life-changing, but it's real money for incremental effort on code that's already built.

The main risk is time allocation. Each submission that misses the deadline (as happened with ETHDenver) produces zero revenue. A hard policy of "quality freeze 24h before deadline, submit what's ready" would improve the hit rate.

The strategic benefit goes beyond prize money: each submission generates visibility, relationships with ecosystem teams, and feedback on what the market values.

**Verdict: Pursue actively. Maintain a submission calendar, apply to all relevant bounties, enforce strict deadlines. This is the most reliable near-term revenue with zero capital.**
