---
fest_type: task
fest_id: 06_implement_trading.md
fest_name: implement_trading
fest_parent: 02_defi_base
fest_order: 6
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Autonomous Trading

## Objective

Implement the `Strategy`, `TradeExecutor`, and `PnLTracker` to enable the DeFi agent to execute autonomous trading strategies on Base. The agent must generate revenue that exceeds its operational costs (gas, fees) to qualify for the Base self-sustaining agent bounty ($3k+). This is the most critical capability for the DeFi agent.

**Project:** `agent-defi` at `projects/agent-defi/`
**Package:** `internal/base/trading/`

## Requirements

- [ ] Implement at least one trading strategy that can generate positive returns
- [ ] Implement the trade executor for on-chain swap execution on Base
- [ ] Implement accurate P&L tracking of all revenue, gas costs, and fees
- [ ] Include ERC-8021 attribution in all trade transactions
- [ ] Demonstrate that revenue exceeds costs (self-sustaining)
- [ ] Handle all errors with contextual wrapping
- [ ] Pass `context.Context` through all I/O operations

## Implementation

### Step 1: Define the model types

In `internal/base/trading/models.go`:

```go
package trading

import (
    "math/big"
    "time"
)

// Signal is a trading decision from a strategy.
type Signal struct {
    // Action is the trading action: "buy", "sell", or "hold".
    Action string

    // Pair is the trading pair (e.g., "WETH/USDC").
    Pair string

    // Amount is the suggested trade size.
    Amount *big.Int

    // Confidence is the strategy's confidence in this signal (0.0 to 1.0).
    Confidence float64

    // Reason explains why this signal was generated (for audit trail).
    Reason string
}

// Trade is a trade to be executed on-chain.
type Trade struct {
    // Pair is the trading pair.
    Pair string

    // Side is "buy" or "sell".
    Side string

    // AmountIn is the input amount.
    AmountIn *big.Int

    // MinAmountOut is the minimum acceptable output (slippage protection).
    MinAmountOut *big.Int

    // TokenIn is the input token address.
    TokenIn string

    // TokenOut is the output token address.
    TokenOut string

    // DEXRouter is the DEX router contract address.
    DEXRouter string

    // Deadline is the transaction deadline.
    Deadline time.Time
}

// TradeResult is the outcome of an executed trade.
type TradeResult struct {
    // TxHash is the transaction hash.
    TxHash string

    // AmountIn is the actual input amount.
    AmountIn *big.Int

    // AmountOut is the actual output amount.
    AmountOut *big.Int

    // GasCost is the gas spent on this transaction.
    GasCost *big.Int

    // EffectivePrice is the execution price.
    EffectivePrice float64

    // Slippage is the actual slippage incurred.
    Slippage float64

    // BlockNumber is the block where the trade was included.
    BlockNumber uint64

    // ExecutedAt is when the trade was confirmed.
    ExecutedAt time.Time
}

// MarketState represents current market conditions for strategy evaluation.
type MarketState struct {
    // Pair is the trading pair.
    Pair string

    // Price is the current mid price.
    Price float64

    // Volume24h is the 24-hour trading volume.
    Volume24h float64

    // PriceHistory is recent price data points.
    PriceHistory []PricePoint

    // Timestamp is when this state was captured.
    Timestamp time.Time
}

// PricePoint is a single price data point.
type PricePoint struct {
    Price     float64
    Timestamp time.Time
}

// Position represents a current token holding.
type Position struct {
    Token   string
    Amount  *big.Int
    ValueUSD float64
}

// Balance represents a token balance.
type Balance struct {
    Token   string
    Amount  *big.Int
    Decimals int
}

// TradeRecord is a historical trade for P&L tracking.
type TradeRecord struct {
    Trade       Trade
    Result      TradeResult
    Strategy    string
    RecordedAt  time.Time
}

// GasCost tracks gas expenditure for P&L.
type GasCost struct {
    TxHash   string
    Amount   *big.Int
    Purpose  string
    Timestamp time.Time
}

// Fee tracks protocol fees for P&L.
type Fee struct {
    Amount   *big.Int
    Protocol string
    Timestamp time.Time
}
```

### Step 2: Implement a simple trading strategy

For the hackathon demo, implement a simple but demonstrable strategy. A good choice is a **mean reversion strategy** on a liquid Base pair:

In `internal/base/trading/strategy.go`:

