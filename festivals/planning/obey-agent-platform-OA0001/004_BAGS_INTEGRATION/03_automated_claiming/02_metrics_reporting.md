---
fest_type: task
fest_id: 02_metrics_reporting.md
fest_name: metrics_reporting
fest_parent: 03_automated_claiming
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.511951-06:00
fest_tracking: true
---

# Task: Token Metrics Collection & Reporting

## Objective

Implement periodic OBEY token metrics collection in `projects/agent-bags/internal/metrics/metrics.go` that tracks volume, holders, fees, pool depth, and reports to the platform coordinator via HCS.

## Requirements

- [ ] `MetricsCollector` struct with configurable poll interval (default 5 minutes)
- [ ] Collect from Bags API: pool state (price, volume, liquidity, market cap, holder count)
- [ ] Collect from Bags API: lifetime fees (total SOL/USDC collected, transaction count)
- [ ] Collect from Bags API: claim stats (total claimed, claim count)
- [ ] Store time-series snapshots in memory (rolling 24h window for dashboard)
- [ ] Report metrics to HCS coordinator topic (JSON message via existing Hedera integration)
- [ ] Expose current metrics via a `Snapshot()` method for the dashboard API

## Implementation

### Step 1: Define MetricsCollector and snapshot types

In `projects/agent-bags/internal/metrics/metrics.go`:

```go
package metrics

import (
    "context"
    "log/slog"
    "sync"
    "time"

    "github.com/lancekrogers/agent-bags/internal/bags"
)

// Snapshot represents a point-in-time view of OBEY token metrics.
type Snapshot struct {
    Timestamp     time.Time `json:"timestamp"`

    // Pool metrics
    Price         float64   `json:"price"`
    Volume24h     float64   `json:"volume24h"`
    Liquidity     float64   `json:"liquidity"`
    MarketCap     float64   `json:"marketCap"`
    HolderCount   int       `json:"holderCount"`
    PoolType      string    `json:"poolType"` // "dbc" or "damm_v2"

    // Fee metrics
    LifetimeFeesSOL  float64 `json:"lifetimeFeesSOL"`
    LifetimeFeesUSDC float64 `json:"lifetimeFeesUSDC"`
    TotalVolume      float64 `json:"totalVolume"`
    TotalTxCount     int     `json:"totalTxCount"`

    // Claim metrics
    TotalClaimedSOL  float64 `json:"totalClaimedSOL"`
    TotalClaimedUSDC float64 `json:"totalClaimedUSDC"`
    ClaimCount       int     `json:"claimCount"`
}

// CollectorConfig holds configuration for the metrics collector.
type CollectorConfig struct {
    Interval  time.Duration // poll interval (default 5m)
    TokenMint string        // OBEY token mint
    MaxHistory int          // max snapshots to keep (default 288 = 24h at 5m intervals)
}

// Collector periodically fetches OBEY token metrics from Bags.
type Collector struct {
    client *bags.Client
    config CollectorConfig
    logger *slog.Logger

    mu       sync.RWMutex
    current  *Snapshot
    history  []Snapshot
}

// NewCollector creates a new metrics collector.
func NewCollector(client *bags.Client, config CollectorConfig, logger *slog.Logger) *Collector {
    if config.Interval == 0 {
        config.Interval = 5 * time.Minute
    }
    if config.MaxHistory == 0 {
        config.MaxHistory = 288 // 24h at 5m intervals
    }
    return &Collector{
        client:  client,
        config:  config,
        logger:  logger,
        history: make([]Snapshot, 0, config.MaxHistory),
    }
}
```

### Step 2: Implement the collection loop

