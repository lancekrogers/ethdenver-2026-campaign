---
fest_type: sequence
fest_id: 01_handlers
fest_name: handlers
fest_parent: 004_WORKFLOW_INTEGRATION
fest_order: 1
fest_status: pending
fest_created: 2026-03-01T17:44:33.240471-07:00
fest_tracking: true
---

# Sequence Goal: 01_handlers

**Sequence:** 01_handlers | **Phase:** 004_WORKFLOW_INTEGRATION | **Status:** Pending | **Created:** 2026-03-01T17:44:33-07:00

## Sequence Objective

**Primary Goal:** Implement the CRE workflow trigger handlers: `onRiskEvaluation()` for HTTP trigger and `onScheduledSweep()` for cron trigger, both wiring through the full risk evaluation pipeline with external data fetching and on-chain receipt writing.

**Contribution to Phase Goal:** Provides the CRE handler functions that connect the risk evaluation logic to CRE's trigger system, enabling simulation and live operation.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **onRiskEvaluation() handler**: Parses `RiskRequest` from HTTP body, fetches market data via CRE HTTP capability, reads Chainlink feed via CRE EVM read capability, calls `evaluateRisk()`, writes receipt on-chain via CRE EVM write capability, returns `RiskDecision` as response
- [ ] **onScheduledSweep() handler**: Generates synthetic `RiskRequest` with hardcoded realistic parameters (buy signal, 0.85 confidence, risk_score 10, ETH/USD pair, $1000 position) and fresh `runtime.Now()` timestamp, runs same pipeline as HTTP handler
- [ ] **InitWorkflow() updated**: Both handlers registered with `cre.NewHandler` using appropriate triggers

### Quality Standards

- [ ] **CRE capability usage**: HTTP trigger, cron trigger, HTTP fetch, EVM read, and EVM write capabilities all exercised
- [ ] **Cron timestamp freshness**: Cron trigger uses `runtime.Now()` for timestamp so Gate 3 never triggers on staleness

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_http_trigger | Implement onRiskEvaluation() HTTP handler | Primary handler for live agent integration |
| 02_cron_trigger | Implement onScheduledSweep() cron handler | Simulation entry point for `cre workflow simulate` |

## Dependencies

### Prerequisites (from other sequences)

- 003_RISK_LOGIC/03_evaluation_pipeline: `evaluateRisk()` function complete
- 002_FOUNDATION/02_contract: Deployed contract address and Go EVM bindings
- 002_FOUNDATION/01_project_scaffold: `config.json` with all endpoint URLs

### Provides (to other sequences)

- Complete CRE workflow ready for simulation: Used by 02_simulation

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| CRE HTTP trigger format differs from expected | Med | Med | Study CRE SDK docs and hackathon skills repo examples |
| CoinGecko API rate limits during simulation | Med | Low | Fallback logic from Phase 003 handles this gracefully |
| EVM write gas estimation fails | Low | Med | Use fixed gas limit as fallback |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: HTTP trigger handler parses request and fetches data
- [ ] **Milestone 2**: Cron trigger handler generates synthetic request
- [ ] **Milestone 3**: Both handlers write receipts on-chain and return decisions

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete
- [ ] Performance benchmarks met

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed
- [ ] Standards compliance verified

### Iteration Decision

- [ ] Need another iteration? TBD after execution
- [ ] If yes, new tasks created: TBD
