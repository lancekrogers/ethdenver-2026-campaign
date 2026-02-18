---
fest_type: task
fest_id: 02_polish_readme.md
fest_name: polish_readme
fest_parent: 05_base_package
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Polish Agent-DeFi README

**Task Number:** 02 | **Sequence:** 05_base_package | **Autonomy:** medium

## Objective

Polish the agent-defi `README.md` to serve as the primary submission document for the Base ($3k+) self-sustaining agent bounty. Focus on ERC-8004 identity, x402 payment protocol, ERC-8021 attribution, trading strategy, and P&L proof summary.

## Requirements

- [ ] Project overview explaining the DeFi agent and its self-sustaining model
- [ ] ERC standard integrations documented (ERC-8004, x402, ERC-8021)
- [ ] Trading strategy explained at a high level (what it trades, how it decides, what makes it profitable)
- [ ] P&L summary section with net profit figure and link to full P&L proof document
- [ ] Setup instructions for running the DeFi agent
- [ ] Bounty alignment section mapping features to Base bounty requirements
- [ ] README saved at `projects/agent-defi/README.md`

## Implementation

### Step 1: Read the existing README

```bash
cd $(fgo) && cat README.md
```

### Step 2: Write the project overview

Explain:

- What the DeFi agent does (autonomous trading agent on Base that generates revenue to sustain itself)
- The self-sustaining model (revenue from trades covers gas costs, service fees, and profit)
- How it fits into the larger multi-agent economy (receives trade signals from coordinator, pays for inference services)

### Step 3: Document ERC standard integrations

For each standard, explain what it provides and how it is used:

**ERC-8004 (Agent Identity)**:
- What: On-chain identity standard for AI agents
- How: The DeFi agent has a registered on-chain identity that other agents and contracts can verify

**x402 (Payment Protocol)**:
- What: HTTP-based payment protocol for machine-to-machine payments
- How: The agent uses x402 to pay for inference services and receive payments for completed work

**ERC-8021 (Attribution)**:
- What: On-chain attribution standard for AI-generated actions
- How: Every trade the agent makes is attributed on-chain, creating a verifiable track record

### Step 4: Explain the trading strategy

At a high level:

- What markets or token pairs does the agent trade?
- How does it decide when to trade (signals from coordinator, on-chain conditions, etc.)?
- What makes the strategy profitable (spread capture, arbitrage, signal quality)?
- What are the risk controls (max position size, stop-loss, etc.)?

Do not reveal proprietary implementation details -- keep it at a level that demonstrates understanding and viability.

### Step 5: Write P&L summary

Include a summary of the profitability data:

- Number of trading cycles completed
- Net profit (from the profitability validation report)
- Link to the full P&L proof document at `docs/pnl-proof.md`

### Step 6: Write bounty alignment section

Map features to Base bounty requirements:

| Base Bounty Requirement | How This Project Meets It |
|------------------------|---------------------------|
| Self-sustaining agent | Revenue from trades exceeds costs (proven with P&L) |
| On-chain identity | ERC-8004 agent registration |
| Payment protocol | x402 for machine-to-machine payments |
| Attribution | ERC-8021 on-chain attribution for all trades |

## Done When

- [ ] README has all required sections
- [ ] ERC standard integrations clearly documented
- [ ] Trading strategy explained accessibly
- [ ] P&L summary included with link to full proof
- [ ] Bounty alignment maps to Base requirements
- [ ] All links verified valid
