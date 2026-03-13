---
fest_type: task
fest_id: 01_claim_loop.md
fest_name: claim_loop
fest_parent: 03_automated_claiming
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.511557-06:00
fest_tracking: true
---

# Task: Automated Fee Claiming Loop

## Objective

Implement the periodic fee claiming daemon in `projects/agent-bags/internal/fees/fees.go` that runs every 6 hours, fetches claimable positions, generates claim transactions, signs and submits them, and logs results.

## Requirements

- [ ] `ClaimService` struct with configurable claim interval (default 6 hours from env `BAGS_CLAIM_INTERVAL`)
- [ ] `Run` method that starts a ticker-based loop, respecting context cancellation
- [ ] Each claim cycle: get claimable positions -> get claim txs v3 -> sign each -> submit each -> log results
- [ ] Also claim partner fees via `GET /claim/partner` if the agent has partner positions
- [ ] Track claim results: number of txs submitted, total SOL/USDC claimed, any failures
- [ ] Graceful error handling: individual tx failure does not stop the cycle, all positions attempted
- [ ] Emit structured log entries for each claim attempt (success/failure, amounts, tx signatures)

## Implementation

### Step 1: Define ClaimService

In `projects/agent-bags/internal/fees/fees.go`:

```go
package fees

import (
    "context"
    "fmt"
    "log/slog"
    "time"

    "github.com/lancekrogers/agent-bags/internal/bags"
)

// ClaimConfig holds configuration for the claim service.
type ClaimConfig struct {
    Interval  time.Duration // how often to run claim cycle (default 6h)
    TokenMint string        // OBEY token mint address
}

// ClaimResult tracks the outcome of a single claim cycle.
type ClaimResult struct {
    Timestamp     time.Time
    TxSubmitted   int
    TxSucceeded   int
    TxFailed      int
    TotalSOL      float64
    TotalUSDC     float64
    Errors        []error
    Signatures    []string
}

// ClaimService runs periodic fee claiming against the Bags API.
type ClaimService struct {
    client *bags.Client
    signer *bags.Signer
    config ClaimConfig
    logger *slog.Logger

    // Track last claim result for metrics reporting
    lastResult *ClaimResult
}

// NewClaimService creates a new fee claiming service.
func NewClaimService(client *bags.Client, signer *bags.Signer, config ClaimConfig, logger *slog.Logger) *ClaimService {
    if config.Interval == 0 {
        config.Interval = 6 * time.Hour
    }
    return &ClaimService{
        client: client,
        signer: signer,
        config: config,
        logger: logger,
    }
}

// LastResult returns the most recent claim cycle result.
func (s *ClaimService) LastResult() *ClaimResult {
    return s.lastResult
}
```

### Step 2: Implement the main run loop

