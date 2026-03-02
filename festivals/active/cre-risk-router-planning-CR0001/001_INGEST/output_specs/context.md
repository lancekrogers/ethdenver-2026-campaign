# Context

## Existing System: Obey Agent Economy

A multi-chain autonomous AI agent system built for ETHDenver 2026. This is the context the CRE Risk Router plugs into.

### Agents (Go)

| Agent | Chain | Purpose |
|---|---|---|
| agent-coordinator | Hedera (HCS) | Task orchestration, agent coordination via consensus messaging |
| agent-inference | 0G | AI inference on decentralized GPU, generates trading signals |
| agent-defi | Base Sepolia | DeFi strategy execution, token swaps |

### Contracts (Solidity/Foundry)

- `AgentSettlement.sol` — Task settlement and payment
- `ReputationDecay.sol` — Agent reputation scoring
- `AgentINFT.sol` — Agent identity NFTs

### Other Components

- **Dashboard** — Next.js frontend showing agent activity
- **hiero-plugin** — TypeScript plugin for Hedera HCS integration

## Design History

The CRE Risk Router concept went through multiple design iterations:

1. **Codex design** (`workflow/design/chainlink/codex/`) — Strong concept, flawed execution plan. Treated CRE as a CLI wrapper, targeted wrong network, spread scope across 5 repos. Scored 6.3/10.

2. **Claude design** (`workflow/design/chainlink/claude/`) — 7 documents correcting Codex's approach. Established standalone CRE workflow model, correct testnet targeting, P0/P1/P2 priority stack.

3. **Consolidated spec** (`workflow/design/cre-risk-router/spec.md`) — Merged both designs into a single implementation spec. Went through 3 rounds of cross-agent review (agent-thread.md) resolving:
   - Oracle health validation (full `latestRoundData()` tuple)
   - Position sizing safety (abs + clamp)
   - Price precision consistency (8 decimals throughout)
   - CoinGecko fallback behavior for Gates 5 and 6
   - `MaxPositionBps` cap enforcement in Gate 6
   - Gate 8 configurability for clean-clone simulation
   - Integration evidence framing ("integration path proof" not "live integrated run")

4. **Idea exploration** (`workflow/explore/chainlink/idea-exploration.md`) — 6 alternative ideas evaluated. Risk Router scored highest on impact/feasibility/differentiation.

## Key References

| Resource | Location |
|---|---|
| Hackathon requirements | `docs/2026_requirements/moltbook/chainlink/clink-converge-hackathon.md` |
| Final spec (source of truth) | `workflow/design/cre-risk-router/spec.md` |
| Agent thread (review history) | `workflow/design/cre-risk-router/agent-thread.md` |
| Codex design (reference) | `workflow/design/chainlink/codex/` |
| Claude design (detailed) | `workflow/design/chainlink/claude/` |
| Idea exploration | `workflow/explore/chainlink/idea-exploration.md` |
| CRE hackathon skills repo | `github.com/smartcontractkit/chainlink-agents-hackathon-skills` |
| CRE skills repo | `github.com/smartcontractkit/chainlink-agent-skills/cre-skills` |
| Registration form | `https://forms.gle/xk1PcnRmky2k7yDF7` |

## Prior Art / Competitive Landscape

Most hackathon submissions will be isolated CRE workflows that:
- Fetch one data source
- Apply 1-2 if-statements
- Write a result on-chain
- Show only happy-path scenarios

Our advantages:
- 8 risk gates with production-level logic
- Denied scenarios as first-class outcomes
- Real agent economy context (3 agents, 4 chains)
- 5 CRE capabilities exercised
- Graceful degradation under data unavailability
