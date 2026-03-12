---
fest_type: sequence
fest_id: 02_base_sepolia_evidence
fest_name: base-sepolia-evidence
fest_parent: 003_EVIDENCE
fest_order: 2
fest_status: pending
fest_created: 2026-03-11T05:02:32.003977-06:00
fest_tracking: true
---

# Sequence Goal: 02_base_sepolia_evidence

**Sequence:** 02_base_sepolia_evidence | **Phase:** 003_EVIDENCE | **Status:** Pending | **Created:** 2026-03-11T05:02:32-06:00

## Sequence Objective

**Primary Goal:** Generate 2+ write transactions on Base Sepolia (chain ID 84532) to produce verifiable on-chain evidence for the grant submission.

**Contribution to Phase Goal:** Provides the Base Sepolia transaction hashes and basescan links that grant reviewers need to verify our ERC-8004 identity and Uniswap V3 swap integrations.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Funded Base Sepolia Wallet**: Wallet funded with testnet ETH and USDC (0x036CbD53842c5426634e7929541eC2318f3dCF7e) on Base Sepolia
- [ ] **ERC-8004 Identity Registration**: Successful identity registration transaction on Base Sepolia via agent-defi, tx hash on basescan
- [ ] **Uniswap V3 Swap**: Successful swap transaction on Base Sepolia via agent-defi SwapRouter, tx hash on basescan

### Quality Standards

- [ ] **Transaction Verification**: Every tx hash verified on sepolia.basescan.org (not just claimed from logs)
- [ ] **Write Operations Only**: All transactions are state-changing write operations, not view calls

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 03_fund_base_wallet | Fund wallet with ETH + USDC on Base Sepolia | Prerequisite for all other transactions |
| 02_execute_identity_registration | Register ERC-8004 identity on Base Sepolia | Generates identity registration evidence tx |
| 01_execute_uniswap_swap | Execute Uniswap V3 swap on Base Sepolia | Generates swap evidence tx |

## Dependencies

### Prerequisites (from other sequences)

- None: This sequence runs independently from the 0G sequence. Requires only pre-phase checklist items (funded wallet, working RPC, agent-defi built).

### Provides (to other sequences)

- Base Sepolia transaction hashes: Used by 03_evidence_manifest for the final evidence compilation

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Base Sepolia faucet rate-limited | Med | High | Fund wallet early; use multiple faucet sources if needed |
| USDC faucet unavailable | Med | Med | Bridge USDC from another testnet or use alternative token pair for swap |
| agent-defi Base Sepolia config missing | Low | Med | Verify config before starting; update chain config if needed |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Wallet funded with ETH and USDC on Base Sepolia
- [ ] **Milestone 2**: ERC-8004 identity registration confirmed on basescan
- [ ] **Milestone 3**: Uniswap V3 swap confirmed on basescan

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
