# OBEY — Verifiable Agent Autonomy

## Design Spec for Synthesis Hackathon Submission

**Date**: 2026-03-16
**Author**: Lance Rogers + Obey Agent
**Status**: Draft (post-review revision)

---

## 1. Problem Statement

### How do I trust an AI agent with my money?

Today's agent-wallet integrations are black boxes. You can see on-chain *what* happened but never *why*. There is no structured audit trail of agent reasoning, no quality gates before irreversible financial actions, and no way to build verifiable reputation across agents.

**Who feels this pain:**

- **DeFi users** giving bots wallet access — millions in TVL managed by agents with zero decision transparency
- **DAOs** evaluating whether to delegate treasury management to autonomous agents
- **Agent marketplaces** needing trust signals before hiring an agent for a task
- **Compliance teams** who will eventually require auditable AI decision-making in finance
- **Developers** building agent systems with no framework for structured autonomous execution

**Why existing solutions fail:**

| Current Approach | Problem |
|-----------------|---------|
| Trading bots with wallet keys | No spending boundaries — agent has full access to principal |
| Multisig + manual approval | Defeats autonomy — human bottleneck on every action |
| Transaction logs on-chain | Shows *what* happened, not *why* — no decision audit trail |
| API rate limits | Coarse controls — can't express "only trade whitelisted tokens under $1K per swap" |
| Agent reputation (off-chain) | Self-reported, unverifiable, no consequence for bad behavior |

---

## 2. Solution: OBEY

OBEY is an autonomous agent treasury system with verifiable decision orchestration.

Three core innovations:

### 2.1 Human-Controlled Boundaries (ObeyVault)

An ERC-4626 vault where humans deposit USDC and set enforceable spending boundaries at the contract level. The agent can trade but **never touch principal** beyond what boundaries allow.

- Guardian controls: token whitelist, max swap size, daily volume cap, slippage limits, pause
- Agent controls: `executeSwap()` only — cannot transfer, modify limits, or bypass guards
- NAV via Uniswap V3 TWAP oracle (30-minute window, manipulation-resistant)
- All swaps emit `SwapExecuted(tokenIn, tokenOut, amountIn, amountOut, reason)` — rationale stored on-chain

### 2.2 Verifiable Decision Framework (Festival Methodology)

Every agent decision follows a structured, auditable loop powered by the Festival Methodology:

```
DISCOVER → PLAN → EXECUTE → VERIFY → REPORT
```

This isn't just logging — it's a hierarchical planning system where:
- **Phases** define major stages of work
- **Sequences** group related tasks with dependencies
- **Tasks** are atomic work items with acceptance criteria
- **Quality gates** enforce testing/review/iteration before progression
- Every step produces structured artifacts (agent_log.json) — not just text logs

The Festival Methodology was purpose-built for human-AI collaboration. It operates on steps-to-completion rather than time estimates, enables parallel agent execution via interface-first design, and enforces quality gates at every sequence boundary.

### 2.3 Earned Reputation (ERC-8004 Identity)

Agents register on-chain identity via ERC-8004. Every vault operation, every festival execution, every verified outcome builds a **portable, verifiable track record** that other agents and humans can evaluate before extending trust.

---

## 3. Architecture

