---
fest_type: task
fest_id: 02_design_agent_architecture.md
fest_name: design_agent_architecture
fest_parent: 02_defi_base
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design Agent Architecture

## Objective

Design the complete architecture for the DeFi agent in the `agent-defi` project. Define the package layout, interfaces, trading strategy framework, P&L tracking, and agent lifecycle. This design becomes the blueprint for all subsequent implementation tasks in this sequence.

**Project:** `agent-defi` at `projects/agent-defi/`

## Requirements

- [ ] Define the package layout under `internal/`
- [ ] Design the agent lifecycle: start -> register identity -> start trading -> report P&L -> respond to coordinator
- [ ] Design the trading strategy framework with P&L tracking
- [ ] Define core interfaces for each package
- [ ] Create the directory structure and placeholder files

## Implementation

### Step 1: Define the package layout

Navigate to the agent-defi project:

```bash
fgo
```

Create the following package structure under `internal/`:

```
internal/
  agent/              # Agent lifecycle, main loop, configuration
    agent.go          # Core Agent struct and lifecycle methods
    config.go         # Agent configuration
  base/
    identity/         # ERC-8004 on-chain identity
      register.go     # IdentityRegistry interface and implementation
      models.go       # Identity, Registration type definitions
    payment/          # x402 payment protocol
      x402.go         # PaymentProtocol interface and implementation
      models.go       # Payment, Invoice, Receipt type definitions
    trading/          # Autonomous trading strategies
      strategy.go     # Strategy interface and implementations
      executor.go     # TradeExecutor for on-chain execution
      pnl.go          # P&L tracker
      models.go       # Trade, Position, PnLReport type definitions
    attribution/      # ERC-8021 builder attribution
      builder.go      # AttributionEncoder interface and implementation
      models.go       # Attribution code type definitions
  hcs/                # Hedera Consensus Service integration
    handler.go        # HCS message handler
    messages.go       # P&L report and task message types
cmd/
  agent-defi/
    main.go           # Entry point, wires dependencies, starts agent
```

### Step 2: Create the directory structure

```bash
mkdir -p internal/agent
mkdir -p internal/base/identity
mkdir -p internal/base/payment
mkdir -p internal/base/trading
mkdir -p internal/base/attribution
mkdir -p internal/hcs
mkdir -p cmd/agent-defi
```

### Step 3: Define core interfaces

**internal/base/identity/register.go** -- IdentityRegistry interface:

```go
package identity

import "context"

// IdentityRegistry manages on-chain agent identity via ERC-8004 on Base.
type IdentityRegistry interface {
    // Register creates a new on-chain identity for this agent.
    // Returns the identity address or identifier.
    Register(ctx context.Context, req RegistrationRequest) (*Identity, error)

    // Verify checks that an agent identity is valid and registered.
    Verify(ctx context.Context, agentID string) (bool, error)

    // GetIdentity retrieves the full identity record for an agent.
    GetIdentity(ctx context.Context, agentID string) (*Identity, error)
}
```

**internal/base/payment/x402.go** -- PaymentProtocol interface:

```go
package payment

import "context"

// PaymentProtocol implements the x402 machine-to-machine payment protocol.
type PaymentProtocol interface {
    // Pay sends a payment to the specified recipient.
    Pay(ctx context.Context, req PaymentRequest) (*Receipt, error)

    // RequestPayment creates an invoice for a service rendered.
    RequestPayment(ctx context.Context, invoice Invoice) (*PaymentRequest, error)

    // VerifyPayment confirms a payment was received and valid.
    VerifyPayment(ctx context.Context, receiptID string) (bool, error)
}
```

**internal/base/trading/strategy.go** -- Strategy interface:

