---
fest_type: phase
fest_id: 004_FOUNDATION
fest_name: FOUNDATION
fest_parent: cre-risk-router-planning-CR0001
fest_order: 4
fest_status: pending
fest_created: 2026-03-01T17:42:33.387639-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 002_FOUNDATION

**Phase:** 002_FOUNDATION | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Scaffold the CRE Risk Router project structure and deploy the RiskDecisionReceipt smart contract to a CRE-supported EVM testnet.

**Context:** This phase builds on the validated CRE environment from Phase 001 (testnet selection, auth flow, SDK patterns) and creates the project foundation that all subsequent implementation phases depend on. The project scaffold provides the directory structure, config files, and build tooling. The deployed contract provides the on-chain receipt target for the workflow.

## Required Outcomes

Deliverables this phase must produce:

- [ ] Project created via `camp project new cre-risk-router` as a submodule in the monorepo with private GitHub repo at `github.com/lancekrogers/cre-risk-router`
- [ ] Complete project scaffold: `go.mod`, directory structure per spec Section 3, `config.json` with all Config fields and defaults, `secrets.yaml` declarations, `.env.example` template
- [ ] Justfile with recipes: `just simulate`, `just broadcast`, `just test`, `just deploy`
- [ ] `RiskDecisionReceipt.sol` contract implementing `recordDecision()`, `isDecisionValid()`, `getRunCount()` with events, storage, and duplicate prevention per spec Section 7
- [ ] 4 Foundry tests passing: approved decision, denied decision, duplicate rejection, TTL expiry
- [ ] Contract deployed to CRE-supported testnet with contract address captured and updated in `config.json`
- [ ] EVM bindings generated via `cre generate-bindings evm` from contract ABI, compiling successfully in Go

## Quality Standards

Quality criteria for all work in this phase:

- [ ] Project structure matches spec Section 3 exactly
- [ ] All config fields have documented defaults matching spec Section 5
- [ ] Contract tests cover all four core scenarios with proper assertions
- [ ] Contract deployment is verified on block explorer
- [ ] Generated Go bindings compile without errors

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_project_scaffold | Create the project structure with all config files and build tooling | Scaffolded project with `go.mod`, `config.json`, `justfile` |
| 02_contract | Write, test, and deploy RiskDecisionReceipt.sol, generate EVM bindings | Deployed contract address + working Go bindings |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_project_scaffold
- [ ] 02_contract

## Notes

The project lives at `projects/cre-risk-router/` as a submodule. The GitHub repo starts private and must be made public before final submission. The testnet for contract deployment was determined in Phase 001. Requirements traced: P0.1-P0.4.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
