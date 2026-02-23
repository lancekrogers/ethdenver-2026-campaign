---
fest_type: task
fest_id: 03_wire_x402_into_trading_loop.md
fest_name: wire x402 into trading loop
fest_parent: 01_base_agent_bugfixes
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T17:49:06.903786-07:00
fest_tracking: true
---

# Task: Wire x402 Payment Into Trading Loop

## Objective

Integrate the existing x402 payment protocol into the agent's trading cycle so the agent actually pays for market data before executing trades, demonstrating the HTTP 402 payment flow required by the Base bounty.

## Requirements

- [ ] `executeTradingCycle` in `projects/agent-defi/internal/agent/agent.go` calls `a.payment.Pay()` at least once per cycle before fetching market data
- [ ] The x402 payment cost is recorded in the P&L tracker via `a.pnl.RecordFee()` so it appears in the self-sustainability calculation

## Implementation

### Step 1: Understand the current code

In `projects/agent-defi/internal/agent/agent.go`, the `Agent` struct already has a `payment` field. The `executeTradingCycle` method calls `GetMarketState` then `Evaluate` then `Execute` but never touches `a.payment`. The x402 protocol is fully implemented in `projects/agent-defi/internal/base/payment/x402.go` — it just isn't called.

### Step 2: Add x402 payment before market data fetch

In `executeTradingCycle`, before calling `GetMarketState`:

```go
if a.payment != nil && a.cfg.MarketDataEndpoint != "" {
    cost, err := a.payment.Pay(ctx, a.cfg.MarketDataEndpoint, a.cfg.MarketDataCost)
    if err != nil {
        a.logger.Warn("x402 payment failed", "err", err)
    } else {
        a.pnl.RecordFee(cost, "x402-market-data")
    }
}
```

### Step 3: Add config fields

In the agent's config struct, add:

- `MarketDataEndpoint string` env: `DEFI_MARKET_DATA_ENDPOINT`
- `MarketDataCost string` env: `DEFI_MARKET_DATA_COST`, default: `"1000000000000000"` (0.001 ETH)

### Step 4: Update tests

In `projects/agent-defi/internal/agent/agent_test.go`, mock the payment client and verify `Pay` is called during `executeTradingCycle`. Verify the P&L tracker receives the fee.

## Done When

- [ ] All requirements met
- [ ] Test confirms: when `MarketDataEndpoint` is set, `payment.Pay()` is called once per trading cycle and the cost appears in `pnl.Report()` under fees
