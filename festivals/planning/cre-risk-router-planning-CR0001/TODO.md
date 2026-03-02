# Festival TODO - cre-risk-router-planning

**Goal**: Build and submit a CRE Risk Router to the Chainlink Convergence Hackathon by March 8, 2026
**Status**: Planning

---

## Festival Progress Overview

### Phase Completion Status

- [x] 001_INGEST — Ingest spec and produce structured planning outputs
- [x] 002_PLAN — Decompose requirements into implementation plan and scaffold festival
- [ ] 003_CRE_VALIDATION — Validate CRE CLI works end-to-end (hard gate)
- [ ] 004_FOUNDATION — Project scaffold and contract deployment
- [ ] 005_RISK_LOGIC — 8 risk gates, types, helpers, evaluation pipeline
- [ ] 006_WORKFLOW_INTEGRATION — CRE handlers and first successful simulation
- [ ] 007_SUBMISSION — Documentation, evidence, and publish
- [ ] 008_INTEGRATION — P1 bridge to existing agent economy (if time)

### Current Work Status

```
Active Phase: 003_CRE_VALIDATION (next)
Active Sequences: N/A — not yet started
Blockers: None
```

---

## Phase Progress

### 001_INGEST

**Status**: Completed

#### Outputs

- [x] `purpose.md` — Festival goal, success criteria
- [x] `requirements.md` — 37 requirements across Phase 0/P0/P1/P2
- [x] `constraints.md` — Hard/soft constraints, risk table
- [x] `context.md` — Existing system, design history, references
- [x] `spec.md` — Full spec copied for reference

### 002_PLAN

**Status**: Completed

#### Outputs

- [x] `STRUCTURE.md` — Festival hierarchy with all phases/sequences/tasks
- [x] `IMPLEMENTATION_PLAN.md` — Detailed plan with requirement tracing
- [x] `decisions/INDEX.md` — No open decisions

### 003_CRE_VALIDATION

**Status**: Not Started

#### Sequences

- [ ] 01_cli_setup — Install, authenticate, hello-world, dry run
- [ ] 02_evm_validation — Deploy contract, EVM write, broadcast, document findings

### 004_FOUNDATION

**Status**: Not Started

#### Sequences

- [ ] 01_project_scaffold — `camp project new`, justfile
- [ ] 02_contract — Receipt contract, tests, deploy, EVM bindings

### 005_RISK_LOGIC

**Status**: Not Started

#### Sequences

- [ ] 01_types_and_helpers — Data types and utility functions
- [ ] 02_risk_gates — 8 risk gates implementation
- [ ] 03_evaluation_pipeline — Main evaluation function and fallback logic

### 006_WORKFLOW_INTEGRATION

**Status**: Not Started

#### Sequences

- [ ] 01_handlers — HTTP and cron trigger handlers
- [ ] 02_simulation — Dry run, broadcast, debug/iterate

### 007_SUBMISSION

**Status**: Not Started

#### Sequences

- [ ] 01_documentation — README, scenarios, e2e demo
- [ ] 02_evidence — Simulation logs, block explorer verification
- [ ] 03_publish — Moltbook draft, registration, review, publish

### 008_INTEGRATION

**Status**: Not Started (P1 — only if P0 stable)

#### Sequences

- [ ] 01_coordinator_bridge — CRE client in agent-coordinator
- [ ] 02_agent_signals — Inference fields, DeFi guard, HCS messages

---

## Blockers

None currently.

---

## Decision Log

- Repo structure: `projects/cre-risk-router/` in monorepo via `camp project new` (resolved)
- Price precision: 8-decimal standard matching Chainlink USD feeds (resolved)

---

*Detailed progress available via `fest status`*