---
fest_type: task
fest_id: 01_observer_cli.md
fest_name: 01_observer_cli
fest_parent: 05_submission
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-13T19:25:35.194708-06:00
fest_updated: 2026-03-15T19:52:21.822932-06:00
fest_tracking: true
---


# Task: Observer CLI

## Objective

Create a CLI tool that queries vault on-chain state and displays USDC balance, total assets (NAV), share price, held tokens, and trade history for monitoring and demo purposes.

## Dependencies

- Sequence 02 (vault client package at `internal/vault/`) must be complete.
- The vault client must expose: `NewClient`, `USDCBalance`, `TotalAssets`, `SharePrice`, `HeldTokens` methods.

## Context

- This tool is used for monitoring and during the demo recording (`01_submission_prep`).
- It reads from on-chain state only (no writes, no private keys needed).
- Environment variables: `VAULT_ADDRESS`, `RPC_URL`

## Step 1: Create the observer CLI

Create `projects/agent-defi/cmd/observer/main.go` with the following exact content:

```go
package main

import (
    "context"
    "fmt"
    "log"
    "math/big"
    "os"
    "time"

    "github.com/lancekrogers/agent-defi/internal/vault"
)

func main() {
    vaultAddr := os.Getenv("VAULT_ADDRESS")
    rpcURL := os.Getenv("RPC_URL")
    if vaultAddr == "" || rpcURL == "" {
        log.Fatal("VAULT_ADDRESS and RPC_URL required")
    }

    client := vault.NewClient(vault.Config{
        RPCURL:       rpcURL,
        VaultAddress: vaultAddr,
    })

    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    fmt.Println("=== OBEY Vault Status ===")
    fmt.Printf("Vault: %s\n\n", vaultAddr)

    balance, err := client.USDCBalance(ctx)
    if err != nil {
        fmt.Printf("USDC Balance: error (%v)\n", err)
    } else {
        fmt.Printf("USDC Balance: %s\n", formatUSDC(balance))
    }

    total, err := client.TotalAssets(ctx)
    if err != nil {
        fmt.Printf("Total Assets (NAV): error (%v)\n", err)
    } else {
        fmt.Printf("Total Assets (NAV): %s USDC\n", formatUSDC(total))
    }

    sharePrice, err := client.SharePrice(ctx)
    if err != nil {
        fmt.Printf("Share Price: error (%v)\n", err)
    } else {
        fmt.Printf("Share Price: %s\n", sharePrice.Text('f', 6))
    }

    tokens, err := client.HeldTokens(ctx)
    if err == nil && len(tokens) > 0 {
        fmt.Println("\nHeld Tokens:")
        for _, t := range tokens {
            fmt.Printf("  - %s\n", t.Hex())
        }
    }

    fmt.Println("\n(Trade history via SwapExecuted events — coming soon)")
}

func formatUSDC(wei *big.Int) string {
    if wei == nil {
        return "0"
    }
    f := new(big.Float).SetInt(wei)
    f.Quo(f, new(big.Float).SetFloat64(1e6))
    return f.Text('f', 2)
}
```

**Note**: The import path `github.com/lancekrogers/agent-defi/internal/vault` must match the module path in `projects/agent-defi/go.mod`. Adjust if the module path differs.

## Step 2: Verify it compiles

```bash
cd projects/agent-defi && go build ./cmd/observer/
```

This should produce no errors. The binary will be created in the current directory.

## Step 3: Add justfile recipe

Add the following recipe to the agent-defi justfile (either `projects/agent-defi/justfile` or the appropriate modular justfile):

```just
observer:
    go run ./cmd/observer/
```

## Step 4: Test the observer (requires a deployed vault)

```bash
cd projects/agent-defi
VAULT_ADDRESS=<deployed vault address> \
RPC_URL=https://mainnet.base.org \
just observer
```

Expected output:

```
=== OBEY Vault Status ===
Vault: 0x...

USDC Balance: 100.00
Total Assets (NAV): 100.00 USDC
Share Price: 1.000000

(Trade history via SwapExecuted events — coming soon)
```

## Verification Checklist

- [ ] `projects/agent-defi/cmd/observer/main.go` exists with the full code above
- [ ] `cd projects/agent-defi && go build ./cmd/observer/` compiles without errors
- [ ] Justfile recipe `observer` added
- [ ] Running with valid `VAULT_ADDRESS` and `RPC_URL` displays vault state

## Done When

- [ ] All verification checks pass
- [ ] `go build ./cmd/observer/` compiles successfully
- [ ] Running with VAULT_ADDRESS and RPC_URL displays vault state