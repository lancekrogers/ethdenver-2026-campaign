---
fest_type: sequence
fest_id: 02_unblock_0g
fest_name: unblock_0g
fest_parent: 003_EXECUTE
fest_order: 2
fest_status: pending
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Sequence Goal: 02_unblock_0g

**Sequence:** 02_unblock_0g | **Phase:** 003_EXECUTE | **Status:** Pending | **Created:** 2026-02-21T09:45:00-07:00

## Sequence Objective

**Primary Goal:** Get the inference agent executing real inference on 0G Compute by fixing the serving contract ABI mismatch, verifying storage and iNFT capabilities, and confirming the agent connects to a live provider on Galileo testnet.

**Contribution to Phase Goal:** The inference agent is the AI brain of the economy cycle. Without working 0G Compute, the E2E tests in sequence 04 cannot run inference tasks and the 0G track submission packages (06 and 07) cannot demonstrate real capabilities. This sequence unblocks everything downstream that depends on inference working.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Working ABI**: `broker.go` calls `getAllServices(0, 100)` and `getService(address)` — the real contract methods — instead of the non-existent `getServiceCount()`/`getService(uint256)` pair
- [ ] **Provider Discovery**: `listFromChain()` returns at least one provider from the live Galileo testnet contract at `0xa79F4c8311FF93C06b8CfB403690cc987c93F91E`
- [ ] **Live Inference**: A real inference request submitted to a discovered provider completes successfully (or documents the specific failure if the provider is unresponsive)
- [ ] **Storage Verified**: 0G Storage upload/download confirmed working with the Flow contract
- [ ] **iNFT Status**: ERC-7857 iNFT contract status documented (deployed or needs deployment) and test mint attempted

### Quality Standards

- [ ] All existing tests pass after ABI changes
- [ ] ABI JSON is accurate to the real contract — no guessed method signatures
- [ ] Error handling is preserved: context cancellation, provider failures, empty service lists
- [ ] No new `fmt.Errorf` calls — use existing error wrapping pattern

### Completion Criteria

- [ ] All 5 implementation tasks completed
- [ ] Testing gate passed (`go test ./...` clean)
- [ ] Code review completed and findings addressed
- [ ] Changes committed and pushed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_set_serving_contract.md | Set `ZG_SERVING_CONTRACT` env var | Points the broker at the real pre-deployed contract |
| 02_fix_serving_abi.md | Fix ABI mismatch in `broker.go` | Enables `listFromChain()` to actually decode responses |
| 03_test_0g_compute.md | Verify compute works end-to-end | Proves the fix works against the live contract |
| 04_test_0g_storage.md | Verify 0G Storage upload/download | Confirms storage side of the inference pipeline |
| 05_test_0g_inft.md | Check and test iNFT contract | Validates or unblocks ERC-7857 agent identity |
| 06_testing.md | Quality gate: run test suite | Verifies no regressions from ABI changes |
| 07_review.md | Quality gate: code review | Reviews ABI fix correctness and style compliance |
| 08_iterate.md | Quality gate: iterate | Addresses review and test findings |
| 09_fest_commit.md | Quality gate: commit | Commits all changes with proper message |

## Dependencies

### Prerequisites (from other sequences)

- None. This sequence runs in parallel with 01_dashboard_verify and 03_unblock_base. It has no dependency on any other sequence in this phase.

### Provides (to other sequences)

- **04_e2e_testing**: Working inference is required for the full economy cycle test. This sequence must complete before E2E testing can proceed.
- **06_zerog_track2_package**: The 0G Track 2 package documents compute integration — needs a working demo.
- **07_zerog_track3_package**: The 0G Track 3 package documents storage + iNFT — needs verified storage and iNFT status.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Real contract ABI differs from documented spec | Medium | High | Read the actual ABI from Galileo testnet via `cast abi-encode` or block explorer before coding |
| No active providers on testnet | Medium | High | Fall back to HTTP endpoint if chain returns empty list; document the gap |
| iNFT contract not deployed on 0G Chain | Medium | Medium | Deploy using go-ethereum + foundry; treat as a subtask of 05 |
| Galileo RPC unstable during testing | Low | Medium | Retry with backoff; document if persistent |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Contract address configured, ABI updated, `go build ./...` passes
- [ ] **Milestone 2**: `listFromChain()` returns at least one provider from live testnet
- [ ] **Milestone 3**: Compute, storage, and iNFT tests complete; all quality gates passed; changes committed
