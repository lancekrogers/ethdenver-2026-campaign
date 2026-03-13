---
fest_type: task
fest_id: 03_launch_meteora.md
fest_name: launch_meteora
fest_parent: 02_token_launch
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.493156-06:00
fest_tracking: true
---

# Task: Launch OBEY Token on Meteora DBC

## Objective

Implement the Meteora Dynamic Bonding Curve (DBC) launch workflow that generates the launch transaction via Bags API, signs it with the agent's Solana keypair, and submits it to launch the OBEY token for trading.

## Requirements

- [ ] `LaunchToken` method on `Manager` that orchestrates: get launch tx -> sign -> submit -> verify
- [ ] Call `POST /tokens/launch` to get the pre-signed Meteora DBC transaction
- [ ] Sign the transaction using the `Signer` from the auth client task
- [ ] Submit signed transaction via `POST /transactions/send`
- [ ] Poll `GET /pools/:mint` after submission to verify the pool is live
- [ ] Retry submission up to 3 times if the transaction fails (network errors, not validation errors)
- [ ] Idempotency: if pool already exists for the mint, skip launch

## Implementation

### Step 1: Implement LaunchOnMeteora on Manager

Add to `projects/agent-bags/internal/token/token.go`:

```go
// LaunchOnMeteora launches the OBEY token on Meteora DBC via Bags.
// This creates the bonding curve pool that enables trading.
// Must be called after CreateToken and ConfigureFeeShare.
func (m *Manager) LaunchOnMeteora(ctx context.Context) error {
    if err := ctx.Err(); err != nil {
        return err
    }
    if m.mintAddr == "" {
        return fmt.Errorf("mint address not set: call CreateToken first")
    }

    // Idempotency: check if pool already exists
    pool, err := m.client.GetPoolByMint(ctx, m.mintAddr)
    if err == nil && pool != nil && pool.PoolKey != "" {
        // Pool already live, nothing to do
        return nil
    }

    // Step 1: Get pre-signed launch transaction from Bags
    launchResp, err := m.client.LaunchToken(ctx, m.mintAddr)
    if err != nil {
        return fmt.Errorf("getting launch transaction: %w", err)
    }

    // Step 2: Sign the transaction
    signedTx, err := m.signer.SignTransaction(launchResp.Transaction)
    if err != nil {
        return fmt.Errorf("signing launch transaction: %w", err)
    }

    // Step 3: Submit with retry
    var submitErr error
    for attempt := 0; attempt < 3; attempt++ {
        if attempt > 0 {
            backoff := time.Duration(1<<uint(attempt-1)) * time.Second
            select {
            case <-ctx.Done():
                return ctx.Err()
            case <-time.After(backoff):
            }
        }

        result, err := m.client.SendTransaction(ctx, signedTx)
        if err != nil {
            submitErr = err
            // Don't retry on 4xx (validation errors like bad signature)
            if apiErr, ok := err.(*bags.APIError); ok && apiErr.StatusCode < 500 {
                return fmt.Errorf("submitting launch tx (non-retryable): %w", err)
            }
            continue
        }

        // Step 4: Verify pool creation by polling
        if err := m.waitForPool(ctx, result.Signature); err != nil {
            return fmt.Errorf("waiting for pool creation: %w", err)
        }
        return nil
    }
    return fmt.Errorf("submitting launch transaction after 3 attempts: %w", submitErr)
}

// waitForPool polls GetPoolByMint until the pool appears or timeout.
func (m *Manager) waitForPool(ctx context.Context, txSig string) error {
    timeout := time.After(60 * time.Second)
    ticker := time.NewTicker(3 * time.Second)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        case <-timeout:
            return fmt.Errorf("timeout waiting for pool after tx %s", txSig)
        case <-ticker.C:
            pool, err := m.client.GetPoolByMint(ctx, m.mintAddr)
            if err != nil {
                continue // pool not visible yet, keep polling
            }
            if pool != nil && pool.PoolKey != "" {
                return nil // pool is live
            }
        }
    }
}
```

### Step 2: Wire into startup sequence

In `cmd/agent-bags/main.go` `run()`, after fee share configuration:

```go
// Launch on Meteora DBC
if err := tokenMgr.LaunchOnMeteora(ctx); err != nil {
    return fmt.Errorf("launching OBEY on Meteora: %w", err)
}
fmt.Println("OBEY token launched on Meteora DBC")

// Verify pool state
pool, err := client.GetPoolByMint(ctx, tokenMgr.MintAddress())
if err != nil {
    return fmt.Errorf("verifying pool: %w", err)
}
fmt.Printf("Pool live: key=%s type=%s liquidity=%.2f\n", pool.PoolKey, pool.PoolType, pool.Liquidity)
```

### Step 3: Write tests

In `projects/agent-bags/internal/token/token_test.go`:

1. `TestLaunchOnMeteoraSuccess` — mock launch tx endpoint, mock send tx, mock pool appears on 2nd poll
2. `TestLaunchOnMeteoraIdempotent` — mock GetPoolByMint returns existing pool, verify no launch tx requested
3. `TestLaunchOnMeteoraRetry` — first SendTransaction returns 500, second succeeds
4. `TestLaunchOnMeteoraNoMint` — error when mint not set
5. `TestLaunchOnMeteoraTimeout` — pool never appears, verify timeout error after 60s (use short timeout in test)
6. `TestLaunchOnMeteoraNonRetryable` — 400 on send, verify no retry

## Done When

- [ ] All requirements met
- [ ] Full launch flow: get tx -> sign -> submit -> poll for pool -> confirm live
- [ ] Idempotency: existing pool detected via GetPoolByMint, launch skipped
- [ ] Retry logic handles transient network errors
- [ ] Pool verification polls every 3s up to 60s timeout
- [ ] `go test ./internal/token/...` passes with all launch tests green
