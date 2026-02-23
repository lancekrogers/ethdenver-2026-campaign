---
fest_type: task
fest_id: 01_fix_strategy_moving_average.md
fest_name: fix strategy moving average
fest_parent: 01_base_agent_bugfixes
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T17:49:06.902766-07:00
fest_tracking: true
---

# Task: Fix Mean Reversion Moving Average

## Objective

Replace the hardcoded `price * 0.98` moving average in `GetMarketState` with a real windowed TWAP so the mean reversion strategy produces correct buy and sell signals.

## Requirements

- [ ] `GetMarketState` in `projects/agent-defi/internal/base/trading/executor.go` returns a `MovingAverage` computed from a sliding window of historical prices, not `price * 0.98`
- [ ] The strategy in `projects/agent-defi/internal/base/trading/strategy.go` correctly produces BUY signals when price < MA and SELL signals when price > MA (currently it always sells because MA is always below price)

## Implementation

### Step 1: Add a price history ring buffer

Create a new file `projects/agent-defi/internal/base/trading/moving_avg.go`:

- Define a `MovingAverage` struct with a `[]float64` ring buffer, a `size` int (window length, default 20), and a `mu sync.Mutex`
- Method `Add(price float64)` appends to the buffer, evicting oldest if len > size
- Method `Value() float64` returns the arithmetic mean of all prices in the buffer. If buffer is empty, return 0
- Method `Ready() bool` returns true when buffer has at least `size/2` entries (enough data to be meaningful)

### Step 2: Wire the moving average into the Executor

In `projects/agent-defi/internal/base/trading/executor.go`:

- Add a `ma *MovingAverage` field to the `Executor` struct
- Initialize it in the constructor: `ma: NewMovingAverage(20)`
- In `GetMarketState`, after fetching the current `price` from Uniswap V3 `slot0`:
  1. Call `e.ma.Add(price)`
  2. If `e.ma.Ready()`, set `state.MovingAverage = e.ma.Value()`
  3. If not ready, set `state.MovingAverage = price` (neutral — no trade signal until we have data)
- Remove the line `MovingAverage: price * 0.98`

### Step 3: Verify strategy logic

In `projects/agent-defi/internal/base/trading/strategy.go`, confirm `Evaluate` compares `market.Price` against `market.MovingAverage` with the correct threshold (default 2%). The existing logic should be correct once MA is real — buy when price is >2% below MA, sell when >2% above MA.

### Step 4: Write tests

In `projects/agent-defi/internal/base/trading/moving_avg_test.go`:

- Test `Add` + `Value` with known values (e.g., add 10, 20, 30 -> avg is 20)
- Test `Ready` returns false when buffer has fewer than size/2 entries
- Test ring buffer eviction when exceeding window size
- Test thread safety with concurrent Add calls

## Done When

- [ ] All requirements met
- [ ] Unit test proves: add 20 prices trending up, MA is lower than latest price, strategy returns SELL; add 20 prices trending down, MA is higher than latest price, strategy returns BUY