```go
package trading

import (
    "context"
    "math"
)

// MeanReversionStrategy implements a simple mean reversion trading strategy.
// It buys when the price is below the moving average and sells when above.
// This is suitable for a hackathon demo -- the goal is demonstrable execution
// with positive returns, not sophisticated alpha generation.
type MeanReversionStrategy struct {
    // WindowSize is the number of price points for the moving average.
    WindowSize int

    // Threshold is how far from the mean (as a percentage) to trigger a trade.
    // For example, 0.02 means buy at 2% below mean, sell at 2% above.
    Threshold float64

    // TradeSize is the fixed size per trade.
    TradeSize *big.Int

    // MaxPosition is the maximum position size for risk management.
    MaxPos Position
}

func (s *MeanReversionStrategy) Name() string {
    return "mean_reversion"
}

func (s *MeanReversionStrategy) Evaluate(ctx context.Context, state MarketState) (*Signal, error) {
    if err := ctx.Err(); err != nil {
        return nil, err
    }

    if len(state.PriceHistory) < s.WindowSize {
        return &Signal{Action: "hold", Pair: state.Pair, Reason: "insufficient price history"}, nil
    }

    // Calculate moving average
    var sum float64
    recent := state.PriceHistory[len(state.PriceHistory)-s.WindowSize:]
    for _, p := range recent {
        sum += p.Price
    }
    mean := sum / float64(s.WindowSize)

    // Calculate deviation from mean
    deviation := (state.Price - mean) / mean

    if deviation < -s.Threshold {
        return &Signal{
            Action:     "buy",
            Pair:       state.Pair,
            Amount:     s.TradeSize,
            Confidence: math.Min(math.Abs(deviation)/s.Threshold, 1.0),
            Reason:     fmt.Sprintf("price %.4f is %.2f%% below mean %.4f", state.Price, deviation*100, mean),
        }, nil
    }

    if deviation > s.Threshold {
        return &Signal{
            Action:     "sell",
            Pair:       state.Pair,
            Amount:     s.TradeSize,
            Confidence: math.Min(deviation/s.Threshold, 1.0),
            Reason:     fmt.Sprintf("price %.4f is %.2f%% above mean %.4f", state.Price, deviation*100, mean),
        }, nil
    }

    return &Signal{Action: "hold", Pair: state.Pair, Reason: "price within threshold"}, nil
}

func (s *MeanReversionStrategy) MaxPosition() Position {
    return s.MaxPos
}
```

### Step 3: Implement the trade executor

In `internal/base/trading/executor.go`:

```go
package trading

import "context"

// ExecutorConfig holds configuration for the trade executor.
type ExecutorConfig struct {
    // ChainRPC is the Base chain RPC endpoint.
    ChainRPC string

    // ChainID is the Base chain ID (8453 for mainnet, 84532 for Sepolia).
    ChainID int64

    // PrivateKey is the agent's private key for signing transactions.
    PrivateKey string

    // DEXRouterAddress is the DEX router contract (e.g., Uniswap V3 on Base).
    DEXRouterAddress string

    // MaxSlippage is the maximum acceptable slippage percentage (e.g., 0.005 for 0.5%).
    MaxSlippage float64

    // Attribution is the ERC-8021 encoder for adding builder codes.
    Attribution AttributionEncoder
}
```

Key implementation details:

**Execute(ctx, trade)**:

1. Check `ctx.Err()` before starting
2. Build the DEX swap calldata (e.g., Uniswap V3 `exactInputSingle`)
3. Apply ERC-8021 attribution via `e.cfg.Attribution.Encode(ctx, calldata)`
4. Estimate gas
5. Sign the transaction
6. Submit to Base
7. Wait for receipt
8. Parse swap events from the receipt to get actual amounts
9. Calculate effective price and slippage
10. Return TradeResult with gas cost tracked

**GetBalance(ctx, token)**:

1. For native ETH: query the balance of the agent's address
2. For ERC-20: call `balanceOf(agentAddress)` on the token contract
3. Return Balance with amount and decimals

**GetMarketState(ctx, pair)**:

1. Query the DEX pool for current price (e.g., Uniswap V3 `slot0`)
2. Query an on-chain oracle or DEX for recent price history
3. Calculate 24h volume if available
4. Return MarketState for strategy evaluation

### Step 4: Implement P&L tracking

In `internal/base/trading/pnl.go`:

