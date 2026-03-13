---
fest_type: task
fest_id: 02_nav_reporting.md
fest_name: nav_reporting
fest_parent: 03_agent_vault_client
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.396143-06:00
fest_tracking: true
---

# Task: NAV Calculation and Reporting Pipeline

## Objective

Build the off-chain NAV calculation and reporting pipeline that the OBEY Predictor agent runs continuously — computing NAV from Drift BET positions, verifying it independently, and submitting `update_nav` transactions to the on-chain vault.

## Requirements

- [ ] NAV calculator that sums vault USDC balance + Drift BET position values
- [ ] Independent NAV verifier that cross-checks agent-reported NAV against Drift API
- [ ] Periodic NAV reporting loop (configurable interval, default 5 minutes)
- [ ] Deviation threshold — reject NAV updates that deviate more than 1% from independently calculated value
- [ ] All NAV updates logged with before/after values for audit trail
- [ ] Graceful handling of Drift API failures (retry with backoff, skip update if unreachable)
- [ ] Context propagation throughout

## Implementation

### Step 1: NAV Calculator

File: `pkg/navcalc/calculator.go`

```go
package navcalc

import (
    "context"
    "fmt"

    "github.com/gagliardetto/solana-go"
)

// Position represents a single open position on Drift BET
type Position struct {
    MarketID    string  // Drift market identifier
    Side        string  // "YES" or "NO"
    Size        uint64  // number of contracts
    AvgEntry    float64 // average entry price (0.0 - 1.0)
    CurrentMid  float64 // current mid-market price (0.0 - 1.0)
    Resolved    bool    // has the market resolved?
    WonPayout   uint64  // if resolved and won, the USDC payout
}

// NAVReport contains the full breakdown of vault value
type NAVReport struct {
    // USDC sitting idle in the vault's on-chain token account
    VaultUSDCBalance uint64
    // Total value of open Drift BET positions (in USDC base units, 6 decimals)
    OpenPositionValue uint64
    // Breakdown of individual positions
    Positions []Position
    // Total NAV = VaultUSDCBalance + OpenPositionValue
    TotalNAV uint64
    // Timestamp of calculation
    CalculatedAt int64
}

// DriftClient defines the interface for reading Drift BET positions
type DriftClient interface {
    // GetOpenPositions returns all open BET positions for the agent wallet
    GetOpenPositions(ctx context.Context, wallet solana.PublicKey) ([]Position, error)
    // GetMarketPrice returns the current mid price for a BET market
    GetMarketPrice(ctx context.Context, marketID string) (float64, error)
}

// Calculator computes NAV from on-chain USDC balance and Drift positions
type Calculator struct {
    drift       DriftClient
    vaultClient VaultReader
}

// VaultReader reads on-chain vault state (subset of vaultclient)
type VaultReader interface {
    FetchVaultUSDCBalance(ctx context.Context, ata solana.PublicKey) (uint64, error)
    FetchVaultState(ctx context.Context) (*VaultState, error)
}

// VaultState is a minimal copy of vaultclient.VaultState to avoid circular deps
type VaultState struct {
    VaultUsdcATA solana.PublicKey
    TotalNav     uint64
    TotalShares  uint64
    AgentWallet  solana.PublicKey
}

// New creates a NAV calculator
func New(drift DriftClient, vaultClient VaultReader) *Calculator {
    return &Calculator{drift: drift, vaultClient: vaultClient}
}

// Calculate computes the current NAV by summing vault USDC + position values
func (c *Calculator) Calculate(ctx context.Context) (*NAVReport, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("context cancelled before NAV calculation: %w", err)
    }

    // 1. Read on-chain USDC balance
    vaultState, err := c.vaultClient.FetchVaultState(ctx)
    if err != nil {
        return nil, fmt.Errorf("fetching vault state: %w", err)
    }

    usdcBalance, err := c.vaultClient.FetchVaultUSDCBalance(ctx, vaultState.VaultUsdcATA)
    if err != nil {
        return nil, fmt.Errorf("fetching USDC balance: %w", err)
    }

    // 2. Get open Drift BET positions
    positions, err := c.drift.GetOpenPositions(ctx, vaultState.AgentWallet)
    if err != nil {
        return nil, fmt.Errorf("fetching Drift positions: %w", err)
    }

    // 3. Value each position
    var openValue uint64
    for i, pos := range positions {
        if pos.Resolved {
            openValue += pos.WonPayout
            continue
        }

        // Get current market price
        currentPrice, err := c.drift.GetMarketPrice(ctx, pos.MarketID)
        if err != nil {
            // If we can't price a position, value it at entry (conservative)
            currentPrice = pos.AvgEntry
        }
        positions[i].CurrentMid = currentPrice

        // Position value = size * current_price (in USDC base units)
        // Drift BET contracts pay 1 USDC if correct, so value = size * probability
        posValue := uint64(float64(pos.Size) * currentPrice)
        openValue += posValue
    }

    // 4. Total NAV
    totalNAV := usdcBalance + openValue

    return &NAVReport{
        VaultUSDCBalance:  usdcBalance,
        OpenPositionValue: openValue,
        Positions:         positions,
        TotalNAV:          totalNAV,
        CalculatedAt:      time.Now().Unix(),
    }, nil
}
```

