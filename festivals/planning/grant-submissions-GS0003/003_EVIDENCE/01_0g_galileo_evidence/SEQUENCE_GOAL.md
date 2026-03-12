---
fest_type: sequence
fest_id: 01_0g_galileo_evidence
fest_name: 0g-galileo-evidence
fest_parent: 003_EVIDENCE
fest_order: 1
fest_status: pending
fest_created: 2026-03-11T05:02:28.582903-06:00
fest_tracking: true
---

# Sequence Goal: 01_0g_galileo_evidence

**Sequence:** 01_0g_galileo_evidence | **Phase:** 003_EVIDENCE | **Status:** Pending | **Created:** 2026-03-11T05:02:28-06:00

## Sequence Objective

**Primary Goal:** Generate 4+ write transactions on the 0G Galileo testnet (chain ID 16602) to produce verifiable on-chain evidence for the grant submission.

**Contribution to Phase Goal:** Provides the core 0G-specific transaction hashes and chainscan links that grant reviewers need to verify our integration with 0G Storage, DA, and iNFT systems.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Funded Galileo Wallet**: Wallet funded with testnet A0GI via faucet.0g.ai, confirmed balance on chainscan
- [ ] **Deployed AgentINFT Contract**: AgentINFT.sol deployed to 0G Galileo with verified contract address on chainscan
- [ ] **Storage Submit Transaction**: Successful `submit()` call to the 0G Storage Flow contract (0x22E03a6A89B950F1c82ec5e74F8eCa321a105296)
- [ ] **DA Submit Transaction**: Successful `submitOriginalData()` call to the 0G DA Entrance contract (0xE75A073dA5bb7b0eC622170Fd268f35E675a957B)
- [ ] **iNFT Mint Transaction**: Successful `mint()` call on the deployed AgentINFT contract with token ID recorded

### Quality Standards

- [ ] **Transaction Verification**: Every tx hash verified on chainscan.io (not just claimed from logs)
- [ ] **Write Operations Only**: All transactions are state-changing write operations, not view calls

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 05_fund_galileo_wallet | Fund wallet via 0G faucet | Prerequisite for all other transactions |
| 04_deploy_agent_inft | Deploy AgentINFT.sol to Galileo | Provides contract address for iNFT mint |
| 03_execute_storage_submit | Execute Storage submit() | Generates storage layer evidence tx |
| 02_execute_da_submit | Execute DA submitOriginalData() | Generates DA layer evidence tx |
| 01_execute_inft_mint | Execute iNFT mint() | Generates iNFT minting evidence tx |

## Dependencies

### Prerequisites (from other sequences)

- None: This is the first sequence in the phase. Requires only pre-phase checklist items (funded wallet, working RPC, compiled contracts).

### Provides (to other sequences)

- 0G Galileo transaction hashes and contract addresses: Used by 03_evidence_manifest for the final evidence compilation

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 0G faucet rate-limited or down | Med | High | Try faucet early; have backup funded wallet ready |
| RPC endpoint unreliable | Low | High | Use alternative RPC endpoints if available; retry with backoff |
| Contract deployment fails on Galileo | Low | Med | Test locally with fork first; verify Solidity version compatibility |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Wallet funded and confirmed on chainscan
- [ ] **Milestone 2**: AgentINFT.sol deployed, contract address recorded
- [ ] **Milestone 3**: All 4 write transactions (deploy, storage, DA, mint) confirmed on chainscan

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
