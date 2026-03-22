# Video Demo — Synthesis Hackathon Submission

## Overview

3-minute programmatic video demo for the OBEY Vault Agent submission, built with [Remotion](https://www.remotion.dev/) (React-based video framework). The video tells one story: **"What happens when an AI agent trades your money — and can't cheat."**

## Video Structure (3 min @ 30fps = 5,400 frames)

### Scene 1: Hook + Vault Boundaries (0:00–0:30, frames 0–900)

**What to show:**
- Title card: "OBEY Vault Agent — Autonomous Trading with Human Boundaries"
- Animated display of vault constraints pulled from contract:
  - Max swap: $1,000 USDC
  - Daily volume cap: $10,000
  - Max slippage: 100 bps
  - Token whitelist: USDC, WETH
- Guardian vs Agent role separation diagram
- ObeyVault contract address on Base Sepolia

**Narration/text overlay:**
> "These limits are enforced at the EVM level. The agent literally cannot exceed them."

**Data source:** `agent.json` → `compute_constraints`, contract read calls

---

### Scene 2: Agent Identity — ERC-8004 (0:30–0:50, frames 900–1500)

**What to show:**
- ERC-8004 registration tx hash with Basescan link
- Identity contract address: `0x0C97820abBdD2562645DaE92D35eD581266CCe70`
- Operator wallet linked to agent identity
- "Portable, verifiable, on-chain identity"

**Data source:** `agent.json` → `erc8004_identity`, `erc8004_registration_tx`

---

### Scene 3: Live Ritual Cycle — The Money Shot (0:50–1:50, frames 1500–3300)

**What to show:**
- Festival Methodology loop diagram: discover → plan → execute → verify
- Terminal recording or animated recreation of:
  1. `fest ritual run agent-market-research-RI-AM0001` creating an instance
  2. Obey daemon session creation (session ID, workdir binding)
  3. Agent querying Uniswap V3 pools (tool calls)
  4. CRE 8-gate risk evaluation running
  5. `decision.json` appearing with result
- Show a **NO_GO** decision with blocking factors
  - "The agent decided NOT to trade. That's the point."
- Show a **GO** decision with confidence, deviation, signal
- Animated transition from decision → vault swap execution

**Data source:** Real `decision.json` from `.campaign/quests/`, `agent_log.json` entries

---

### Scene 4: On-Chain Receipt (1:50–2:20, frames 3300–4200)

**What to show:**
- SwapExecuted event from Base Sepolia tx `0xafc1c6b2...a9d7`
- Highlight the `reason` field — encoded rationale committed at tx time
- Before/after vault balances
- `agent_log.json` entry showing the full loop:
  - Tools used, confidence, gates passed, execution result, verification

**Narration/text overlay:**
> "Every trade has a receipt. Every receipt is on-chain. Every receipt builds reputation."

**Data source:** `agent_log.json` execute entry, Basescan event log

---

### Scene 5: Multi-Chain Architecture (2:20–2:40, frames 4200–4800)

**What to show:**
- Architecture diagram with chains:
  - **Base Sepolia** — ObeyVault, ERC-8004, trading
  - **Hedera Testnet** — HCS messaging, AGT token payments
  - **Ethereum Sepolia** — CRE risk evaluations
  - **0G Galileo** — Decentralized compute contracts
  - **Status Network** — Gasless agent registration
- Transaction counts per chain (80+ total)
- 5 deployed contracts on Base, 3 on 0G

**Data source:** `contracts/deployments/base-sepolia.json`, README stats

---

### Scene 6: Closing (2:40–3:00, frames 4800–5400)

**What to show:**
- "The agent cooks. The vault keeps it honest. Every receipt is on-chain."
- Project links: GitHub, Moltbook post
- Tech stack badges: Go, Solidity, ERC-4626, ERC-8004, Uniswap V3, Hedera HCS, Chainlink CRE, Festival Methodology
- Tracks submitted to (6 tracks, ~$47K potential)

---

## Data Files for Dynamic Content

The video should read real project data, not hardcoded strings:

| Data | File | Key Fields |
|------|------|------------|
| Agent manifest | `/agent.json` | name, tools, constraints, identity |
| Execution log | `/projects/agent-defi/agent_log.json` | entries[] with decisions, reasoning, execution |
| Deployments | `/projects/contracts/deployments/base-sepolia.json` | contract addresses, tx hashes |
| Conversation log | `/conversationLog.json` | human-agent collaboration entries |
| Ritual decisions | `.campaign/quests/*/003_DECIDE/*/results/decision.json` | GO/NO_GO, confidence, guardrails |

---

## Live System Demo Runbook

If recording live terminal footage to embed or recreate in the video:

### Prerequisites

```bash
fest version          # fest CLI in PATH
just obey ping        # daemon responds
```

### Start the system

```bash
# Terminal 1: daemon (foreground for visible session creation)
just obey start-fg

# Terminal 2: trigger a ritual cycle
fest ritual run agent-market-research-RI-AM0001

# Terminal 3: watch for decision artifacts
watch -n 1 'ls .campaign/quests/*/003_DECIDE/01_synthesize_decision/results/ 2>/dev/null'
```

### Show the results

```bash
# Decision artifact
cat .campaign/quests/<latest>/003_DECIDE/01_synthesize_decision/results/decision.json | python3 -m json.tool

# Aggregate log
cat projects/agent-defi/agent_log.json | python3 -m json.tool

# Dashboard
cd projects/dashboard && npm run dev
# Open http://localhost:3000
```

### Basescan links to show

- Vault contract: `https://sepolia.basescan.org/address/0xbAbDd92397Cd812593e79A5b4c2a32bB4aDb06b1`
- Swap tx: `https://sepolia.basescan.org/tx/0xafc1c6b2e0ad1e0f0bff17aa86f2cca6ab19ce2859929e5fa066b989d2d3a9d7`
- ERC-8004 registration: `https://sepolia.basescan.org/tx/0x9b31bd785dd7b12649d9d12379546c268aea1da6e0060777bed6276cf8e4002a`