### Step 2: NAV Verifier

File: `pkg/navcalc/verifier.go`

```go
package navcalc

import (
    "context"
    "fmt"
    "math"
)

const (
    // MaxDeviationPct is the maximum allowed deviation between
    // agent-reported NAV and independently calculated NAV
    MaxDeviationPct = 1.0
)

// Verifier independently calculates NAV and compares against reported values
type Verifier struct {
    calc *Calculator
}

// NewVerifier creates a NAV verifier
func NewVerifier(calc *Calculator) *Verifier {
    return &Verifier{calc: calc}
}

// VerifyResult contains the verification outcome
type VerifyResult struct {
    ReportedNAV     uint64
    CalculatedNAV   uint64
    DeviationPct    float64
    Accepted        bool
    Reason          string
}

// Verify checks if a reported NAV is within acceptable deviation
func (v *Verifier) Verify(ctx context.Context, reportedNAV uint64) (*VerifyResult, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("context cancelled: %w", err)
    }

    report, err := v.calc.Calculate(ctx)
    if err != nil {
        return nil, fmt.Errorf("independent NAV calculation failed: %w", err)
    }

    result := &VerifyResult{
        ReportedNAV:   reportedNAV,
        CalculatedNAV: report.TotalNAV,
    }

    // Calculate deviation
    if report.TotalNAV == 0 {
        if reportedNAV == 0 {
            result.Accepted = true
            result.Reason = "both zero"
            return result, nil
        }
        result.Accepted = false
        result.Reason = "calculated NAV is zero but reported is non-zero"
        return result, nil
    }

    deviation := math.Abs(float64(reportedNAV)-float64(report.TotalNAV)) / float64(report.TotalNAV) * 100.0
    result.DeviationPct = deviation

    if deviation <= MaxDeviationPct {
        result.Accepted = true
        result.Reason = fmt.Sprintf("deviation %.2f%% within threshold", deviation)
    } else {
        result.Accepted = false
        result.Reason = fmt.Sprintf("deviation %.2f%% exceeds %.1f%% threshold", deviation, MaxDeviationPct)
    }

    return result, nil
}
```

### Step 3: NAV Reporting Loop

File: `pkg/navcalc/reporter.go`

