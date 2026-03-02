---
fest_type: phase
fest_id: 003_CRE_VALIDATION
fest_name: CRE_VALIDATION
fest_parent: cre-risk-router-planning-CR0001
fest_order: 3
fest_status: pending
fest_created: 2026-03-01T17:42:27.667861-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 001_CRE_VALIDATION

**Phase:** 001_CRE_VALIDATION | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Validate that the CRE CLI works end-to-end, including installation, authentication, workflow simulation, and on-chain EVM writes. This is a hard gate that blocks all subsequent phases.

**Context:** This is the first phase and the single most important validation step. If basic CRE simulation or EVM broadcast does not work, the entire project plan must be reassessed before writing any Risk Router code. The findings from this phase directly inform testnet selection, SDK import paths, and EVM write patterns used in all later phases.

## Required Outcomes

Deliverables this phase must produce:

- [ ] CRE CLI installed and `cre --version` returns a valid version
- [ ] CRE authentication complete (`cre login`, `cre whoami` verified)
- [ ] Hello-world CRE workflow created (cron trigger, logs a string, compiles)
- [ ] Dry-run simulation passes without errors (`cre workflow simulate .`)
- [ ] Trivial Solidity contract deployed to a CRE-supported EVM testnet via Foundry
- [ ] EVM write added to hello-world workflow and broadcast simulation produces a tx hash (`cre workflow simulate . --broadcast`)
- [ ] Findings document covering: supported testnets, auth flow, SDK import paths, EVM write patterns, gotchas

## Quality Standards

Quality criteria for all work in this phase:

- [ ] Every CRE command produces expected output without errors
- [ ] All findings are documented with exact commands and outputs for reproducibility
- [ ] Testnet contract deployment is verified on a block explorer
- [ ] No assumptions made about CRE behavior without validation

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_cli_setup | Install CRE CLI, authenticate, create hello-world workflow, pass dry-run simulation | Working CRE workflow that passes `cre workflow simulate .` |
| 02_evm_validation | Deploy trivial contract, add EVM write to workflow, pass broadcast simulation | Tx hash from `cre workflow simulate . --broadcast` + findings document |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_cli_setup
- [ ] 02_evm_validation

## Notes

This phase is a hard gate. If tasks 04 (dry run) or 03 (broadcast) fail after debugging, stop and reassess the entire approach before continuing. The testnet selected here will be used for all subsequent contract deployments. Requirements traced: 0.1-0.7.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
