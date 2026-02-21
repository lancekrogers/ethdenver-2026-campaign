---
fest_type: task
fest_id: 04_implement_x402.md
fest_name: implement_x402
fest_parent: 02_defi_base
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement x402 Payment Protocol

## Objective

Implement the `PaymentProtocol` interface to enable machine-to-machine payments using the x402 protocol on Base. The x402 protocol extends HTTP with a 402 Payment Required flow, allowing agents to pay for services and receive payment for work without human intervention. This capability is essential for the autonomous economy model and the Base self-sustaining agent bounty.

**Project:** `agent-defi` at `projects/agent-defi/`
**Package:** `internal/base/payment/`

## Requirements

- [ ] Implement the `PaymentProtocol` interface defined in the architecture task
- [ ] Support sending payments to other agents or services
- [ ] Support creating invoices (payment requests) for services rendered
- [ ] Support verifying that payments were received
- [ ] Implement the HTTP 402 payment handshake flow
- [ ] Handle all errors with contextual wrapping
- [ ] Pass `context.Context` through all I/O operations

## Implementation

### Step 1: Research x402 protocol

Before writing code, research the x402 payment protocol:

1. Read the x402 specification from Coinbase/Base documentation
2. Understand the HTTP 402 flow:
   - Client requests a resource
   - Server responds with 402 Payment Required and a payment envelope
   - Client makes the on-chain payment
   - Client re-requests the resource with proof of payment
   - Server validates payment and serves the resource
3. Identify the payment envelope format (what fields are required)
4. Determine which tokens are supported (ETH, USDC on Base)
5. Check for existing Go implementations or reference clients

Document findings in comments at the top of `x402.go`.

### Step 2: Define the model types

In `internal/base/payment/models.go`:

```go
package payment

import (
    "math/big"
    "time"
)

// PaymentRequest represents a request to make a payment.
type PaymentRequest struct {
    // RecipientAddress is the on-chain address to pay.
    RecipientAddress string

    // Amount is the payment amount in the smallest unit (wei for ETH, 6 decimals for USDC).
    Amount *big.Int

    // Token is the token to pay with ("ETH" or token contract address).
    Token string

    // InvoiceID links this payment to a specific invoice.
    InvoiceID string

    // Memo is an optional message attached to the payment.
    Memo string

    // Deadline is the latest time this payment can be made.
    Deadline time.Time
}

// Invoice is a payment request created by a service provider.
type Invoice struct {
    // InvoiceID is the unique identifier for this invoice.
    InvoiceID string

    // ServiceDescription describes what the payment is for.
    ServiceDescription string

    // Amount is the requested payment amount.
    Amount *big.Int

    // Token is the requested payment token.
    Token string

    // RecipientAddress is where payment should be sent.
    RecipientAddress string

    // ExpiresAt is when this invoice expires.
    ExpiresAt time.Time

    // PaymentEndpoint is the URL to submit proof of payment.
    PaymentEndpoint string
}

// Receipt confirms a completed payment.
type Receipt struct {
    // ReceiptID is the unique identifier for this receipt.
    ReceiptID string

    // InvoiceID links back to the original invoice.
    InvoiceID string

    // TxHash is the on-chain transaction hash.
    TxHash string

    // Amount is the amount paid.
    Amount *big.Int

    // Token is the token used for payment.
    Token string

    // PaidAt is when the payment was confirmed.
    PaidAt time.Time

    // GasCost is the gas spent on this transaction (tracked for P&L).
    GasCost *big.Int

    // BlockNumber is the block where the payment was included.
    BlockNumber uint64
}

// PaymentEnvelope is the x402 protocol response envelope
// returned with HTTP 402 responses.
type PaymentEnvelope struct {
    // Version is the x402 protocol version.
    Version string `json:"version"`

    // Network is the blockchain network (e.g., "base", "base-sepolia").
    Network string `json:"network"`

    // RecipientAddress is where to send payment.
    RecipientAddress string `json:"recipient"`

    // Amount is the required payment in smallest unit.
    Amount string `json:"amount"`

    // Token is the payment token address or "ETH".
    Token string `json:"token"`

    // PayloadHash is the hash of the resource being paid for.
    PayloadHash string `json:"payload_hash"`

    // Expiry is when this payment envelope expires.
    Expiry int64 `json:"expiry"`
}
```

### Step 3: Implement the payment protocol

In `internal/base/payment/x402.go`:

```go
package payment

// ProtocolConfig holds configuration for the x402 payment protocol.
type ProtocolConfig struct {
    // ChainRPC is the Base chain RPC endpoint.
    ChainRPC string

    // ChainID is the Base chain network identifier.
    ChainID int64

    // PrivateKey is the agent's private key for signing payments.
    PrivateKey string

    // DefaultToken is the default token for payments (e.g., USDC address).
    DefaultToken string

    // MaxGasPrice is the maximum gas price the agent will pay (safety limit).
    MaxGasPrice *big.Int
}
```

