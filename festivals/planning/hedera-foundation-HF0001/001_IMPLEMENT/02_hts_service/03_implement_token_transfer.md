---
fest_type: task
fest_id: 03_implement_token_transfer.md
fest_name: implement_token_transfer
fest_parent: 02_hts_service
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Token Transfer

**Task Number:** 03 | **Sequence:** 02_hts_service | **Autonomy:** medium

## Objective

Implement the `TokenTransfer` interface from `internal/hedera/hts/interfaces.go`. This implementation handles token transfers between agent accounts and token association. The coordinator calls `Transfer` after an agent completes a task and passes quality gates, settling the payment in the festival token.

## Requirements

- [ ] Create `internal/hedera/hts/transfer.go` implementing the `TokenTransfer` interface
- [ ] Implement `Transfer` using `hedera.TransferTransaction` with token transfer
- [ ] Implement `AssociateToken` using `hedera.TokenAssociateTransaction`
- [ ] Support multi-agent accounts (transfers between any two Hedera accounts)
- [ ] All methods propagate `context.Context` and check `ctx.Err()` before starting
- [ ] All errors wrapped with operational context (token ID, from/to account IDs, amount)
- [ ] Constructor accepts `*hedera.Client` via dependency injection
- [ ] Create `internal/hedera/hts/transfer_test.go` with table-driven tests

## Implementation

### Step 1: Create transfer.go

Create `internal/hedera/hts/transfer.go`:

```go
package hts

import (
    "context"
    "fmt"

    "github.com/hashgraph/hedera-sdk-go/v2"
)

// TransferService implements the TokenTransfer interface using the Hedera Go SDK.
type TransferService struct {
    client *hedera.Client
}

// NewTransferService creates a new TransferService with the given Hedera client.
func NewTransferService(client *hedera.Client) *TransferService {
    return &TransferService{client: client}
}

// Compile-time interface assertion.
var _ TokenTransfer = (*TransferService)(nil)
```

### Step 2: Implement Transfer

The `Transfer` method moves tokens from one account to another. In the Hedera model, a transfer is expressed as a debit from the sender and a credit to the recipient in a single atomic transaction.

```go
func (s *TransferService) Transfer(ctx context.Context, req TransferRequest) (*TransferReceipt, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("transfer token %s from %s to %s: context cancelled before start: %w",
            req.TokenID, req.FromAccountID, req.ToAccountID, err)
    }

    if req.Amount <= 0 {
        return nil, fmt.Errorf("transfer token %s: amount must be positive, got %d", req.TokenID, req.Amount)
    }

    tx := hedera.NewTransferTransaction().
        AddTokenTransfer(req.TokenID, req.FromAccountID, -req.Amount).
        AddTokenTransfer(req.TokenID, req.ToAccountID, req.Amount)

    if req.Memo != "" {
        tx = tx.SetTransactionMemo(req.Memo)
    }

    frozen, err := tx.FreezeWith(s.client)
    if err != nil {
        return nil, fmt.Errorf("transfer %d of token %s from %s to %s: freeze: %w",
            req.Amount, req.TokenID, req.FromAccountID, req.ToAccountID, err)
    }

    resp, err := frozen.Execute(s.client)
    if err != nil {
        return nil, fmt.Errorf("transfer %d of token %s from %s to %s: execute: %w",
            req.Amount, req.TokenID, req.FromAccountID, req.ToAccountID, err)
    }

    receipt, err := resp.GetReceipt(s.client)
    if err != nil {
        return nil, fmt.Errorf("transfer %d of token %s from %s to %s: get receipt: %w",
            req.Amount, req.TokenID, req.FromAccountID, req.ToAccountID, err)
    }

    return &TransferReceipt{
        TransactionID: resp.TransactionID,
        TokenID:       req.TokenID,
        FromAccountID: req.FromAccountID,
        ToAccountID:   req.ToAccountID,
        Amount:        req.Amount,
        Status:        receipt.Status.String(),
    }, nil
}
```

Key implementation notes:
- `AddTokenTransfer` is called twice: once with negative amount (debit sender) and once with positive amount (credit recipient)
- The transaction is atomic -- either both sides succeed or neither does
- Amount validation happens before any network call
- Error messages include all four key identifiers: token ID, from, to, and amount

