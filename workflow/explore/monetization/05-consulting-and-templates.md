# 05 — Consulting and Templates

## Description

Package the Obey Agent Economy architecture as consulting deliverables and paid project templates. The Hiero Plugin already ships 5 templates. The multi-chain agent architecture (CRE risk gates + HCS orchestration + x402 payments + 0G inference) is genuinely novel and hard to replicate from scratch.

## What Exists Today

### Templates (Ready to Ship)

The Hiero Plugin (`projects/hiero-plugin/`) provides 5 project templates via `hcli camp init`:

| Template | What It Scaffolds |
|----------|-------------------|
| `hedera-smart-contract` | Hardhat + Hedera testnet JSON-RPC config |
| `hedera-dapp` | Vite + React + HashConnect wallet integration |
| `hedera-agent` | Go agent with HCS messaging + HTS token ops |
| `0g-agent` | Go agent with 0G Compute inference + session auth + DA |
| `0g-inft-build` | ERC-7857 iNFT minting with encrypted metadata on 0G Chain |

These are tested (37 passing tests) and functional.

### Consulting Assets (Deployable as Engagement Materials)

- **CRE Risk Router** — auditable pre-trade risk evaluation with on-chain receipts
- **Agent Coordinator** — multi-agent task dispatch with HCS audit trails and quality gates
- **Smart Contracts** — AgentSettlement (single + batch + scheduled), ReputationDecay (time-linear), AgentINFT (ERC-7857)
- **Dashboard** — 6-panel operational visibility (festival, HCS, CRE, agents, P&L, inference)
- **x402 integration** — working machine-to-machine payment protocol implementation
- **Docker Compose** — full service topology for local deployment

## Capital Required

Zero for templates. Near zero for consulting (domain, basic site, maybe a Calendly pro account).

| Item | Cost |
|------|------|
| Template distribution | $0 (npm publish or GitHub) |
| Consulting website | $0-20/mo |
| Demo infrastructure | $5-20/mo (VPS for live demo) |

## Revenue Model

### Templates

| Model | Price | Notes |
|-------|-------|-------|
| Free + premium | $0 / $29-99 | Basic templates free, advanced (multi-agent, x402) paid |
| GitHub Sponsors | $5-50/mo | Sponsor tiers with template access |
| Marketplace | $49-199 per template | Sell on Gumroad, Lemon Squeezy, or npm premium |

Template revenue is typically low volume: $100-500/month unless you hit a niche with real demand.

### Consulting

| Engagement | Price | Scope |
|------------|-------|-------|
| Risk controls integration | $8k-$25k | Integrate CRE risk gates into client's agent system |
| Agent reliability audit | $3k-$12k | Architecture review, failure-mode testing, incident runbook |
| Custom MVP build | $15k-$50k | 2-4 week agent system using our modules |
| Workflow enablement | $2k-$10k | Install festival methodology + delivery operating model |

(Pricing from existing `monetization-exploration.md`, validated against market rates for crypto consulting.)

## Moat

- **Multi-chain integration depth.** Most agent frameworks are single-chain or chain-agnostic abstractions. This codebase has deep, working integrations with Chainlink CRE, Hedera HCS/HTS, 0G Compute/DA, and Base/Uniswap. Hard to replicate.
- **On-chain evidence.** Deployed contracts, broadcast transactions, and DON receipts prove the system works. Not slides, not diagrams — on-chain state.
- **Production patterns.** Quality gates, fail-closed risk checks, audit trails, position constraints — these are patterns from production trading systems applied to agents. Most hackathon code doesn't have this.
- **Template ecosystem.** 5 working templates that scaffold real projects, not toy examples.

## Blockers

### Hard Blockers

1. **Finding clients.** The biggest blocker is distribution. "Build it and they will come" doesn't work for consulting. Need active outreach, content marketing, or ecosystem partnerships.

2. **Solo capacity.** Consulting is time-bounded by the consultant's availability. One person can serve 1-2 concurrent clients. Revenue caps at $15k-30k/month without subcontractors.

3. **Template market size.** The market for "Hedera + 0G + Chainlink agent templates" is extremely niche. The template revenue model depends on volume that may not exist.

### Soft Blockers

4. **Credibility without track record.** First-time consulting clients want references. The hackathon work is strong proof-of-capability but isn't a client engagement.

5. **Pricing validation.** The $8k-$25k range for risk controls integration is a hypothesis. The actual willingness-to-pay is unknown until tested with real prospects.

6. **Scope creep.** Agent systems are complex. Fixed-price engagements risk expanding beyond the agreed scope as clients discover edge cases.

## Honest Assessment

Consulting is the **most proven path to revenue** from technical expertise. The existing codebase is a strong portfolio — far beyond what most crypto consultants can show. The templates are a nice supplement but won't generate meaningful revenue alone.

The key challenge is distribution. The `monetization-exploration.md` outlines a 30-day validation plan (40 targets, 8 discovery calls, 2 paid discoveries). This is the right approach. The question is whether Lance wants to spend time selling vs. building.

Templates should be released for free (or nearly free) as marketing for consulting. They generate inbound leads from developers who try the templates, hit limitations, and need custom work.

**Verdict: Highest-probability revenue path. The codebase is real, the skill set is real, the market exists. Bottleneck is sales effort, not product readiness.**
