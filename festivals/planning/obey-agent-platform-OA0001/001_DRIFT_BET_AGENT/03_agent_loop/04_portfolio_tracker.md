---
fest_type: task
fest_id: 04_portfolio_tracker.md
fest_name: portfolio_tracker
fest_parent: 03_agent_loop
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.317291-06:00
fest_tracking: true
---

# Task: Portfolio Tracker Implementation

## Objective

Implement the portfolio tracking system that maintains position state, calculates NAV from prediction market positions, tracks P&L (realized and unrealized), records trade history, and generates performance reports for HCS publishing.

## Requirements

- [ ] Track all open positions with entry prices and current values
- [ ] NAV calculation: cash balance + sum(position_size * current_price)
- [ ] Realized P&L tracking (from settled/closed positions)
- [ ] Unrealized P&L tracking (from open positions at current prices)
- [ ] Trade history recording with timestamps and tx signatures
- [ ] Win rate calculation across resolved positions
- [ ] Performance report generation for HCS publishing
- [ ] Thread-safe (multiple goroutines access portfolio)

## Implementation

### Step 1: Implement the Portfolio Tracker

Update file `projects/agent-prediction/internal/portfolio/portfolio.go`:

```go
package portfolio

import (
	"sync"
	"time"

	"github.com/lancekrogers/agent-prediction/internal/adapters"
)

// TradeRecord captures a single trade execution.
type TradeRecord struct {
	MarketID    string
	Platform    string
	Direction   string
	OutcomeID   string
	Size        float64
	Edge        float64
	TxSignature string
	ExecutedAt  time.Time
	Reason      string
}

// PositionState tracks an open position with P&L data.
type PositionState struct {
	adapters.Position
	EntryTime    time.Time
	IsResolved   bool
	Won          bool
	RealizedPnL  float64
}

// Report contains performance metrics for HCS publishing.
type Report struct {
	NAV            float64
	CashBalance    float64
	TotalReturn    float64 // (NAV - initial) / initial
	RealizedPnL    float64
	UnrealizedPnL  float64
	WinRate        float64 // resolved positions that won
	OpenPositions  int
	TotalTrades    int
	ResolvedTrades int
	WonTrades      int
	HighWaterMark  float64
	MaxDrawdown    float64
}

// Tracker maintains portfolio state, positions, and performance metrics.
type Tracker struct {
	mu sync.RWMutex

	initialNAV    float64
	cashBalance   float64
	positions     map[string]*PositionState // keyed by MarketID
	trades        []TradeRecord
	highWaterMark float64
	maxDrawdown   float64

	// Resolved position stats
	resolvedCount int
	wonCount      int
	totalRealizedPnL float64
}

// NewTracker creates a portfolio tracker with the given initial NAV (seed capital).
func NewTracker(initialNAV float64) *Tracker {
	return &Tracker{
		initialNAV:    initialNAV,
		cashBalance:   initialNAV,
		positions:     make(map[string]*PositionState),
		highWaterMark: initialNAV,
	}
}

// NAV returns the current net asset value: cash + sum(position values).
func (t *Tracker) NAV() float64 {
	t.mu.RLock()
	defer t.mu.RUnlock()
	return t.nav()
}

// nav is the internal (unlocked) NAV calculation.
func (t *Tracker) nav() float64 {
	nav := t.cashBalance
	for _, pos := range t.positions {
		if !pos.IsResolved {
			nav += pos.Value
		}
	}
	return nav
}

// RecordTrade records a new trade execution.
func (t *Tracker) RecordTrade(signal adapters.Signal, txSig string) {
	t.mu.Lock()
	defer t.mu.Unlock()

	record := TradeRecord{
		MarketID:    signal.MarketID,
		Platform:    signal.Platform,
		Direction:   signal.Direction,
		OutcomeID:   signal.OutcomeID,
		Size:        signal.Size,
		Edge:        signal.Edge,
		TxSignature: txSig,
		ExecutedAt:  time.Now(),
		Reason:      signal.Reason,
	}
	t.trades = append(t.trades, record)

	// Deduct trade size from cash balance
	t.cashBalance -= signal.Size

	// Create or update position
	if _, exists := t.positions[signal.MarketID]; !exists {
		t.positions[signal.MarketID] = &PositionState{
			Position: adapters.Position{
				MarketID:  signal.MarketID,
				Platform:  signal.Platform,
				OutcomeID: signal.OutcomeID,
				Size:      signal.Size,
				AvgPrice:  signal.Edge, // approximate; updated from adapter
				Value:     signal.Size,
			},
			EntryTime: time.Now(),
		}
	}
}

// UpdatePositions syncs position state from the adapter's current positions.
func (t *Tracker) UpdatePositions(positions []adapters.Position) {
	t.mu.Lock()
	defer t.mu.Unlock()

	// Update existing positions with current values
	currentMarkets := make(map[string]bool)
	for _, p := range positions {
		currentMarkets[p.MarketID] = true

		if existing, ok := t.positions[p.MarketID]; ok {
			existing.Position = p
		} else {
			// Position exists on chain but not in our records
			// (could be from a previous run)
			t.positions[p.MarketID] = &PositionState{
				Position:  p,
				EntryTime: time.Now(),
			}
		}
	}

	// Mark positions that are no longer in the adapter as resolved
	for marketID, pos := range t.positions {
		if !currentMarkets[marketID] && !pos.IsResolved {
			pos.IsResolved = true
			// If position disappeared, it was settled.
			// Positive value means we won.
			if pos.Value > pos.Size*pos.AvgPrice {
				pos.Won = true
				pos.RealizedPnL = pos.Size // full payout on winning prediction
				t.wonCount++
			} else {
				pos.RealizedPnL = -pos.Size * pos.AvgPrice // lost the cost
			}
			t.resolvedCount++
			t.totalRealizedPnL += pos.RealizedPnL

			// Return any value to cash
			t.cashBalance += pos.Value
		}
	}

	// Update high water mark and max drawdown
	currentNAV := t.nav()
	if currentNAV > t.highWaterMark {
		t.highWaterMark = currentNAV
	}
	if t.highWaterMark > 0 {
		drawdown := (t.highWaterMark - currentNAV) / t.highWaterMark
		if drawdown > t.maxDrawdown {
			t.maxDrawdown = drawdown
		}
	}
}

// Report generates a performance report for HCS publishing.
func (t *Tracker) Report() Report {
	t.mu.RLock()
	defer t.mu.RUnlock()

	currentNAV := t.nav()

	// Calculate unrealized P&L
	unrealizedPnL := 0.0
	openPositions := 0
	for _, pos := range t.positions {
		if !pos.IsResolved {
			openPositions++
			unrealizedPnL += pos.Value - (pos.Size * pos.AvgPrice)
		}
	}

	// Win rate
	winRate := 0.0
	if t.resolvedCount > 0 {
		winRate = float64(t.wonCount) / float64(t.resolvedCount)
	}

	// Total return
	totalReturn := 0.0
	if t.initialNAV > 0 {
		totalReturn = (currentNAV - t.initialNAV) / t.initialNAV
	}

	return Report{
		NAV:            currentNAV,
		CashBalance:    t.cashBalance,
		TotalReturn:    totalReturn,
		RealizedPnL:    t.totalRealizedPnL,
		UnrealizedPnL:  unrealizedPnL,
		WinRate:        winRate,
		OpenPositions:  openPositions,
		TotalTrades:    len(t.trades),
		ResolvedTrades: t.resolvedCount,
		WonTrades:      t.wonCount,
		HighWaterMark:  t.highWaterMark,
		MaxDrawdown:    t.maxDrawdown,
	}
}

// Trades returns a copy of all trade records.
func (t *Tracker) Trades() []TradeRecord {
	t.mu.RLock()
	defer t.mu.RUnlock()

	result := make([]TradeRecord, len(t.trades))
	copy(result, t.trades)
	return result
}
```

