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

## Dependencies

- None for this sequence — standalone package with no internal imports beyond stdlib.

## Implementation Steps

### Step 1: Create `projects/agent-defi/internal/risk/manager_test.go`

Create the directory if needed: `mkdir -p projects/agent-defi/internal/risk`

Write the test file first (TDD). Contains 4 tests:

```go
package risk

import (
	"context"
	"testing"
)

func TestManager_RejectsOversizedPosition(t *testing.T) {
	m := NewManager(Config{
		MaxPositionUSD:   1000,
		MaxDailyVolumeUSD: 10000,
		MaxDrawdownPct:   0.10,
		InitialNAV:       10000,
	})

	// Position of 2000 USD exceeds 1000 USD limit
	err := m.Check(context.Background(), 2000, 1.0)
	if err == nil {
		t.Fatal("expected rejection for oversized position")
	}
}

func TestManager_ClampsPosition(t *testing.T) {
	m := NewManager(Config{
		MaxPositionUSD:   1000,
		MaxDailyVolumeUSD: 10000,
		MaxDrawdownPct:   0.10,
		InitialNAV:       10000,
	})

	// Request 2000 units at price 1.0 → should clamp to 1000
	clamped := m.Clamp(2000, 1.0)
	if clamped != 1000 {
		t.Fatalf("expected clamped size 1000, got %f", clamped)
	}

	// Request 500 units at price 1.0 → should pass through unchanged
	clamped = m.Clamp(500, 1.0)
	if clamped != 500 {
		t.Fatalf("expected size 500, got %f", clamped)
	}
}

func TestManager_DailyVolumeTracking(t *testing.T) {
	m := NewManager(Config{
		MaxPositionUSD:   5000,
		MaxDailyVolumeUSD: 1000,
		MaxDrawdownPct:   0.10,
		InitialNAV:       10000,
	})

	// Record 800 USD in volume
	m.RecordTrade(800, 1.0)

	// Next trade of 300 USD would push total to 1100, exceeding 1000 daily limit
	err := m.Check(context.Background(), 300, 1.0)
	if err == nil {
		t.Fatal("expected rejection for daily volume exceeded")
	}

	// Trade of 200 should be fine (800 + 200 = 1000)
	err = m.Check(context.Background(), 200, 1.0)
	if err != nil {
		t.Fatalf("expected 200 to pass, got: %v", err)
	}
}

func TestManager_DrawdownHalt(t *testing.T) {
	m := NewManager(Config{
		MaxPositionUSD:   5000,
		MaxDailyVolumeUSD: 10000,
		MaxDrawdownPct:   0.10,
		InitialNAV:       10000,
	})

	// NAV drops to 8900 → 11% drawdown, exceeds 10% limit
	m.UpdateNAV(8900)

	err := m.Check(context.Background(), 100, 1.0)
	if err == nil {
		t.Fatal("expected drawdown halt")
	}
}
```

### Step 2: Run Tests (Expect Failure)

```bash
cd projects/agent-defi && go test ./internal/risk/... -v
```

This will fail because the `risk` package does not exist yet.

### Step 3: Create `projects/agent-defi/internal/risk/manager.go`

```go
package risk

import (
	"context"
	"fmt"
	"sync"
	"time"
)

// Config holds risk management parameters.
type Config struct {
	MaxPositionUSD    float64
	MaxDailyVolumeUSD float64
	MaxDrawdownPct    float64
	InitialNAV        float64
}

// Manager enforces off-chain risk limits: position size, daily volume, and drawdown.
// Thread-safe via sync.Mutex.
type Manager struct {
	mu          sync.Mutex
	cfg         Config
	dailyVolume float64
	currentDay  int // day of year for reset tracking
	peakNAV     float64
	currentNAV  float64
}

// NewManager creates a risk manager with the given configuration.
func NewManager(cfg Config) *Manager {
	return &Manager{
		cfg:        cfg,
		peakNAV:    cfg.InitialNAV,
		currentNAV: cfg.InitialNAV,
		currentDay: time.Now().YearDay(),
	}
}

// Check validates whether a trade of the given size (in base units) at the given price
// is allowed under current risk limits. Returns an error if the trade is rejected.
func (m *Manager) Check(ctx context.Context, size float64, price float64) error {
	if err := ctx.Err(); err != nil {
		return fmt.Errorf("risk: context cancelled: %w", err)
	}

	m.mu.Lock()
	defer m.mu.Unlock()

	m.resetDayIfNeeded()

	positionUSD := size * price

	// Check position size limit
	if positionUSD > m.cfg.MaxPositionUSD {
		return fmt.Errorf("risk: position %.2f USD exceeds max %.2f USD", positionUSD, m.cfg.MaxPositionUSD)
	}

	// Check daily volume limit
	if m.dailyVolume+positionUSD > m.cfg.MaxDailyVolumeUSD {
		return fmt.Errorf("risk: daily volume would be %.2f USD, exceeds max %.2f USD",
			m.dailyVolume+positionUSD, m.cfg.MaxDailyVolumeUSD)
	}

	// Check drawdown limit
	if m.peakNAV > 0 {
		drawdown := (m.peakNAV - m.currentNAV) / m.peakNAV
		if drawdown > m.cfg.MaxDrawdownPct {
			return fmt.Errorf("risk: drawdown %.2f%% exceeds max %.2f%%",
				drawdown*100, m.cfg.MaxDrawdownPct*100)
		}
	}

	return nil
}

// Clamp reduces size so that size*price does not exceed MaxPositionUSD.
// Also clamps to remaining daily volume. Returns the clamped size.
func (m *Manager) Clamp(size float64, price float64) float64 {
	m.mu.Lock()
	defer m.mu.Unlock()

	m.resetDayIfNeeded()

	maxSize := m.cfg.MaxPositionUSD / price
	if size > maxSize {
		size = maxSize
	}

	remainingVolume := m.cfg.MaxDailyVolumeUSD - m.dailyVolume
	maxByVolume := remainingVolume / price
	if size > maxByVolume {
		size = maxByVolume
	}

	return size
}

// RecordTrade records a completed trade for daily volume tracking.
func (m *Manager) RecordTrade(size float64, price float64) {
	m.mu.Lock()
	defer m.mu.Unlock()

	m.resetDayIfNeeded()
	m.dailyVolume += size * price
}

// UpdateNAV updates the current net asset value and tracks peak for drawdown calculation.
func (m *Manager) UpdateNAV(nav float64) {
	m.mu.Lock()
	defer m.mu.Unlock()

	m.currentNAV = nav
	if nav > m.peakNAV {
		m.peakNAV = nav
	}
}

// resetDayIfNeeded resets daily volume if the day has changed.
// Must be called with mu held.
func (m *Manager) resetDayIfNeeded() {
	today := time.Now().YearDay()
	if today != m.currentDay {
		m.dailyVolume = 0
		m.currentDay = today
	}
}
```

### Step 4: Run Tests

```bash
cd projects/agent-defi && go test ./internal/risk/... -v
```

**Expected output:** All 4 tests PASS:
- `TestManager_RejectsOversizedPosition`
- `TestManager_ClampsPosition`
- `TestManager_DailyVolumeTracking`
- `TestManager_DrawdownHalt`

## Done When

- [ ] All requirements met
- [ ] `cd projects/agent-defi && go test ./internal/risk/... -v` passes all 4 tests
