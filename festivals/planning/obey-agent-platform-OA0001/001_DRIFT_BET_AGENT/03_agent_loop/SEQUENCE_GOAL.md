---
fest_type: sequence
fest_id: 03_agent_loop
fest_name: agent_loop
fest_parent: 001_DRIFT_BET_AGENT
fest_order: 3
fest_status: pending
fest_created: 2026-03-13T02:20:31.109226-06:00
fest_tracking: true
---

# Sequence Goal: 03_agent_loop

**Sequence:** 03_agent_loop | **Phase:** 001_DRIFT_BET_AGENT | **Status:** Pending | **Created:** 2026-03-13T02:20:31-06:00

## Sequence Objective

**Primary Goal:** Wire the Drift client and analysis pipeline into a complete agent execution loop with configurable intervals, risk management, portfolio tracking, NAV calculation, and a mock mode for dry-run testing.

**Contribution to Phase Goal:** This sequence assembles the individual components (Drift client, analysis pipeline) into a running agent binary. It adds the operational layer: configuration, scheduling, risk enforcement, position tracking, and testability. The output is a deployable agent ready for mainnet.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Agent config**: Configuration loaded from environment variables (PRED_ prefix) covering Solana wallet path, Drift API endpoint, Claude API key, trading interval, risk parameters
- [ ] **Execution loop**: Goroutine-based loop with three cycles: trading (15min), P&L reporting (5min), health checks (30s) following existing agent-defi patterns
- [ ] **Risk manager**: Position sizing enforcing max % of NAV per position, stop-loss at configurable drawdown %, concentration limits per market, daily loss limit
- [ ] **Portfolio tracker**: Tracks open Drift BET positions, calculates NAV from current position values plus cash, generates P&L reports for HCS
- [ ] **Mock mode**: Full mock adapters (Drift, Claude) for dry-run testing exercising identical code paths without real funds

### Quality Standards

- [ ] **Graceful shutdown**: Agent handles SIGTERM/SIGINT, cancels context, waits for in-flight operations
- [ ] **No goroutine leaks**: All goroutines tied to context cancellation and verified via testing

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_config.md | Agent config from env vars, wallet loading, interval settings | Configuration foundation for all agent components |
| 02_execution_loop.md | Goroutine-based loop with trading, P&L, and health cycles | Core scheduling and orchestration |
| 03_risk_manager.md | Position sizing, drawdown limits, concentration checks | Prevents catastrophic losses |
| 04_portfolio_tracker.md | Position tracking, NAV calculation, P&L reporting via HCS | NAV for risk decisions and external visibility |
| 05_mock_mode.md | Mock adapters for dry-run testing | Full agent testing without real funds |
| 06_testing.md | Quality gate: run full test suite | Ensures agent loop operates correctly |
| 07_review.md | Quality gate: code review | Validates architecture and risk logic |
| 08_iterate.md | Quality gate: address review feedback | Resolves any issues found |
| 09_fest_commit.md | Quality gate: commit completed work | Finalizes sequence deliverables |

## Dependencies

### Prerequisites (from other sequences)

- 01_drift_client: DriftBETAdapter for market access and trade execution
- 02_analysis_pipeline: Analysis engine and Signal types for trading decisions

### Provides (to other sequences)

- Complete agent binary: Used by 04_mainnet_deployment (deployed to production)
- Portfolio tracker NAV calculation: Used by 002_MVP_VAULT/03_agent_vault_client (on-chain NAV updates)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Agent executes too many trades consuming seed capital in fees | Med | High | Risk manager enforces daily trade count and loss limits |
| Goroutine leak causes memory growth over time | Low | Med | Context-based goroutine lifecycle; memory monitoring in health check |
| Config drift between mock and live mode | Low | Med | Mock adapters implement identical interface; shared config struct |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Agent starts, loads config, connects to Drift (or mock)
- [ ] **Milestone 2**: Execution loop runs trading cycle with risk checks
- [ ] **Milestone 3**: Mock mode passes full dry-run with simulated market data

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

- [ ] Need another iteration? No
- [ ] If yes, new tasks created: N/A
