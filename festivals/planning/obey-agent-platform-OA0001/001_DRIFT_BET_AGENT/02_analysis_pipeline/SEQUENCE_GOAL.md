---
fest_type: sequence
fest_id: 02_analysis_pipeline
fest_name: analysis_pipeline
fest_parent: 001_DRIFT_BET_AGENT
fest_order: 2
fest_status: pending
fest_created: 2026-03-13T02:20:31.090692-06:00
fest_tracking: true
---

# Sequence Goal: 02_analysis_pipeline

**Sequence:** 02_analysis_pipeline | **Phase:** 001_DRIFT_BET_AGENT | **Status:** Pending | **Created:** 2026-03-13T02:20:31-06:00

## Sequence Objective

**Primary Goal:** Build a Claude-powered analysis pipeline that normalizes Drift BET market data, parses resolution rules, estimates event probabilities, and generates trading signals with edge, confidence, and position sizing recommendations.

**Contribution to Phase Goal:** The analysis pipeline is the agent's intelligence layer. It transforms raw market data into actionable trading signals. Without it, the agent has market access (from 01_drift_client) but no ability to identify profitable opportunities.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Claude API client**: Go client for Claude API with structured market analysis prompts and response parsing into typed structs
- [ ] **Market normalizer**: NormalizedMarket struct population from Drift BET market data (question, resolution rules, outcomes with prices, volume, liquidity, expiry)
- [ ] **Resolution analyzer**: LLM prompt chain that parses resolution rules precisely, assesses probability based on current information, and identifies mispricing between market price and estimated fair value
- [ ] **Signal generator**: Converts LLM analysis output into Signal structs with market ID, direction, outcome, edge estimate, confidence score, recommended size, and reasoning text

### Quality Standards

- [ ] **Prompt quality**: Resolution rule analysis prompt correctly identifies edge cases where title and rules diverge
- [ ] **Signal structure**: Every Signal includes reasoning text traceable to specific data inputs

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_claude_client.md | Go client for Claude API with structured prompts and response parsing | Provides LLM access for all analysis steps |
| 02_market_normalization.md | Populate NormalizedMarket structs from Drift BET data | Standardizes market data for analysis pipeline input |
| 03_resolution_analysis.md | LLM prompt chain for resolution rule parsing and probability estimation | Core intelligence: identifies mispriced markets |
| 04_signal_generation.md | Convert analysis output into Signal structs with edge/confidence/sizing | Produces actionable trading signals for agent loop |
| 05_testing.md | Quality gate: run full test suite | Ensures analysis pipeline produces valid signals |
| 06_review.md | Quality gate: code review | Validates prompt quality and code design |
| 07_iterate.md | Quality gate: address review feedback | Resolves any issues found in review |
| 08_fest_commit.md | Quality gate: commit completed work | Finalizes sequence deliverables |

## Dependencies

### Prerequisites (from other sequences)

- 01_drift_client: Drift BET market data types (Market, Outcome, OrderBook) for normalization input

### Provides (to other sequences)

- Analysis pipeline and Signal type: Used by 03_agent_loop (signal consumption, trade execution decisions)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| LLM hallucination in probability estimates | Med | High | Cross-reference with market prices; reject signals with unreasonably high edge claims (>30%) |
| Claude API latency impacts trading cycle timing | Low | Med | Run analysis async; cache recent analyses; set timeout at 30s per analysis |
| Resolution rule parsing misinterprets edge cases | Med | Med | Include multiple resolution rule examples in prompt; add unit tests with known edge cases |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Claude client successfully sends analysis prompts and parses responses
- [ ] **Milestone 2**: Market normalizer populates NormalizedMarket from live Drift data
- [ ] **Milestone 3**: Full pipeline produces Signal structs from raw market data

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
