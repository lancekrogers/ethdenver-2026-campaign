---
fest_type: sequence
fest_id: 02_token_launch
fest_name: token_launch
fest_parent: 004_BAGS_INTEGRATION
fest_order: 2
fest_status: pending
fest_created: 2026-03-13T02:20:39.839918-06:00
fest_tracking: true
---

# Sequence Goal: 02_token_launch

**Sequence:** 02_token_launch | **Phase:** 004_BAGS_INTEGRATION | **Status:** Pending | **Created:** 2026-03-13T02:20:39-06:00

## Sequence Objective

**Primary Goal:** Create the OBEY token on Bags with metadata, configure fee sharing (40% treasury / 30% performance pool / 20% holders / 10% creator), and launch on Meteora DBC with verified on-chain state and live trading.

**Contribution to Phase Goal:** This sequence produces the live OBEY token — the second revenue stream for the platform. Once launched, every trade generates 1% creator fees split among the configured recipients. The live token also satisfies the primary Bags hackathon requirement.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **OBEY token**: Created via Bags API with metadata (name: "OBEY Agent Economy", symbol: "OBEY", image, description linking to platform)
- [ ] **Fee sharing**: Configured with 4 recipients at 4000/3000/2000/1000 bps (treasury/performance/holders/creator)
- [ ] **Meteora DBC launch**: Token live on bonding curve, trading verified, mint address recorded, explorer link confirmed

### Quality Standards

- [ ] **On-chain verification**: Token mint, metadata, and fee sharing config verified on Solana explorer
- [ ] **Fee split accuracy**: Test trade confirms fee distribution matches configured bps

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_create_token.md | Create OBEY token via Bags API with metadata | Produces the token on-chain |
| 02_configure_fees.md | Set fee sharing: 40/30/20/10 split across 4 recipients | Configures revenue distribution |
| 03_launch_meteora.md | Launch on Meteora DBC, verify trading is live | Makes token tradeable |
| 04_testing.md | Quality gate: verify on-chain state | Ensures token and fees are correct |
| 05_review.md | Quality gate: review launch process | Validates launch execution |
| 06_iterate.md | Quality gate: address any issues | Resolves post-launch issues |
| 07_fest_commit.md | Quality gate: commit completed work | Finalizes deliverables |

## Dependencies

### Prerequisites (from other sequences)

- 01_bags_client: Bags API client (auth, token operations) for programmatic token creation

### Provides (to other sequences)

- OBEY token mint address: Used by 03_automated_claiming (fee claiming targets this token)
- Live token trading: Used by 005_GROWTH_ENGINE (OBEY airdrop incentives reference this token)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Token launch fails or gets stuck in Bags pipeline | Low | High | Test with a throwaway token first; have manual fallback via Bags UI |
| Fee sharing misconfigured | Low | High | Double-check bps values before launch; verify with test trade immediately after |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: OBEY token created with metadata on Solana
- [ ] **Milestone 2**: Fee sharing configured and verified
- [ ] **Milestone 3**: Token trading live on Meteora DBC

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