```go
package trading

import (
    "math/big"
    "sync"
    "time"
)

// PnLTracker records all trading activity and computes profit/loss.
type PnLTracker struct {
    mu        sync.RWMutex
    trades    []TradeRecord
    gasCosts  []GasCost
    fees      []Fee
    startTime time.Time
}

// NewPnLTracker creates a new P&L tracker.
func NewPnLTracker() *PnLTracker {
    return &PnLTracker{
        startTime: time.Now(),
    }
}

// RecordTrade adds a completed trade to the P&L tracker.
func (t *PnLTracker) RecordTrade(record TradeRecord) {
    t.mu.Lock()
    defer t.mu.Unlock()
    t.trades = append(t.trades, record)
    // Also record the gas cost
    t.gasCosts = append(t.gasCosts, GasCost{
        TxHash:    record.Result.TxHash,
        Amount:    record.Result.GasCost,
        Purpose:   "trade",
        Timestamp: record.RecordedAt,
    })
}

// RecordGasCost records a non-trade gas expenditure (e.g., identity registration).
func (t *PnLTracker) RecordGasCost(cost GasCost) {
    t.mu.Lock()
    defer t.mu.Unlock()
    t.gasCosts = append(t.gasCosts, cost)
}

// Report generates a P&L report for the given time period.
func (t *PnLTracker) Report(from, to time.Time) PnLReport {
    t.mu.RLock()
    defer t.mu.RUnlock()

    report := PnLReport{
        PeriodStart: from,
        PeriodEnd:   to,
    }

    // Calculate total revenue from profitable trades
    // Calculate total gas costs
    // Calculate total fees
    // Compute net P&L
    // Determine win rate
    // Set IsSelfSustaining flag

    report.NetPnL = report.TotalRevenue - report.TotalGasCosts - report.TotalFees
    report.IsSelfSustaining = report.NetPnL > 0

    return report
}
```

The P&L tracker must be thread-safe because trades may be recorded from the main loop while reports are being generated for HCS publishing.

### Step 5: Define sentinel errors

```go
var (
    ErrTradeReverted     = errors.New("trading: trade transaction reverted")
    ErrSlippageExceeded  = errors.New("trading: slippage exceeded maximum")
    ErrInsufficientBalance = errors.New("trading: insufficient token balance")
    ErrDEXUnreachable    = errors.New("trading: DEX contract unreachable")
    ErrNoLiquidity       = errors.New("trading: insufficient liquidity in pool")
    ErrStrategyError     = errors.New("trading: strategy evaluation failed")
)
```

### Step 6: Write unit tests

Create test files for each component:

**internal/base/trading/strategy_test.go:**

1. **TestMeanReversion_Buy**: Price below mean by threshold, verify buy signal
2. **TestMeanReversion_Sell**: Price above mean by threshold, verify sell signal
3. **TestMeanReversion_Hold**: Price within threshold, verify hold signal
4. **TestMeanReversion_InsufficientHistory**: Not enough data, verify hold
5. **TestMeanReversion_ContextCancelled**: Cancel context, verify error

**internal/base/trading/executor_test.go:**

1. **TestExecute_Success**: Mock successful swap, verify TradeResult with gas
2. **TestExecute_Reverted**: Mock reverted transaction, verify ErrTradeReverted
3. **TestExecute_SlippageExceeded**: Mock high slippage, verify error
4. **TestExecute_AttributionIncluded**: Verify calldata includes ERC-8021 attribution
5. **TestGetBalance_ETH**: Mock ETH balance query
6. **TestGetBalance_ERC20**: Mock USDC balance query
7. **TestGetMarketState_Success**: Mock pool price query

**internal/base/trading/pnl_test.go:**

1. **TestPnLTracker_RecordTrade**: Record a trade, verify it appears in report
2. **TestPnLTracker_NetPositive**: Record profitable trades, verify IsSelfSustaining=true
3. **TestPnLTracker_NetNegative**: Record losing trades, verify IsSelfSustaining=false
4. **TestPnLTracker_GasCostsTracked**: Verify gas costs reduce net P&L
5. **TestPnLTracker_ConcurrentAccess**: Read and write from multiple goroutines
6. **TestPnLTracker_WinRate**: Mix of wins and losses, verify correct percentage
7. **TestPnLTracker_TimeFiltering**: Trades outside period excluded from report

### Step 7: Verify compilation and tests

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
go build ./internal/base/trading/...
go test ./internal/base/trading/... -v -race
go vet ./internal/base/trading/...
```

Note the `-race` flag -- the P&L tracker is concurrent and must be race-free.

## Done When

- [ ] `MeanReversionStrategy` implemented with buy/sell/hold signals
- [ ] `TradeExecutor` implemented with on-chain swap execution and gas tracking
- [ ] `PnLTracker` implemented with thread-safe trade recording and report generation
- [ ] ERC-8021 attribution integrated into trade execution calldata
- [ ] P&L report accurately reflects revenue, gas costs, fees, and net P&L
- [ ] `IsSelfSustaining` flag correctly identifies when revenue exceeds costs
- [ ] Slippage protection prevents excessive loss on swaps
- [ ] Sentinel errors defined for all failure modes
- [ ] Table-driven unit tests cover strategy, executor, and P&L tracker
- [ ] `go test -race` passes (no data races in P&L tracker)
- [ ] `go build`, `go test`, and `go vet` all pass cleanly
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
