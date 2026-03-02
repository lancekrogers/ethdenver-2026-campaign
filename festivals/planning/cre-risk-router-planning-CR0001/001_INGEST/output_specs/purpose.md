# Festival Purpose

## Primary Goal

Build and submit a CRE Risk Router to the Chainlink Convergence Hackathon (agents-only track, Moltbook) by March 8, 2026 11:59 PM ET.

## Vision

A standalone CRE workflow in Go that acts as an AI-powered risk decision layer for the Obey Agent Economy. The workflow evaluates trade requests against 8 risk gates, reads Chainlink price feeds, and writes immutable decision receipts on-chain. The submission demonstrates CRE as the safety layer for autonomous multi-chain DeFi agents.

## Why This Matters

- **Prizes:** $3,500 (1st) / $1,500 (2nd)
- **Competitive advantage:** We have a real 3-agent, 4-chain economy to contextualize the CRE workflow. Other teams will submit isolated fetch-and-write pipelines.
- **Demonstrates CRE depth:** 8 risk gates, 5 CRE capabilities, denied scenarios, production patterns — far beyond typical hackathon submissions.

## Success Criteria

### Functional Success

- [ ] `cre workflow simulate .` runs from clean clone without errors
- [ ] `cre workflow simulate . --broadcast` produces a verifiable on-chain tx hash
- [ ] RiskDecisionReceipt.sol deployed and verified on CRE-supported testnet
- [ ] 5 simulation scenarios produce correct outcomes (2 approved, 3 denied)
- [ ] `demo/e2e.sh` demonstrates integration path with realistic agent payload
- [ ] Moltbook post published with all required sections before deadline

### Quality Success

- [ ] README enables clone-to-simulate in under 5 commands
- [ ] All 8 risk gates implemented with correct logic (including edge cases)
- [ ] Chainlink oracle health validation uses full `latestRoundData()` tuple
- [ ] Position sizing formula handles negative volatility and extreme values
- [ ] No secrets in repository; `.env.example` template provided
- [ ] CRE Experience Feedback section contains genuine, non-empty feedback

## Done When

- Published Moltbook post with correct `#chainlink-hackathon-convergence #cre-ai` format
- Working simulation with tx hash evidence
- Human registration form completed
- All P0 deliverables shipped
