---
fest_type: task
fest_id: 02_create_0g_inft_template.md
fest_name: create 0g inft template
fest_parent: 04_0g_templates
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:54.687714-07:00
fest_tracking: true
---

# Task: Create 0g-inft-build Camp Template

## Objective

Create the `0g-inft-build` Go project scaffold template at `projects/hiero-plugin/templates/0g-inft-build/` that gives developers a starting point for minting ERC-7857 intelligent NFTs on 0G with AES-256-GCM encrypted model weights stored on 0G DA, based on the patterns in `projects/agent-inference/`.

## Requirements

- [ ] Template directory `projects/hiero-plugin/templates/0g-inft-build/` exists with a complete Go module scaffold
- [ ] `internal/inft/minter.go` loads the ERC-7857 ABI and provides a `Mint(ctx, tokenURI, encryptedModelCID)` method
- [ ] `internal/inft/abi.go` (or embedded ABI JSON file) contains the minimal ERC-7857 ABI for `mint` and `tokenURI`
- [ ] `internal/crypto/encrypt.go` provides `Encrypt(key, plaintext) (ciphertext, nonce, error)` and `Decrypt(key, ciphertext, nonce) ([]byte, error)` using AES-256-GCM
- [ ] `internal/da/publisher.go` provides a `Publisher` stub with `Publish(ctx, data) (cid, error)` that sends data to the 0G DA layer
- [ ] `internal/config/config.go` loads `ZG_RPC_URL`, `ZG_PRIVATE_KEY`, `ZG_CONTRACT_ADDRESS`, `ZG_DA_ENDPOINT`, `ZG_ENCRYPT_KEY` with validation
- [ ] `cmd/mint/main.go` orchestrates: load config, encrypt model weights, publish to DA, mint iNFT with the DA CID as tokenURI
- [ ] `go.mod` declares module `0g-inft-build` and pins `go-ethereum`
- [ ] `Justfile` has `build`, `run`, `test`, `lint`, and `clean` recipes

## Implementation

### Step 1: Examine the reference implementation

Read `projects/agent-inference/internal/inft/` and `projects/agent-inference/internal/da/` (if they exist) for the ABI loading pattern, encrypt/decrypt pattern, and DA publisher pattern before creating files.

### Step 2: Create the directory tree

```
projects/hiero-plugin/templates/0g-inft-build/
  cmd/
    mint/
      main.go
  internal/
    config/
      config.go
    crypto/
      encrypt.go
    da/
      publisher.go
    inft/
      abi.go
      minter.go
  go.mod
  Justfile
  .env.example
```

### Step 3: Write `go.mod`

```go
module 0g-inft-build

go 1.22

require (
    github.com/ethereum/go-ethereum v1.13.14
)
```

### Step 4: Write `internal/config/config.go`

```go
package config

import (
    "fmt"
    "os"
)

type Config struct {
    RPCUrl          string
    PrivateKey      string
    ContractAddress string
    DAEndpoint      string
    EncryptKey      string // 32-byte hex key for AES-256-GCM
}

func Load() (*Config, error) {
    cfg := &Config{
        RPCUrl:          os.Getenv("ZG_RPC_URL"),
        PrivateKey:      os.Getenv("ZG_PRIVATE_KEY"),
        ContractAddress: os.Getenv("ZG_CONTRACT_ADDRESS"),
        DAEndpoint:      os.Getenv("ZG_DA_ENDPOINT"),
        EncryptKey:      os.Getenv("ZG_ENCRYPT_KEY"),
    }
    if cfg.RPCUrl == "" {
        return nil, fmt.Errorf("ZG_RPC_URL is required")
    }
    if cfg.PrivateKey == "" {
        return nil, fmt.Errorf("ZG_PRIVATE_KEY is required")
    }
    if cfg.ContractAddress == "" {
        return nil, fmt.Errorf("ZG_CONTRACT_ADDRESS is required")
    }
    if len(cfg.EncryptKey) != 64 {
        return nil, fmt.Errorf("ZG_ENCRYPT_KEY must be a 64-character hex string (32 bytes)")
    }
    return cfg, nil
}
```

### Step 5: Write `internal/crypto/encrypt.go`

