---
fest_type: sequence
fest_id: 02_agent_runtime
fest_name: agent runtime
fest_parent: 001_IMPLEMENT
fest_order: 2
fest_status: completed
fest_created: 2026-03-13T19:19:51.990933-06:00
fest_updated: 2026-03-15T19:39:19.092706-06:00
fest_tracking: true
---


# Sequence Goal: 02_agent_runtime

**Sequence:** 02_agent_runtime | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-03-13T19:19:51-06:00

## Sequence Objective

**Primary Goal:** Build a Go agent runtime that autonomously trades through the vault using an LLM strategy, risk management, and a continuous trading loop.

**Contribution to Phase Goal:** The agent runtime is the autonomous actor that analyzes markets and executes trades through the vault's constrained interface. It demonstrates the core human-AI collaboration model: the agent is powerful but bounded.

## Working Directory

**Primary:** `projects/agent-defi/` (relative to campaign root)
**Absolute:** `/Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi/`

> **IMPORTANT:** Before executing ANY command in this sequence, navigate to the working directory first:
> ```bash
> cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi/
> ```
> All Go development, tests, and binary builds operate from this directory. Run `cd projects/agent-defi` before any `go` command.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Vault Client**: Go bindings (abigen) and VaultClient interface for reading vault state and submitting swaps
- [ ] **LLM Strategy**: Claude API-backed trading strategy that produces buy/sell/hold signals with JSON parsing
- [ ] **Risk Manager**: Position limits, drawdown halt, and daily volume cap enforcement
- [ ] **Trading Loop**: Runner that wires fetch -> analyze -> filter -> execute in a continuous cycle
- [ ] **Entry Point**: `vault-agent` binary with env-based configuration

### Quality Standards

- [ ] **Test Coverage**: All packages have unit tests with context cancellation tests
- [ ] **Compilation**: `go build ./cmd/vault-agent/` succeeds

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_vault_client | Go bindings and VaultClient interface | Provides the bridge between Go agent and on-chain vault |
| 02_llm_strategy | LLM trading strategy using Claude API | Gives the agent market analysis and decision-making capability |
| 03_risk_manager | Position limits, drawdown halt, daily volume cap | Adds off-chain risk guardrails complementing on-chain boundaries |
| 04_trading_loop | Runner wiring fetch -> analyze -> filter -> execute | Orchestrates all components into a continuous autonomous loop |
| 05_entry_point | vault-agent binary with env-based config | Produces the deployable binary that runs the agent |

## Dependencies

### Prerequisites (from other sequences)

- 01_vault_contract: Compiled ObeyVault ABI for abigen binding generation

### Provides (to other sequences)

- vault-agent binary: Used by 04_deploy_integrate (E2E testnet integration)
- VaultClient interface: Used by 05_submission (observer CLI)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| abigen compatibility with Foundry output | Med | Med | Extract ABI via jq from forge build output, test binding generation |
| Claude API rate limits during trading loop | Low | Med | 5-minute interval between cycles, exponential backoff on errors |
| Existing trading package interface mismatch | Med | Med | Check existing Strategy/TradeExecutor interfaces before implementing |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Vault client with Go bindings compiles and passes context cancellation tests (Task 1)
- [ ] **Milestone 2**: LLM strategy and risk manager with full test coverage (Tasks 2-3)
- [ ] **Milestone 3**: Trading loop runner and vault-agent binary compile and pass integration tests (Tasks 4-5)

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