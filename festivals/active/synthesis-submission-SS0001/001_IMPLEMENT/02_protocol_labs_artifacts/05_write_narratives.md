---
fest_type: task
fest_id: 04_write_narratives.md
fest_name: write narratives
fest_parent: 02_protocol_labs_artifacts
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-16T21:39:46.214394-06:00
fest_tracking: true
---

# Task: Write Differentiated Protocol Labs Narratives

## Objective

Write two distinct submission narratives for Protocol Labs tracks: "Let the Agent Cook" (autonomy focus) and "Agents With Receipts" (identity/trust focus).

## Requirements

- [ ] Write "Cook" narrative emphasizing autonomous multi-tool orchestration and the festival loop
- [ ] Write "Receipts" narrative emphasizing ERC-8004 identity, on-chain verifiability, and trust building
- [ ] Ensure narratives are genuinely distinct -- same project, different lens

## Implementation

1. **"Let the Agent Cook" narrative** — save as `workflow/explore/synthesis/narrative-cook.md`
   - **Opening hook:** "OBEY is an autonomous agent that doesn't just trade — it follows a structured decision framework with built-in safety rails, and every decision is auditable."
   - **Paragraph 1 — The autonomous loop:** Festival Methodology provides the discover→plan→execute→verify loop. The agent runs a research ritual (RI-AM0001) that ingests market data, analyzes price deviation against a 30-period MA, runs 8 CRE risk gates, and produces a structured GO/NO_GO decision — all without human intervention.
   - **Paragraph 2 — Multi-tool orchestration:** In a single trading cycle, the agent calls: Uniswap V3 pool contracts (price data), Uniswap Developer Platform API (quote routing), CRE Risk Router (8-gate evaluation), and ObeyVault contract (boundary-enforced swap execution). Each tool call is logged in agent_log.json.
   - **Paragraph 3 — Safety guardrails:** The vault contract enforces spending boundaries at the EVM level — token whitelist, max swap size, daily volume cap, slippage limits. The CRE Risk Router adds 8 pre-trade gates. The agent physically cannot violate these constraints.
   - **Paragraph 4 — Compute budget awareness:** Festival Methodology operates on steps-to-completion, not time estimates. The ritual completes in seconds. NO_GO decisions (agent choosing NOT to trade) demonstrate judgment, not just execution.
   - **Evidence to cite:** agent.json, agent_log.json, 3+ complete autonomous loop iterations, SwapExecuted events on Basescan, festival ritual structure

2. **"Agents With Receipts" narrative** — save as `workflow/explore/synthesis/narrative-receipts.md`
   - **Opening hook:** "Every decision has a receipt. Every receipt builds reputation. Every reputation is verifiable on-chain."
   - **Paragraph 1 — On-chain identity:** ERC-8004 identity registered on Base (tx: `0x9b31bd...`). The agent has a persistent, portable identity that follows it across platforms.
   - **Paragraph 2 — Verifiable receipts:** Every vault swap emits a `SwapExecuted(tokenIn, tokenOut, amountIn, amountOut, reason)` event. The `reason` field contains the agent's encoded rationale — not just what happened, but WHY.
   - **Paragraph 3 — Trust model:** Guardian (human) sets boundaries. Agent operates within them. The separation is enforced at the contract level — the agent role can ONLY call `executeSwap()`. The guardian can pause, update limits, or change the agent address at any time.
   - **Paragraph 4 — Reputation accumulation:** Each successful trade verified against the pre-trade plan builds the agent's track record. Other agents or humans can query the ERC-8004 identity to see: how many trades, what accuracy, what risk profile.
   - **Paragraph 5 — Structured proof:** agent_log.json provides the complete reasoning chain. Not just "bought WETH" but "price deviated -2.3% from SMA, confidence 0.72, 7/8 CRE gates passed, estimated net profit $12.50."
   - **Evidence to cite:** ERC-8004 registration tx, SwapExecuted events with reason field, agent_log.json, guardian/agent role separation in ObeyVault.sol

3. Each narrative should be 300-500 words — concise enough for a submission description field

## Done When

- [ ] All requirements met
- [ ] "Cook" narrative written and saved
- [ ] "Receipts" narrative written and saved
- [ ] Narratives are distinct enough that a judge reading both would see different value propositions
