---
fest_type: task
fest_id: 01_vault_client.md
fest_name: 01_vault_client
fest_parent: 02_agent_runtime
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:24:37.731196-06:00
fest_tracking: true
---

# Task: Vault Client Go Bindings

## Objective

Generate Go bindings from ObeyVault ABI via abigen and implement a VaultClient interface for reading vault state and submitting swaps.

## Requirements

- [ ] Generate ABI bindings: extract ABI from Foundry output, run abigen to create `internal/vault/bindings.go`
- [ ] Create `internal/vault/client.go` with Client interface (USDCBalance, TotalAssets, SharePrice, ExecuteSwap, HeldTokens)
- [ ] Define SwapParams and Config structs
- [ ] Implement ExecuteSwap using abigen-generated transactor
- [ ] Create `internal/vault/client_test.go` with context cancellation tests
- [ ] All functions check ctx.Err() before starting I/O

## Dependencies

- **Sequence 01 (vault contract)** must be complete — needs the compiled ABI from Foundry output for abigen.
- Reuses existing `internal/base/ethutil/` package for `LoadKey`, `DialClient`, `MakeTransactOpts`.

## Implementation Steps

### Step 1: Generate ABI Bindings

Generate Go bindings from the compiled Solidity contract using `abigen`.

```bash
cd projects/contracts
forge build
jq '.abi' out/ObeyVault.sol/ObeyVault.json > /tmp/ObeyVault.abi
abigen --abi /tmp/ObeyVault.abi --pkg vault --type ObeyVault --out ../agent-defi/internal/vault/bindings.go
```

If `abigen` is not installed:

```bash
go install github.com/ethereum/go-ethereum/cmd/abigen@latest
```

**Verification:** Confirm `projects/agent-defi/internal/vault/bindings.go` exists and contains the `NewObeyVault` constructor and `ExecuteSwap` method.

### Step 2: Create `projects/agent-defi/internal/vault/client.go`

Create the directory if needed: `mkdir -p projects/agent-defi/internal/vault`

Write the following file exactly:

```go
package vault

import (
	"context"
	"fmt"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/lancekrogers/agent-defi/internal/base/ethutil"
)

// Client reads vault state and submits swaps via executeSwap.
type Client interface {
	USDCBalance(ctx context.Context) (*big.Int, error)
	TotalAssets(ctx context.Context) (*big.Int, error)
	SharePrice(ctx context.Context) (*big.Float, error)
	ExecuteSwap(ctx context.Context, params SwapParams) (common.Hash, error)
	HeldTokens(ctx context.Context) ([]common.Address, error)
}

type SwapParams struct {
	TokenIn      common.Address
	TokenOut     common.Address
	AmountIn     *big.Int
	MinAmountOut *big.Int
	Reason       []byte
}

type Config struct {
	RPCURL       string
	ChainID      int64
	VaultAddress string
	PrivateKey   string
}

type client struct {
	cfg Config
}

func NewClient(cfg Config) Client {
	return &client{cfg: cfg}
}

func (c *client) USDCBalance(ctx context.Context) (*big.Int, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("vault: context cancelled: %w", err)
	}
	return big.NewInt(0), nil // placeholder — calls asset().balanceOf(vault) via eth_call
}

func (c *client) TotalAssets(ctx context.Context) (*big.Int, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("vault: context cancelled: %w", err)
	}
	return big.NewInt(0), nil // placeholder — calls vault.totalAssets() via eth_call
}

func (c *client) SharePrice(ctx context.Context) (*big.Float, error) {
	return new(big.Float), nil // placeholder — totalAssets / totalSupply
}

func (c *client) ExecuteSwap(ctx context.Context, params SwapParams) (common.Hash, error) {
	if err := ctx.Err(); err != nil {
		return common.Hash{}, fmt.Errorf("vault: context cancelled: %w", err)
	}

	key, err := ethutil.LoadKey(c.cfg.PrivateKey)
	if err != nil {
		return common.Hash{}, fmt.Errorf("vault: load key: %w", err)
	}

	ethClient, err := ethutil.DialClient(ctx, c.cfg.RPCURL)
	if err != nil {
		return common.Hash{}, fmt.Errorf("vault: dial: %w", err)
	}
	defer ethClient.Close()

	vaultAddr := common.HexToAddress(c.cfg.VaultAddress)
	bound, err := NewObeyVault(vaultAddr, ethClient)
	if err != nil {
		return common.Hash{}, fmt.Errorf("vault: bind contract: %w", err)
	}

	opts, err := ethutil.MakeTransactOpts(ctx, key, c.cfg.ChainID)
	if err != nil {
		return common.Hash{}, fmt.Errorf("vault: make tx opts: %w", err)
	}

	tx, err := bound.ExecuteSwap(opts, params.TokenIn, params.TokenOut, params.AmountIn, params.MinAmountOut, params.Reason)
	if err != nil {
		return common.Hash{}, fmt.Errorf("vault: executeSwap failed: %w", err)
	}

	return tx.Hash(), nil
}

func (c *client) HeldTokens(ctx context.Context) ([]common.Address, error) {
	return nil, nil // placeholder — calls heldTokenCount + heldTokenAt via abigen
}
```

**Notes:**
- `NewObeyVault` comes from the generated `bindings.go` file (Step 1).
- `ethutil.LoadKey`, `ethutil.DialClient`, `ethutil.MakeTransactOpts` are in `internal/base/ethutil/client.go`.
- Placeholder methods (`USDCBalance`, `TotalAssets`, `SharePrice`, `HeldTokens`) return zero values. They will be filled in once the contract ABI shape is confirmed. The important thing is the interface and `ExecuteSwap` are correct now.

### Step 3: Create `projects/agent-defi/internal/vault/client_test.go`

Write the following file exactly:

```go
package vault

import (
	"context"
	"testing"
)

func TestClientContextCancellation(t *testing.T) {
	c := NewClient(Config{})
	ctx, cancel := context.WithCancel(context.Background())
	cancel()

	_, err := c.USDCBalance(ctx)
	if err == nil {
		t.Fatal("expected error on cancelled context")
	}

	_, err = c.ExecuteSwap(ctx, SwapParams{})
	if err == nil {
		t.Fatal("expected error on cancelled context")
	}
}
```

### Step 4: Run Tests

```bash
cd projects/agent-defi && go test ./internal/vault/... -v
```

**Expected output:** `PASS` — both context cancellation assertions should succeed.

## Done When

- [ ] All requirements met
- [ ] `cd projects/agent-defi && go test ./internal/vault/... -v` passes
