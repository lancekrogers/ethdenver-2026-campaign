---
fest_type: sequence
fest_id: 04_mainnet_deployment
fest_name: mainnet_deployment
fest_parent: 001_DRIFT_BET_AGENT
fest_order: 4
fest_status: pending
fest_created: 2026-03-13T02:20:31.127377-06:00
fest_tracking: true
---

# Sequence Goal: 04_mainnet_deployment

**Sequence:** 04_mainnet_deployment | **Phase:** 001_DRIFT_BET_AGENT | **Status:** Pending | **Created:** 2026-03-13T02:20:31-06:00

## Sequence Objective

**Primary Goal:** Deploy the prediction market agent to Solana mainnet with a funded wallet, verify live trading with small positions, integrate HCS reporting, and confirm 24-hour operational stability.

**Contribution to Phase Goal:** This sequence takes the tested agent binary and puts it into production. A successful 24-hour monitored run with real trades on Drift BET completes the phase and proves the core thesis that AI agents can profitably trade prediction markets autonomously.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Funded Solana wallet**: Generated agent keypair funded with SOL for gas and $5K-$10K USDC seed capital
- [ ] **Mainnet deployment**: Agent binary running and verified trading live Drift BET markets, monitored for 24h with no crashes
- [ ] **HCS integration**: Agent broadcasting trade events and P&L reports to coordinator HCS topics

### Quality Standards

- [ ] **Conservative sizing**: Initial positions capped at 2% of seed capital until 24h stability confirmed
- [ ] **Real-time monitoring**: Logs, health checks, and HCS messages visible during observation period

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_solana_wallet_setup.md | Generate wallet, fund with SOL + USDC seed capital | Provides funded wallet for mainnet trading |
| 02_deploy_and_verify.md | Deploy agent, verify live trading, monitor 24h | Validates agent on mainnet |
| 03_hcs_integration.md | Connect to HCS topics, broadcast trades and P&L | External visibility and coordination |
| 04_testing.md | Quality gate: verify deployment health | Ensures stability requirements met |
| 05_review.md | Quality gate: deployment review | Validates process and monitoring |
| 06_iterate.md | Quality gate: address issues from 24h monitoring | Resolves mainnet-specific issues |
| 07_fest_commit.md | Quality gate: commit completed work | Finalizes sequence deliverables |

## Dependencies

### Prerequisites (from other sequences)

- 03_agent_loop: Complete agent binary with risk management and portfolio tracking

### Provides (to other sequences)

- Live mainnet agent with known wallet address: Used by 002_MVP_VAULT (vault points to agent wallet)
- HCS trade/P&L data stream: Used by 003_LANDING_PAGE (data source for agent profile)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Agent loses significant capital in first 24h | Low | High | 15% max drawdown stop-loss; 2% max position size; manual kill switch |
| Solana RPC unreliability | Low | Med | Multiple RPC endpoints with failover (Helius/Triton) |
| HCS publish failures | Low | Low | Non-blocking; agent continues trading; retry with backoff |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Wallet created, funded, agent deployed to mainnet
- [ ] **Milestone 2**: First successful live trade on Drift BET
- [ ] **Milestone 3**: 24-hour monitored run complete with stable operation

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