Key implementation details:

**Pay(ctx, req)**:

1. Check `ctx.Err()` before starting
2. Determine if payment is native ETH or an ERC-20 token
3. For ETH: Build a standard value transfer transaction
4. For ERC-20 (e.g., USDC): Build a `transfer(to, amount)` contract call
5. Estimate gas and check against MaxGasPrice safety limit
6. Sign the transaction
7. Submit to Base
8. Wait for receipt
9. Return a Receipt with the transaction hash, gas cost, and block number
10. Track the gas cost for P&L reporting

**RequestPayment(ctx, invoice)**:

1. Generate an invoice ID
2. Create the x402 PaymentEnvelope with the invoice details
3. The agent exposes this envelope when another agent requests a paid service
4. Return the PaymentRequest that the payer needs to fulfill

**VerifyPayment(ctx, receiptID)**:

1. Look up the transaction by hash
2. Verify the transfer event matches the expected amount and recipient
3. Confirm the transaction is finalized (sufficient block confirmations)
4. Return true if payment is valid

### Step 4: Implement the HTTP 402 handshake

The x402 flow requires HTTP handling. Implement helpers for both sides:

**As a payer (handling 402 responses):**

```go
// HandlePaymentRequired processes an HTTP 402 response,
// extracts the payment envelope, makes the payment, and
// retries the request with proof of payment.
func (p *protocol) HandlePaymentRequired(ctx context.Context, resp *http.Response) (*http.Response, error) {
    // 1. Parse the PaymentEnvelope from the 402 response body
    // 2. Validate the envelope (amount, expiry, network)
    // 3. Make the on-chain payment using Pay()
    // 4. Construct a new request with the payment proof header
    //    (e.g., X-Payment-Proof: <tx_hash>)
    // 5. Retry the original request
    // 6. Return the successful response
}
```

**As a payee (creating 402 responses):**

```go
// CreatePaymentRequiredResponse builds an HTTP 402 response
// with the payment envelope for the requested resource.
func (p *protocol) CreatePaymentRequiredResponse(invoice Invoice) *http.Response {
    // Build the PaymentEnvelope and return as 402 response body
}
```

### Step 5: Define sentinel errors

```go
var (
    ErrPaymentFailed     = errors.New("payment: on-chain payment failed")
    ErrInvoiceExpired    = errors.New("payment: invoice has expired")
    ErrInsufficientFunds = errors.New("payment: insufficient funds for payment")
    ErrGasTooHigh        = errors.New("payment: gas price exceeds safety limit")
    ErrInvalidProof      = errors.New("payment: payment proof is invalid")
    ErrChainUnreachable  = errors.New("payment: Base chain RPC unreachable")
)
```

### Step 6: Write unit tests

Create `internal/base/payment/x402_test.go`:

1. **TestPay_ETH_Success**: Mock ETH transfer, verify receipt with gas cost
2. **TestPay_ERC20_Success**: Mock USDC transfer, verify receipt
3. **TestPay_InsufficientFunds**: Mock low balance, verify ErrInsufficientFunds
4. **TestPay_GasTooHigh**: Set low MaxGasPrice, verify ErrGasTooHigh safety
5. **TestPay_ContextCancelled**: Cancel during transaction wait, verify clean exit
6. **TestRequestPayment_Success**: Create invoice, verify PaymentRequest generated
7. **TestVerifyPayment_Valid**: Mock confirmed transaction, verify returns true
8. **TestVerifyPayment_Invalid**: Mock wrong amount, verify returns false
9. **TestHandlePaymentRequired_FullFlow**: Mock 402 response, verify payment and retry
10. **TestPay_TracksGasCost**: Verify gas cost is included in receipt for P&L

### Step 7: Verify compilation and tests

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
go build ./internal/base/payment/...
go test ./internal/base/payment/... -v
go vet ./internal/base/payment/...
```

## Done When

- [ ] `PaymentProtocol` interface fully implemented in `internal/base/payment/x402.go`
- [ ] All model types defined in `internal/base/payment/models.go`
- [ ] ETH and ERC-20 token payments supported
- [ ] x402 HTTP 402 handshake flow implemented (both payer and payee sides)
- [ ] Gas cost tracking integrated into receipts for P&L reporting
- [ ] MaxGasPrice safety limit prevents overpaying for gas
- [ ] Sentinel errors defined for all failure modes
- [ ] Table-driven unit tests cover payment, verification, 402 flow, and error cases
- [ ] `go build`, `go test`, and `go vet` all pass cleanly
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
- [ ] x402 protocol research findings documented in code comments