### Step 2: Create Tests

Create file `projects/agent-prediction/internal/portfolio/portfolio_test.go`:

```go
package portfolio

import (
	"testing"

	"github.com/lancekrogers/agent-prediction/internal/adapters"
)

func TestNewTracker(t *testing.T) {
	tracker := NewTracker(10000)

	if tracker.NAV() != 10000 {
		t.Errorf("expected initial NAV 10000, got %f", tracker.NAV())
	}

	report := tracker.Report()
	if report.CashBalance != 10000 {
		t.Errorf("expected cash 10000, got %f", report.CashBalance)
	}
	if report.TotalReturn != 0 {
		t.Errorf("expected 0 total return, got %f", report.TotalReturn)
	}
}

func TestRecordTrade(t *testing.T) {
	tracker := NewTracker(10000)

	signal := adapters.Signal{
		MarketID:  "drift_bet:0",
		Platform:  "drift_bet",
		Direction: "buy",
		OutcomeID: "yes",
		Size:      500,
		Edge:      0.15,
	}

	tracker.RecordTrade(signal, "tx123")

	report := tracker.Report()
	if report.CashBalance != 9500 {
		t.Errorf("expected cash 9500, got %f", report.CashBalance)
	}
	if report.TotalTrades != 1 {
		t.Errorf("expected 1 trade, got %d", report.TotalTrades)
	}
	if report.OpenPositions != 1 {
		t.Errorf("expected 1 open position, got %d", report.OpenPositions)
	}

	trades := tracker.Trades()
	if len(trades) != 1 {
		t.Fatalf("expected 1 trade record, got %d", len(trades))
	}
	if trades[0].TxSignature != "tx123" {
		t.Errorf("expected tx sig 'tx123', got %q", trades[0].TxSignature)
	}
}

func TestUpdatePositions_ValueChange(t *testing.T) {
	tracker := NewTracker(10000)

	signal := adapters.Signal{
		MarketID: "drift_bet:0", Platform: "drift_bet",
		Direction: "buy", OutcomeID: "yes", Size: 500, Edge: 0.60,
	}
	tracker.RecordTrade(signal, "tx1")

	// Price went up — position is worth more
	tracker.UpdatePositions([]adapters.Position{
		{MarketID: "drift_bet:0", Platform: "drift_bet", OutcomeID: "yes", Size: 500, AvgPrice: 0.60, Value: 600},
	})

	nav := tracker.NAV()
	expected := 9500 + 600.0 // cash + position value
	if nav != expected {
		t.Errorf("expected NAV %f, got %f", expected, nav)
	}
}

func TestUpdatePositions_Resolution(t *testing.T) {
	tracker := NewTracker(10000)

	signal := adapters.Signal{
		MarketID: "drift_bet:0", Platform: "drift_bet",
		Direction: "buy", OutcomeID: "yes", Size: 500, Edge: 0.60,
	}
	tracker.RecordTrade(signal, "tx1")

	// Position exists
	tracker.UpdatePositions([]adapters.Position{
		{MarketID: "drift_bet:0", Platform: "drift_bet", OutcomeID: "yes", Size: 500, AvgPrice: 0.60, Value: 500},
	})

	// Position disappears (market resolved)
	tracker.UpdatePositions([]adapters.Position{})

	report := tracker.Report()
	if report.OpenPositions != 0 {
		t.Errorf("expected 0 open positions after resolution, got %d", report.OpenPositions)
	}
	if report.ResolvedTrades != 1 {
		t.Errorf("expected 1 resolved trade, got %d", report.ResolvedTrades)
	}
}

func TestHighWaterMarkAndDrawdown(t *testing.T) {
	tracker := NewTracker(10000)

	// NAV increases to 12000
	tracker.UpdatePositions([]adapters.Position{
		{MarketID: "m1", Value: 2000},
	})

	report := tracker.Report()
	if report.HighWaterMark != 12000 {
		t.Errorf("expected HWM 12000, got %f", report.HighWaterMark)
	}

	// NAV drops to 10500 (position lost value)
	tracker.UpdatePositions([]adapters.Position{
		{MarketID: "m1", Value: 500},
	})

	report = tracker.Report()
	expectedDrawdown := (12000 - 10500.0) / 12000.0
	if report.MaxDrawdown < expectedDrawdown-0.01 || report.MaxDrawdown > expectedDrawdown+0.01 {
		t.Errorf("expected drawdown ~%.2f%%, got %.2f%%", expectedDrawdown*100, report.MaxDrawdown*100)
	}
}

func TestWinRate(t *testing.T) {
	tracker := NewTracker(10000)

	// Record 3 trades
	for i := 0; i < 3; i++ {
		tracker.RecordTrade(adapters.Signal{
			MarketID: "m" + string(rune('0'+i)), Size: 100, Edge: 0.5,
		}, "tx")
	}

	// Simulate: m0 won (high value), m1 lost (no value), m2 still open
	tracker.UpdatePositions([]adapters.Position{
		{MarketID: "m0", Size: 100, AvgPrice: 0.5, Value: 200}, // winning
		{MarketID: "m1", Size: 100, AvgPrice: 0.5, Value: 10},  // losing
		{MarketID: "m2", Size: 100, AvgPrice: 0.5, Value: 100}, // open
	})

	// Resolve m0 and m1 (remove from positions)
	tracker.UpdatePositions([]adapters.Position{
		{MarketID: "m2", Size: 100, AvgPrice: 0.5, Value: 100},
	})

	report := tracker.Report()
	if report.ResolvedTrades != 2 {
		t.Errorf("expected 2 resolved trades, got %d", report.ResolvedTrades)
	}
	if report.OpenPositions != 1 {
		t.Errorf("expected 1 open position, got %d", report.OpenPositions)
	}
}
```

## Done When

- [ ] All requirements met
- [ ] `internal/portfolio/portfolio.go` implements `Tracker` with full position tracking
- [ ] NAV calculation accounts for cash + open position values
- [ ] `RecordTrade` deducts cash and creates position state
- [ ] `UpdatePositions` syncs from adapter, detects resolutions, tracks P&L
- [ ] High water mark and max drawdown are tracked
- [ ] Win rate is calculated from resolved positions
- [ ] `Report()` generates all metrics needed for HCS publishing
- [ ] Thread-safe with `sync.RWMutex`
- [ ] `go test ./internal/portfolio/...` passes