```
Human (Guardian)
  │
  ├── Deposits USDC into ObeyVault
  ├── Sets boundaries: whitelist, maxSwap, dailyCap, slippage
  ├── Reviews festival plans before agent executes
  └── Can pause() at any time — human always has kill switch
  │
  ▼
Festival Orchestrator
  │
  ├── Phase: DISCOVER
  │   └── Agent scans market conditions, identifies opportunities
  │
  ├── Phase: PLAN
  │   └── Agent proposes trades with rationale
  │   └── CRE Risk Router: 8-gate evaluation pipeline
  │       ├── Signal confidence threshold (≥0.6)
  │       ├── Risk score ceiling (≤75)
  │       ├── Signal staleness (≤300s TTL)
  │       ├── Oracle health check
  │       ├── Price deviation check (≤500 BPS)
  │       ├── Position sizing (volatility + risk scaling)
  │       ├── Hold signal filter
  │       └── Heartbeat breaker (liveness check)
  │
  ├── Phase: EXECUTE
  │   └── vault.executeSwap() — contract enforces all boundaries
  │   └── Uniswap V3 SwapRouter02 on Base
  │
  ├── Phase: VERIFY
  │   └── Compare outcome vs plan
  │   └── Update agent_log.json with structured results
  │
  └── All phases emit structured events
      └── agent.json (manifest) + agent_log.json (execution log)
  │
  ▼
ObeyVault (ERC-4626 on Base)
  │
  ├── Contract-level boundary enforcement
  ├── SwapExecuted events with encoded rationale
  ├── Share token (oVAULT) for depositors
  └── NAV = USDC balance + TWAP(held tokens)
  │
  ▼
ERC-8004 Identity Registry (Base)
  │
  ├── Agent identity registered on-chain
  ├── Trade history = verifiable track record
  └── Portable reputation across platforms
```

---

## 4. Existing Infrastructure (Built, Tested, Deployed)

| Component | Status | Location | Chain |
|-----------|--------|----------|-------|
| **ObeyVault.sol** (ERC-4626) | Deployed, 15 Foundry tests passing | `projects/contracts/src/ObeyVault.sol` | Base Sepolia |
| **Go trading agent** | Built, 10 Go tests passing | `projects/agent-defi/` | Base Sepolia |
| **ERC-8004 identity registry** | Deployed + registered | `0x0C97820abBdD2562645DaE92D35eD581266CCe70` | Base Sepolia |
| **Uniswap V3 integration** | Working (SwapRouter02) | Vault executeSwap() | Base Sepolia |
| **CRE Risk Router** | 8-gate pipeline, on-chain receipts | `projects/cre-risk-router/` | Ethereum Sepolia |
| **Agent Coordinator** | HCS/HTS orchestration | `projects/agent-coordinator/` | Hedera Testnet |
| **Agent Inference** | 0G Compute/Storage/Chain/DA | `projects/agent-inference/` | 0G Galileo |
| **Dashboard** | 6-panel observer UI | `projects/dashboard/` | N/A |
| **Festival Methodology** | Complete framework + CLI (`fest`) | `festivals/` + `fest` CLI | N/A |
| **Camp CLI** | Campaign workspace management | `camp` CLI | N/A |
| **Smart contracts** (4 systems) | Deployed across chains | `projects/contracts/` | 0G, Base, Eth Sepolia |
| **On-chain evidence** | 80+ verified transactions | Multiple explorers | 4 chains |
| **Completed festivals** | 6 festivals (dungeon/completed) | `festivals/dungeon/completed/` | N/A |

### Key Deployed Addresses

| Contract | Chain | Address |
|----------|-------|---------|
| ObeyVault | Base Sepolia | `0xa7412780435905728260d5eaA59786e4a3C07e7E` |
| AgentIdentityRegistry (ERC-8004) | Base Sepolia | `0x0C97820abBdD2562645DaE92D35eD581266CCe70` |
| AgentSettlement | Base Sepolia | `0xa5378FbDCD2799C549A559C1C7c1F91D7C983A44` |
| ReputationDecay | Base Sepolia | `0x54734cC3AF4Db984cD827f967BaF6C64DEAEd0B1` |
| AgentINFT (ERC-7857) | Base Sepolia | `0xfcA344515D72a05232DF168C1eA13Be22383cCB6` |
| RiskDecisionReceipt | Ethereum Sepolia | `0x9C7Aa5502ad229c80894E272Be6d697Fd02001d7` |

---

## 5. Bounty Targeting Strategy

### Tier 1 — Primary Targets (Must Submit)

#### Protocol Labs "Let the Agent Cook" — $8,000

