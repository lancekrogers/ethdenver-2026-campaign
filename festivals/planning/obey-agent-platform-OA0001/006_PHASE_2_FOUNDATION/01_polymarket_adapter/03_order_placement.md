---
fest_type: task
fest_id: 03_order_placement.md
fest_name: order_placement
fest_parent: 01_polymarket_adapter
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.569237-06:00
fest_tracking: true
---

# Task: Polymarket Order Placement & Position Management

## Objective

Implement order creation, cancellation, CTF token split/merge/redeem operations, and the full `MarketAdapter` interface for Polymarket in `projects/agent-prediction/internal/adapters/polymarket/adapter.go`.

## Requirements

- [ ] `PlaceOrder` method: submit limit or market orders (GTC/FOK) to the CLOB
- [ ] Order signing: EIP-712 typed data signing for order messages
- [ ] `CancelOrder` method: cancel open orders by ID
- [ ] `CancelAll` method: cancel all open orders (emergency)
- [ ] `RedeemPosition` method: redeem winning CTF tokens for USDC.e after resolution
- [ ] `GetPositionValue` method: price current CTF positions using order book mid price
- [ ] Implement the full `MarketAdapter` interface from the system architecture
- [ ] Order size validation: respect minimum order size from market config

## Implementation

### Step 1: Define order types

Add to `projects/agent-prediction/internal/adapters/polymarket/orders.go`:

```go
package polymarket

import (
    "context"
    "encoding/json"
    "fmt"
    "math/big"
    "strconv"
    "time"
)

// OrderSide is BUY or SELL.
type OrderSide string

const (
    Buy  OrderSide = "BUY"
    Sell OrderSide = "SELL"
)

// OrderType is GTC (Good Til Cancelled) or FOK (Fill Or Kill).
type TimeInForce string

const (
    GTC TimeInForce = "GTC"
    FOK TimeInForce = "FOK"
)

// OrderRequest represents a new order to place.
type OrderRequest struct {
    TokenID     string      `json:"tokenID"`
    Price       string      `json:"price"`       // decimal 0.01-0.99
    Size        string      `json:"size"`        // number of shares
    Side        OrderSide   `json:"side"`
    TimeInForce TimeInForce `json:"tif"`
    Expiration  int64       `json:"expiration"`  // unix timestamp, 0 = no expiry
    Nonce       int64       `json:"nonce"`
    FeeRateBps  int         `json:"feeRateBps"`  // 0 for makers, up to 200 for takers
}

// SignedOrder is an order with the EIP-712 signature attached.
type SignedOrder struct {
    Order     OrderRequest `json:"order"`
    Signature string       `json:"signature"` // hex-encoded EIP-712 signature
    Owner     string       `json:"owner"`     // signer address
    OrderType string       `json:"orderType"` // "GTC" or "FOK"
}

// OrderResult is returned after successful order placement.
type OrderResult struct {
    OrderID      string `json:"id"`
    Status       string `json:"status"` // "live", "matched", "cancelled"
    TransactedAt string `json:"transactedAt,omitempty"`
}
```

### Step 2: Implement EIP-712 order signing

```go
// signOrder creates an EIP-712 signature for a CLOB order.
// The signed typed data follows the Polymarket order schema:
// Domain: { name: "Polymarket CTF Exchange", version: "1", chainId: 137, verifyingContract: CTF_EXCHANGE_ADDRESS }
// Type: Order { salt, maker, signer, taker, tokenId, makerAmount, takerAmount, expiration, nonce, feeRateBps, side, signatureType }
func (c *CLOBClient) signOrder(order OrderRequest) (string, error) {
    // Convert price and size to maker/taker amounts
    // For BUY: makerAmount = size * price (USDC to spend), takerAmount = size (shares to receive)
    // For SELL: makerAmount = size (shares to sell), takerAmount = size * price (USDC to receive)

    price := new(big.Float)
    price.SetString(order.Price)

    size := new(big.Float)
    size.SetString(order.Size)

    // Scale to contract decimals (USDC = 6 decimals, CTF = 6 decimals)
    scaleFactor := new(big.Float).SetInt64(1_000_000)

    var makerAmount, takerAmount *big.Int
    if order.Side == Buy {
        cost := new(big.Float).Mul(size, price)
        cost.Mul(cost, scaleFactor)
        makerAmount, _ = cost.Int(nil)
        sizeScaled := new(big.Float).Mul(size, scaleFactor)
        takerAmount, _ = sizeScaled.Int(nil)
    } else {
        sizeScaled := new(big.Float).Mul(size, scaleFactor)
        makerAmount, _ = sizeScaled.Int(nil)
        revenue := new(big.Float).Mul(size, price)
        revenue.Mul(revenue, scaleFactor)
        takerAmount, _ = revenue.Int(nil)
    }

    // Build EIP-712 struct hash
    salt := generateSalt()
    sideEnum := 0 // 0 = BUY
    if order.Side == Sell {
        sideEnum = 1
    }

    // Hash and sign using crypto/secp256k1
    digest := buildOrderDigest(
        salt,
        c.publicAddress(),
        c.publicAddress(),
        "0x0000000000000000000000000000000000000000", // taker = anyone
        order.TokenID,
        makerAmount.String(),
        takerAmount.String(),
        order.Expiration,
        order.Nonce,
        order.FeeRateBps,
        sideEnum,
    )

    signature, err := signDigest(c.signer, digest)
    if err != nil {
        return "", fmt.Errorf("signing order: %w", err)
    }
    return "0x" + fmt.Sprintf("%x", signature), nil
}
```

