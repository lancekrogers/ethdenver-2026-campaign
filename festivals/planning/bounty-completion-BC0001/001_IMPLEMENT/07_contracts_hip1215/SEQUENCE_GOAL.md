---
fest_type: sequence
fest_id: 07_contracts_hip1215
fest_name: contracts hip1215
fest_parent: 001_IMPLEMENT
fest_order: 7
fest_status: pending
fest_created: 2026-02-21T17:48:56.77726-07:00
fest_tracking: true
---

# Sequence Goal: 07_contracts_hip1215

**Sequence:** 07_contracts_hip1215 | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-21T17:48:56-07:00

## Sequence Objective

**Primary Goal:** Add HIP-1215 Scheduled Transaction support to AgentSettlement.sol and ReputationDecay.sol by integrating the Hedera Schedule Service system contract at address 0x167, enabling time-delayed batch settlements and automated reputation decay.

**Contribution to Phase Goal:** Hedera Track 1 ($15k) values use of native Hedera services. HIP-1215 scheduled transactions are a differentiating Hedera-native feature that strengthens the submission by demonstrating the contracts leverage Hedera's unique capabilities rather than being generic EVM contracts.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **IHederaScheduleService interface**: Solidity interface for the system contract at 0x167 with `hasScheduleCapacity()` and `scheduleNative()` functions
- [ ] **scheduleBatchSettle function**: New function in AgentSettlement.sol that checks capacity then schedules a future batch settlement via HIP-1215
- [ ] **scheduleDecay function**: New function in ReputationDecay.sol that schedules automated periodic decay via HIP-1215
- [ ] **Hedera RPC profile**: Foundry profile in foundry.toml targeting Hedera testnet JSON-RPC for deployment

### Quality Standards

- [ ] **Tests pass**: `cd projects/contracts && forge test` passes including new scheduling tests
- [ ] **No regressions**: All existing AgentSettlement and ReputationDecay tests still pass

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_integrate_hip1215_scheduling | Add IHederaScheduleService interface and scheduling functions to both contracts | Contracts can schedule future settlements and decay |
| 02_add_hedera_rpc_profile | Add Hedera testnet RPC profile to foundry.toml | Contracts deployable to Hedera testnet |
| 03_update_forge_tests | Add Forge tests mocking the HIP-1215 system contract | Scheduling logic verified without Hedera node |

## Dependencies

### Prerequisites (from other sequences)

- None: AgentSettlement.sol and ReputationDecay.sol already exist and compile

### Provides (to other sequences)

- HIP-1215 integration: Strengthens Hedera Track 1 submission, used by 002_REVIEW phase

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| HIP-1215 system contract interface may differ from docs | Medium | High | Check Hedera GitHub for canonical IHederaScheduleService.sol interface |
| vm.mockCall may not work cleanly for system contract | Low | Medium | Use vm.etch to place code at 0x167 before mocking |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: IHederaScheduleService interface created and both contracts compile with new functions
- [ ] **Milestone 2**: Forge tests pass with mocked system contract
- [ ] **Milestone 3**: Hedera RPC profile added to foundry.toml

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed

### Iteration Decision

- [ ] Need another iteration? No
- [ ] If yes, new tasks created: N/A
