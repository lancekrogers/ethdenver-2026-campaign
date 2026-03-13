---
fest_type: task
fest_id: 03_bridge_manager.md
fest_name: bridge_manager
fest_parent: 02_cross_platform
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.588809-06:00
fest_tracking: true
---

# Task: Cross-Chain Bridge Manager

## Objective

Implement the `BridgeManager` that handles USDC bridging between Solana (vault), Polygon (Polymarket), and Base (Limitless) using Wormhole, with batching, balance tracking, and in-transit fund accounting for NAV calculation.

## Requirements

- [ ] `BridgeManager` struct managing working capital balances across 3 chains
- [ ] `Bridge` method: initiate a USDC bridge between any two supported chains
- [ ] Batching: bridge in $5K chunks minimum to amortize costs, not per-trade
- [ ] Balance tracking: current available balance on each chain
- [ ] In-transit tracking: funds currently being bridged (for NAV calculation)
- [ ] `EnsureBalance` method: ensure a target chain has enough USDC, triggering bridge if needed
- [ ] Bridge status polling: track pending bridges and update balances on completion
- [ ] Support Wormhole for Solana <-> Polygon and Solana <-> Base routes

## Implementation

### Step 1: Define BridgeManager types

Create `projects/agent-prediction/internal/bridge/manager.go`:

```go
package bridge

import (
    "context"
    "fmt"
    "log/slog"
    "sync"
    "time"
)

// Chain identifiers.
const (
    ChainSolana  = "solana"
    ChainPolygon = "polygon"
    ChainBase    = "base"
)

// BridgeTransfer represents a pending or completed cross-chain transfer.
type BridgeTransfer struct {
    ID          string
    FromChain   string
    ToChain     string
    Amount      float64 // USDC amount
    Status      TransferStatus
    InitiatedAt time.Time
    CompletedAt *time.Time
    TxHash      string // source chain tx hash
    DestTxHash  string // destination chain tx hash (once complete)
}

type TransferStatus string

const (
    TransferPending   TransferStatus = "pending"
    TransferComplete  TransferStatus = "complete"
    TransferFailed    TransferStatus = "failed"
)

// ChainBalance tracks available and in-transit USDC on a chain.
type ChainBalance struct {
    Chain      string
    Available  float64 // USDC available for trading
    InTransit  float64 // USDC currently being bridged TO this chain
    LastUpdate time.Time
}

// BridgeConfig holds configuration for the bridge manager.
type BridgeConfig struct {
    MinBridgeAmount  float64       // minimum bridge amount in USDC (default $5,000)
    PollInterval     time.Duration // how often to check bridge status (default 30s)
    WormholeRPCURL   string
    SolanaRPCURL     string
    PolygonRPCURL    string
    BaseRPCURL       string
}

// Manager coordinates cross-chain USDC bridging.
type Manager struct {
    config    BridgeConfig
    logger    *slog.Logger

    mu        sync.RWMutex
    balances  map[string]*ChainBalance
    transfers []*BridgeTransfer

    // Chain-specific bridge implementations
    wormhole  WormholeBridge
}

// WormholeBridge is the interface for Wormhole bridge operations.
type WormholeBridge interface {
    // InitiateTransfer starts a USDC transfer from source to destination chain.
    InitiateTransfer(ctx context.Context, fromChain, toChain string, amount float64) (txHash string, err error)
    // GetTransferStatus checks if a transfer has completed.
    GetTransferStatus(ctx context.Context, txHash string, fromChain string) (TransferStatus, string, error)
}

// NewManager creates a new bridge manager.
func NewManager(config BridgeConfig, wormhole WormholeBridge, logger *slog.Logger) *Manager {
    if config.MinBridgeAmount == 0 {
        config.MinBridgeAmount = 5000
    }
    if config.PollInterval == 0 {
        config.PollInterval = 30 * time.Second
    }

    m := &Manager{
        config:   config,
        logger:   logger,
        wormhole: wormhole,
        balances: map[string]*ChainBalance{
            ChainSolana:  &ChainBalance{Chain: ChainSolana},
            ChainPolygon: &ChainBalance{Chain: ChainPolygon},
            ChainBase:    &ChainBalance{Chain: ChainBase},
        },
    }
    return m
}
```

### Step 2: Implement balance management and bridging

