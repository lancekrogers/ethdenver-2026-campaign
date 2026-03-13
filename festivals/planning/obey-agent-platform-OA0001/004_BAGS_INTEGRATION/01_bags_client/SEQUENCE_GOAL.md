---
fest_type: sequence
fest_id: 01_bags_client
fest_name: bags_client
fest_parent: 004_BAGS_INTEGRATION
fest_order: 1
fest_status: pending
fest_created: 2026-03-13T02:20:39.815079-06:00
fest_tracking: true
---

# Sequence Goal: 01_bags_client

**Sequence:** 01_bags_client | **Phase:** 004_BAGS_INTEGRATION | **Status:** Pending | **Created:** 2026-03-13T02:20:39-06:00

## Sequence Objective

**Primary Goal:** Implement a Go client for the Bags API covering agent authentication (JWT), token creation/metadata, swap operations, and fee claiming — providing the foundation for OBEY token launch and automated revenue collection.

**Contribution to Phase Goal:** Every Bags integration operation depends on this client. Token launch, fee configuration, fee claiming, and metrics reporting all use these API clients. Without them, the OBEY token cannot be created or managed programmatically.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Auth client**: Agent registration with Bags, Moltbook JWT acquisition (365-day token), automatic token refresh before expiration
- [ ] **Token client**: Create token with metadata (name, symbol, image, description), configure fee sharing with multiple recipients and basis point splits
- [ ] **Trading client**: Get swap quote and execute swap transactions for OBEY token
- [ ] **Fee client**: List claimable fee positions, generate claim transactions (V3), sign and submit claims, verify receipt on-chain

### Quality Standards

- [ ] **Retry logic**: All API calls include retry with exponential backoff on transient failures
- [ ] **JWT management**: Token refresh handled automatically with thread-safe access

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_auth_client.md | Agent registration, JWT acquisition, token refresh | Authentication foundation for all Bags operations |
| 02_token_client.md | Create token, set metadata, configure fee sharing | Enables OBEY token creation and configuration |
| 03_trading_client.md | Quote and swap operations | Enables programmatic OBEY token trading |
| 04_fee_client.md | List claimable fees, execute claims, verify | Enables automated revenue collection |
| 05_testing.md | Quality gate: run full test suite | Validates all client operations |
| 06_review.md | Quality gate: code review | Validates API integration quality |
| 07_iterate.md | Quality gate: address review feedback | Resolves issues |
| 08_fest_commit.md | Quality gate: commit completed work | Finalizes deliverables |

## Dependencies

### Prerequisites (from other sequences)

- None (this sequence can start independently; Bags API access is the only external dependency)

### Provides (to other sequences)

- Bags API client package: Used by 02_token_launch (token creation) and 03_automated_claiming (fee collection)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Bags API changes or is undocumented | Med | High | Review existing Bags integration code in codebase; test against live API early |
| JWT expiration causes missed fee claims | Low | Med | Auto-refresh well before expiration; alert on refresh failures |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Auth client acquires and refreshes JWT successfully
- [ ] **Milestone 2**: Token client creates test token with fee sharing config
- [ ] **Milestone 3**: Fee client lists and claims test fees

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