```go
package trading

import "context"

// Strategy defines an autonomous trading strategy.
type Strategy interface {
    // Name returns the strategy identifier.
    Name() string

    // Evaluate analyzes current market conditions and returns
    // a trade signal (buy, sell, hold) with reasoning.
    Evaluate(ctx context.Context, state MarketState) (*Signal, error)

    // MaxPosition returns the maximum position size for risk management.
    MaxPosition() Position
}
```

**internal/base/trading/executor.go** -- TradeExecutor interface:

```go
package trading

import "context"

// TradeExecutor submits trades on-chain and tracks execution.
type TradeExecutor interface {
    // Execute submits a trade to the Base DEX.
    Execute(ctx context.Context, trade Trade) (*TradeResult, error)

    // GetBalance returns the current token balance.
    GetBalance(ctx context.Context, token string) (*Balance, error)

    // GetMarketState returns current market data for strategy evaluation.
    GetMarketState(ctx context.Context, pair string) (*MarketState, error)
}
```

**internal/base/attribution/builder.go** -- AttributionEncoder interface:

```go
package attribution

import "context"

// AttributionEncoder adds ERC-8021 builder attribution to transactions.
type AttributionEncoder interface {
    // Encode adds the attribution code to transaction calldata.
    Encode(ctx context.Context, txData []byte) ([]byte, error)

    // Decode extracts the attribution code from transaction calldata.
    Decode(ctx context.Context, txData []byte) (*Attribution, error)
}
```

### Step 4: Design the trading strategy framework

The trading framework consists of three layers:

1. **Strategy**: Pure logic that evaluates market state and produces signals. No I/O -- receives data, returns decisions. This makes strategies easy to test and backtest.

2. **Executor**: Handles on-chain execution. Takes trade signals and submits transactions to Base DEX contracts. Includes ERC-8021 attribution in every transaction.

3. **P&L Tracker**: Records every trade, tracks costs (gas, slippage, fees) and revenue (trade profits). Produces P&L reports for HCS publishing. The self-sustaining requirement means this tracker must prove revenue > costs.

Design a simple initial strategy suitable for hackathon demo:
- Track a single trading pair on a Base DEX (e.g., WETH/USDC on Uniswap v3 on Base)
- Use a simple mean-reversion or momentum strategy
- Focus on demonstrable execution rather than sophisticated alpha generation
- The key metric is: total revenue from trades minus total gas costs and fees must be positive

### Step 5: Design P&L tracking

In `internal/base/trading/pnl.go`:

```go
package trading

// PnLTracker records all trading activity and computes profit/loss.
type PnLTracker struct {
    trades    []TradeRecord
    gasCosts  []GasCost
    fees      []Fee
    startTime time.Time
}

// PnLReport is a periodic summary of trading performance.
type PnLReport struct {
    // TotalRevenue is gross profit from trades.
    TotalRevenue float64

    // TotalGasCosts is the sum of all gas spent on transactions.
    TotalGasCosts float64

    // TotalFees is the sum of DEX and protocol fees.
    TotalFees float64

    // NetPnL is TotalRevenue - TotalGasCosts - TotalFees.
    NetPnL float64

    // TradeCount is the number of trades executed.
    TradeCount int

    // WinRate is the percentage of profitable trades.
    WinRate float64

    // IsSelfSustaining is true when NetPnL > 0.
    IsSelfSustaining bool

    // Period is the time range this report covers.
    PeriodStart time.Time
    PeriodEnd   time.Time
}
```

### Step 6: Verify the scaffold compiles

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
go build ./...
```

## Done When

- [ ] All directories under `internal/` created as specified
- [ ] Each package has its interface file with documented Go interfaces
- [ ] Each package has a models file with type definitions
- [ ] Trading strategy framework designed with Strategy, Executor, and PnLTracker
- [ ] P&L report format defined with self-sustaining flag
- [ ] `cmd/agent-defi/main.go` exists with a minimal main function
- [ ] `go build ./...` succeeds with no errors
- [ ] Package layout is clean: no file exceeds 500 lines, all interfaces have 3-5 methods max
