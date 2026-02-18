---
fest_type: task
fest_id: 02_implement_token_create.md
fest_name: implement_token_create
fest_parent: 02_hts_service
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Token Creation

**Task Number:** 02 | **Sequence:** 02_hts_service | **Autonomy:** medium

## Objective

Implement the `TokenCreator` interface from `internal/hedera/hts/interfaces.go`. This implementation wraps the Hedera Go SDK's token service to create fungible tokens and query token metadata on testnet. The coordinator uses this to create the payment token at the start of a festival run.

## Requirements

- [ ] Create `internal/hedera/hts/token.go` implementing the `TokenCreator` interface
- [ ] Implement `CreateFungibleToken` using `hedera.TokenCreateTransaction`
- [ ] Implement `TokenInfo` using `hedera.TokenInfoQuery`
- [ ] All methods propagate `context.Context` and check `ctx.Err()` before starting
- [ ] All errors wrapped with operational context (token name, account IDs)
- [ ] Constructor accepts `*hedera.Client` via dependency injection
- [ ] Create `internal/hedera/hts/token_test.go` with table-driven tests

## Implementation

### Step 1: Create token.go

Create `internal/hedera/hts/token.go`:

```go
package hts

import (
    "context"
    "fmt"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

// TokenService implements the TokenCreator interface using the Hedera Go SDK.
type TokenService struct {
    client *hedera.Client
}

// NewTokenService creates a new TokenService with the given Hedera client.
func NewTokenService(client *hedera.Client) *TokenService {
    return &TokenService{client: client}
}

// Compile-time interface assertion.
var _ TokenCreator = (*TokenService)(nil)
```

### Step 2: Implement CreateFungibleToken

```go
func (s *TokenService) CreateFungibleToken(ctx context.Context, config TokenConfig) (hedera.TokenID, error) {
    if err := ctx.Err(); err != nil {
        return hedera.TokenID{}, fmt.Errorf("create token %q: context cancelled before start: %w", config.Name, err)
    }

    tx := hedera.NewTokenCreateTransaction().
        SetTokenName(config.Name).
        SetTokenSymbol(config.Symbol).
        SetDecimals(uint(config.Decimals)).
        SetInitialSupply(config.InitialSupply).
        SetTreasuryAccountID(config.TreasuryAccountID).
        SetTokenType(hedera.TokenTypeFungibleCommon)

    if config.AdminKey != nil {
        tx = tx.SetAdminKey(*config.AdminKey)
    }

    if config.SupplyKey != nil {
        tx = tx.SetSupplyKey(*config.SupplyKey)
    }

    frozen, err := tx.FreezeWith(s.client)
    if err != nil {
        return hedera.TokenID{}, fmt.Errorf("create token %q: freeze transaction: %w", config.Name, err)
    }

    resp, err := frozen.Execute(s.client)
    if err != nil {
        return hedera.TokenID{}, fmt.Errorf("create token %q: execute: %w", config.Name, err)
    }

    receipt, err := resp.GetReceipt(s.client)
    if err != nil {
        return hedera.TokenID{}, fmt.Errorf("create token %q: get receipt: %w", config.Name, err)
    }

    if receipt.TokenID == nil {
        return hedera.TokenID{}, fmt.Errorf("create token %q: receipt contained nil token ID", config.Name)
    }

    return *receipt.TokenID, nil
}
```

Key implementation notes:
- `SetTokenType(hedera.TokenTypeFungibleCommon)` explicitly marks this as a fungible token
- AdminKey and SupplyKey are optional (nil means immutable/fixed supply respectively)
- The `Decimals` field type may need adjustment based on the exact Hedera SDK version -- check the SDK docs for `SetDecimals` parameter type

### Step 3: Implement TokenInfo

```go
func (s *TokenService) TokenInfo(ctx context.Context, tokenID hedera.TokenID) (*TokenMetadata, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("token info %s: context cancelled before start: %w", tokenID, err)
    }

    info, err := hedera.NewTokenInfoQuery().
        SetTokenID(tokenID).
        Execute(s.client)
    if err != nil {
        return nil, fmt.Errorf("token info %s: execute query: %w", tokenID, err)
    }

    return &TokenMetadata{
        TokenID:     tokenID,
        Name:        info.Name,
        Symbol:      info.Symbol,
        Decimals:    uint32(info.Decimals),
        TotalSupply: info.TotalSupply,
        TreasuryID:  info.Treasury,
    }, nil
}
```

### Step 4: Create token_test.go

Create `internal/hedera/hts/token_test.go`:

```go
package hts_test

import (
    "context"
    "testing"

    "your-module/internal/hedera/hts"
)

func TestNewTokenService(t *testing.T) {
    svc := hts.NewTokenService(nil)
    if svc == nil {
        t.Fatal("expected non-nil service even with nil client")
    }
}

func TestCreateFungibleToken_ContextCancellation(t *testing.T) {
    tests := []struct {
        name    string
        ctx     context.Context
        wantErr bool
    }{
        {
            name:    "cancelled context returns error",
            ctx:     cancelledContext(),
            wantErr: true,
        },
        {
            name:    "deadline exceeded returns error",
            ctx:     expiredContext(),
            wantErr: true,
        },
    }

    svc := hts.NewTokenService(nil)

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            _, err := svc.CreateFungibleToken(tt.ctx, hts.DefaultTokenConfig())
            if (err != nil) != tt.wantErr {
                t.Errorf("CreateFungibleToken() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}

func TestTokenInfo_ContextCancellation(t *testing.T) {
    svc := hts.NewTokenService(nil)
    ctx, cancel := context.WithCancel(context.Background())
    cancel()

    _, err := svc.TokenInfo(ctx, hedera.TokenID{})
    if err == nil {
        t.Error("expected error for cancelled context")
    }
}

func TestDefaultTokenConfig(t *testing.T) {
    cfg := hts.DefaultTokenConfig()

    tests := []struct {
        name string
        got  interface{}
        want interface{}
    }{
        {"Name", cfg.Name, "Agent Payment Token"},
        {"Symbol", cfg.Symbol, "APT"},
        {"Decimals", cfg.Decimals, uint32(0)},
        {"InitialSupply", cfg.InitialSupply, uint64(1000000)},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            if tt.got != tt.want {
                t.Errorf("%s = %v, want %v", tt.name, tt.got, tt.want)
            }
        })
    }
}

func cancelledContext() context.Context {
    ctx, cancel := context.WithCancel(context.Background())
    cancel()
    return ctx
}

func expiredContext() context.Context {
    ctx, cancel := context.WithTimeout(context.Background(), 0)
    defer cancel()
    return ctx
}
```

Replace `your-module` with the actual module path from go.mod.

### Step 5: Verify

```bash
go build ./internal/hedera/hts/...
go vet ./internal/hedera/hts/...
go test ./internal/hedera/hts/... -v -count=1
```

## Done When

- [ ] `internal/hedera/hts/token.go` exists and compiles
- [ ] `TokenService` implements the `TokenCreator` interface (verified by compile-time assertion)
- [ ] `CreateFungibleToken` creates a fungible token with all config fields applied
- [ ] `TokenInfo` queries and returns token metadata
- [ ] Both methods check `ctx.Err()` before proceeding
- [ ] All errors include token name and/or token ID in the error message
- [ ] `token_test.go` has table-driven tests for context cancellation and config defaults
- [ ] `go test ./internal/hedera/hts/...` passes
- [ ] File is under 500 lines, all functions under 50 lines
