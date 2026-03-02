---
fest_type: sequence
fest_id: 02_contract
fest_name: contract
fest_parent: 002_FOUNDATION
fest_order: 2
fest_status: pending
fest_created: 2026-03-01T17:43:24.940113-07:00
fest_tracking: true
---

# Sequence Goal: 02_contract

**Sequence:** 02_contract | **Phase:** 002_FOUNDATION | **Status:** Pending | **Created:** 2026-03-01T17:43:24-07:00

## Sequence Objective

**Primary Goal:** Write, test, and deploy `RiskDecisionReceipt.sol` to a CRE-supported EVM testnet and generate Go EVM bindings from the contract ABI.

**Contribution to Phase Goal:** Provides the on-chain receipt contract that the CRE workflow writes decisions to. The contract address and generated Go bindings are required by Phase 003 (risk logic) and Phase 004 (workflow integration).

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **RiskDecisionReceipt.sol**: Contract implementing `recordDecision()`, `isDecisionValid()`, `getRunCount()` with events, storage mappings, and duplicate prevention per spec Section 7
- [ ] **Foundry tests**: 4 passing tests covering approved decision, denied decision, duplicate rejection, and TTL expiry via `vm.warp`
- [ ] **Testnet deployment**: Contract deployed to CRE-supported testnet with address captured and updated in `config.json`
- [ ] **EVM bindings**: Go bindings generated via `cre generate-bindings evm` from contract ABI, compiling without errors

### Quality Standards

- [ ] **Contract correctness**: All 4 Foundry tests pass with proper storage, event, and counter assertions
- [ ] **Binding compatibility**: Generated Go code compiles and matches the contract interface

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_receipt_contract | Write RiskDecisionReceipt.sol per spec Section 7 | Provides the on-chain receipt contract |
| 02_foundry_tests | Write 4 Foundry tests for contract scenarios | Validates contract correctness |
| 03_deploy_testnet | Deploy contract to CRE-supported testnet | Makes the contract available for CRE workflow writes |
| 04_evm_bindings | Generate Go bindings from contract ABI | Provides Go interface for calling the contract from the workflow |

## Dependencies

### Prerequisites (from other sequences)

- 01_project_scaffold: Scaffolded project with directory structure and `foundry.toml`
- 001_CRE_VALIDATION/02_evm_validation: Validated testnet, deployment patterns

### Provides (to other sequences)

- Deployed contract address in `config.json`: Used by 004_WORKFLOW_INTEGRATION/01_handlers
- Generated Go EVM bindings: Used by 003_RISK_LOGIC and 004_WORKFLOW_INTEGRATION

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Chainlink price feed addresses unavailable on chosen testnet | Med | Med | Check Chainlink data feeds page; use alternative testnet if needed |
| `cre generate-bindings evm` has unexpected behavior | Med | Med | Fall back to manual Go binding generation from ABI |
| Testnet deployment fails or is flaky | Low | Med | Retry with different RPC endpoint or faucet refill |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Contract written and compiling
- [ ] **Milestone 2**: All 4 Foundry tests passing
- [ ] **Milestone 3**: Contract deployed, bindings generated, `config.json` updated

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
