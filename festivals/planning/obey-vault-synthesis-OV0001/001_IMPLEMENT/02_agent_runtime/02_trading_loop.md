---
fest_type: task
fest_id: 01_trading_loop.md
fest_name: 04_trading_loop
fest_parent: 02_agent_runtime
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:24:37.788149-06:00
fest_tracking: true
---

# Task: Trading Loop Runner

## Objective

Implement the main agent loop runner that orchestrates the full trading cycle: fetch market state, evaluate strategy, check risk, execute swap via vault.

## Requirements

- [ ] Create `internal/loop/runner.go` with Config (Interval, TokenIn, TokenOut) and Runner struct
- [ ] Runner takes injected dependencies: vault.Client, trading.TradeExecutor (for market data only), trading.Strategy, risk.Manager
- [ ] Implement Run(ctx) with ticker-based loop that calls cycle() on each tick
- [ ] Implement cycle(): fetch market state -> update NAV -> evaluate strategy -> risk check -> clamp -> execute via vault.ExecuteSwap -> record trade
- [ ] Hold signals skip execution, risk rejections log and continue
- [ ] Create `internal/loop/runner_test.go` with mock vault, executor, strategy: buy signal executes swap, hold signal skips swap

## Implementation

See implementation plan Task 11 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to create:**
- `projects/agent-defi/internal/loop/runner.go`
- `projects/agent-defi/internal/loop/runner_test.go`

## Done When

- [ ] All requirements met
- [ ] `cd projects/agent-defi && go test ./internal/loop/... -v` passes
