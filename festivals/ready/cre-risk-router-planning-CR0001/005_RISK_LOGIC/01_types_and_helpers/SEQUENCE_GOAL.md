---
fest_type: sequence
fest_id: 01_types_and_helpers
fest_name: types and helpers
fest_parent: 003_RISK_LOGIC
fest_order: 1
fest_status: pending
fest_created: 2026-03-01T17:43:47.543595-07:00
fest_tracking: true
---

# Sequence Goal: 01_types_and_helpers

**Sequence:** 01_types_and_helpers | **Phase:** 003_RISK_LOGIC | **Status:** Pending | **Created:** 2026-03-01T17:43:47-07:00

## Sequence Objective

**Primary Goal:** Define all data types (`RiskRequest`, `RiskDecision`, `MarketData`, `Config`) and utility functions (`generateRunID`, `hashDecision`, `calculateSlippage`, `toFeedDecimals`, `clamp`) used throughout the risk evaluation pipeline.

**Contribution to Phase Goal:** Provides the type definitions and helper functions that all 8 risk gates and the evaluation pipeline depend on. These must be complete before gates can be implemented.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **types.go**: `RiskRequest`, `RiskDecision`, `MarketData`, and `Config` structs with all fields matching spec Section 5 exactly, including JSON tags and 8-decimal precision on `ChainlinkPrice`
- [ ] **helpers.go**: `generateRunID()` using keccak256 with `runtime.Rand`, `hashDecision()` for keccak256 of all decision fields, `calculateSlippage()`, `toFeedDecimals()` for converting float prices to 8-decimal integers, `clamp()` for bounding values

### Quality Standards

- [ ] **Spec fidelity**: Every field name, type, and JSON tag matches spec Section 5 exactly
- [ ] **Precision correctness**: `toFeedDecimals()` correctly converts float64 prices to uint64 with 8-decimal precision; `uint64` at 8 decimals supports prices up to ~184 billion

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_types | Define all data types per spec Section 5 | Provides struct definitions for the entire pipeline |
| 01_helpers | Implement utility functions for hashing, sizing, and conversion | Provides shared helpers used by gates and evaluation pipeline |

## Dependencies

### Prerequisites (from other sequences)

- 002_FOUNDATION/01_project_scaffold: Scaffolded project with `go.mod` and directory structure

### Provides (to other sequences)

- Type definitions: Used by 02_risk_gates and 03_evaluation_pipeline
- Helper functions: Used by 02_risk_gates (clamp, toFeedDecimals) and 03_evaluation_pipeline (generateRunID, hashDecision)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| CRE SDK types conflict with our type names | Low | Low | Use package-level type aliases or rename if needed |
| Precision loss in float64 to uint64 conversion | Low | Med | Use math.Round before cast; validate with known Chainlink price values |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: All structs defined in `types.go` with correct JSON tags
- [ ] **Milestone 2**: All helper functions implemented in `helpers.go`
- [ ] **Milestone 3**: Both files compile and pass unit tests

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