```go
// SetBalance updates the known balance for a chain (called after on-chain queries).
func (m *Manager) SetBalance(chain string, available float64) {
    m.mu.Lock()
    defer m.mu.Unlock()
    if b, ok := m.balances[chain]; ok {
        b.Available = available
        b.LastUpdate = time.Now()
    }
}

// Balance returns the current balance for a chain.
func (m *Manager) Balance(chain string) ChainBalance {
    m.mu.RLock()
    defer m.mu.RUnlock()
    if b, ok := m.balances[chain]; ok {
        return *b
    }
    return ChainBalance{}
}

// TotalInTransit returns the total USDC currently being bridged (for NAV calculation).
func (m *Manager) TotalInTransit() float64 {
    m.mu.RLock()
    defer m.mu.RUnlock()
    var total float64
    for _, t := range m.transfers {
        if t.Status == TransferPending {
            total += t.Amount
        }
    }
    return total
}

// EnsureBalance checks if the target chain has at least `needed` USDC.
// If not, initiates a bridge from the chain with the most available balance.
func (m *Manager) EnsureBalance(ctx context.Context, targetChain string, needed float64) error {
    m.mu.RLock()
    target := m.balances[targetChain]
    available := target.Available + target.InTransit
    m.mu.RUnlock()

    if available >= needed {
        return nil // already have enough (including in-transit)
    }

    deficit := needed - available
    bridgeAmount := max(deficit, m.config.MinBridgeAmount) // at least min bridge amount

    // Find the chain with the most available balance to bridge from
    sourceChain := m.findBestSource(targetChain, bridgeAmount)
    if sourceChain == "" {
        return fmt.Errorf("no chain has enough USDC to bridge %.2f to %s", bridgeAmount, targetChain)
    }

    return m.Bridge(ctx, sourceChain, targetChain, bridgeAmount)
}

// Bridge initiates a USDC transfer between chains.
func (m *Manager) Bridge(ctx context.Context, fromChain, toChain string, amount float64) error {
    if err := ctx.Err(); err != nil {
        return err
    }
    if fromChain == toChain {
        return fmt.Errorf("cannot bridge to the same chain")
    }

    m.logger.Info("initiating bridge transfer",
        "from", fromChain, "to", toChain, "amount", amount)

    txHash, err := m.wormhole.InitiateTransfer(ctx, fromChain, toChain, amount)
    if err != nil {
        return fmt.Errorf("initiating bridge %s->%s: %w", fromChain, toChain, err)
    }

    transfer := &BridgeTransfer{
        ID:          fmt.Sprintf("bridge-%d", time.Now().UnixNano()),
        FromChain:   fromChain,
        ToChain:     toChain,
        Amount:      amount,
        Status:      TransferPending,
        InitiatedAt: time.Now(),
        TxHash:      txHash,
    }

    m.mu.Lock()
    m.transfers = append(m.transfers, transfer)
    m.balances[fromChain].Available -= amount
    m.balances[toChain].InTransit += amount
    m.mu.Unlock()

    m.logger.Info("bridge transfer initiated",
        "id", transfer.ID, "tx_hash", txHash)

    return nil
}

func (m *Manager) findBestSource(targetChain string, needed float64) string {
    m.mu.RLock()
    defer m.mu.RUnlock()

    var bestChain string
    var bestBalance float64
    for chain, balance := range m.balances {
        if chain == targetChain {
            continue
        }
        if balance.Available >= needed && balance.Available > bestBalance {
            bestChain = chain
            bestBalance = balance.Available
        }
    }
    return bestChain
}
```

### Step 3: Implement bridge status polling

```go
// PollTransfers checks the status of all pending bridge transfers.
// Call this periodically (e.g., every 30 seconds).
func (m *Manager) PollTransfers(ctx context.Context) {
    m.mu.RLock()
    pending := make([]*BridgeTransfer, 0)
    for _, t := range m.transfers {
        if t.Status == TransferPending {
            pending = append(pending, t)
        }
    }
    m.mu.RUnlock()

    for _, transfer := range pending {
        status, destTx, err := m.wormhole.GetTransferStatus(ctx, transfer.TxHash, transfer.FromChain)
        if err != nil {
            m.logger.Error("failed to poll bridge status",
                "id", transfer.ID, "error", err)
            continue
        }

        if status == TransferComplete {
            m.mu.Lock()
            transfer.Status = TransferComplete
            now := time.Now()
            transfer.CompletedAt = &now
            transfer.DestTxHash = destTx
            // Move from in-transit to available
            m.balances[transfer.ToChain].InTransit -= transfer.Amount
            m.balances[transfer.ToChain].Available += transfer.Amount
            m.mu.Unlock()

            m.logger.Info("bridge transfer complete",
                "id", transfer.ID,
                "from", transfer.FromChain,
                "to", transfer.ToChain,
                "amount", transfer.Amount,
                "duration", time.Since(transfer.InitiatedAt),
            )
        } else if status == TransferFailed {
            m.mu.Lock()
            transfer.Status = TransferFailed
            m.balances[transfer.FromChain].Available += transfer.Amount
            m.balances[transfer.ToChain].InTransit -= transfer.Amount
            m.mu.Unlock()

            m.logger.Error("bridge transfer failed",
                "id", transfer.ID, "tx_hash", transfer.TxHash)
        }
    }
}

// RunPoller starts a background loop that polls transfer statuses.
func (m *Manager) RunPoller(ctx context.Context) error {
    ticker := time.NewTicker(m.config.PollInterval)
    defer ticker.Stop()
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        case <-ticker.C:
            m.PollTransfers(ctx)
        }
    }
}
```

### Step 4: Write tests

Create `internal/bridge/manager_test.go`:

1. `TestEnsureBalanceSufficientNoOp` — target has enough, verify no bridge initiated
2. `TestEnsureBalanceTriggersBridge` — target short, verify bridge from chain with most funds
3. `TestBridgeMinAmount` — deficit is $500 but min is $5000, verify $5000 bridged
4. `TestBridgeUpdateBalances` — after Bridge(), verify source decremented and target in-transit incremented
5. `TestPollTransferComplete` — mock Wormhole returns complete, verify in-transit moves to available
6. `TestPollTransferFailed` — mock failure, verify amount returned to source
7. `TestTotalInTransit` — multiple pending transfers, verify correct sum
8. `TestBridgeSameChainRejected` — verify error when fromChain == toChain

## Done When

- [ ] All requirements met
- [ ] Bridges in minimum $5K batches to amortize costs
- [ ] Available and in-transit balances tracked per chain
- [ ] `EnsureBalance` triggers bridge only when needed
- [ ] Completed bridges move funds from in-transit to available
- [ ] Failed bridges return funds to source chain balance
- [ ] `TotalInTransit()` provides accurate data for NAV calculation
- [ ] `go test ./internal/bridge/...` passes with all bridge manager tests green
