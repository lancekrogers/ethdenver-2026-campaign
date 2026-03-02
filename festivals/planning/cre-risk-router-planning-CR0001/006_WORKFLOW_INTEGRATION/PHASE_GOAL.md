---
fest_type: phase
fest_id: 006_WORKFLOW_INTEGRATION
fest_name: WORKFLOW_INTEGRATION
fest_parent: cre-risk-router-planning-CR0001
fest_order: 6
fest_status: pending
fest_created: 2026-03-01T17:42:33.424088-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 004_WORKFLOW_INTEGRATION

**Phase:** 004_WORKFLOW_INTEGRATION | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Wire the risk evaluation logic into CRE workflow handlers (HTTP trigger and cron trigger) and achieve the first successful end-to-end simulation with on-chain receipt write.

**Context:** This phase builds on the completed risk gates and types from Phase 003 and the deployed contract from Phase 002. It connects the evaluation pipeline to CRE's trigger system and external data sources (CoinGecko HTTP fetch, Chainlink EVM read), producing the first real simulation output. A successful broadcast simulation here proves the core submission works.

## Required Outcomes

Deliverables this phase must produce:

- [ ] `onRiskEvaluation()` HTTP trigger handler: parses `RiskRequest` from HTTP body, fetches market data via HTTP capability, reads Chainlink feed via EVM capability, calls `evaluateRisk()`, writes receipt on-chain, returns `RiskDecision`
- [ ] `onScheduledSweep()` cron trigger handler: generates synthetic `RiskRequest` with hardcoded realistic parameters and fresh `runtime.Now()` timestamp, runs same pipeline
- [ ] Dry-run simulation passes: `cre workflow simulate .` completes without errors
- [ ] Broadcast simulation passes: `cre workflow simulate . --broadcast` produces a tx hash
- [ ] On-chain receipt verified on block explorer

## Quality Standards

Quality criteria for all work in this phase:

- [ ] Both triggers exercise the full pipeline: parse, fetch, evaluate, write, return
- [ ] Cron trigger uses `runtime.Now()` so Gate 3 (staleness) always passes in simulation
- [ ] Workflow produces a valid result regardless of external data availability (graceful fallback)
- [ ] Simulation output includes clear log lines showing gate results and decision outcome
- [ ] Tx hash is visible in broadcast simulation output

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_handlers | Implement CRE workflow trigger handlers (HTTP + cron) | `workflow.go` with `onRiskEvaluation()` and `onScheduledSweep()` |
| 02_simulation | First successful end-to-end simulation with on-chain write | Passing dry-run and broadcast simulations with verified tx hash |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_handlers
- [ ] 02_simulation

## Notes

The workflow fetches live data from CoinGecko and Chainlink -- not mocks. Simulation requires network access and a responsive testnet. Fallback behavior ensures valid results even if external data is unavailable. The cron trigger exists so `cre workflow simulate` works without an external HTTP client. Requirements traced: P0.13-P0.16.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