### Step 3: Implement AssociateToken

Before an agent account can receive tokens, the token must be associated with that account:

```go
func (s *TransferService) AssociateToken(ctx context.Context, tokenID hedera.TokenID, accountID hedera.AccountID) error {
    if err := ctx.Err(); err != nil {
        return fmt.Errorf("associate token %s with account %s: context cancelled before start: %w",
            tokenID, accountID, err)
    }

    tx, err := hedera.NewTokenAssociateTransaction().
        SetAccountID(accountID).
        SetTokenIDs(tokenID).
        FreezeWith(s.client)
    if err != nil {
        return fmt.Errorf("associate token %s with account %s: freeze: %w", tokenID, accountID, err)
    }

    resp, err := tx.Execute(s.client)
    if err != nil {
        return fmt.Errorf("associate token %s with account %s: execute: %w", tokenID, accountID, err)
    }

    _, err = resp.GetReceipt(s.client)
    if err != nil {
        return fmt.Errorf("associate token %s with account %s: get receipt: %w", tokenID, accountID, err)
    }

    return nil
}
```

**Important note for the implementer:** Token association requires the account's private key to sign the transaction. In a multi-agent setup, the coordinator needs access to each agent's key for association, OR each agent must self-associate. The design should document which approach is used. For the hackathon demo, the coordinator holding all keys is acceptable.

### Step 4: Create transfer_test.go

Create `internal/hedera/hts/transfer_test.go`:

```go
package hts_test

import (
    "context"
    "testing"

    "your-module/internal/hedera/hts"
    "github.com/hashgraph/hedera-sdk-go/v2"
)

func TestTransfer_ContextCancellation(t *testing.T) {
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

    svc := hts.NewTransferService(nil)

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            req := hts.TransferRequest{
                TokenID:       hedera.TokenID{Token: 1},
                FromAccountID: hedera.AccountID{Account: 100},
                ToAccountID:   hedera.AccountID{Account: 200},
                Amount:        10,
            }
            _, err := svc.Transfer(tt.ctx, req)
            if (err != nil) != tt.wantErr {
                t.Errorf("Transfer() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}

func TestTransfer_InvalidAmount(t *testing.T) {
    tests := []struct {
        name    string
        amount  int64
        wantErr bool
    }{
        {
            name:    "zero amount returns error",
            amount:  0,
            wantErr: true,
        },
        {
            name:    "negative amount returns error",
            amount:  -10,
            wantErr: true,
        },
        {
            name:    "positive amount is valid (will fail on nil client but passes validation)",
            amount:  10,
            wantErr: true, // fails on nil client, but passes amount validation
        },
    }

    svc := hts.NewTransferService(nil)

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            req := hts.TransferRequest{
                TokenID:       hedera.TokenID{Token: 1},
                FromAccountID: hedera.AccountID{Account: 100},
                ToAccountID:   hedera.AccountID{Account: 200},
                Amount:        tt.amount,
            }
            _, err := svc.Transfer(context.Background(), req)
            if (err != nil) != tt.wantErr {
                t.Errorf("Transfer() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}

func TestAssociateToken_ContextCancellation(t *testing.T) {
    svc := hts.NewTransferService(nil)
    ctx, cancel := context.WithCancel(context.Background())
    cancel()

    err := svc.AssociateToken(ctx, hedera.TokenID{}, hedera.AccountID{})
    if err == nil {
        t.Error("expected error for cancelled context")
    }
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

- [ ] `internal/hedera/hts/transfer.go` exists and compiles
- [ ] `TransferService` implements the `TokenTransfer` interface (verified by compile-time assertion)
- [ ] `Transfer` handles debit/credit atomically using `AddTokenTransfer`
- [ ] `Transfer` validates amount is positive before making network calls
- [ ] `AssociateToken` associates a token with an account
- [ ] Both methods check `ctx.Err()` before proceeding
- [ ] All errors include token ID, account IDs, and amount where applicable
- [ ] `transfer_test.go` has table-driven tests for context cancellation and amount validation
- [ ] `go test ./internal/hedera/hts/...` passes
- [ ] File is under 500 lines, all functions under 50 lines
