---
fest_type: sequence
fest_id: 02_erc7857_inft_contract
fest_name: erc7857 inft contract
fest_parent: 001_IMPLEMENT
fest_order: 2
fest_status: pending
fest_created: 2026-02-21T17:48:50.667568-07:00
fest_tracking: true
---

# Sequence Goal: 02_erc7857_inft_contract

**Sequence:** 02_erc7857_inft_contract | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-21T17:48:50-07:00

## Sequence Objective

**Primary Goal:** Write, test, and deploy an ERC-7857 iNFT Solidity contract to the 0G Galileo testnet so the inference agent can mint real on-chain iNFTs — the core requirement for 0G Track 3.

**Contribution to Phase Goal:** The Go client code in `projects/agent-inference/internal/zerog/inft/minter.go` already calls `mint()`, `updateEncryptedMetadata()`, and `ownerOf()` against an on-chain contract, but `ZG_INFT_CONTRACT` is blank — there is no deployed contract. Without this contract, 0G Track 3 cannot be submitted.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **ERC-7857 Solidity contract**: `projects/contracts/src/AgentINFT.sol` implementing ERC-721 + encrypted metadata storage + the `mint`, `updateEncryptedMetadata`, and `ownerOf` functions that the Go minter expects
- [ ] **Forge test suite**: `projects/contracts/test/AgentINFT.t.sol` with tests for mint, metadata update, ownership, and encrypted data storage
- [ ] **Deployed contract address**: `ZG_INFT_CONTRACT` populated in `projects/agent-inference/.env` pointing to the deployed contract on 0G Galileo testnet

### Quality Standards

- [ ] **Forge tests pass**: `cd projects/contracts && forge test` passes including the new iNFT tests
- [ ] **ABI compatibility**: The contract's function signatures match what `minter.go` encodes — `mint(address,string,string,bytes,bytes32,string)` and `updateEncryptedMetadata(uint256,bytes)`

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_implement_erc7857_contract | Write the Solidity contract | Deployable ERC-7857 contract exists |
| 02_write_forge_tests | Write comprehensive Forge tests | Contract correctness verified |
| 03_deploy_and_configure | Deploy to Galileo and set env vars | Go minter can target the live contract |

## Dependencies

### Prerequisites (from other sequences)

- None — the existing Forge project in `projects/contracts/` has all tooling ready

### Provides (to other sequences)

- Deployed iNFT contract address: Used by 03_zerog_compute_payment (minting iNFTs per inference requires the contract)
- Updated contracts README: Used by 06_doc_accuracy

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 0G Galileo EVM RPC is unreliable for deployment | Medium | High | Have Hedera testnet EVM as fallback deployment target |
| ABI mismatch between Solidity and Go minter | Medium | High | Cross-reference minter.go ABI encoding before writing contract |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: AgentINFT.sol compiles with `forge build`
- [ ] **Milestone 2**: All Forge tests pass
- [ ] **Milestone 3**: Contract deployed and `ZG_INFT_CONTRACT` set

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete
- [ ] ABI compatibility verified against Go minter

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed
- [ ] Standards compliance verified

### Iteration Decision

- [ ] Need another iteration? No
- [ ] If yes, new tasks created: N/A
