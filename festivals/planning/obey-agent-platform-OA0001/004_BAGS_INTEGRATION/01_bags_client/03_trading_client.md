---
fest_type: task
fest_id: 03_trading_client.md
fest_name: trading_client
fest_parent: 01_bags_client
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.473349-06:00
fest_tracking: true
---

# Task: Trading & Swap Client

## Objective

Implement Bags API methods for getting trade quotes, creating swap transactions, and submitting signed transactions in `projects/agent-bags/internal/bags/client.go`.

## Requirements

- [ ] `GetTradeQuote` method: `GET /trade/quote` with input mint, output mint, amount, and slippage parameters
- [ ] `CreateSwap` method: `POST /swap/create` to generate a ready-to-sign swap transaction
- [ ] `SendTransaction` method: `POST /transactions/send` to submit a signed serialized transaction
- [ ] Quote response includes output amount, price impact percentage, slippage, and route info
- [ ] Transaction signing helper using the agent's Solana keypair (ed25519)
- [ ] All methods propagate `context.Context`

## Implementation

### Step 1: Define trading types

Add to `projects/agent-bags/internal/bags/types.go`:

```go
// TradeQuote is the response from GET /trade/quote.
type TradeQuote struct {
    InputMint    string  `json:"inputMint"`
    OutputMint   string  `json:"outputMint"`
    InputAmount  uint64  `json:"inputAmount"`
    OutputAmount uint64  `json:"outputAmount"`
    PriceImpact  float64 `json:"priceImpact"`  // percentage, e.g. 0.5 = 0.5%
    Slippage     float64 `json:"slippage"`
    Route        string  `json:"route"`         // routing info (e.g. "meteora_dbc", "damm_v2")
    Fee          uint64  `json:"fee"`
}

// CreateSwapRequest holds parameters for generating a swap transaction.
type CreateSwapRequest struct {
    InputMint   string  `json:"inputMint"`
    OutputMint  string  `json:"outputMint"`
    Amount      uint64  `json:"amount"`
    Slippage    float64 `json:"slippage"`   // basis points or percentage per API spec
}

// CreateSwapResponse contains the unsigned swap transaction.
type CreateSwapResponse struct {
    Transaction string `json:"transaction"` // base64 serialized transaction
}

// SendTransactionRequest wraps a signed transaction for submission.
type SendTransactionRequest struct {
    Transaction string `json:"transaction"` // base64 signed serialized transaction
}

// SendTransactionResponse is returned after transaction submission.
type SendTransactionResponse struct {
    Signature string `json:"signature"` // Solana transaction signature
    Status    string `json:"status"`
}
```

### Step 2: Implement GetTradeQuote

Add to `projects/agent-bags/internal/bags/client.go`:

```go
// GetTradeQuote fetches a swap quote for the given token pair and amount.
// Amount is in the smallest unit (lamports for SOL, base units for SPL tokens).
func (c *Client) GetTradeQuote(ctx context.Context, inputMint, outputMint string, amount uint64, slippage float64) (*TradeQuote, error) {
    path := fmt.Sprintf("/trade/quote?inputMint=%s&outputMint=%s&amount=%d&slippage=%f",
        inputMint, outputMint, amount, slippage)

    resp, err := c.do(ctx, http.MethodGet, path, nil)
    if err != nil {
        return nil, fmt.Errorf("get trade quote: %w", err)
    }
    var quote TradeQuote
    if err := decodeResponse(resp, &quote); err != nil {
        return nil, fmt.Errorf("get trade quote decode: %w", err)
    }
    return &quote, nil
}
```

### Step 3: Implement CreateSwap

```go
// CreateSwap generates an unsigned swap transaction ready for signing.
func (c *Client) CreateSwap(ctx context.Context, req CreateSwapRequest) (*CreateSwapResponse, error) {
    body, err := json.Marshal(req)
    if err != nil {
        return nil, fmt.Errorf("marshaling swap request: %w", err)
    }

    resp, err := c.do(ctx, http.MethodPost, "/swap/create", bytes.NewReader(body))
    if err != nil {
        return nil, fmt.Errorf("create swap: %w", err)
    }
    var result CreateSwapResponse
    if err := decodeResponse(resp, &result); err != nil {
        return nil, fmt.Errorf("create swap decode: %w", err)
    }
    return &result, nil
}
```