**Why we win:** Festival methodology IS the autonomous loop they're judging.

| Requirement | How OBEY Satisfies |
|-------------|-------------------|
| Full autonomous loop (discover→plan→execute→verify→submit) | Festival phases map 1:1 to this loop |
| ERC-8004 identity linked to operator wallet | Already deployed on Base Sepolia |
| agent.json manifest | Generate from existing agent config |
| agent_log.json execution log | Format festival completion events |
| Real tool/API use | Uniswap V3 swaps, CRE risk evaluation |
| Multi-tool orchestration | Vault + Uniswap + CRE + ERC-8004 |
| Safety guardrails | 8-gate CRE pipeline + vault contract boundaries |
| Compute budget awareness | Festival tracks task completion efficiency |

**Bonus signals:** Multi-agent swarms (coordinator + inference + DeFi agents)

#### Protocol Labs "Agents With Receipts" — $8,004

**Why we win:** Every decision has an on-chain receipt.

| Requirement | How OBEY Satisfies |
|-------------|-------------------|
| ERC-8004 integration via real on-chain transactions | Identity registered, vault events linked |
| Autonomous system architecture | Festival-driven orchestration with 3 specialized agents |
| Agent identity + operator model | Guardian (human) / Agent separation in vault |
| On-chain verifiability | SwapExecuted events + ERC-8004 registration tx |
| DevSpot compatibility (agent.json, agent_log.json) | Generate from festival execution data |

#### Uniswap "Agentic Finance" — $5,000

**Why we win:** Hard requirements already met.

| Hard Requirement | Status |
|-----------------|--------|
| Real Developer Platform API key | Have it (trade-api.gateway.uniswap.org) |
| Functional swaps | ObeyVault.executeSwap() via SwapRouter02 |
| Real TxIDs on testnet or mainnet | Sepolia txns exist; mainnet planned |
| Open-source public GitHub with README | Will be public by deadline |
| No mocks | All real on-chain execution |

**Bonus depth:** Uniswap V3 TWAP oracle for vault NAV pricing.

#### Synthesis Open Track — $19,559

**Why we win:** Meta-agent evaluates cross-sponsor merit. OBEY touches Protocol Labs (autonomy), Uniswap (agentic finance), ERC-8004 (identity), and festival orchestration — exactly what "well-designed agent systems with cross-sponsor compatibility" rewards.

**No additional work needed.** Submit to this track alongside sponsor tracks.

### Tier 2 — Low-Effort Add-Ons

#### Status Network — $50 guaranteed (up to $2,000)

**What's needed:** Deploy any smart contract to Status Network Sepolia + execute 1 gasless transaction + include agent component + README or short video.

**Why it's free money:** Qualification-based bounty with equal-share distribution. Deploy a minimal contract, execute 1 tx, document it. ~30 minutes of work for guaranteed payout.

**Implementation:**
1. Deploy a simplified vault or identity contract to Status Sepolia
2. Execute one gasless transaction (Status Network gas = 0 at protocol level)
3. Include tx hash proof in submission
4. Reference OBEY agent as the AI component
5. Include short README

#### Markee Github Integration — $800 (proportional)

**What's needed:** Grant OAuth via Markee app, add Markee delimiter text to a markdown file in the obey-agent-economy repo, appear as "Live" on Markee integrations page.

**Why it's free money:** Proportional payout based on unique views and funds added to your Markee message. No subjective judging — pure math. Only disqualified if <10 unique views AND no funds added. A genuine, active repo like obey-agent-economy should easily clear the view threshold once public.