```go
package crypto

import (
    "crypto/aes"
    "crypto/cipher"
    "crypto/rand"
    "fmt"
    "io"
)

// Encrypt encrypts plaintext with AES-256-GCM using the provided 32-byte key.
// Returns ciphertext and nonce separately so both can be stored.
func Encrypt(key, plaintext []byte) (ciphertext, nonce []byte, err error) {
    block, err := aes.NewCipher(key)
    if err != nil {
        return nil, nil, fmt.Errorf("new aes cipher: %w", err)
    }
    gcm, err := cipher.NewGCM(block)
    if err != nil {
        return nil, nil, fmt.Errorf("new gcm: %w", err)
    }
    nonce = make([]byte, gcm.NonceSize())
    if _, err = io.ReadFull(rand.Reader, nonce); err != nil {
        return nil, nil, fmt.Errorf("generate nonce: %w", err)
    }
    ciphertext = gcm.Seal(nil, nonce, plaintext, nil)
    return ciphertext, nonce, nil
}

// Decrypt decrypts ciphertext with AES-256-GCM using the provided key and nonce.
func Decrypt(key, ciphertext, nonce []byte) ([]byte, error) {
    block, err := aes.NewCipher(key)
    if err != nil {
        return nil, fmt.Errorf("new aes cipher: %w", err)
    }
    gcm, err := cipher.NewGCM(block)
    if err != nil {
        return nil, fmt.Errorf("new gcm: %w", err)
    }
    plaintext, err := gcm.Open(nil, nonce, ciphertext, nil)
    if err != nil {
        return nil, fmt.Errorf("gcm open: %w", err)
    }
    return plaintext, nil
}
```

### Step 6: Write `internal/da/publisher.go`

```go
package da

import (
    "context"
    "fmt"
)

// Publisher submits data blobs to the 0G DA layer.
// Replace the stub body with the actual 0G DA SDK call.
type Publisher struct {
    endpoint string
}

func NewPublisher(endpoint string) *Publisher {
    return &Publisher{endpoint: endpoint}
}

// Publish sends data to the 0G DA layer and returns a content ID.
func (p *Publisher) Publish(ctx context.Context, data []byte) (string, error) {
    if err := ctx.Err(); err != nil {
        return "", err
    }
    // TODO: replace with actual 0G DA client call
    // e.g. daClient.Submit(ctx, &da.BlobRequest{Data: data})
    return fmt.Sprintf("da-cid-%x", data[:4]), nil
}
```

### Step 7: Write `internal/inft/abi.go`

```go
package inft

// ERC7857ABI is the minimal ABI for the ERC-7857 iNFT contract.
// Replace with the full ABI from your deployed contract.
const ERC7857ABI = `[
  {
    "inputs": [
      {"internalType": "address", "name": "to", "type": "address"},
      {"internalType": "string",  "name": "tokenURI", "type": "string"}
    ],
    "name": "mint",
    "outputs": [{"internalType": "uint256", "name": "tokenId", "type": "uint256"}],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "uint256", "name": "tokenId", "type": "uint256"}],
    "name": "tokenURI",
    "outputs": [{"internalType": "string", "name": "", "type": "string"}],
    "stateMutability": "view",
    "type": "function"
  }
]`
```

### Step 8: Write `internal/inft/minter.go`

```go
package inft

import (
    "context"
    "fmt"
    "math/big"

    "github.com/ethereum/go-ethereum/accounts/abi"
    "github.com/ethereum/go-ethereum/accounts/abi/bind"
    "github.com/ethereum/go-ethereum/common"
    "github.com/ethereum/go-ethereum/ethclient"
    "strings"
)

// Minter mints ERC-7857 iNFTs on the 0G EVM chain.
type Minter struct {
    contract *bind.BoundContract
    address  common.Address
    client   *ethclient.Client
}

// NewMinter creates a Minter bound to the deployed ERC-7857 contract.
func NewMinter(client *ethclient.Client, contractAddress string) (*Minter, error) {
    addr := common.HexToAddress(contractAddress)
    parsed, err := abi.JSON(strings.NewReader(ERC7857ABI))
    if err != nil {
        return nil, fmt.Errorf("parse abi: %w", err)
    }
    contract := bind.NewBoundContract(addr, parsed, client, client, client)
    return &Minter{contract: contract, address: addr, client: client}, nil
}

// Mint mints a new iNFT with the given tokenURI (typically a 0G DA CID).
// Returns the minted token ID.
func (m *Minter) Mint(ctx context.Context, opts *bind.TransactOpts, to common.Address, tokenURI string) (*big.Int, error) {
    tx, err := m.contract.Transact(opts, "mint", to, tokenURI)
    if err != nil {
        return nil, fmt.Errorf("mint tx: %w", err)
    }
    receipt, err := bind.WaitMined(ctx, m.client, tx)
    if err != nil {
        return nil, fmt.Errorf("wait mined: %w", err)
    }
    if receipt.Status == 0 {
        return nil, fmt.Errorf("mint tx reverted: %s", tx.Hash().Hex())
    }
    // Token ID is in the first log topic — parse from receipt if needed
    return big.NewInt(int64(receipt.BlockNumber.Int64())), nil
}
```

