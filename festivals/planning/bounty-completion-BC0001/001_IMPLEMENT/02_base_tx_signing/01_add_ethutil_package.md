---
fest_type: task
fest_id: 01_add_ethutil_package.md
fest_name: add ethutil package
fest_parent: 02_base_tx_signing
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:46.794883-07:00
fest_tracking: true
---

# Task: Add go-ethereum Dependency and Create ethutil Package

## Objective

Add the go-ethereum dependency to agent-defi and create `internal/base/ethutil/client.go` with the key management and client helper functions that all subsequent signing tasks will use.

## Requirements

- [ ] Run `go get github.com/ethereum/go-ethereum` in `projects/agent-defi`
- [ ] Create `projects/agent-defi/internal/base/ethutil/client.go` with four exported functions
- [ ] `LoadKey(hexKey string) (*ecdsa.PrivateKey, error)` — decode hex private key
- [ ] `MakeTransactOpts(ctx context.Context, key *ecdsa.PrivateKey, chainID *big.Int) (*bind.TransactOpts, error)` — build transactor with EIP-1559 defaults
- [ ] `DialClient(ctx context.Context, rpcURL string) (*ethclient.Client, error)` — dial and return ethclient
- [ ] `AddressFromKey(key *ecdsa.PrivateKey) common.Address` — derive address from key

## Implementation

Mirror the pattern from `projects/agent-inference/internal/zerog/chain.go` — read that file first to understand the existing style in this codebase.

Step 1: Add the dependency.

```bash
cd projects/agent-defi
go get github.com/ethereum/go-ethereum
go mod tidy
```

Step 2: Create the directory and file.

```bash
mkdir -p projects/agent-defi/internal/base/ethutil
```

Step 3: Write `internal/base/ethutil/client.go`:

```go
package ethutil

import (
    "context"
    "crypto/ecdsa"
    "encoding/hex"
    "fmt"
    "math/big"
    "strings"

    "github.com/ethereum/go-ethereum/accounts/abi/bind"
    "github.com/ethereum/go-ethereum/common"
    "github.com/ethereum/go-ethereum/crypto"
    "github.com/ethereum/go-ethereum/ethclient"
)

// LoadKey decodes a hex-encoded private key (with or without 0x prefix).
func LoadKey(hexKey string) (*ecdsa.PrivateKey, error) {
    hexKey = strings.TrimPrefix(hexKey, "0x")
    b, err := hex.DecodeString(hexKey)
    if err != nil {
        return nil, fmt.Errorf("decode hex key: %w", err)
    }
    key, err := crypto.ToECDSA(b)
    if err != nil {
        return nil, fmt.Errorf("parse ecdsa key: %w", err)
    }
    return key, nil
}

// MakeTransactOpts builds an EIP-1559 TransactOpts for the given key and chain.
func MakeTransactOpts(ctx context.Context, key *ecdsa.PrivateKey, chainID *big.Int) (*bind.TransactOpts, error) {
    opts, err := bind.NewKeyedTransactorWithChainID(key, chainID)
    if err != nil {
        return nil, fmt.Errorf("build transact opts: %w", err)
    }
    opts.Context = ctx
    return opts, nil
}

// DialClient dials an Ethereum-compatible JSON-RPC endpoint and returns a client.
func DialClient(ctx context.Context, rpcURL string) (*ethclient.Client, error) {
    client, err := ethclient.DialContext(ctx, rpcURL)
    if err != nil {
        return nil, fmt.Errorf("dial rpc %s: %w", rpcURL, err)
    }
    return client, nil
}

// AddressFromKey derives the Ethereum address from a private key.
func AddressFromKey(key *ecdsa.PrivateKey) common.Address {
    return crypto.PubkeyToAddress(key.PublicKey)
}
```

Step 4: Verify it compiles.

```bash
cd projects/agent-defi
just build
```

## Done When

- [ ] All requirements met
- [ ] `go.mod` in projects/agent-defi includes `github.com/ethereum/go-ethereum`
- [ ] `internal/base/ethutil/client.go` compiles without errors
- [ ] `just build` passes in projects/agent-defi