### Step 4: Implement SendTransaction

```go
// SendTransaction submits a signed serialized transaction to the Solana network via Bags.
func (c *Client) SendTransaction(ctx context.Context, signedTxBase64 string) (*SendTransactionResponse, error) {
    body := fmt.Sprintf(`{"transaction":"%s"}`, signedTxBase64)
    resp, err := c.do(ctx, http.MethodPost, "/transactions/send", strings.NewReader(body))
    if err != nil {
        return nil, fmt.Errorf("send transaction: %w", err)
    }
    var result SendTransactionResponse
    if err := decodeResponse(resp, &result); err != nil {
        return nil, fmt.Errorf("send transaction decode: %w", err)
    }
    return &result, nil
}
```

### Step 5: Implement transaction signing helper

Create `projects/agent-bags/internal/bags/signer.go`:

```go
package bags

import (
    "crypto/ed25519"
    "encoding/base64"
    "fmt"
)

// Signer handles Solana transaction signing.
type Signer struct {
    privateKey ed25519.PrivateKey
    publicKey  ed25519.PublicKey
}

// NewSigner creates a Signer from a base58-encoded Solana private key.
// Use the key from ExportWalletKey or from SOLANA_PRIVATE_KEY env var.
func NewSigner(privateKeyBytes []byte) (*Signer, error) {
    if len(privateKeyBytes) != ed25519.PrivateKeySize {
        return nil, fmt.Errorf("invalid private key length: got %d, want %d", len(privateKeyBytes), ed25519.PrivateKeySize)
    }
    pk := ed25519.PrivateKey(privateKeyBytes)
    return &Signer{
        privateKey: pk,
        publicKey:  pk.Public().(ed25519.PublicKey),
    }, nil
}

// SignTransaction takes a base64-encoded serialized transaction,
// deserializes it, signs it, and returns the base64-encoded signed transaction.
// The transaction format follows Solana's versioned transaction wire format.
func (s *Signer) SignTransaction(unsignedTxBase64 string) (string, error) {
    txBytes, err := base64.StdEncoding.DecodeString(unsignedTxBase64)
    if err != nil {
        return "", fmt.Errorf("decoding transaction: %w", err)
    }

    // Solana transaction layout: [num_signatures][signatures...][message...]
    // For a pre-serialized tx from Bags, the signature slots are pre-allocated
    // but contain zeros. We need to sign the message portion and insert our signature.
    //
    // The message starts after: 1 byte (num_required_sigs) + (num_required_sigs * 64 bytes)
    if len(txBytes) < 1 {
        return "", fmt.Errorf("transaction too short")
    }
    numSigs := int(txBytes[0])
    messageStart := 1 + (numSigs * 64)
    if len(txBytes) < messageStart {
        return "", fmt.Errorf("transaction too short for %d signatures", numSigs)
    }

    message := txBytes[messageStart:]
    signature := ed25519.Sign(s.privateKey, message)

    // Insert signature at first slot (index 1..65)
    copy(txBytes[1:65], signature)

    return base64.StdEncoding.EncodeToString(txBytes), nil
}

// PublicKeyBytes returns the 32-byte public key.
func (s *Signer) PublicKeyBytes() []byte {
    return []byte(s.publicKey)
}
```

### Step 6: Write tests

Create `projects/agent-bags/internal/bags/trading_test.go`:

1. `TestGetTradeQuote` — mock endpoint, verify query params are correct, parse response
2. `TestCreateSwap` — mock returns base64 tx, verify JSON body sent correctly
3. `TestSendTransaction` — mock accepts signed tx, returns signature
4. `TestGetTradeQuoteHighSlippage` — verify slippage parameter passes through
5. `TestSignTransaction` — create a known unsigned tx, sign, verify signature is valid ed25519

## Done When

- [ ] All requirements met
- [ ] `GetTradeQuote` correctly builds query string and parses quote response
- [ ] `CreateSwap` sends JSON body and returns unsigned transaction
- [ ] `SendTransaction` submits signed transaction and returns Solana signature
- [ ] `Signer.SignTransaction` produces a valid ed25519 signature in the correct tx slot
- [ ] `go test ./internal/bags/...` passes with all trading tests green
