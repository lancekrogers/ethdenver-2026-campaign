---
fest_type: task
fest_id: 01_draft_post.md
fest_name: draft post
fest_parent: 03_publish
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:45:34.402946-07:00
fest_tracking: true
---

# Task: draft post

## Objective

Draft the Moltbook submission post covering all 10 required sections per spec Section 10, including project description, architecture, risk gates, contract details, simulation evidence, and integration path.

## Requirements

- [ ] Moltbook post draft covers all 10 required sections from spec Section 10 (Req P0.21)
- [ ] Section 1 (Title): "CRE Risk Router -- On-Chain Risk Decisions for Autonomous DeFi Agents"
- [ ] Section 2 (Summary): 2-3 sentence overview of purpose and approach
- [ ] Section 3 (Problem Statement): Why autonomous agents need a risk layer
- [ ] Section 4 (Architecture): Data flow diagram and component description
- [ ] Section 5 (Risk Gates): All 8 gates with descriptions, thresholds, and deny reasons
- [ ] Section 6 (Smart Contract): RiskDecisionReceipt.sol address, interface, event schema
- [ ] Section 7 (Simulation): Screenshots/logs from simulation runs with tx hash
- [ ] Section 8 (Evidence): Block explorer link and/or screenshot showing DecisionRecorded event
- [ ] Section 9 (Scenarios): Summary of 5 pre-built scenarios and their expected outcomes
- [ ] Section 10 (Integration): How agent-coordinator will call CRE Risk Router (P1 roadmap)

## Implementation

1. **Create `submission/moltbook-draft.md`** at `projects/cre-risk-router/submission/moltbook-draft.md`.

2. **Section 1 -- Title**:
   ```
   # CRE Risk Router -- On-Chain Risk Decisions for Autonomous DeFi Agents
   ```

3. **Section 2 -- Summary**:
   - Describe CRE Risk Router as a Chainlink CRE workflow that evaluates risk for autonomous DeFi agent trade signals
   - Mention 8 risk gates, on-chain receipt via RiskDecisionReceipt.sol, and Chainlink oracle integration
   - Emphasize: every decision is transparent, auditable, and recorded on-chain

4. **Section 3 -- Problem Statement**:
   - Autonomous AI agents generate trade signals but lack a systematic risk evaluation layer
   - Without guardrails, agents can execute trades with stale data, excessive risk, or during oracle outages
   - CRE Risk Router provides a trustless, on-chain risk decision pipeline

5. **Section 4 -- Architecture**:
   - Data flow: HTTP POST (RiskRequest) -> Parse + Validate -> Fetch Market Data (Chainlink + CoinGecko) -> Evaluate 8 Risk Gates -> Write Receipt On-Chain -> Return RiskDecision
   - Include ASCII art or markdown table showing the pipeline stages
   - Mention CRE capabilities used: HTTP trigger, cron trigger, HTTP fetch, EVM read, EVM write

6. **Section 5 -- Risk Gates**:
   - Create a table with columns: Gate #, Name, Type, Description, Default Threshold
   - Gate 1: Signal Confidence | Hard | Reject if signal_confidence < threshold | 0.6
   - Gate 2: Risk Score Ceiling | Hard | Reject if risk_score > max | 75
   - Gate 3: Signal Staleness | Hard | Reject if signal age > TTL | 300s
   - Gate 4: Oracle Health | Hard | Reject if latestRoundData() fails validation | N/A
   - Gate 5: Price Deviation | Soft | Reject if CoinGecko vs Chainlink > 5% | 500 BPS
   - Gate 6: Volatility-Adjusted Sizing | Soft | Constrain position based on volatility | 10% fallback
   - Gate 7: Hold Signal Filter | Hard | Reject hold signals outright | N/A
   - Gate 8: Agent Heartbeat | Hard | Circuit breaker if agent silent > threshold | 600s

7. **Section 6 -- Smart Contract**:
   - Include contract address (from Phase 002 deployment)
   - Show the `DecisionRecorded` event signature
   - Show the `recordDecision` function signature
   - Mention testnet name and chain ID

8. **Section 7 -- Simulation**:
   - Embed or reference the simulation log from `evidence/simulation-output.log`
   - Highlight: gate evaluation results, final decision, tx hash
   - Show both `just simulate` (dry-run) and `just broadcast` (on-chain) outputs

9. **Section 8 -- Evidence**:
   - Include the block explorer permanent link from Phase 005 evidence capture
   - Describe what the tx shows: contract call, DecisionRecorded event, parameters
   - Include screenshot reference if available

10. **Section 9 -- Scenarios**:
    - Table summarizing the 5 scenarios: name, signal, confidence, risk_score, expected outcome, deny reason
    - Reference `scenarios/` directory for full JSON payloads

11. **Section 10 -- Integration Path**:
    - Describe how `agent-coordinator` will call CRE Risk Router via HTTP before task assignment
    - Show the integration flow: agent-inference produces signal -> coordinator calls CRE -> CRE returns decision -> coordinator assigns or blocks task
    - Mention P1 requirements: CRE client package, signal fields, DeFi guard, HCS messages

12. **Review the draft** for completeness, clarity, and accuracy against the spec.

## Done When

- [ ] All requirements met
- [ ] Draft covers all 10 Moltbook sections with specific, accurate content
- [ ] No placeholder text or TODO markers remain in the draft
- [ ] Evidence references point to actual captured artifacts