### Step 3: Implement PlaceOrder

```go
// PlaceOrder submits a signed order to the CLOB.
func (c *CLOBClient) PlaceOrder(ctx context.Context, order OrderRequest) (*OrderResult, error) {
    if err := ctx.Err(); err != nil {
        return nil, err
    }

    // Sign the order
    order.Nonce = time.Now().UnixNano()
    signature, err := c.signOrder(order)
    if err != nil {
        return nil, fmt.Errorf("signing order: %w", err)
    }

    signed := SignedOrder{
        Order:     order,
        Signature: signature,
        Owner:     c.publicAddress(),
        OrderType: string(order.TimeInForce),
    }

    body, err := json.Marshal(signed)
    if err != nil {
        return nil, fmt.Errorf("marshaling order: %w", err)
    }

    resp, err := c.do(ctx, "POST", "/order", string(body))
    if err != nil {
        return nil, fmt.Errorf("placing order: %w", err)
    }
    defer resp.Body.Close()

    var result OrderResult
    if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
        return nil, fmt.Errorf("decoding order result: %w", err)
    }
    return &result, nil
}

// CancelOrder cancels an open order by ID.
func (c *CLOBClient) CancelOrder(ctx context.Context, orderID string) error {
    body := fmt.Sprintf(`{"id":"%s"}`, orderID)
    resp, err := c.do(ctx, "DELETE", "/order", body)
    if err != nil {
        return fmt.Errorf("canceling order: %w", err)
    }
    resp.Body.Close()
    return nil
}

// CancelAll cancels all open orders.
func (c *CLOBClient) CancelAll(ctx context.Context) error {
    resp, err := c.do(ctx, "DELETE", "/order/all", "")
    if err != nil {
        return fmt.Errorf("canceling all orders: %w", err)
    }
    resp.Body.Close()
    return nil
}
```

### Step 4: Implement the MarketAdapter interface

Create `projects/agent-prediction/internal/adapters/polymarket/adapter.go`:

```go
// PolymarketAdapter implements the MarketAdapter interface.
type PolymarketAdapter struct {
    clob  *CLOBClient
    gamma *GammaClient
}

func NewPolymarketAdapter(privateKey *ecdsa.PrivateKey) (*PolymarketAdapter, error) {
    clob, err := NewCLOBClient(privateKey)
    if err != nil {
        return nil, err
    }
    return &PolymarketAdapter{
        clob:  clob,
        gamma: NewGammaClient(),
    }, nil
}

func (a *PolymarketAdapter) ListMarkets(ctx context.Context, filters MarketFilters) ([]Market, error) {
    // Use Gamma for metadata, CLOB for prices
    active := true
    gammaMarkets, err := a.gamma.ListMarkets(ctx, GammaListParams{
        Active:   &active,
        Category: filters.Category,
        Limit:    filters.Limit,
    })
    // Convert to platform Market type and enrich with CLOB prices
    // ...
}

func (a *PolymarketAdapter) PlaceOrder(ctx context.Context, order OrderRequest) (*OrderResult, error) {
    return a.clob.PlaceOrder(ctx, order)
}

func (a *PolymarketAdapter) GetPositionValue(ctx context.Context, position Position) (float64, error) {
    book, err := a.clob.GetOrderBook(ctx, position.AssetID)
    if err != nil {
        return 0, err
    }
    // Mid price = (best_bid + best_ask) / 2
    if len(book.Bids) == 0 || len(book.Asks) == 0 {
        return 0, nil
    }
    bid, _ := strconv.ParseFloat(book.Bids[0].Price, 64)
    ask, _ := strconv.ParseFloat(book.Asks[0].Price, 64)
    mid := (bid + ask) / 2.0
    size, _ := strconv.ParseFloat(position.Size, 64)
    return mid * size, nil
}

func (a *PolymarketAdapter) RedeemPosition(ctx context.Context, positionID string) (*RedeemResult, error) {
    // Call CTF contract to redeem winning tokens for USDC.e
    // This is an on-chain Polygon transaction
    // ...
}
```

### Step 5: Write tests

1. `TestPlaceOrderBuy` — mock CLOB, verify order JSON has correct maker/taker amounts
2. `TestPlaceOrderSell` — verify sell-side amount calculation
3. `TestCancelOrder` — mock DELETE, verify order ID passed
4. `TestSignOrder` — verify EIP-712 signature is valid secp256k1
5. `TestGetPositionValue` — mock order book, verify mid price calculation
6. `TestMinimumOrderSize` — verify order below minimum is rejected

## Done When

- [ ] All requirements met
- [ ] Orders are signed with EIP-712 and submitted to CLOB
- [ ] Buy/sell maker/taker amounts are calculated correctly from price and size
- [ ] Cancel and cancel-all work
- [ ] Position valuation uses order book mid price
- [ ] `PolymarketAdapter` satisfies the `MarketAdapter` interface
- [ ] `go test ./internal/adapters/polymarket/...` passes
