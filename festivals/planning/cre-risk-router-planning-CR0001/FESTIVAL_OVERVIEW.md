# Festival Overview: cre-risk-router

## Problem Statement

**Current State:** The Obey Agent Economy has 3 working agents (coordinator, inference, DeFi) across 3 chains but lacks a decentralized risk evaluation layer. Agents rely solely on local strategy logic with no independent verification or on-chain audit trail for trade decisions.

**Desired State:** A CRE workflow that intercepts trade requests, evaluates them against 8 risk dimensions, and writes immutable decision receipts on-chain. Submitted to the Chainlink Convergence Hackathon.

**Why This Matters:** Hackathon prizes ($3,500/$1,500), demonstrates CRE as a safety layer for autonomous agents, and adds Chainlink integration to the Obey Agent Economy.

## Scope

### In Scope

- Spec ingestion and implementation planning
- CRE workflow in Go (standalone at `projects/cre-risk-router/`)
- RiskDecisionReceipt.sol contract on CRE-supported testnet
- 8 risk gates with Chainlink price feed integration
- 5 simulation scenarios (2 approved, 3 denied)
- Integration path proof via `demo/e2e.sh`
- Moltbook submission with all required sections

### Out of Scope

- Production deployment or mainnet contracts
- Dashboard CRE panel (P2 stretch)
- Multi-feed oracle aggregation
- Rate limiting or gas budgeting
- Authentication hardening beyond CRE DON-level verification

## Planned Phases

### 001_INGEST (complete)

Ingest the CRE Risk Router spec and produce structured planning outputs (purpose, requirements, constraints, context).

### 002_PLAN (complete)

Decompose requirements into an implementation plan, scaffold the festival structure, validate.

### 003_CRE_VALIDATION

Validate CRE CLI installation, authentication, and basic simulation + broadcast. Hard gate — blocks everything.

### 004_FOUNDATION

Scaffold the project, write and deploy RiskDecisionReceipt.sol, generate EVM bindings.

### 005_RISK_LOGIC

Implement all 8 risk gates, types, helpers, and the evaluation pipeline with fallback logic.

### 006_WORKFLOW_INTEGRATION

Wire risk logic into CRE HTTP and cron trigger handlers. Achieve first successful simulation and broadcast.

### 007_SUBMISSION

Create README, scenarios, e2e demo, capture evidence, draft and publish Moltbook post.

### 008_INTEGRATION (P1)

Bridge CRE Risk Router to existing agent economy — coordinator client, inference fields, DeFi guard, HCS messages.

## Notes

- Full product spec: `workflow/design/cre-risk-router/spec.md`
- Phase 003 is a hard gate — if basic CRE simulation fails, approach is reassessed
- Phase 008 only starts if P0 (phases 003-007) is stable
- Deadline: March 8, 2026 11:59 PM ET
