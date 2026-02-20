---
fest_type: task
fest_id: 01_design_hts_package.md
fest_name: design_hts_package
fest_parent: 02_hts_service
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design HTS Package

**Task Number:** 01 | **Sequence:** 02_hts_service | **Autonomy:** medium

## Objective

Design the HTS (Hedera Token Service) package interfaces and token ID management strategy. This task produces the interface file that defines the contract for all token operations. The interfaces must support the agent payment flow: the coordinator creates a fungible token, then transfers it to agents as payment for completed tasks.

## Requirements

- [ ] Create the package directory `internal/hedera/hts/`
- [ ] Define the `TokenCreator` interface (token creation and configuration)
- [ ] Define the `TokenTransfer` interface (token transfers between accounts)
- [ ] Define token configuration struct with sensible defaults for the agent payment use case
- [ ] Define token transfer request/receipt structs
- [ ] Write the interface file at `internal/hedera/hts/interfaces.go`
- [ ] Write the types file at `internal/hedera/hts/types.go`

## Implementation

### Step 1: Create the package directory

Working in the agent-coordinator project (navigate with `fgo`), create the HTS package:

```
internal/
  hedera/
    hts/
      interfaces.go
      types.go
```

### Step 2: Write interfaces.go

Create `internal/hedera/hts/interfaces.go`:

```go
package hts

import (
    "context"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

// TokenCreator handles HTS token lifecycle operations.
// Used by the coordinator to create the payment token for the agent flow.
type TokenCreator interface {
    // CreateFungibleToken creates a new fungible token on Hedera and returns its ID.
    // The token is configured using the provided TokenConfig.
    CreateFungibleToken(ctx context.Context, config TokenConfig) (hedera.TokenID, error)

    // TokenInfo retrieves metadata about an existing token.
    TokenInfo(ctx context.Context, tokenID hedera.TokenID) (*TokenMetadata, error)
}

// TokenTransfer handles HTS token transfer operations between accounts.
// Used by the coordinator to pay agents for completed tasks.
type TokenTransfer interface {
    // Transfer moves tokens from one account to another.
    // Returns a receipt with the transaction details.
    Transfer(ctx context.Context, req TransferRequest) (*TransferReceipt, error)

    // AssociateToken associates a token with an account so it can receive transfers.
    // Each agent account must be associated with the payment token before receiving transfers.
    AssociateToken(ctx context.Context, tokenID hedera.TokenID, accountID hedera.AccountID) error
}
```

Design decisions:

- `TokenCreator` is separate from `TokenTransfer` (Interface Segregation Principle)
- `CreateFungibleToken` takes a `TokenConfig` struct instead of many parameters
- `Transfer` uses a `TransferRequest` struct for clarity and extensibility
- `AssociateToken` is on `TokenTransfer` because it is part of the transfer workflow (an account must be associated before it can receive tokens)

### Step 3: Write types.go

Create `internal/hedera/hts/types.go`:

```go
package hts

import (
    "github.com/hashgraph/hedera-sdk-go/v2"
)

// TokenConfig holds configuration for creating a new fungible token.
type TokenConfig struct {
    // Name is the human-readable token name (e.g., "Agent Payment Token").
    Name string

    // Symbol is the short token symbol (e.g., "APT").
    Symbol string

    // Decimals is the number of decimal places (0 for whole tokens only).
    Decimals uint32

    // InitialSupply is the number of tokens to mint at creation.
    InitialSupply uint64

    // TreasuryAccountID is the account that holds the initial supply and acts as treasury.
    TreasuryAccountID hedera.AccountID

    // AdminKey is the key that can modify the token. If nil, the token is immutable.
    AdminKey *hedera.PublicKey

    // SupplyKey is the key that can mint/burn tokens. If nil, supply is fixed.
    SupplyKey *hedera.PublicKey
}

// DefaultTokenConfig returns sensible defaults for the agent payment use case.
// The caller must still set TreasuryAccountID.
func DefaultTokenConfig() TokenConfig {
    return TokenConfig{
        Name:          "Agent Payment Token",
        Symbol:        "APT",
        Decimals:      0,
        InitialSupply: 1000000,
    }
}

// TokenMetadata holds information about an existing HTS token.
type TokenMetadata struct {
    TokenID       hedera.TokenID
    Name          string
    Symbol        string
    Decimals      uint32
    TotalSupply   uint64
    TreasuryID    hedera.AccountID
}

// TransferRequest specifies a token transfer between two accounts.
type TransferRequest struct {
    // TokenID is the token to transfer.
    TokenID hedera.TokenID

    // FromAccountID is the sender account.
    FromAccountID hedera.AccountID

    // ToAccountID is the recipient account.
    ToAccountID hedera.AccountID

    // Amount is the number of tokens to transfer (in the token's smallest unit).
    Amount int64

    // Memo is an optional memo attached to the transfer transaction.
    Memo string
}

// TransferReceipt holds the result of a completed token transfer.
type TransferReceipt struct {
    // TransactionID is the Hedera transaction ID for this transfer.
    TransactionID hedera.TransactionID

    // TokenID is the token that was transferred.
    TokenID hedera.TokenID

    // FromAccountID is the sender.
    FromAccountID hedera.AccountID

    // ToAccountID is the recipient.
    ToAccountID hedera.AccountID

    // Amount is the number of tokens transferred.
    Amount int64

    // Status is the transaction status from the receipt.
    Status string
}
```

Design decisions:

- `TokenConfig` uses a struct with exported fields for clarity (no builder pattern -- KISS)
- `DefaultTokenConfig` provides sensible defaults but requires the caller to set `TreasuryAccountID`
- `TransferRequest` bundles all transfer parameters (avoids long parameter lists)
- `TransferReceipt` captures enough detail for audit logging and payment tracking
- `Amount` is `int64` (not `uint64`) because the Hedera SDK uses signed integers for transfer amounts (negative = debit, positive = credit)

### Step 4: Verify compilation

```bash
go build ./internal/hedera/hts/...
go vet ./internal/hedera/hts/...
```

## Done When

- [ ] `internal/hedera/hts/interfaces.go` exists with TokenCreator and TokenTransfer interfaces
- [ ] `internal/hedera/hts/types.go` exists with TokenConfig, TokenMetadata, TransferRequest, TransferReceipt
- [ ] Interfaces have 2-3 methods each (small and focused)
- [ ] All method signatures include `context.Context` as first parameter
- [ ] `DefaultTokenConfig()` returns usable defaults for the agent payment flow
- [ ] `go build ./internal/hedera/hts/...` passes with no errors
- [ ] `go vet ./internal/hedera/hts/...` passes with no warnings
