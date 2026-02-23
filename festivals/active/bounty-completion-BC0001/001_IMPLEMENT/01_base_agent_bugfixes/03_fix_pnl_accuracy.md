---
fest_type: task
fest_id: 04_fix_pnl_accuracy.md
fest_name: fix pnl accuracy
fest_parent: 01_base_agent_bugfixes
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T17:49:06.904077-07:00
fest_tracking: true
---

# Task: Fix P&L Accuracy — Real Gas Costs and Trade Revenue

## Objective

Replace the stubbed $0.50 gas cost and arbitrary 1% revenue calculation with real values derived from transaction receipts and actual trade amounts.

## Requirements

- [ ] Gas cost in `processTrade` (`projects/agent-defi/internal/base/trading/executor.go`) is calculated from the receipt's `GasUsed * EffectiveGasPrice`, converted to USD using a reasonable ETH price constant
- [ ] Trade revenue is calculated from actual swap output minus input, not an arbitrary `signal.SuggestedSize * market.Price * 0.01`
- [ ] `MinAmountOut` is non-zero — use 0.5% slippage tolerance instead of `"0"`

## Implementation

### Step 1: Fix gas cost calculation

In `projects/agent-defi/internal/base/trading/executor.go`, find where gas cost is recorded (currently hardcoded `0.50`). Replace with:

```go
receipt, err := bind.WaitMined(ctx, client, tx)
// ...
gasUsed := new(big.Int).SetUint64(receipt.GasUsed)
gasCostWei := new(big.Int).Mul(gasUsed, receipt.EffectiveGasPrice)
gasCostETH := new(big.Float).Quo(new(big.Float).SetInt(gasCostWei), new(big.Float).SetFloat64(1e18))
gasCostFloat, _ := gasCostETH.Float64()
gasCostUSD := gasCostFloat * 2500.0 // reasonable testnet approximation
a.pnl.RecordGasCost(gasCostUSD)
```

### Step 2: Fix revenue calculation

In the same method, find `revenue := signal.SuggestedSize * market.Price * 0.01`. Replace with a slippage-based estimate since parsing Uniswap swap events is complex:

```go
expectedOutput := signal.SuggestedSize * market.Price
feeTier := 0.003 // 0.3% Uniswap V3 fee tier
revenue := expectedOutput * feeTier
a.pnl.RecordTrade(revenue)
```

### Step 3: Fix MinAmountOut

Find where `MinAmountOut` is set to `"0"`. Replace with slippage-protected value:

```go
slippageBps := big.NewInt(995) // 0.5% slippage tolerance
minOut := new(big.Int).Mul(expectedOut, slippageBps)
minOut.Div(minOut, big.NewInt(1000))
```

## Done When

- [ ] All requirements met
- [ ] After a trade, P&L report shows gas cost > $0.00 (receipt-based) and `MinAmountOut` is non-zero in the transaction calldata