```go
// Run starts the metrics collection loop. Blocks until ctx is cancelled.
func (c *Collector) Run(ctx context.Context) error {
    c.logger.Info("starting metrics collector",
        "interval", c.config.Interval,
        "token_mint", c.config.TokenMint,
    )

    // Collect immediately on start
    c.collect(ctx)

    ticker := time.NewTicker(c.config.Interval)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            c.logger.Info("metrics collector shutting down")
            return ctx.Err()
        case <-ticker.C:
            c.collect(ctx)
        }
    }
}

func (c *Collector) collect(ctx context.Context) {
    if err := ctx.Err(); err != nil {
        return
    }

    snap := Snapshot{
        Timestamp: time.Now(),
    }

    // Fetch pool data
    pool, err := c.client.GetPoolByMint(ctx, c.config.TokenMint)
    if err != nil {
        c.logger.Error("failed to fetch pool metrics", "error", err)
    } else {
        snap.Price = pool.Price
        snap.Volume24h = pool.Volume24h
        snap.Liquidity = pool.Liquidity
        snap.MarketCap = pool.MarketCap
        snap.HolderCount = pool.HolderCount
        snap.PoolType = pool.PoolType
    }

    // Fetch lifetime fees
    fees, err := c.client.GetLifetimeFees(ctx, c.config.TokenMint)
    if err != nil {
        c.logger.Error("failed to fetch lifetime fees", "error", err)
    } else {
        snap.LifetimeFeesSOL = fees.TotalFeesSOL
        snap.LifetimeFeesUSDC = fees.TotalFeesUSDC
        snap.TotalVolume = fees.TotalVolume
        snap.TotalTxCount = fees.TotalTransactions
    }

    // Fetch claim stats
    stats, err := c.client.GetClaimStats(ctx)
    if err != nil {
        c.logger.Error("failed to fetch claim stats", "error", err)
    } else {
        snap.TotalClaimedSOL = stats.TotalClaimedSOL
        snap.TotalClaimedUSDC = stats.TotalClaimedUSDC
        snap.ClaimCount = stats.ClaimCount
    }

    // Store snapshot
    c.mu.Lock()
    c.current = &snap
    c.history = append(c.history, snap)
    if len(c.history) > c.config.MaxHistory {
        c.history = c.history[len(c.history)-c.config.MaxHistory:]
    }
    c.mu.Unlock()

    c.logger.Info("metrics collected",
        "price", snap.Price,
        "volume_24h", snap.Volume24h,
        "liquidity", snap.Liquidity,
        "holders", snap.HolderCount,
        "lifetime_fees_sol", snap.LifetimeFeesSOL,
        "total_claimed_sol", snap.TotalClaimedSOL,
    )
}
```

### Step 3: Expose snapshot accessors

```go
// Snapshot returns the most recent metrics snapshot.
func (c *Collector) Snapshot() *Snapshot {
    c.mu.RLock()
    defer c.mu.RUnlock()
    return c.current
}

// History returns the rolling 24h history of snapshots.
func (c *Collector) History() []Snapshot {
    c.mu.RLock()
    defer c.mu.RUnlock()
    result := make([]Snapshot, len(c.history))
    copy(result, c.history)
    return result
}

// HCSMetricsMessage formats the current snapshot as an HCS-compatible JSON message.
// This is sent to the coordinator topic for platform-wide visibility.
func (c *Collector) HCSMetricsMessage() map[string]any {
    c.mu.RLock()
    defer c.mu.RUnlock()
    if c.current == nil {
        return nil
    }
    return map[string]any{
        "type":              "obey_token_metrics",
        "timestamp":         c.current.Timestamp.Unix(),
        "token_mint":        c.config.TokenMint,
        "price":             c.current.Price,
        "volume_24h":        c.current.Volume24h,
        "liquidity":         c.current.Liquidity,
        "market_cap":        c.current.MarketCap,
        "holder_count":      c.current.HolderCount,
        "pool_type":         c.current.PoolType,
        "lifetime_fees_sol": c.current.LifetimeFeesSOL,
        "total_claimed_sol": c.current.TotalClaimedSOL,
        "claim_count":       c.current.ClaimCount,
    }
}
```

### Step 4: Wire into main.go

In `cmd/agent-bags/main.go` `run()`, start metrics alongside claim service:

```go
metricsSvc := metrics.NewCollector(client, metrics.CollectorConfig{
    Interval:  5 * time.Minute,
    TokenMint: tokenMgr.MintAddress(),
}, logger)

go func() {
    if err := metricsSvc.Run(ctx); err != nil && err != context.Canceled {
        logger.Error("metrics collector error", "error", err)
    }
}()
```

### Step 5: Write tests

Create `projects/agent-bags/internal/metrics/metrics_test.go`:

1. `TestCollectSuccess` — mock all 3 API calls, verify snapshot has all fields populated
2. `TestCollectPartialFailure` — pool call fails, fees/stats succeed, verify partial snapshot
3. `TestHistoryRollingWindow` — add 300 snapshots, verify only MaxHistory (288) retained
4. `TestSnapshotConcurrency` — read Snapshot() from multiple goroutines during collect
5. `TestHCSMetricsMessage` — verify JSON message format matches coordinator protocol
6. `TestCollectorContextCancel` — start Run, cancel, verify shutdown

## Done When

- [ ] All requirements met
- [ ] Collector polls pool, lifetime fees, and claim stats from Bags API every 5 minutes
- [ ] Snapshots stored in rolling 24h window (288 entries at 5m intervals)
- [ ] `Snapshot()` returns current metrics, `History()` returns full time series
- [ ] `HCSMetricsMessage()` produces valid JSON for the coordinator topic
- [ ] Partial API failures do not crash the collector; available data is still stored
- [ ] `go test ./internal/metrics/...` passes with all metrics tests green
