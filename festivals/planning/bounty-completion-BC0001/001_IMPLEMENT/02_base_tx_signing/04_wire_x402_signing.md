---
fest_type: task
fest_id: 04_wire_x402_signing.md
fest_name: wire x402 signing
fest_parent: 02_base_tx_signing
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:46.795836-07:00
fest_tracking: true
---

# Task: Wire Real Transaction Signing in x402.go

## Objective

Replace the stub payment transaction code in `x402.go` lines 137–152 with real go-ethereum signing that builds a value transfer or ERC-20 transfer transaction, signs it, sends it, and polls for the receipt using the existing `getTransactionReceipt()` infrastructure.

## Requirements

- [ ] `Protocol` struct holds `*ethclient.Client` and `*ecdsa.PrivateKey` fields
- [ ] Constructor initializes both fields using `ethutil.DialClient` and `ethutil.LoadKey`
- [ ] Stub at lines 137–152 replaced with a real payment transaction (ETH value transfer or ERC-20 transfer depending on payment token)
- [ ] Receipt polled using the existing `getTransactionReceipt()` function — do not duplicate polling logic
- [ ] Function returns real tx hash on success

## Implementation

First, read the current file to understand the exact stub location, existing struct, and the `getTransactionReceipt` function:

```
projects/agent-defi/internal/base/payment/x402.go
```

Note: `getTransactionReceipt()` already exists and works — reuse it rather than calling `bind.WaitMined` directly.

Step 1: Update the `Protocol` struct.

```go
type Protocol struct {
    cfg    *Config
    client *ethclient.Client
    key    *ecdsa.PrivateKey
    // ... any existing fields
}
```

Step 2: Update the constructor.

```go
func NewProtocol(ctx context.Context, cfg *Config) (*Protocol, error) {
    client, err := ethutil.DialClient(ctx, cfg.RPCURL)
    if err != nil {
        return nil, fmt.Errorf("x402 dial client: %w", err)
    }
    key, err := ethutil.LoadKey(cfg.PrivateKey)
    if err != nil {
        return nil, fmt.Errorf("x402 load key: %w", err)
    }
    return &Protocol{cfg: cfg, client: client, key: key}, nil
}
```

Step 3: Replace the stub with real payment tx code.

For an ETH payment:

```go
nonce, err := p.client.PendingNonceAt(ctx, ethutil.AddressFromKey(p.key))
if err != nil {
    return nil, fmt.Errorf("get nonce: %w", err)
}
gasPrice, err := p.client.SuggestGasPrice(ctx)
if err != nil {
    return nil, fmt.Errorf("suggest gas price: %w", err)
}
chainID := big.NewInt(p.cfg.ChainID)
toAddr := common.HexToAddress(payment.Recipient)
value := payment.Amount // *big.Int denominated in wei

tx := types.NewTx(&types.DynamicFeeTx{
    ChainID:   chainID,
    Nonce:     nonce,
    GasTipCap: gasPrice,
    GasFeeCap: new(big.Int).Mul(gasPrice, big.NewInt(2)),
    Gas:       21000,
    To:        &toAddr,
    Value:     value,
})
signer := types.NewLondonSigner(chainID)
signed, err := types.SignTx(tx, signer, p.key)
if err != nil {
    return nil, fmt.Errorf("sign payment tx: %w", err)
}
if err := p.client.SendTransaction(ctx, signed); err != nil {
    return nil, fmt.Errorf("send payment tx: %w", err)
}
// Reuse existing receipt poller
receipt, err := p.getTransactionReceipt(ctx, signed.Hash())
if err != nil {
    return nil, fmt.Errorf("poll payment receipt: %w", err)
}
if receipt.Status != types.ReceiptStatusSuccessful {
    return nil, fmt.Errorf("payment tx reverted: %s", signed.Hash().Hex())
}
return signed.Hash(), nil
```

If x402 payments use ERC-20 tokens instead of native ETH, encode a `transfer(address,uint256)` calldata (selector `0xa9059cbb`) and set `To` to the token contract address with `Value: nil`. Use the same signing pattern.

Adjust `payment` struct field names to match the actual function signature — read the file first.

Step 4: Add imports as needed (same set as other signing tasks).

Step 5: Run build.

```bash
cd projects/agent-defi && just build
```

## Done When

- [ ] All requirements met
- [ ] `just build` passes in projects/agent-defi
- [ ] `x402.Pay` sends a real payment transaction on Base Sepolia and returns a tx hash
