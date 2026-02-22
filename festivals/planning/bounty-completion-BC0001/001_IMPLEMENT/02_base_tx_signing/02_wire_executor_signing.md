---
fest_type: task
fest_id: 02_wire_executor_signing.md
fest_name: wire executor signing
fest_parent: 02_base_tx_signing
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:46.795246-07:00
fest_tracking: true
---

# Task: Wire Real Transaction Signing in executor.go

## Objective

Replace the stub transaction code in `executor.go` lines 142–161 with real go-ethereum signing that builds a `types.DynamicFeeTx`, signs it, RLP-encodes it, submits it via `eth_sendRawTransaction`, and polls for the receipt using `bind.WaitMined`.

## Requirements

- [ ] `Executor` struct holds `*ethclient.Client` and `*ecdsa.PrivateKey` fields
- [ ] `NewExecutor` initializes both fields using `ethutil.DialClient` and `ethutil.LoadKey`
- [ ] Stub at lines 142–161 replaced with real `types.DynamicFeeTx` construction, signing, and submission
- [ ] Receipt polled using `bind.WaitMined` and checked for `Status == 1`
- [ ] Function returns real tx hash on success

## Implementation

First, read the current file to understand the exact stub location and existing struct:

```
projects/agent-defi/internal/base/trading/executor.go
```

Step 1: Update the `Executor` struct to hold client and key fields.

Add to the struct (or create the struct if it is missing):
```go
type Executor struct {
    cfg    *Config
    client *ethclient.Client
    key    *ecdsa.PrivateKey
    // ... any existing fields
}
```

Step 2: Update `NewExecutor` to initialize client and key.

```go
func NewExecutor(ctx context.Context, cfg *Config) (*Executor, error) {
    client, err := ethutil.DialClient(ctx, cfg.RPCURL)
    if err != nil {
        return nil, fmt.Errorf("executor dial client: %w", err)
    }
    key, err := ethutil.LoadKey(cfg.PrivateKey)
    if err != nil {
        return nil, fmt.Errorf("executor load key: %w", err)
    }
    return &Executor{cfg: cfg, client: client, key: key}, nil
}
```

Step 3: Replace the stub at lines 142–161 with real signing code.

```go
// Build EIP-1559 dynamic fee transaction
nonce, err := e.client.PendingNonceAt(ctx, ethutil.AddressFromKey(e.key))
if err != nil {
    return nil, fmt.Errorf("get nonce: %w", err)
}
gasPrice, err := e.client.SuggestGasPrice(ctx)
if err != nil {
    return nil, fmt.Errorf("suggest gas price: %w", err)
}
chainID := big.NewInt(e.cfg.ChainID)
tx := types.NewTx(&types.DynamicFeeTx{
    ChainID:   chainID,
    Nonce:     nonce,
    GasTipCap: gasPrice,
    GasFeeCap: new(big.Int).Mul(gasPrice, big.NewInt(2)),
    Gas:       300000,
    To:        &dexRouter,   // common.Address of DEX router
    Data:      calldata,     // ABI-encoded swap calldata
})
signer := types.NewLondonSigner(chainID)
signed, err := types.SignTx(tx, signer, e.key)
if err != nil {
    return nil, fmt.Errorf("sign tx: %w", err)
}
if err := e.client.SendTransaction(ctx, signed); err != nil {
    return nil, fmt.Errorf("send tx: %w", err)
}
receipt, err := bind.WaitMined(ctx, e.client, signed)
if err != nil {
    return nil, fmt.Errorf("wait mined: %w", err)
}
if receipt.Status != types.ReceiptStatusSuccessful {
    return nil, fmt.Errorf("tx reverted: %s", signed.Hash().Hex())
}
return signed.Hash(), nil
```

Adjust variable names (`dexRouter`, `calldata`) to match what the existing function already has in scope. The `dexRouter` address should come from `cfg.DEXRouter` or equivalent.

Step 4: Add required imports at the top of the file:

```go
"math/big"
"github.com/ethereum/go-ethereum/accounts/abi/bind"
"github.com/ethereum/go-ethereum/core/types"
"github.com/<module>/internal/base/ethutil"
```

Step 5: Run build.

```bash
cd projects/agent-defi && just build
```

## Done When

- [ ] All requirements met
- [ ] `just build` passes in projects/agent-defi
- [ ] `executor.Execute` sends a real transaction on Base Sepolia and returns a tx hash
