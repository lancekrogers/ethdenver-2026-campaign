---
fest_type: task
fest_id: 01_risk_manager.md
fest_name: 03_risk_manager
fest_parent: 02_agent_runtime
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:24:37.769867-06:00
fest_tracking: true
---

# Task: Risk Manager

## Objective

Implement an off-chain risk manager that enforces position limits, daily volume caps, and drawdown halts as a secondary safety layer complementing on-chain vault constraints.

## Requirements

- [ ] Create `internal/risk/manager.go` with Config (MaxPositionUSD, MaxDailyVolumeUSD, MaxDrawdownPct, InitialNAV)
- [ ] Implement Check(ctx, signal, price) that validates position size, daily volume, and drawdown
- [ ] Implement Clamp(signal, price) that reduces signal size to fit within limits
- [ ] Implement RecordTrade(size, price) and UpdateNAV(nav) for tracking
- [ ] Thread-safe with sync.Mutex, daily volume resets on day boundary
- [ ] Create `internal/risk/manager_test.go` with tests: oversized rejection, clamp, daily volume tracking, drawdown halt

## Implementation

See implementation plan Task 10 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to create:**
- `projects/agent-defi/internal/risk/manager.go`
- `projects/agent-defi/internal/risk/manager_test.go`

## Done When

- [ ] All requirements met
- [ ] `cd projects/agent-defi && go test ./internal/risk/... -v` passes all 4 tests