```go
package navcalc

import (
    "context"
    "fmt"
    "log/slog"
    "time"
)

// NavUpdater submits NAV updates to the on-chain vault
type NavUpdater interface {
    UpdateNAV(ctx context.Context, newNav uint64) (string, error)
}

// Reporter runs the periodic NAV calculation and submission loop
type Reporter struct {
    calc     *Calculator
    verifier *Verifier
    updater  NavUpdater
    interval time.Duration
    logger   *slog.Logger
}

// ReporterConfig configures the NAV reporter
type ReporterConfig struct {
    // How often to calculate and report NAV
    Interval time.Duration
    // Logger for structured logging
    Logger *slog.Logger
}

// NewReporter creates a NAV reporter
func NewReporter(calc *Calculator, verifier *Verifier, updater NavUpdater, cfg ReporterConfig) *Reporter {
    interval := cfg.Interval
    if interval == 0 {
        interval = 5 * time.Minute
    }
    logger := cfg.Logger
    if logger == nil {
        logger = slog.Default()
    }
    return &Reporter{
        calc:     calc,
        verifier: verifier,
        updater:  updater,
        interval: interval,
        logger:   logger,
    }
}

// Run starts the NAV reporting loop. Blocks until context is cancelled.
func (r *Reporter) Run(ctx context.Context) error {
    r.logger.Info("starting NAV reporter", "interval", r.interval)

    // Run immediately on start, then on interval
    if err := r.reportOnce(ctx); err != nil {
        r.logger.Error("initial NAV report failed", "error", err)
    }

    ticker := time.NewTicker(r.interval)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            r.logger.Info("NAV reporter shutting down")
            return ctx.Err()
        case <-ticker.C:
            if err := r.reportOnce(ctx); err != nil {
                r.logger.Error("NAV report cycle failed", "error", err)
                // Continue running — next tick will retry
            }
        }
    }
}

func (r *Reporter) reportOnce(ctx context.Context) error {
    // 1. Calculate NAV
    report, err := r.calc.Calculate(ctx)
    if err != nil {
        return fmt.Errorf("calculating NAV: %w", err)
    }

    r.logger.Info("NAV calculated",
        "total_nav", report.TotalNAV,
        "usdc_balance", report.VaultUSDCBalance,
        "open_positions", report.OpenPositionValue,
        "num_positions", len(report.Positions),
    )

    // 2. Verify against independent calculation
    result, err := r.verifier.Verify(ctx, report.TotalNAV)
    if err != nil {
        return fmt.Errorf("verifying NAV: %w", err)
    }

    if !result.Accepted {
        r.logger.Warn("NAV verification failed — skipping update",
            "reported", result.ReportedNAV,
            "calculated", result.CalculatedNAV,
            "deviation_pct", result.DeviationPct,
            "reason", result.Reason,
        )
        return fmt.Errorf("NAV verification failed: %s", result.Reason)
    }

    // 3. Submit on-chain update
    sig, err := r.updater.UpdateNAV(ctx, report.TotalNAV)
    if err != nil {
        return fmt.Errorf("submitting NAV update tx: %w", err)
    }

    r.logger.Info("NAV updated on-chain",
        "new_nav", report.TotalNAV,
        "tx_signature", sig,
        "deviation_pct", result.DeviationPct,
    )

    return nil
}
```

### Step 4: Integration with the OBEY Predictor agent

The agent's main run loop (from doc 11) calls into this pipeline:

```go
// In the agent's Run() method:
func (a *PredictorAgent) Run(ctx context.Context) {
    // Start NAV reporter as a background goroutine
    reporter := navcalc.NewReporter(
        a.navCalc,
        a.navVerifier,
        a.vaultClient, // implements NavUpdater
        navcalc.ReporterConfig{
            Interval: 5 * time.Minute,
            Logger:   a.logger,
        },
    )

    go func() {
        if err := reporter.Run(ctx); err != nil {
            a.logger.Error("NAV reporter stopped", "error", err)
        }
    }()

    // ... rest of trading loop
}
```

### Step 5: Audit logging

Every NAV update should produce a structured log entry that can be queried for auditing:

```go
// Log format (structured JSON):
// {
//   "level": "INFO",
//   "msg": "NAV updated on-chain",
//   "time": "2026-03-13T15:04:05Z",
//   "new_nav": 1234567890,
//   "old_nav": 1200000000,
//   "usdc_balance": 800000000,
//   "open_positions": 434567890,
//   "tx_signature": "5KtW...",
//   "deviation_pct": 0.23,
//   "num_positions": 7
// }
```

These logs serve as the off-chain audit trail that proves NAV was independently verified before each update. Per the MVP trust model from doc 11, this is the primary defense against NAV manipulation until oracle-based NAV replaces it in Phase 2.

## Done When

- [ ] All requirements met
- [ ] `Calculator.Calculate()` correctly sums vault USDC + Drift position values
- [ ] `Verifier.Verify()` rejects NAV deviations > 1%
- [ ] `Reporter.Run()` loops on interval, calculates, verifies, and submits NAV updates
- [ ] Drift API failures are handled gracefully (logged, skipped, retried on next tick)
- [ ] All functions accept `context.Context` and check cancellation
- [ ] Structured logging with all relevant fields for audit trail
- [ ] Unit tests for Calculator (mock Drift client with known positions)
- [ ] Unit tests for Verifier (deviation threshold enforcement)
- [ ] Integration test: Reporter runs 2 cycles against devnet vault
