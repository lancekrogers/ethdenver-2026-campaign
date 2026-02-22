---
fest_type: task
fest_id: 03_wire_register_signing.md
fest_name: wire register signing
fest_parent: 02_base_tx_signing
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:46.795575-07:00
fest_tracking: true
---

# Task: Wire Real Transaction Signing in register.go

## Objective

Replace the stub registration transaction code in `register.go` lines 177–207 with real go-ethereum signing that ABI-encodes the `register(bytes32,bytes,bytes)` calldata, builds a transaction, signs it, sends it, and polls for the receipt.

## Requirements

- [ ] `Registry` struct holds `*ethclient.Client` and `*ecdsa.PrivateKey` fields
- [ ] `NewRegistry` (or equivalent constructor) initializes both fields using `ethutil.DialClient` and `ethutil.LoadKey`
- [ ] Stub at lines 177–207 replaced with ABI-encoded calldata construction, tx signing, and submission
- [ ] Receipt polled and `Status == 1` verified
- [ ] Function returns real tx hash on success

## Implementation

First, read the current file to understand the exact stub location and existing struct:

```
projects/agent-defi/internal/base/identity/register.go
```

Step 1: Update the `Registry` struct to hold client and key fields.

```go
type Registry struct {
    cfg    *Config
    client *ethclient.Client
    key    *ecdsa.PrivateKey
    // ... any existing fields
}
```

Step 2: Update the constructor to initialize client and key using ethutil:

```go
func NewRegistry(ctx context.Context, cfg *Config) (*Registry, error) {
    client, err := ethutil.DialClient(ctx, cfg.RPCURL)
    if err != nil {
        return nil, fmt.Errorf("registry dial client: %w", err)
    }
    key, err := ethutil.LoadKey(cfg.PrivateKey)
    if err != nil {
        return nil, fmt.Errorf("registry load key: %w", err)
    }
    return &Registry{cfg: cfg, client: client, key: key}, nil
}
```

Step 3: Replace the stub with real ABI encoding and tx submission.

The ERC-8004 `register(bytes32,bytes,bytes)` function selector is `0x<computed>`. Use `crypto.Keccak256` to compute the selector:

```go
// Build register(bytes32,bytes,bytes) calldata
sig := []byte("register(bytes32,bytes,bytes)")
selector := crypto.Keccak256(sig)[:4]

// ABI-encode arguments: agentID (bytes32), metadata (bytes), pubKey (bytes)
abiArgs := abi.Arguments{
    {Type: must(abi.NewType("bytes32", "", nil))},
    {Type: must(abi.NewType("bytes", "", nil))},
    {Type: must(abi.NewType("bytes", "", nil))},
}
encoded, err := abiArgs.Pack(agentID, metadata, pubKey)
if err != nil {
    return nil, fmt.Errorf("abi encode register args: %w", err)
}
calldata := append(selector, encoded...)

// Build and sign transaction
nonce, err := r.client.PendingNonceAt(ctx, ethutil.AddressFromKey(r.key))
if err != nil {
    return nil, fmt.Errorf("get nonce: %w", err)
}
gasPrice, err := r.client.SuggestGasPrice(ctx)
if err != nil {
    return nil, fmt.Errorf("suggest gas price: %w", err)
}
chainID := big.NewInt(r.cfg.ChainID)
registryAddr := common.HexToAddress(r.cfg.RegistryAddress)
tx := types.NewTx(&types.DynamicFeeTx{
    ChainID:   chainID,
    Nonce:     nonce,
    GasTipCap: gasPrice,
    GasFeeCap: new(big.Int).Mul(gasPrice, big.NewInt(2)),
    Gas:       200000,
    To:        &registryAddr,
    Data:      calldata,
})
signer := types.NewLondonSigner(chainID)
signed, err := types.SignTx(tx, signer, r.key)
if err != nil {
    return nil, fmt.Errorf("sign register tx: %w", err)
}
if err := r.client.SendTransaction(ctx, signed); err != nil {
    return nil, fmt.Errorf("send register tx: %w", err)
}
receipt, err := bind.WaitMined(ctx, r.client, signed)
if err != nil {
    return nil, fmt.Errorf("wait mined register tx: %w", err)
}
if receipt.Status != types.ReceiptStatusSuccessful {
    return nil, fmt.Errorf("register tx reverted: %s", signed.Hash().Hex())
}
return signed.Hash(), nil
```

Use a `must` helper for ABI type construction or handle the error inline — either is acceptable.

Step 4: Add imports:

```go
"math/big"
"github.com/ethereum/go-ethereum/accounts/abi"
"github.com/ethereum/go-ethereum/accounts/abi/bind"
"github.com/ethereum/go-ethereum/common"
"github.com/ethereum/go-ethereum/core/types"
"github.com/ethereum/go-ethereum/crypto"
"github.com/<module>/internal/base/ethutil"
```

Step 5: Run build.

```bash
cd projects/agent-defi && just build
```

## Done When

- [ ] All requirements met
- [ ] `just build` passes in projects/agent-defi
- [ ] `register.Register` sends a real ERC-8004 registration transaction on Base Sepolia and returns a tx hash
