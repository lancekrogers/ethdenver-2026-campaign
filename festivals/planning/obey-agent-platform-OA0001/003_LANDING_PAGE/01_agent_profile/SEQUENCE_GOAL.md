---
fest_type: sequence
fest_id: 01_agent_profile
fest_name: agent_profile
fest_parent: 003_LANDING_PAGE
fest_order: 1
fest_status: pending
fest_created: 2026-03-13T02:20:39.746429-06:00
fest_tracking: true
---

# Sequence Goal: 01_agent_profile

**Sequence:** 01_agent_profile | **Phase:** 003_LANDING_PAGE | **Status:** Pending | **Created:** 2026-03-13T02:20:39-06:00

## Sequence Objective

**Primary Goal:** Build REST API endpoints serving agent performance data and a Next.js agent profile page displaying live NAV chart, trade history, performance metrics, and strategy description.

**Contribution to Phase Goal:** The agent profile is the primary trust-building element. Visitors need to see live proof of performance (NAV growth, win rate, trade history) before depositing. This sequence provides both the data layer and the visual presentation.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Data API**: REST endpoints for agent stats (NAV, return %, win rate, Sharpe, max drawdown, trade count), trade history (paginated), and NAV chart time-series data
- [ ] **Profile page**: Next.js page at /agents/:id showing NAV chart (Recharts), trade history table, strategy description, risk profile section, and depositor stats
- [ ] **Performance metrics**: Calculated values: return %, win rate, Sharpe ratio, max drawdown, average holding period, trade count — displayed with appropriate formatting

### Quality Standards

- [ ] **Data freshness**: NAV chart updates within 5 minutes of on-chain NAV change
- [ ] **Responsive**: Profile page renders correctly on desktop (1200px+) and tablet (768px+)

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_data_api.md | REST API for agent stats, trade history, NAV chart data | Provides data layer for frontend |
| 02_profile_page.md | Next.js page with NAV chart, trades, strategy, status | Visual presentation of agent performance |
| 03_performance_metrics.md | Calculate and display return, Sharpe, drawdown, win rate | Quantitative trust signals for depositors |
| 04_testing.md | Quality gate: run full test suite | Ensures API and UI work correctly |
| 05_review.md | Quality gate: code review | Validates data accuracy and UI quality |
| 06_iterate.md | Quality gate: address review feedback | Resolves issues |
| 07_fest_commit.md | Quality gate: commit completed work | Finalizes deliverables |

## Dependencies

### Prerequisites (from other sequences)

- 002_MVP_VAULT/03_agent_vault_client: On-chain NAV data for API reads
- 001_DRIFT_BET_AGENT/04_mainnet_deployment: HCS trade data stream for trade history

### Provides (to other sequences)

- Agent profile page and data API: Used by 02_deposit_flow (deposit button on profile) and 03_landing_design (featured agent card)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Trade history data volume grows large | Low | Low | Paginate API responses; index by agent_id + timestamp |
| NAV chart data gaps from missed updates | Low | Med | Interpolate gaps; show last-known NAV with staleness indicator |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: REST API returns agent stats and trade history
- [ ] **Milestone 2**: Profile page renders with NAV chart and trade table
- [ ] **Milestone 3**: Performance metrics calculated and displayed correctly

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
