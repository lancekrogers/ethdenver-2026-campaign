---
fest_type: sequence
fest_id: 03_zerog_compute_payment
fest_name: zerog compute payment
fest_parent: 001_IMPLEMENT
fest_order: 3
fest_status: pending
fest_created: 2026-02-21T17:48:50.667568-07:00
fest_tracking: true
---

# Sequence Goal: 03_zerog_compute_payment

**Sequence:** 03_zerog_compute_payment | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-21T17:48:50-07:00

## Sequence Objective

**Primary Goal:** Implement 0G Compute session-based payment auth and fill in missing environment variables so the inference agent can actually run paid inference against real 0G providers on Galileo testnet.

**Contribution to Phase Goal:** Provider discovery works (on-chain via the InferenceServing contract), but actual inference requests return 401 because the agent doesn't construct the required signed Bearer token. Without session auth, 0G Track 2 ($7k) cannot be demonstrated.

## Success Criteria

### Required Deliverables

- [ ] **Session auth**: Broker constructs signed `app-sk-<base64(msg:sig)>` Bearer tokens before inference requests
- [ ] **Environment config**: All `ZG_*` variables populated in `.env` with valid testnet values

### Quality Standards

- [ ] **Tests pass**: `cd projects/agent-inference && just test` passes
- [ ] **Auth header present**: Unit test verifies Authorization header is set on HTTP requests

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_implement_session_auth | Build Bearer token construction and 401 retry | Inference requests authenticate with providers |
| 02_configure_env_vars | Fill empty ZG_* variables | All 0G services have valid endpoints |

## Dependencies

### Prerequisites (from other sequences)

- 02_erc7857_inft_contract: Provides `ZG_INFT_CONTRACT` address needed for iNFT minting per inference

### Provides (to other sequences)

- Working 0G inference: Used by demo verification and 06_doc_accuracy

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 0G auth protocol may have changed since codebase was written | Medium | High | Check 0G docs and Discord for current auth format |
| Storage node endpoint may be unavailable | Low | Medium | Try multiple known endpoints |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Bearer token construction compiles and passes unit test
- [ ] **Milestone 2**: All environment variables populated with valid values
- [ ] **Milestone 3**: End-to-end inference request succeeds against Galileo provider

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
