---
fest_type: sequence
fest_id: 02_hts_service
fest_name: hts_service
fest_parent: 001_IMPLEMENT
fest_order: 2
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 02_hts_service

**Sequence:** 02_hts_service | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Build a complete HTS (Hedera Token Service) package that provides token creation and token transfer operations for the agent payment flow in the agent-coordinator project.

**Contribution to Phase Goal:** This sequence delivers the payment infrastructure that the coordinator uses to settle agent compensation. When an agent completes a task and passes quality gates, the coordinator triggers an HTS token transfer as payment. Without this package, the coordinator cannot complete the plan-to-payment cycle that is the core demo for the Hedera Track 3 bounty.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **HTS Interface Definitions**: Clean Go interfaces for TokenCreator and TokenTransfer defined in `internal/hedera/hts/interfaces.go`
- [ ] **Token Creation**: Working token creation on Hedera testnet in `internal/hedera/hts/token.go`
- [ ] **Token Transfer**: Working token transfer between agent accounts in `internal/hedera/hts/transfer.go`
- [ ] **Token ID Management**: Design for tracking token IDs across the agent payment flow

### Quality Standards

- [ ] **Context Propagation**: All I/O functions accept `context.Context` as first parameter and respect cancellation
- [ ] **Error Wrapping**: All errors wrapped with operational context (token ID, account IDs, amounts)
- [ ] **Table-Driven Tests**: Unit tests cover happy path, error cases, and context cancellation
- [ ] **Code Size**: No file exceeds 500 lines, no function exceeds 50 lines
- [ ] **Zero Solidity**: All HTS operations use the native Hedera Go SDK only

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Package can be imported and used by the coordinator for payment settlement

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_design_hts_package.md | Design interfaces and token ID management | Establishes the contract for token operations |
| 02_implement_token_create.md | Implement token creation | Delivers the TokenCreator interface implementation |
| 03_implement_token_transfer.md | Implement token transfers | Delivers the TokenTransfer interface implementation |
| 04_testing_and_verify.md | Test all HTS operations | Quality gate: verifies implementations work |
| 05_code_review.md | Review code quality | Quality gate: ensures standards compliance |
| 06_review_results_iterate.md | Address findings | Quality gate: resolves issues |

## Dependencies

### Prerequisites (from other sequences)

- **01_hcs_service**: Project must be linked (task 01) and Hedera Go SDK must be available in go.mod

### Provides (to other sequences)

- **HTS Package**: Used by 04_coordinator for payment settlement after task completion
- **Token Management Patterns**: Used by 06_integration for testnet account setup and E2E testing

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Testnet HBAR insufficient for token operations | Medium | Medium | Pre-fund accounts via faucet, document minimum HBAR requirements |
| Token association complexity for multi-agent setup | Medium | High | Design clear account-to-token association flow, test with 3+ accounts |
| HTS transaction fees on testnet | Low | Low | Monitor fees, use small token amounts for testing |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: HTS interfaces designed and reviewed
- [ ] **Milestone 2**: Token creation and transfer both implemented and compiling
- [ ] **Milestone 3**: All quality gates passed, package ready for coordinator consumption

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass with `go test ./internal/hedera/hts/...`
- [ ] Context cancellation tests verify graceful handling
- [ ] Token transfer tests verify multi-account scenarios

### Code Review

- [ ] Code review conducted against project standards
- [ ] `go vet` and `staticcheck` pass with no warnings

### Iteration Decision

- [ ] Need another iteration? To be determined after code review
- [ ] If yes, new tasks created with specific findings
