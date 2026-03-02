---
fest_type: festival
fest_id: CR0001
fest_name: cre-risk-router-planning
fest_status: completed
fest_created: 2026-03-01T15:45:35.977594-07:00
fest_updated: 2026-03-02T01:37:10.517721-07:00
fest_tracking: true
---




# cre-risk-router

**Status:** Planned | **Created:** 2026-03-01T15:45:35-07:00

## Festival Objective

**Primary Goal:** Build and submit a CRE Risk Router to the Chainlink Convergence Hackathon by March 8, 2026.

**Vision:** A standalone CRE workflow in Go that evaluates trade risk for autonomous DeFi agents using 8 risk gates, reads Chainlink price feeds, and writes immutable decision receipts on-chain. Planned, built, and submitted as part of the Obey Agent Economy.

## Success Criteria

### Functional Success

- [ ] `cre workflow simulate .` runs from clean clone without errors
- [ ] `cre workflow simulate . --broadcast` produces verifiable on-chain tx hash
- [ ] RiskDecisionReceipt.sol deployed and verified on CRE-supported testnet
- [ ] 5 simulation scenarios produce correct outcomes (2 approved, 3 denied)
- [ ] `demo/e2e.sh` demonstrates integration path with coordinator-format payload
- [ ] Moltbook post published with all 10 required sections before deadline

### Quality Success

- [ ] README enables clone-to-simulate in under 5 commands
- [ ] All 8 risk gates implemented with correct edge case handling
- [ ] 8-decimal price precision consistent across Go types, contract, and events
- [ ] No secrets in repository

## Progress Tracking

### Phase Completion

- [x] 001_INGEST: Ingest spec and produce structured planning outputs
- [x] 002_PLAN: Decompose requirements into implementation plan and scaffold festival
- [ ] 003_CRE_VALIDATION: Validate CRE CLI works end-to-end (hard gate)
- [ ] 004_FOUNDATION: Project scaffold and contract deployment
- [ ] 005_RISK_LOGIC: 8 risk gates, types, helpers, evaluation pipeline
- [ ] 006_WORKFLOW_INTEGRATION: CRE handlers and first successful simulation
- [ ] 007_SUBMISSION: Documentation, evidence, and publish
- [ ] 008_INTEGRATION: P1 bridge to existing agent economy (if time)

## Complete When

- [ ] All P0 phases completed (003-007)
- [ ] Moltbook post published before March 8, 2026 11:59 PM ET
- [ ] Human registration form completed