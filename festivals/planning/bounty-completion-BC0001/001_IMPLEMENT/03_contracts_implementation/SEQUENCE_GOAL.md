---
fest_type: sequence
fest_id: 03_contracts_implementation
fest_name: contracts implementation
fest_parent: bounty-completion-BC0001
fest_order: 3
fest_status: pending
fest_created: 2026-02-21T16:43:00.366479-07:00
fest_tracking: true
---

# Sequence Goal: 03_contracts_implementation

**Sequence:** 03_contracts_implementation | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-21T16:43:00-07:00

## Sequence Objective

**Primary Goal:** Implement `AgentSettlement.sol` and `ReputationDecay.sol` from scratch, write Forge tests that pass for both, and produce a deploy script for Hedera testnet EVM — qualifying the project for Hedera Track 2.

**Contribution to Phase Goal:** Hedera Track 2 requires demonstrable on-chain smart contract functionality. The contracts directory currently has no implemented Solidity. This sequence delivers two purpose-built contracts with real business logic, a complete test suite, and a deploy script — providing the on-chain evidence needed for Track 2 qualification.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **AgentSettlement.sol**: Ownable contract with `settle`, `batchSettle`, and `AgentPaid` event — compiles with `forge build`
- [ ] **ReputationDecay.sol**: Contract with `updateReputation`, `getReputation`, and configurable linear time-decay — compiles with `forge build`
- [ ] **Forge tests**: Both contracts have tests covering settle, batch, access control, decay math, and edge cases — all pass with `forge test`
- [ ] **Deploy script**: `Deploy.s.sol` deploys both contracts to Hedera testnet EVM and outputs addresses

### Quality Standards

- [ ] **Forge build clean**: `forge build` exits 0 with no errors or warnings before tests are written
- [ ] **Forge test passing**: `forge test` exits 0 with all test cases green
- [ ] **Solidity best practices**: Checks-effects-interactions pattern, named return values, custom errors, events on all state changes

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_forge_setup.md | Verify foundry.toml, install OZ deps, confirm `forge build` works | Foundation for all contract tasks |
| 02_implement_settlement.md | Write AgentSettlement.sol | Delivers settlement contract deliverable |
| 03_implement_reputation.md | Write ReputationDecay.sol | Delivers reputation contract deliverable |
| 04_write_tests.md | Write Forge tests for both contracts | Delivers test suite deliverable |
| 05_deploy_script.md | Write Deploy.s.sol for Hedera testnet EVM | Delivers deploy script deliverable |
| 06_testing.md | Run `forge test` and verify all pass | Confirms deliverables meet quality standards |
| 07_review.md | Code review both contracts and tests | Ensures Solidity best practices |
| 08_iterate.md | Address review feedback | Final iteration gate |
| 09_fest_commit.md | Commit and record completion | Marks sequence done |

## Dependencies

### Prerequisites (from other sequences)

- None: This sequence is standalone. The only prerequisite is that Foundry is installed in the development environment.

### Provides (to other sequences)

- Hedera Track 2 qualification: Deployed contract addresses and `forge test` passing consumed by 002_REVIEW phase

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Hedera testnet EVM incompatibility with Solidity features | Med | Med | Use Solidity 0.8.x and avoid assembly; test with Hedera EVM version in foundry.toml |
| OpenZeppelin version conflicts | Low | Low | Pin OZ version in foundry.toml remappings |
| Decay math overflow for large reputation values | Med | Med | Use SafeMath or checked arithmetic (default in 0.8.x); test with boundary values |
| Deploy script fails due to Hedera RPC differences | Med | Low | Test deploy locally with `forge script --fork-url` before testnet deployment |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: `forge build` passes with both contracts compiling cleanly
- [ ] **Milestone 2**: `forge test` passes with all test cases green
- [ ] **Milestone 3**: Deploy script runs against Hedera testnet EVM and outputs deployed addresses

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
