---
fest_type: task
fest_id: 01_create_0g_agent_template.md
fest_name: create 0g agent template
fest_parent: 04_0g_templates
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:54.687273-07:00
fest_tracking: true
---

# Task: Create 0g-agent Camp Template

## Objective

Create the `0g-agent` Go project scaffold template at `projects/hiero-plugin/templates/0g-agent/` modeled on `projects/agent-inference/`, wiring 0G Compute broker, Storage client, and chain client stubs so a generated project compiles and runs against the 0G testnet with only environment variable configuration.

## Requirements

- [ ] Template directory `projects/hiero-plugin/templates/0g-agent/` exists with a complete Go module scaffold
- [ ] `internal/zerog/compute.go` provides a `ComputeBroker` stub with `SubmitTask(ctx, payload)` method
- [ ] `internal/zerog/storage.go` provides a `StorageClient` stub with `Upload(ctx, data)` and `Download(ctx, cid)` methods
- [ ] `internal/zerog/chain.go` provides `LoadKey`, `DialClient`, and `MakeTransactOpts` helpers (mirrors `agent-inference`'s chain.go pattern)
- [ ] `internal/config/config.go` loads all required env vars (`ZG_RPC_URL`, `ZG_PRIVATE_KEY`, `ZG_COMPUTE_ENDPOINT`, `ZG_STORAGE_ENDPOINT`) with clear error messages on missing values
- [ ] `cmd/agent/main.go` wires config, chain client, compute broker, and storage client and runs a simple poll loop
- [ ] `go.mod` declares module `0g-agent` and pins the 0G SDK (or uses standard `go-ethereum` for chain interactions)
- [ ] `Justfile` has `build`, `run`, `test`, and `lint` recipes that mirror the `agent-inference` Justfile pattern

## Implementation

### Step 1: Examine the reference implementation

Read `projects/agent-inference/` to understand the exact file layout, package names, Justfile recipes, and chain.go helper signatures before creating anything.

```
projects/agent-inference/
  cmd/agent/main.go
  internal/zerog/chain.go       (if present — otherwise internal/hedera/chain.go as analog)
  internal/config/config.go
  go.mod
  Justfile
```

### Step 2: Create the directory tree

```
projects/hiero-plugin/templates/0g-agent/
  cmd/
    agent/
      main.go
  internal/
    config/
      config.go
    zerog/
      chain.go
      compute.go
      storage.go
  go.mod
  Justfile
  .env.example
```

Use `t2s` or `mkdir -p` to create the directories, then write each file.

### Step 3: Write `go.mod`

```go
module 0g-agent

go 1.22

require (
    github.com/ethereum/go-ethereum v1.13.14
)
```

Pin go-ethereum as the chain interaction layer. 0G's EVM-compatible chain accepts standard ethclient calls.

### Step 4: Write `internal/config/config.go`

```go
package config

import (
    "fmt"
    "os"
)

type Config struct {
    RPCUrl            string
    PrivateKey        string
    ComputeEndpoint   string
    StorageEndpoint   string
}

func Load() (*Config, error) {
    cfg := &Config{
        RPCUrl:          os.Getenv("ZG_RPC_URL"),
        PrivateKey:      os.Getenv("ZG_PRIVATE_KEY"),
        ComputeEndpoint: os.Getenv("ZG_COMPUTE_ENDPOINT"),
        StorageEndpoint: os.Getenv("ZG_STORAGE_ENDPOINT"),
    }
    if cfg.RPCUrl == "" {
        return nil, fmt.Errorf("ZG_RPC_URL is required")
    }
    if cfg.PrivateKey == "" {
        return nil, fmt.Errorf("ZG_PRIVATE_KEY is required")
    }
    return cfg, nil
}
```

### Step 5: Write `internal/zerog/chain.go`

```go
package zerog

import (
    "context"
    "crypto/ecdsa"
    "fmt"
    "math/big"

    "github.com/ethereum/go-ethereum/accounts/abi/bind"
    "github.com/ethereum/go-ethereum/crypto"
    "github.com/ethereum/go-ethereum/ethclient"
)

func LoadKey(hexKey string) (*ecdsa.PrivateKey, error) {
    return crypto.HexToECDSA(hexKey)
}

func DialClient(ctx context.Context, rpcURL string) (*ethclient.Client, error) {
    client, err := ethclient.DialContext(ctx, rpcURL)
    if err != nil {
        return nil, fmt.Errorf("dial 0G RPC %s: %w", rpcURL, err)
    }
    return client, nil
}

func MakeTransactOpts(ctx context.Context, key *ecdsa.PrivateKey, chainID *big.Int) (*bind.TransactOpts, error) {
    opts, err := bind.NewKeyedTransactorWithChainID(key, chainID)
    if err != nil {
        return nil, fmt.Errorf("make transact opts: %w", err)
    }
    opts.Context = ctx
    return opts, nil
}
```

### Step 6: Write `internal/zerog/compute.go`

```go
package zerog

import (
    "context"
    "fmt"
)

// ComputeBroker submits inference tasks to the 0G Compute network.
// Replace the stub body with the actual 0G Compute SDK call when available.
type ComputeBroker struct {
    endpoint string
}

func NewComputeBroker(endpoint string) *ComputeBroker {
    return &ComputeBroker{endpoint: endpoint}
}

// SubmitTask sends payload to the 0G Compute broker and returns a task ID.
func (b *ComputeBroker) SubmitTask(ctx context.Context, payload []byte) (string, error) {
    if err := ctx.Err(); err != nil {
        return "", err
    }
    // TODO: replace with actual 0G Compute SDK call
    // e.g. client.Submit(ctx, &computepb.TaskRequest{Payload: payload})
    return fmt.Sprintf("task-%x", payload[:4]), nil
}
```

### Step 7: Write `internal/zerog/storage.go`

```go
package zerog

import (
    "context"
    "fmt"
)

// StorageClient uploads and downloads data from the 0G Storage network.
// Replace stub bodies with the actual 0G Storage SDK calls when available.
type StorageClient struct {
    endpoint string
}

func NewStorageClient(endpoint string) *StorageClient {
    return &StorageClient{endpoint: endpoint}
}

// Upload stores data on 0G Storage and returns the content ID.
func (s *StorageClient) Upload(ctx context.Context, data []byte) (string, error) {
    if err := ctx.Err(); err != nil {
        return "", err
    }
    // TODO: replace with actual 0G Storage SDK call
    return fmt.Sprintf("cid-%x", data[:4]), nil
}

// Download retrieves data by content ID from 0G Storage.
func (s *StorageClient) Download(ctx context.Context, cid string) ([]byte, error) {
    if err := ctx.Err(); err != nil {
        return nil, err
    }
    // TODO: replace with actual 0G Storage SDK call
    return []byte("stub-data-for-" + cid), nil
}
```

### Step 8: Write `cmd/agent/main.go`

```go
package main

import (
    "context"
    "log"
    "os"
    "os/signal"
    "syscall"
    "time"

    "0g-agent/internal/config"
    "0g-agent/internal/zerog"
)

func main() {
    cfg, err := config.Load()
    if err != nil {
        log.Fatalf("config: %v", err)
    }

    ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
    defer cancel()

    key, err := zerog.LoadKey(cfg.PrivateKey)
    if err != nil {
        log.Fatalf("load key: %v", err)
    }

    client, err := zerog.DialClient(ctx, cfg.RPCUrl)
    if err != nil {
        log.Fatalf("dial client: %v", err)
    }
    defer client.Close()

    compute := zerog.NewComputeBroker(cfg.ComputeEndpoint)
    storage := zerog.NewStorageClient(cfg.StorageEndpoint)

    _ = key // used when signing transactions

    log.Println("0g-agent running — press Ctrl+C to stop")
    ticker := time.NewTicker(10 * time.Second)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            log.Println("shutting down")
            return
        case <-ticker.C:
            taskID, err := compute.SubmitTask(ctx, []byte("hello-0g"))
            if err != nil {
                log.Printf("compute submit: %v", err)
                continue
            }
            cid, err := storage.Upload(ctx, []byte("result-"+taskID))
            if err != nil {
                log.Printf("storage upload: %v", err)
                continue
            }
            log.Printf("task=%s stored=%s", taskID, cid)
        }
    }
}
```

### Step 9: Write `Justfile`

```makefile
# 0g-agent — justfile
default:
    @just --list --justfile {{source_file()}}

build:
    go build -o bin/ ./cmd/...

run:
    go run ./cmd/agent/...

test:
    go test ./...

lint:
    golangci-lint run ./...

clean:
    rm -rf bin/
```

### Step 10: Write `.env.example`

```
ZG_RPC_URL=https://evmrpc-testnet.0g.ai
ZG_PRIVATE_KEY=<your-hex-private-key>
ZG_COMPUTE_ENDPOINT=https://compute-testnet.0g.ai
ZG_STORAGE_ENDPOINT=https://storage-testnet.0g.ai
```

### Step 11: Verify compilation

Run `go build ./...` inside `projects/hiero-plugin/templates/0g-agent/` and fix any import errors before marking done.

## Done When

- [ ] All requirements met
- [ ] `go build ./...` exits 0 inside the template directory