**Implementation:**
1. Use `claude-code-go` repo (36 stars, existing organic traffic) — higher view potential than freshly-public hackathon repo
2. Grant OAuth permissions via Markee app (https://www.markee.xyz)
3. Add Markee delimiter text to README.md or a visible markdown file
4. Verify "Live" status on Markee GitHub integrations page
5. Done — payout is automatic based on metrics

**Estimated effort:** 15 minutes

**No dependency on repo cleanup** — claude-code-go is already public

### Tier 3 — Stretch Targets

#### MetaMask "Best Use of Delegations" — $5,000

**Alignment:** The ObeyVault's guardian→agent permission model maps to the MetaMask Delegation Framework, but a thin wrapper is NOT enough. The bounty explicitly states: *"Standard patterns without meaningful innovation will not place."*

**Innovation angle — Hierarchical Sub-Delegation for Multi-Agent Treasuries:**

The novel contribution is **sub-delegation chains**: a human delegates vault authority to a coordinator agent, which sub-delegates scoped subsets to specialized trading agents. Each level narrows the permission scope.

```
Human (Guardian)
  └─ Delegation: "trade USDC/WETH, max $1000/day, 90-day expiry"
       └─ Coordinator Agent
            ├─ Sub-delegation: "buy WETH only, max $200/swap"
            │    └─ Mean Reversion Agent
            └─ Sub-delegation: "sell WETH only, max $500/swap"
                 └─ Momentum Agent
```

**Implementation approach:**
1. Build custom ERC-7715 caveats for financial guardrails (token whitelist, size limits, volume caps)
2. Implement sub-delegation: coordinator delegates narrower authority to specialized agents
3. Each agent redeems its delegation when calling `vault.executeSwap()`
4. Delegation chain is verifiable on-chain — judges can trace the permission hierarchy

**Estimated effort:** 6-8 hours (custom caveats + sub-delegation logic + integration tests)

**Go/no-go decision:** Research MetaMask Delegation Framework SDK first (2 hours). If custom caveats are well-documented, proceed. If the SDK is immature or poorly documented, drop this bounty.

#### Locus "Best Use of Locus" — $3,000

**Alignment:** Locus provides agent payment infrastructure on Base using USDC — same chain and base asset as ObeyVault.

**WARNING:** Bounty has automatic disqualification for projects without a working Locus integration. Integration must be deep, not bolted on.

**Implementation approach — Locus as the agent's operational wallet:**
1. Agent's non-vault expenses (API calls, market data, inference) flow through Locus wallet
2. Locus spending controls provide defense-in-depth alongside vault-level controls
3. Locus pay-per-use for external services = agent operational costs are auditable
4. Locus auditability layered with festival execution logs = complete financial picture

**Requirements from bounty:**
- Working Locus integration (core to product, not bolt-on)
- Base chain + USDC only (matches ObeyVault exactly)
- Autonomous payment flows + spending controls + auditability

**Estimated effort:** 4-5 hours (Locus SDK integration + agent wallet setup + testing + docs)

**Go/no-go decision:** Research Locus SDK documentation first (1 hour). If SDK is mature and Base USDC integration is straightforward, proceed.

#### ERC-8183 Open Build (Virtuals) — $2,000

**STATUS: REQUIRES RESEARCH BEFORE COMMITTING**

ERC-8183 is a new standard. Before committing any effort, we need to understand what it specifies and whether OBEY's existing infrastructure has natural overlap. The bounty requires "meaningful, substantive integration" that is "architecturally significant" — no shallow wrappers.

**Decision point:** Research ERC-8183 spec within the first hour of stretch work. If natural fit exists, budget 3-4 hours. If not, drop entirely.

**Estimated effort:** 1 hour research + 3-4 hours implementation IF feasible

---

## 6. Bounty Payout Summary

| Bounty | Prize | Probability | Expected Value | Tier |
|--------|-------|-------------|----------------|------|
| Protocol Labs "Let the Agent Cook" | $8,000 | High | $2,500-4,000 | 1 |
| Protocol Labs "Agents With Receipts" | $8,004 | High | $2,500-4,000 | 1 |
| Uniswap "Agentic Finance" | $5,000 | Medium | $1,500-2,500 | 1 |
| Synthesis Open Track | $19,558.96 | Medium | $2,000-5,000 | 1 |
| Status Network | $50-2,000 | Guaranteed | $50-100 | 2 |
| Markee Github Integration | $800 | High (proportional) | $20-100 | 2 |
| MetaMask Delegations | $5,000 | Medium (if built) | $1,500-2,500 | 3 |
| Locus | $3,000 | Medium (if built) | $1,000-1,500 | 3 |
| ERC-8183 (Virtuals) | $2,000 | Low (needs research) | $0-500 | 3 |
| **TOTAL EXPOSURE** | **$50,562.96** | | **$11,050-20,100** | |

**Conservative floor (Tier 1 + Status only):** ~$5,000-10,000
**With stretch targets:** ~$11,000-20,000

*Note: Expected values are conservative. Protocol Labs bounties have multiple placement tiers ($4K/$2.5K/$1.5K and $4K/$3K/$1K respectively), so even 2nd or 3rd place pays well.*

---

## 7. New Work Required

### Must-Have (Tier 1 + Tier 2)

| Task | Description | Effort |
|------|-------------|--------|
| **Verify Uniswap API integration** | CRITICAL: Confirm agent swap flow routes through Uniswap Developer Platform API for quoting/routing, not just direct SwapRouter02 calls. The bounty requires "Uniswap API with a real API key." The agent already uses `trade-api.gateway.uniswap.org` for quotes — verify this is the correct integration path and document it clearly. | 1-2 hours |
| **agent.json manifest** | Machine-readable manifest: agent name, operator wallet, ERC-8004 identity, supported tools, tech stack, compute constraints, task categories. Research DevSpot schema requirements first. | 1-2 hours |
| **agent_log.json formatter** | Transform festival task completion events into Protocol Labs' required execution log format. Map: decisions, tool calls, retries, failures, final outputs. Must match DevSpot schema. | 3-4 hours |
| **Differentiate PL submissions** | Write distinct narratives: "Let the Agent Cook" = autonomy + multi-tool orchestration story. "Agents With Receipts" = identity + trust + reputation story. Same project, different emphasis. | 1 hour |
| **Base mainnet vault deployment** | Deploy ObeyVault to Base mainnet, fund with USDC (source USDC + ETH for gas first), approve WETH. Budget time for token bridging. | 2 hours |
| **Live trading demo** | Execute 2-3 real Uniswap trades on Base mainnet via vault | 1 hour |
| **Status Network deployment** | Deploy minimal contract to Status Sepolia + 1 gasless tx + tx hash proof | 30 min |
| **Repo cleanup + make public** | Remove secrets, API keys, private submodule refs. Audit all .env files, gitignore patterns. Multi-project workspace with submodules across 4 chains — this is not trivial. | 2-3 hours |
| **ConversationLog capture** | Begin capturing human-agent collaboration log NOW. Determine expected format from submission API. This cannot be fabricated at the end. | Ongoing (start immediately) |
| **Submission packaging** | Video demo (script + rehearse + record), Moltbook post, submission API calls per track. Budget for re-takes. | 3-4 hours |

**Total must-have: ~16-20 hours**

### Stretch (Tier 3)

| Task | Description | Effort |
|------|-------------|--------|
| **MetaMask delegation research** | Research Delegation Framework SDK. Go/no-go decision. | 2 hours |
| **MetaMask delegation implementation** | Custom ERC-7715 caveats + sub-delegation chains (if go) | 6-8 hours |
| **Locus SDK research** | Research Locus SDK docs. Go/no-go decision. | 1 hour |
| **Locus integration** | Locus wallet as agent operational wallet (if go) | 4-5 hours |
| **ERC-8183 research** | Understand spec, evaluate natural overlap | 1 hour |
| **ERC-8183 implementation** | Build integration (if feasible) | 3-4 hours |

**Total stretch (all): ~17-21 hours**
**Total stretch (realistic — pick 1-2): ~8-12 hours**

**Grand total: ~24-32 hours of new work**

---

## 8. Demo Script

### What Judges See (6-checkpoint demo, ~3 minutes)

**Checkpoint 1: Human Sets Boundaries**
- Guardian deposits 100 USDC into ObeyVault
- Sets maxSwapSize: 25 USDC, maxDailyVolume: 100 USDC, maxSlippageBps: 100
- Approves WETH as tradeable token
- Show: Basescan contract interaction txns

**Checkpoint 2: Agent Registers Identity**
- Agent registers ERC-8004 identity on Base
- Show: AgentRegistered event on Basescan
- Show: agent.json manifest (capabilities, tools, constraints)

**Checkpoint 3: Festival Plan Loads**
- Agent shows structured decision framework
- Phases: DISCOVER → PLAN → EXECUTE → VERIFY
- Quality gates between each phase
- Show: festival hierarchy in terminal (fest CLI output)

**Checkpoint 4: Autonomous Trading Loop**
- Agent discovers: WETH price deviated -2.3% from 30-period MA
- Agent plans: Buy 20 USDC worth of WETH, confidence 0.72
- CRE risk gates: All 8 gates pass (show gate-by-gate evaluation)
- Vault enforces: whitelist ✓, size ≤ max ✓, volume ≤ daily ✓, slippage ≤ max ✓
- Execute: Real Uniswap V3 swap, real TxID
- Show: SwapExecuted event with encoded rationale

**Checkpoint 5: Verification + Reputation**
- Agent compares: actual fill vs expected, slippage vs limit
- agent_log.json updated with structured results
- ERC-8004 identity now has verifiable trade in its history
- Show: agent_log.json entry for this trade

**Checkpoint 6: Dashboard Overview**
- Dashboard shows full audit trail across all panels
- Festival progress: phase completion, quality gate status
- DeFi P&L: revenue, costs, net, trade history with tx hashes
- Agent activity: heartbeat, current task, uptime

---

## 9. Submission Metadata

```json
{
  "name": "OBEY — Verifiable Agent Autonomy",
  "description": "Autonomous agent treasury with human-controlled boundaries and verifiable decision orchestration via Festival Methodology",
  "problemStatement": "AI agents managing money operate as black boxes — no structured audit trail of reasoning, no enforceable spending boundaries at the contract level, and no way to build verifiable reputation. OBEY solves this with an ERC-4626 vault enforcing guardian-set boundaries, Festival Methodology structuring every decision into auditable phases, and ERC-8004 identity building portable reputation.",
  "repoURL": "https://github.com/obedience-corp/obey-agent-economy",
  "tracks": [
    "Protocol Labs — Let the Agent Cook",
    "Protocol Labs — Agents With Receipts",
    "Uniswap — Agentic Finance",
    "Synthesis Open Track",
    "Status Network — Go Gasless",
    "MetaMask — Best Use of Delegations",
    "Locus — Best Use of Locus"
  ],
  "submissionMetadata": {
    "agentHarness": "obey by obedience corp",
    "model": "claude-opus-4-6",
    "skills": ["festival-methodology", "camp-workspace-management", "cre-risk-evaluation"],
    "tools": ["fest CLI", "camp CLI", "just (modular justfiles)", "Foundry", "go-ethereum"],
    "helpfulResources": [
      "ERC-4626 vault standard",
      "ERC-8004 agent identity",
      "Uniswap V3 SwapRouter02",
      "Festival Methodology (custom human-AI collaboration framework)"
    ]
  }
}
```

---

## 10. Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Uniswap API vs direct SwapRouter02** | HIGH — could disqualify from $5K bounty | Verify agent uses Uniswap Developer Platform API for quotes BEFORE mainnet deployment. If it's direct calls only, add API integration as priority work item |
| **USDC sourcing on Base mainnet** | MEDIUM — blocks vault funding and live trades | Acquire USDC + ETH for gas on Base mainnet early. Bridge from another chain if needed. Budget 1-2 hours for this |
| **Repo cleanup reveals secrets** | HIGH — publishing API keys or private keys | Audit ALL files across ALL submodules before making public. Check .env files, hardcoded addresses, git history for leaked secrets |
| **DevSpot schema undocumented** | MEDIUM — agent.json/agent_log.json may not validate | Research schema early. If undocumented, study example submissions or ask in Telegram group |
| **Same PL judges evaluate both tracks** | MEDIUM — may judge as one project, not two | Write distinct narratives: "Cook" = autonomy story, "Receipts" = identity/trust story |
| **CRE Risk Router on different chain than vault** | LOW — may confuse judges | Explicitly document that risk evaluation is off-chain relay from Ethereum Sepolia to Base. This is architecturally correct — risk evaluation doesn't need to be on same chain as execution |
| **Base mainnet deployment fails** | MEDIUM | Fall back to Sepolia evidence (still valid for Protocol Labs bounties) |
| **Live trades lose money** | LOW | Use small amounts (20-50 USDC); losses are demo cost |
| **Video demo takes too long** | MEDIUM | Script in advance, pre-stage all transactions, use dashboard as visual anchor. Budget 3-4 hours |
| **Competition quality unknown** | MEDIUM | Festival methodology is unique differentiator — no one else has hierarchical planning-to-execution with on-chain proof |

---

## 11. Priority Order of Execution

**Phase 0: Start Immediately (Ongoing)**
0. Begin capturing conversationLog of human-agent collaboration (required for submission)

**Phase 1: Critical Path (Protocol Labs + Uniswap Hard Requirements)**
1. Verify Uniswap API integration path — go/no-go on Uniswap bounty
2. agent.json + agent_log.json (Protocol Labs hard requirement — research DevSpot schema first)
3. Differentiate PL submission narratives (autonomy vs identity/trust)

**Phase 2: Deployment (On-Chain Evidence)**
4. Source USDC + ETH on Base mainnet
5. Deploy ObeyVault to Base mainnet + fund + approve tokens
6. Execute 2-3 live Uniswap trades via vault
7. Status Network contract deployment + gasless tx (guaranteed $50+)
7b. Markee integration — add delimiter text to claude-code-go README, grant OAuth, verify "Live" (15 min, no dependencies)

**Phase 3: Packaging (Submission Requirements)**
8. Repo cleanup + make public (audit secrets across all submodules)
9. Video demo (script → rehearse → record)
10. Moltbook post
11. Submit to all tracks via Synthesis API

**Phase 4: Stretch Targets (Time Permitting)**
12. Research MetaMask Delegation Framework SDK (2hr go/no-go)
13. Research Locus SDK (1hr go/no-go)
14. Implement whichever passed go/no-go
15. Research ERC-8183 (1hr, lowest priority)

---

## 12. Spec Review Issues Addressed

Issues identified by automated spec review and incorporated into this revision:

| Issue | Severity | Resolution |
|-------|----------|------------|
| Uniswap API vs direct SwapRouter02 calls | Critical | Added as first priority work item — must verify before proceeding |
| ERC-8004 registration on Base Mainnet | Critical | Already registered via Synthesis API (registration creates mainnet identity) |
| ConversationLog not being captured | Critical | Added as Phase 0 ongoing task |
| Time estimates unrealistic (8-10hr) | Important | Inflated to 16-20hr must-have |
| MetaMask thin wrapper won't place | Important | Redesigned as hierarchical sub-delegation with custom caveats (6-8hr) |
| ERC-8183 unknown | Important | Changed to research-first with go/no-go gate |
| Repo cleanup underestimated | Important | Expanded to 2-3hr with secret audit across submodules |
| Expected value calculations optimistic | Suggestion | Tempered to conservative estimates |
| Locus disqualification clause | Important | Added warning + go/no-go research gate |
| PL submissions need differentiation | Important | Added distinct narrative task |
