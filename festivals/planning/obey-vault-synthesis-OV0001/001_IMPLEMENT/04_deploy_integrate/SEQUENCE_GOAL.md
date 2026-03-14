---
fest_type: sequence
fest_id: 04_deploy_integrate
fest_name: deploy integrate
fest_parent: 001_IMPLEMENT
fest_order: 4
fest_status: pending
fest_created: 2026-03-13T19:19:52.03234-06:00
fest_tracking: true
---

# Sequence Goal: 04_deploy_integrate

**Sequence:** 04_deploy_integrate | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-03-13T19:19:52-06:00

## Sequence Objective

**Primary Goal:** Deploy the vault to Base Sepolia and mainnet, register the agent via Synthesis API, run end-to-end integration testing, and complete a security review before mainnet launch.

**Contribution to Phase Goal:** This sequence takes all built components and makes them live on-chain. It validates the full system works end-to-end (deposit -> agent trades -> boundaries enforced -> NAV tracks) and ensures production readiness through security review before mainnet deployment with real USDC.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Sepolia Deployment**: Vault deployed to Base Sepolia with verified contract on Basescan
- [ ] **Agent Registration**: Agent registered via Synthesis API with ERC-8004 identity, participantId and apiKey recorded
- [ ] **E2E Integration**: Agent executes at least one swap on testnet, boundary enforcement verified on-chain
- [ ] **Security Review**: Manual code review documented covering role assignment, token extraction prevention, volume tracking, pause behavior, TWAP resistance
- [ ] **Mainnet Deployment**: Vault deployed to Base mainnet with initial USDC deposit

### Quality Standards

- [ ] **On-chain Verification**: SwapExecuted events visible on Basescan for testnet trades
- [ ] **Security**: No critical findings in code review, all boundary enforcement paths tested

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_deploy_sepolia | Deploy vault to Base Sepolia testnet | Provides testnet environment for integration testing |
| 02_register_agent | Register via Synthesis API (ERC-8004) | Gives the agent its on-chain identity for the hackathon |
| 03_e2e_testnet | End-to-end integration testing on testnet | Validates full system before mainnet |
| 04_security_review | Manual code review before mainnet | Ensures no critical vulnerabilities before real funds |
| 05_deploy_mainnet | Deploy to Base mainnet with real USDC | Goes live with production deployment |

## Dependencies

### Prerequisites (from other sequences)

- 01_vault_contract: Compiled vault contract and deploy script
- 02_agent_runtime: vault-agent binary ready to run
- 03_identity: Synthesis registration client

### Provides (to other sequences)

- Deployed vault addresses (testnet + mainnet): Used by 05_submission
- On-chain trade history: Used by 05_submission (demo recording)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Base Sepolia faucet unavailable for test USDC | Med | Med | Use alternative faucets, bridge from Goerli if needed |
| Security review finds critical issue | Low | High | Fix before mainnet, delay deployment if necessary |
| Mainnet gas costs exceed budget | Low | Med | Use small initial deposit (100 USDC), limit daily volume |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Vault deployed on Sepolia, agent registered (Tasks 1-2)
- [ ] **Milestone 2**: E2E integration passing with on-chain evidence (Task 3)
- [ ] **Milestone 3**: Security review clear, mainnet deployment live (Tasks 4-5)

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
