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

## Dependencies

- Tasks `05_vault_client`, `04_llm_strategy`, `03_risk_manager` must all be complete before starting this task.
- Imports: `internal/vault` (Client), `internal/risk` (Manager), `internal/base/trading` (TradeExecutor, Strategy, MarketState, Signal, SignalBuy, SignalHold).

## IMPORTANT Architecture Note

`trading.TradeExecutor` is used ONLY for `GetMarketState()` — reading market data from the DEX/oracle. All trade execution goes through `vault.Client.ExecuteSwap()`. **Never call `executor.Execute()` from the runner.** The vault contract is the sole trade executor to ensure on-chain accounting and access control.

## Implementation Steps

### Step 1: Create `projects/agent-defi/internal/loop/runner_test.go`

Create the directory if needed: `mkdir -p projects/agent-defi/internal/loop`

```go
package loop

import (
	"context"
	"math/big"
	"sync/atomic"
	"testing"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/lancekrogers/agent-defi/internal/base/trading"
	"github.com/lancekrogers/agent-defi/internal/risk"
	"github.com/lancekrogers/agent-defi/internal/vault"
)

// --- Mock vault.Client ---

type mockVault struct {
	swapCalled atomic.Int32
}

func (m *mockVault) USDCBalance(_ context.Context) (*big.Int, error) {
	return big.NewInt(10000e6), nil // 10,000 USDC
}

func (m *mockVault) TotalAssets(_ context.Context) (*big.Int, error) {
	return big.NewInt(10000e6), nil
}

func (m *mockVault) SharePrice(_ context.Context) (*big.Float, error) {
	return big.NewFloat(1.0), nil
}

func (m *mockVault) ExecuteSwap(_ context.Context, _ vault.SwapParams) (common.Hash, error) {
	m.swapCalled.Add(1)
	return common.Hash{}, nil
}

func (m *mockVault) HeldTokens(_ context.Context) ([]common.Address, error) {
	return nil, nil
}

// --- Mock trading.TradeExecutor (market data only) ---

type mockExecutor struct{}

func (m *mockExecutor) Execute(_ context.Context, _ trading.Trade) (*trading.TradeResult, error) {
	panic("Execute must never be called from runner — use vault.ExecuteSwap")
}

func (m *mockExecutor) GetBalance(_ context.Context, _ string) (*trading.Balance, error) {
	return &trading.Balance{}, nil
}

func (m *mockExecutor) GetMarketState(_ context.Context, _, _ string) (*trading.MarketState, error) {
	return &trading.MarketState{
		Pair:  "WETH/USDC",
		Price: 3000.0,
	}, nil
}

// --- Mock trading.Strategy ---

type mockStrategy struct {
	signal *trading.Signal
}

func (m *mockStrategy) Name() string        { return "mock" }
func (m *mockStrategy) MaxPosition() float64 { return 1.0 }
func (m *mockStrategy) Evaluate(_ context.Context, _ trading.MarketState) (*trading.Signal, error) {
	return m.signal, nil
}

// --- Tests ---

func TestRunner_BuySignalExecutesSwap(t *testing.T) {
	v := &mockVault{}
	strat := &mockStrategy{
		signal: &trading.Signal{
			Type:          trading.SignalBuy,
			Confidence:    0.8,
			SuggestedSize: 500,
			Reason:        "test buy",
			GeneratedAt:   time.Now(),
		},
	}
	mgr := risk.NewManager(risk.Config{
		MaxPositionUSD:    1000,
		MaxDailyVolumeUSD: 10000,
		MaxDrawdownPct:    0.10,
		InitialNAV:        10000,
	})

	r := New(Config{
		Interval: time.Second,
		TokenIn:  "0xUSDC",
		TokenOut: "0xWETH",
	}, v, &mockExecutor{}, strat, mgr)

	// Run a single cycle
	err := r.cycle(context.Background())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if v.swapCalled.Load() != 1 {
		t.Fatalf("expected 1 swap call, got %d", v.swapCalled.Load())
	}
}

func TestRunner_HoldSignalSkipsSwap(t *testing.T) {
	v := &mockVault{}
	strat := &mockStrategy{
		signal: &trading.Signal{
			Type:        trading.SignalHold,
			Confidence:  0.5,
			Reason:      "uncertain",
			GeneratedAt: time.Now(),
		},
	}
	mgr := risk.NewManager(risk.Config{
		MaxPositionUSD:    1000,
		MaxDailyVolumeUSD: 10000,
		MaxDrawdownPct:    0.10,
		InitialNAV:        10000,
	})

	r := New(Config{
		Interval: time.Second,
		TokenIn:  "0xUSDC",
		TokenOut: "0xWETH",
	}, v, &mockExecutor{}, strat, mgr)

	err := r.cycle(context.Background())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if v.swapCalled.Load() != 0 {
		t.Fatalf("expected 0 swap calls for hold signal, got %d", v.swapCalled.Load())
	}
}
```

### Step 2: Create `projects/agent-defi/internal/loop/runner.go`