```go
// Run starts the claim loop. Blocks until ctx is cancelled.
func (s *ClaimService) Run(ctx context.Context) error {
    s.logger.Info("starting fee claim service",
        "interval", s.config.Interval,
        "token_mint", s.config.TokenMint,
    )

    // Run immediately on start, then on ticker
    if err := ctx.Err(); err != nil {
        return err
    }
    s.executeCycle(ctx)

    ticker := time.NewTicker(s.config.Interval)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            s.logger.Info("fee claim service shutting down")
            return ctx.Err()
        case <-ticker.C:
            s.executeCycle(ctx)
        }
    }
}

// executeCycle runs a single claim cycle.
func (s *ClaimService) executeCycle(ctx context.Context) {
    if err := ctx.Err(); err != nil {
        return
    }

    result := &ClaimResult{
        Timestamp: time.Now(),
    }

    s.logger.Info("starting claim cycle")

    // Step 1: Check claimable positions
    positions, err := s.client.GetClaimablePositions(ctx)
    if err != nil {
        s.logger.Error("failed to get claimable positions", "error", err)
        result.Errors = append(result.Errors, err)
        s.lastResult = result
        return
    }

    s.logger.Info("found claimable positions", "count", len(positions))
    if len(positions) == 0 {
        s.lastResult = result
        return
    }

    // Step 2: Get claim transactions for OBEY token
    claimTxs, err := s.client.GetClaimTransactionsV3(ctx, s.config.TokenMint)
    if err != nil {
        s.logger.Error("failed to get claim transactions", "error", err)
        result.Errors = append(result.Errors, err)
    }

    // Step 3: Also get partner claim transactions
    partnerTxs, err := s.client.GetPartnerClaimTx(ctx)
    if err != nil {
        s.logger.Warn("failed to get partner claim txs", "error", err)
        // Non-fatal: continue with regular claims
    }

    // Merge all claim txs
    allTxs := append(claimTxs, partnerTxs...)

    // Step 4: Sign and submit each transaction
    for i, claimTx := range allTxs {
        if err := ctx.Err(); err != nil {
            break
        }

        result.TxSubmitted++
        s.logger.Info("signing claim transaction",
            "index", i+1,
            "total", len(allTxs),
            "mint", claimTx.Mint,
            "pool_type", claimTx.PoolType,
            "est_sol", claimTx.EstimatedSOL,
            "est_usdc", claimTx.EstimatedUSDC,
        )

        // Sign
        signedTx, err := s.signer.SignTransaction(claimTx.Transaction)
        if err != nil {
            s.logger.Error("failed to sign claim tx", "index", i+1, "error", err)
            result.TxFailed++
            result.Errors = append(result.Errors, fmt.Errorf("sign tx %d: %w", i+1, err))
            continue
        }

        // Submit
        txResult, err := s.client.SendTransaction(ctx, signedTx)
        if err != nil {
            s.logger.Error("failed to submit claim tx", "index", i+1, "error", err)
            result.TxFailed++
            result.Errors = append(result.Errors, fmt.Errorf("submit tx %d: %w", i+1, err))
            continue
        }

        result.TxSucceeded++
        result.TotalSOL += claimTx.EstimatedSOL
        result.TotalUSDC += claimTx.EstimatedUSDC
        result.Signatures = append(result.Signatures, txResult.Signature)

        s.logger.Info("claim transaction submitted",
            "index", i+1,
            "signature", txResult.Signature,
            "est_sol", claimTx.EstimatedSOL,
            "est_usdc", claimTx.EstimatedUSDC,
        )
    }

    s.lastResult = result
    s.logger.Info("claim cycle complete",
        "submitted", result.TxSubmitted,
        "succeeded", result.TxSucceeded,
        "failed", result.TxFailed,
        "total_sol", result.TotalSOL,
        "total_usdc", result.TotalUSDC,
    )
}
```

### Step 3: Wire into main.go

In `cmd/agent-bags/main.go` `run()`, after token launch:

```go
// Start fee claiming loop
logger := slog.Default()
claimSvc := fees.NewClaimService(client, signer, fees.ClaimConfig{
    Interval:  cfg.ClaimInterval,
    TokenMint: tokenMgr.MintAddress(),
}, logger)

// Run claim service in background
go func() {
    if err := claimSvc.Run(ctx); err != nil && err != context.Canceled {
        logger.Error("claim service error", "error", err)
    }
}()

<-ctx.Done()
return nil
```

### Step 4: Write tests

Create `projects/agent-bags/internal/fees/fees_test.go`:

1. `TestClaimCycleSuccess` — mock all endpoints, verify full flow: positions -> txs -> sign -> submit
2. `TestClaimCycleNoPositions` — mock empty positions, verify no claim txs fetched
3. `TestClaimCyclePartialFailure` — 3 txs, middle one fails to submit, verify other 2 succeed
4. `TestClaimCycleSignError` — signer returns error, verify tx counted as failed
5. `TestClaimServiceContextCancel` — start Run, cancel context, verify clean shutdown
6. `TestClaimCycleIncludesPartner` — verify partner claim txs are fetched and included

## Done When

- [ ] All requirements met
- [ ] Claim service runs on configurable interval (default 6h)
- [ ] Each cycle fetches positions, generates claim txs, signs, and submits
- [ ] Individual tx failures do not stop the cycle
- [ ] Partner claims are included alongside regular claims
- [ ] Structured logging covers every step with amounts and signatures
- [ ] `go test ./internal/fees/...` passes with all claim loop tests green