### Step 9: Write `cmd/mint/main.go`

```go
package main

import (
    "context"
    "encoding/hex"
    "log"
    "os"
    "os/signal"
    "syscall"

    "0g-inft-build/internal/config"
    zgcrypto "0g-inft-build/internal/crypto"
    "0g-inft-build/internal/da"
    "0g-inft-build/internal/inft"

    "github.com/ethereum/go-ethereum/common"
    "github.com/ethereum/go-ethereum/crypto"
    "github.com/ethereum/go-ethereum/ethclient"
)

func main() {
    cfg, err := config.Load()
    if err != nil {
        log.Fatalf("config: %v", err)
    }

    ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
    defer cancel()

    encKey, err := hex.DecodeString(cfg.EncryptKey)
    if err != nil {
        log.Fatalf("decode encrypt key: %v", err)
    }

    // Encrypt model weights (stub — replace with real model bytes)
    modelWeights := []byte("stub-model-weights")
    ciphertext, nonce, err := zgcrypto.Encrypt(encKey, modelWeights)
    if err != nil {
        log.Fatalf("encrypt: %v", err)
    }
    _ = nonce // store nonce alongside ciphertext in production

    publisher := da.NewPublisher(cfg.DAEndpoint)
    cid, err := publisher.Publish(ctx, ciphertext)
    if err != nil {
        log.Fatalf("da publish: %v", err)
    }
    log.Printf("published encrypted model to DA: cid=%s", cid)

    client, err := ethclient.DialContext(ctx, cfg.RPCUrl)
    if err != nil {
        log.Fatalf("dial rpc: %v", err)
    }
    defer client.Close()

    privKey, err := crypto.HexToECDSA(cfg.PrivateKey)
    if err != nil {
        log.Fatalf("load key: %v", err)
    }

    chainID, err := client.ChainID(ctx)
    if err != nil {
        log.Fatalf("chain id: %v", err)
    }

    opts, err := bind.NewKeyedTransactorWithChainID(privKey, chainID)
    if err != nil {
        log.Fatalf("transact opts: %v", err)
    }
    opts.Context = ctx

    minter, err := inft.NewMinter(client, cfg.ContractAddress)
    if err != nil {
        log.Fatalf("new minter: %v", err)
    }

    to := common.HexToAddress(cfg.ContractAddress) // mint to self for demo
    tokenID, err := minter.Mint(ctx, opts, to, "0g-da://"+cid)
    if err != nil {
        log.Fatalf("mint: %v", err)
    }
    log.Printf("minted iNFT tokenID=%s tokenURI=0g-da://%s", tokenID.String(), cid)
}
```

Note: `bind.NewKeyedTransactorWithChainID` is imported from `go-ethereum/accounts/abi/bind` — add the import to main.go.

### Step 10: Write `Justfile`

```makefile
# 0g-inft-build — justfile
default:
    @just --list --justfile {{source_file()}}

build:
    go build -o bin/ ./cmd/...

run:
    go run ./cmd/mint/...

test:
    go test ./...

lint:
    golangci-lint run ./...

clean:
    rm -rf bin/
```

### Step 11: Write `.env.example`

```
ZG_RPC_URL=https://evmrpc-testnet.0g.ai
ZG_PRIVATE_KEY=<your-hex-private-key>
ZG_CONTRACT_ADDRESS=0x<deployed-erc7857-contract>
ZG_DA_ENDPOINT=https://da-testnet.0g.ai
ZG_ENCRYPT_KEY=<64-char-hex-aes-256-key>
```

### Step 12: Verify compilation

Run `go build ./...` inside `projects/hiero-plugin/templates/0g-inft-build/` and fix any import errors. The `bind.NewKeyedTransactorWithChainID` import in `main.go` must be explicitly listed.

## Done When

- [ ] All requirements met
- [ ] `go build ./...` exits 0 inside the template directory
