# 05 - Submission Strategy

## Submission Format

### Post Title

```
#chainlink-hackathon-convergence #cre-ai — CRE Risk Router for Autonomous Agent Economy
```

### Post Body (First Line)

```
#chainlink-hackathon-convergence #cre-ai
```

## Narrative Strategy

### What Makes This Stand Out

Most hackathon submissions will be isolated CRE workflows that fetch data and write it on-chain. Our submission tells a bigger story:

**"An AI-powered CRE workflow that serves as the risk decision layer for a live autonomous agent economy spanning three blockchains."**

Key differentiators:

1. **Real context** - Not a toy demo; this CRE workflow gates actual DeFi agent behavior
2. **Multi-chain architecture** - Hedera (coordination), 0G (inference), Base (DeFi), CRE (risk)
3. **AI-native** - Inference signals from decentralized GPU compute feed into CRE risk logic
4. **Production patterns** - Position sizing, slippage caps, TTL, staleness checks
5. **Existing infrastructure** - ETHDenver 2026 project with working agents, contracts, dashboard

### Submission Sections

#### 1. Project Description

The CRE Risk Router is an AI-powered risk decision workflow built on the Chainlink Runtime Environment. It acts as a safety layer for autonomous DeFi agents operating in the Obey Agent Economy - a multi-chain system where AI agents coordinate tasks via Hedera HCS, run inference on 0G's decentralized GPU network, and execute DeFi strategies on Base.

**Problem:** Autonomous agents making financial decisions need guardrails. Without a decentralized risk evaluation layer, agents rely solely on local strategy logic - no independent verification, no on-chain audit trail.

**Solution:** The CRE Risk Router intercepts trade requests, evaluates them against multiple risk dimensions (signal confidence, market volatility, Chainlink price feed deviation, position sizing), and writes immutable decision receipts on-chain. Agents only execute trades when the CRE workflow approves them within specified constraints.

**Architecture:**

- CRE workflow receives risk evaluation requests via HTTP trigger
- Fetches market data via HTTP capability
- Reads Chainlink price feeds on testnet via EVM capability
- Evaluates 6 risk gates (confidence, risk score, staleness, price deviation, volatility, signal type)
- Writes approved/denied decisions to RiskDecisionReceipt contract on [testnet]
- Returns constrained parameters (max position, slippage cap, TTL) to calling agent

#### 2. GitHub Repository

[Public repo URL - either as new repo or directory in existing repo]

#### 3. Setup Instructions

```bash
git clone [repo-url]
cd cre-risk-router

# Install CRE CLI
curl -sSL https://cre.chain.link/install | sh

# Configure environment
cp .env.example .env
# Set RPC_URL and any API keys in .env

# Generate EVM bindings
cre generate-bindings evm

# Run simulation
cre workflow simulate . --broadcast --verbose
```

#### 4. Simulation Commands

```bash
# Dry run (no on-chain write)
cre workflow simulate .

# Broadcast (on-chain write, produces tx hash)
cre workflow simulate . --broadcast

# With specific target network
cre workflow simulate . --broadcast --target arbitrum-sepolia --verbose
```

#### 5. Workflow Description

The CRE Risk Router implements a trigger-and-callback model:

- **Trigger:** HTTP POST with risk evaluation request (agent ID, AI signal, risk score, market pair, position size)
- **Capabilities:** HTTP Client (market data), EVM Client (Chainlink price feed reads + on-chain writes)
- **Logic:** 6-gate risk evaluation producing approved/denied decision with constrained parameters
- **Target:** On-chain write to RiskDecisionReceipt contract recording immutable decision proof

Data flow: Agent Signal → CRE HTTP Trigger → Market Data Fetch → Price Feed Read → Risk Evaluation → On-Chain Receipt Write → Decision Response

#### 6. On-Chain Write Explanation

- **Network:** [CRE-supported testnet, e.g., Arbitrum Sepolia]
- **Contract:** `RiskDecisionReceipt.sol` at `0x...`
- **Operation:** `recordDecision(runId, decisionHash, approved, maxPositionUsd, maxSlippageBps, ttlSeconds, chainlinkPrice)`
- **Purpose:** Creates immutable on-chain proof of each CRE risk decision, enabling auditability and agent constraint enforcement

#### 7. Evidence Artifact

[Execution logs showing transaction hash from `cre workflow simulate . --broadcast`]

#### 8. CRE Experience Feedback

[Genuine feedback about CRE development experience - to be written after building]

#### 9. Eligibility Confirmation

- Registration form completed at <https://forms.gle/xk1PcnRmky2k7yDF7>
- One human operator, one agent, one submission

## Evidence Checklist

Before submission:

- [ ] `cre workflow simulate .` runs successfully from clean clone
- [ ] `cre workflow simulate . --broadcast` produces on-chain tx hash
- [ ] Transaction hash is verifiable on testnet block explorer
- [ ] RiskDecisionReceipt contract is verified on testnet
- [ ] Execution logs clearly show the decision flow
- [ ] All secrets are in .env, none hardcoded
- [ ] No placeholder text in submission
- [ ] Repository is public
- [ ] Post title/body match exact format
- [ ] Registration form completed

## Simulation Scenarios for Demo

### Scenario 1: Approved Trade (Happy Path)

```json
{
  "signal": "buy",
  "signal_confidence": 0.85,
  "risk_score": 35,
  "requested_position_usd": 1000
}
```

Expected: Approved, max position $1000, slippage 50 bps

### Scenario 2: Denied - Low Confidence

```json
{
  "signal": "buy",
  "signal_confidence": 0.45,
  "risk_score": 35,
  "requested_position_usd": 1000
}
```

Expected: Denied, reason "signal_confidence_below_threshold"

### Scenario 3: Denied - High Risk

```json
{
  "signal": "buy",
  "signal_confidence": 0.85,
  "risk_score": 82,
  "requested_position_usd": 1000
}
```

Expected: Denied, reason "risk_score_exceeds_maximum"

### Scenario 4: Constrained - Volatility Adjustment

```json
{
  "signal": "buy",
  "signal_confidence": 0.75,
  "risk_score": 55,
  "requested_position_usd": 5000
}
```

Expected: Approved, max position reduced to $2500 due to risk score

## Timeline (March 1-8)

| Day | Deliverable |
|-----|------------|
| Mar 1-2 | CRE workflow scaffold + config + contract |
| Mar 3-4 | Risk evaluation logic + EVM bindings + first `cre simulate` |
| Mar 4-5 | Deploy contract to testnet + `--broadcast` with tx hash |
| Mar 5-6 | Integration hooks (coordinator CRE client, if time) |
| Mar 6-7 | Full simulation scenarios + evidence capture |
| Mar 7-8 | Submission post draft + review + publish |

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| CRE SDK unfamiliar | Start with simplest possible workflow, iterate from there |
| Testnet issues | Deploy contract early (day 3-4), have fallback network |
| Scope creep | P0 = standalone CRE workflow + contract + submission. Nothing else required |
| Time pressure | The existing agent economy is background context, not work. Focus on CRE project only |
| CRE CLI bugs | Install early, test basic commands day 1, report issues if found |
