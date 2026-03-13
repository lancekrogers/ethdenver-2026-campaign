---
fest_type: task
fest_id: 03_risk_manager.md
fest_name: risk_manager
fest_parent: 03_agent_loop
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.317086-06:00
fest_tracking: true
---

# Task: Risk Manager Implementation

## Objective

Implement the risk management layer that filters trading signals based on position limits, portfolio exposure, drawdown controls, daily loss limits, and correlation checks -- protecting the agent from catastrophic losses.

## Requirements

- [ ] Position size limits (max % of NAV per position)
- [ ] Maximum open positions limit
- [ ] Platform exposure limit (for future multi-platform)
- [ ] Category concentration limit (don't over-index on one category)
- [ ] Maximum drawdown halt (stop trading at drawdown threshold)
- [ ] Daily loss limit (stop trading for the day)
- [ ] Minimum liquidity check
- [ ] Signal size adjustment (clamp oversized positions)

## Implementation

### Step 1: Implement the Risk Manager

Update file `projects/agent-prediction/internal/risk/risk.go`:

```go
package risk

import (
	"context"
	"errors"
	"fmt"
	"sync"
	"time"

	"github.com/lancekrogers/agent-prediction/internal/adapters"
)

// Sentinel errors for risk decisions.
var (
	ErrMaxDrawdownReached = errors.New("risk: maximum drawdown reached, trading halted")
	ErrDailyLossExceeded  = errors.New("risk: daily loss limit exceeded")
)

// Config holds risk management parameters.
type Config struct {
	// MaxPositionPct is the max single position as % of NAV (e.g., 0.05 = 5%).
	MaxPositionPct float64

	// MaxDrawdownPct halts trading when drawdown from high-water mark exceeds this.
	MaxDrawdownPct float64

	// DailyLossLimit stops new trades when daily loss exceeds this % of NAV.
	DailyLossLimit float64

	// MaxOpenPositions is the maximum number of concurrent open positions.
	MaxOpenPositions int

	// MaxCategoryPct is the max exposure per market category as % of NAV.
	// Default: 0.30 (30%)
	MaxCategoryPct float64

	// MinLiquidity is the minimum market liquidity to enter a position.
	// Default: 500 USD
	MinLiquidity float64
}

// Manager enforces risk limits on trading signals.
type Manager struct {
	cfg Config

	mu             sync.RWMutex
	highWaterMark  float64
	dailyStartNAV  float64
	dailyStartDate time.Time
}

// NewManager creates a risk manager with the given config.
func NewManager(cfg Config) *Manager {
	if cfg.MaxCategoryPct == 0 {
		cfg.MaxCategoryPct = 0.30
	}
	if cfg.MinLiquidity == 0 {
		cfg.MinLiquidity = 500
	}
	if cfg.MaxOpenPositions == 0 {
		cfg.MaxOpenPositions = 10
	}
	return &Manager{cfg: cfg}
}

// FilterSignals evaluates each signal against risk limits and returns only approved ones.
// Signals that exceed position limits have their size reduced. Signals that violate
// hard limits (drawdown, daily loss) are rejected entirely.
func (m *Manager) FilterSignals(
	ctx context.Context,
	signals []adapters.Signal,
	positions []adapters.Position,
	nav float64,
) ([]adapters.Signal, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("risk: context cancelled: %w", err)
	}

	m.mu.Lock()
	// Update high water mark
	if nav > m.highWaterMark {
		m.highWaterMark = nav
	}

	// Reset daily tracking if new day
	now := time.Now()
	if now.Day() != m.dailyStartDate.Day() || now.Sub(m.dailyStartDate) > 24*time.Hour {
		m.dailyStartNAV = nav
		m.dailyStartDate = now
	}
	if m.dailyStartNAV == 0 {
		m.dailyStartNAV = nav
		m.dailyStartDate = now
	}
	highWater := m.highWaterMark
	dailyStart := m.dailyStartNAV
	m.mu.Unlock()

	// Check 1: Maximum drawdown halt
	if highWater > 0 {
		drawdown := (highWater - nav) / highWater
		if drawdown > m.cfg.MaxDrawdownPct {
			return nil, fmt.Errorf("%w: drawdown %.1f%% exceeds limit %.1f%%",
				ErrMaxDrawdownReached, drawdown*100, m.cfg.MaxDrawdownPct*100)
		}
	}

	// Check 2: Daily loss limit
	if dailyStart > 0 {
		dailyLoss := (dailyStart - nav) / dailyStart
		if dailyLoss > m.cfg.DailyLossLimit {
			return nil, fmt.Errorf("%w: daily loss %.1f%% exceeds limit %.1f%%",
				ErrDailyLossExceeded, dailyLoss*100, m.cfg.DailyLossLimit*100)
		}
	}

	// Check 3: Max open positions
	if len(positions) >= m.cfg.MaxOpenPositions {
		return nil, nil // no new positions, but not an error
	}

	// Build position index for deduplication and category tracking
	positionsByMarket := make(map[string]bool)
	exposureByCategory := make(map[string]float64)
	for _, p := range positions {
		positionsByMarket[p.MarketID] = true
		// For category tracking, we'd need market metadata.
		// For MVP, skip category check if we don't have the data.
	}

	var approved []adapters.Signal

	for _, signal := range signals {
		// Skip markets we already have a position in
		if positionsByMarket[signal.MarketID] {
			continue
		}

		// Position size check and adjustment.
		// Signal.Size is a fraction of portfolio (e.g., 0.05 = 5%) from the strategy layer.
		// Convert to USD for execution, then clamp to max position size.
		if signal.Size > m.cfg.MaxPositionPct {
			signal.Size = m.cfg.MaxPositionPct
		}
		// Convert fraction to USD amount for downstream execution.
		signal.Size = signal.Size * nav

		// Ensure position size is positive
		if signal.Size <= 0 {
			continue
		}

		// Check remaining capacity for open positions
		if len(positions)+len(approved) >= m.cfg.MaxOpenPositions {
			break // no more room
		}

		approved = append(approved, signal)
	}

	return approved, nil
}

// UpdateHighWaterMark manually sets the high water mark (used for initialization).
func (m *Manager) UpdateHighWaterMark(nav float64) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if nav > m.highWaterMark {
		m.highWaterMark = nav
	}
}
```

### Step 2: Create Tests

Create file `projects/agent-prediction/internal/risk/risk_test.go`:

```go
package risk

import (
	"context"
	"errors"
	"testing"

	"github.com/lancekrogers/agent-prediction/internal/adapters"
)

func TestFilterSignals_PositionSizing(t *testing.T) {
	mgr := NewManager(Config{
		MaxPositionPct:   0.05,
		MaxDrawdownPct:   0.15,
		DailyLossLimit:   0.05,
		MaxOpenPositions: 10,
	})
	mgr.UpdateHighWaterMark(10000)

	signals := []adapters.Signal{
		{MarketID: "m1", Size: 0.10}, // 10% of NAV, should be clamped to 5%
		{MarketID: "m2", Size: 0.02}, // 2% of NAV, fine
	}

	approved, err := mgr.FilterSignals(context.Background(), signals, nil, 10000)
	if err != nil {
		t.Fatalf("FilterSignals() error: %v", err)
	}

	if len(approved) != 2 {
		t.Fatalf("expected 2 approved signals, got %d", len(approved))
	}

	// First signal: 10% clamped to 5%, then converted to USD = 500
	if approved[0].Size != 500 { // 0.05 * 10000
		t.Errorf("expected clamped size 500, got %f", approved[0].Size)
	}

	// Second signal: 2% converted to USD = 200
	if approved[1].Size != 200 { // 0.02 * 10000
		t.Errorf("expected size 200, got %f", approved[1].Size)
	}
}

func TestFilterSignals_MaxDrawdown(t *testing.T) {
	mgr := NewManager(Config{
		MaxPositionPct:   0.05,
		MaxDrawdownPct:   0.10,
		DailyLossLimit:   0.05,
		MaxOpenPositions: 10,
	})
	mgr.UpdateHighWaterMark(10000)

	signals := []adapters.Signal{{MarketID: "m1", Size: 100}}

	// NAV dropped 15% from high water mark
	_, err := mgr.FilterSignals(context.Background(), signals, nil, 8500)
	if err == nil {
		t.Fatal("expected error for max drawdown")
	}
	if !errors.Is(err, ErrMaxDrawdownReached) {
		t.Errorf("expected ErrMaxDrawdownReached, got: %v", err)
	}
}

func TestFilterSignals_MaxOpenPositions(t *testing.T) {
	mgr := NewManager(Config{
		MaxPositionPct:   0.05,
		MaxDrawdownPct:   0.50,
		DailyLossLimit:   0.50,
		MaxOpenPositions: 2,
	})

	existingPositions := []adapters.Position{
		{MarketID: "m1", Size: 100},
		{MarketID: "m2", Size: 100},
	}

	signals := []adapters.Signal{{MarketID: "m3", Size: 100}}

	approved, err := mgr.FilterSignals(context.Background(), signals, existingPositions, 10000)
	if err != nil {
		t.Fatalf("FilterSignals() error: %v", err)
	}
	if len(approved) != 0 {
		t.Errorf("expected 0 approved (max positions reached), got %d", len(approved))
	}
}

func TestFilterSignals_SkipExistingPositions(t *testing.T) {
	mgr := NewManager(Config{
		MaxPositionPct:   0.10,
		MaxDrawdownPct:   0.50,
		DailyLossLimit:   0.50,
		MaxOpenPositions: 10,
	})

	existingPositions := []adapters.Position{
		{MarketID: "m1", Size: 100},
	}

	signals := []adapters.Signal{
		{MarketID: "m1", Size: 100}, // already have this
		{MarketID: "m2", Size: 100}, // new market
	}

	approved, err := mgr.FilterSignals(context.Background(), signals, existingPositions, 10000)
	if err != nil {
		t.Fatalf("FilterSignals() error: %v", err)
	}
	if len(approved) != 1 {
		t.Fatalf("expected 1 approved signal, got %d", len(approved))
	}
	if approved[0].MarketID != "m2" {
		t.Errorf("expected market m2, got %s", approved[0].MarketID)
	}
}

func TestFilterSignals_ContextCancellation(t *testing.T) {
	mgr := NewManager(Config{MaxPositionPct: 0.05, MaxDrawdownPct: 0.50, DailyLossLimit: 0.50, MaxOpenPositions: 10})

	ctx, cancel := context.WithCancel(context.Background())
	cancel()

	_, err := mgr.FilterSignals(ctx, []adapters.Signal{{MarketID: "m1", Size: 100}}, nil, 10000)
	if err == nil {
		t.Error("expected error with cancelled context")
	}
}
```

## Done When

- [ ] All requirements met
- [ ] `internal/risk/risk.go` implements `Manager` with `FilterSignals`
- [ ] Position sizing is clamped to `MaxPositionPct` of NAV
- [ ] Max drawdown halts all trading with `ErrMaxDrawdownReached`
- [ ] Daily loss limit halts new trades with `ErrDailyLossExceeded`
- [ ] Max open positions enforced (counts existing + newly approved)
- [ ] Duplicate market positions are skipped
- [ ] High water mark updates correctly
- [ ] `go test ./internal/risk/...` passes with all test cases