```go
package loop

import (
	"context"
	"fmt"
	"log"
	"math/big"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/lancekrogers/agent-defi/internal/base/trading"
	"github.com/lancekrogers/agent-defi/internal/risk"
	"github.com/lancekrogers/agent-defi/internal/vault"
)

// Config holds loop runner configuration.
type Config struct {
	Interval time.Duration
	TokenIn  string
	TokenOut string
}

// Runner orchestrates the agent trading loop.
type Runner struct {
	cfg      Config
	vault    vault.Client
	executor trading.TradeExecutor // used ONLY for GetMarketState — never Execute
	strategy trading.Strategy
	risk     *risk.Manager
}

// New creates a new trading loop runner with injected dependencies.
func New(cfg Config, v vault.Client, exec trading.TradeExecutor, strat trading.Strategy, riskMgr *risk.Manager) *Runner {
	return &Runner{
		cfg:      cfg,
		vault:    v,
		executor: exec,
		strategy: strat,
		risk:     riskMgr,
	}
}

// Run starts the trading loop. It blocks until the context is cancelled.
func (r *Runner) Run(ctx context.Context) error {
	log.Printf("loop: starting %s strategy, interval=%s", r.strategy.Name(), r.cfg.Interval)

	ticker := time.NewTicker(r.cfg.Interval)
	defer ticker.Stop()

	// Run one cycle immediately
	if err := r.cycle(ctx); err != nil {
		log.Printf("loop: cycle error: %v", err)
	}

	for {
		select {
		case <-ctx.Done():
			log.Println("loop: shutting down")
			return ctx.Err()
		case <-ticker.C:
			if err := r.cycle(ctx); err != nil {
				log.Printf("loop: cycle error: %v", err)
			}
		}
	}
}

// cycle executes one full trading cycle:
//  1. Fetch market state (via executor.GetMarketState)
//  2. Update NAV from vault
//  3. Evaluate strategy
//  4. Risk check
//  5. Clamp position size
//  6. Execute swap via vault.ExecuteSwap
func (r *Runner) cycle(ctx context.Context) error {
	if err := ctx.Err(); err != nil {
		return fmt.Errorf("loop: context cancelled: %w", err)
	}

	// Step 1: Fetch market state
	market, err := r.executor.GetMarketState(ctx, r.cfg.TokenIn, r.cfg.TokenOut)
	if err != nil {
		return fmt.Errorf("loop: fetch market state: %w", err)
	}
	log.Printf("loop: market %s price=%.6f", market.Pair, market.Price)

	// Step 2: Update NAV from vault total assets
	totalAssets, err := r.vault.TotalAssets(ctx)
	if err != nil {
		return fmt.Errorf("loop: fetch total assets: %w", err)
	}
	navFloat, _ := new(big.Float).SetInt(totalAssets).Float64()
	r.risk.UpdateNAV(navFloat)

	// Step 3: Evaluate strategy
	signal, err := r.strategy.Evaluate(ctx, *market)
	if err != nil {
		return fmt.Errorf("loop: evaluate strategy: %w", err)
	}
	log.Printf("loop: signal type=%s confidence=%.2f size=%.4f reason=%q",
		signal.Type, signal.Confidence, signal.SuggestedSize, signal.Reason)

	// Hold signals skip execution
	if signal.Type == trading.SignalHold {
		log.Println("loop: hold signal, skipping execution")
		return nil
	}

	// Step 4: Risk check
	if err := r.risk.Check(ctx, signal.SuggestedSize, market.Price); err != nil {
		log.Printf("loop: risk rejected: %v", err)
		return nil // risk rejection is not a fatal error
	}

	// Step 5: Clamp position size
	clampedSize := r.risk.Clamp(signal.SuggestedSize, market.Price)
	log.Printf("loop: clamped size from %.4f to %.4f", signal.SuggestedSize, clampedSize)

	// Step 6: Execute swap via vault (NEVER via executor.Execute)
	amountIn := new(big.Int).SetUint64(uint64(clampedSize * 1e6)) // assuming 6 decimal USDC
	minOut := new(big.Int).SetUint64(0)                            // placeholder — production should calculate slippage

	txHash, err := r.vault.ExecuteSwap(ctx, vault.SwapParams{
		TokenIn:      common.HexToAddress(r.cfg.TokenIn),
		TokenOut:     common.HexToAddress(r.cfg.TokenOut),
		AmountIn:     amountIn,
		MinAmountOut: minOut,
		Reason:       []byte(signal.Reason),
	})
	if err != nil {
		return fmt.Errorf("loop: execute swap: %w", err)
	}

	log.Printf("loop: swap executed tx=%s", txHash.Hex())

	// Record the trade for daily volume tracking
	r.risk.RecordTrade(clampedSize, market.Price)

	return nil
}
```

### Step 3: Run Tests

```bash
cd projects/agent-defi && go test ./internal/loop/... -v
```

**Expected output:** PASS for both tests:
- `TestRunner_BuySignalExecutesSwap` — confirms `vault.ExecuteSwap` was called once
- `TestRunner_HoldSignalSkipsSwap` — confirms no swap call for hold signals

## Done When

- [ ] All requirements met
- [ ] `cd projects/agent-defi && go test ./internal/loop/... -v` passes
