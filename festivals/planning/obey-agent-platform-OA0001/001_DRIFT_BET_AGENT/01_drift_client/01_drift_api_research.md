---
fest_type: task
fest_id: 01_drift_api_research.md
fest_name: drift_api_research
fest_parent: 01_drift_client
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.276776-06:00
fest_tracking: true
---

# Task: Drift BET API Research and Interface Definition

## Objective

Research the Drift BET (prediction market) API surface, document all endpoints needed for market listing, order placement, position tracking, and settlement, and define the Go types and interface contract that the HTTP client will implement.

## Requirements

- [ ] Document all Drift BET REST API endpoints for prediction markets (list markets, get market, place order, get positions, get orderbook)
- [ ] Document Drift BET market data model (market structure, outcome representation, pricing model)
- [ ] Identify authentication mechanism (Solana wallet signing for orders vs. public endpoints for reads)
- [ ] Define Go struct types for Drift BET API request/response payloads
- [ ] Define the `DriftClient` interface in `internal/adapters/drift/client.go`
- [ ] Document rate limits, error codes, and retry strategy

## Implementation

### Step 1: Research Drift BET API

Drift Protocol provides a REST API gateway for their prediction market (BET) product. The primary API surface is:

**Base URLs:**
- Mainnet: `https://drift-historical-data-v2.s3.eu-west-1.amazonaws.com/` (historical)
- API Gateway: `https://dlob.drift.trade` (orderbook/DLOB)
- Market data: `https://mainnet-beta.api.drift.trade` (general API)

**Key Endpoints to Document:**

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/markets/prediction` | GET | List all BET prediction markets |
| `/markets/prediction/{marketIndex}` | GET | Get specific BET market details |
| `/orders?marketType=prediction` | GET | Get open orders for a user |
| `/positions?marketType=prediction` | GET | Get user's prediction market positions |
| `/dlob/bids?marketIndex={idx}&marketType=prediction` | GET | Get bids for a BET market |
| `/dlob/asks?marketIndex={idx}&marketType=prediction` | GET | Get asks for a BET market |

Create a research document at `projects/agent-prediction/docs/drift-bet-api.md` with full details.

### Step 2: Define Go Types

Create file `projects/agent-prediction/internal/adapters/drift/types.go`:

```go
package drift

import "time"

// BETMarket represents a Drift BET prediction market from the API.
type BETMarket struct {
	MarketIndex       int     `json:"marketIndex"`
	MarketName        string  `json:"marketName"`
	Category          string  `json:"category"`
	Title             string  `json:"title"`
	Description       string  `json:"description"`
	ResolutionRules   string  `json:"resolutionRules"`
	ExpiryTs          int64   `json:"expiryTs"`
	ResolutionTs      *int64  `json:"resolutionTs,omitempty"`
	Status            string  `json:"status"` // "active", "resolved", "cancelled"
	YesPrice          float64 `json:"yesPrice"`
	NoPrice           float64 `json:"noPrice"`
	Volume24h         float64 `json:"volume24h"`
	TotalVolume       float64 `json:"totalVolume"`
	Liquidity         float64 `json:"liquidity"`
	OracleSource      string  `json:"oracleSource"`
	ResolvedOutcome   *string `json:"resolvedOutcome,omitempty"` // "yes" or "no"
}

// BETPosition represents a user's position in a BET market.
type BETPosition struct {
	MarketIndex   int     `json:"marketIndex"`
	MarketName    string  `json:"marketName"`
	BaseAssetAmount float64 `json:"baseAssetAmount"` // positive = long YES, negative = long NO
	QuoteAssetAmount float64 `json:"quoteAssetAmount"`
	EntryPrice    float64 `json:"entryPrice"`
	UnrealizedPnl float64 `json:"unrealizedPnl"`
	SettledPnl    float64 `json:"settledPnl"`
}

// BETOrder represents an order on a BET market.
type BETOrder struct {
	OrderID       int     `json:"orderId"`
	MarketIndex   int     `json:"marketIndex"`
	MarketType    string  `json:"marketType"`
	Direction     string  `json:"direction"` // "long" (YES) or "short" (NO)
	Price         float64 `json:"price"`     // 0.00 - 1.00
	BaseAssetAmount float64 `json:"baseAssetAmount"`
	Status        string  `json:"status"`
	OrderType     string  `json:"orderType"` // "limit", "market"
	Slot          uint64  `json:"slot"`
}

// OrderRequest is the payload for placing a BET market order.
type OrderRequest struct {
	MarketIndex   int     `json:"marketIndex"`
	Direction     string  `json:"direction"` // "long" or "short"
	Price         float64 `json:"price"`     // limit price 0.01-0.99
	Amount        float64 `json:"amount"`    // in USDC
	OrderType     string  `json:"orderType"` // "limit" or "market"
}

// OrderResponse is returned after placing an order.
type OrderResponse struct {
	TxSignature string `json:"txSignature"`
	OrderID     int    `json:"orderId"`
	Slot        uint64 `json:"slot"`
}

// DLOBEntry represents a single level in the orderbook.
type DLOBEntry struct {
	Price  float64 `json:"price"`
	Size   float64 `json:"size"`
	Source string  `json:"source"`
}

// Orderbook represents the bids and asks for a BET market.
type Orderbook struct {
	MarketIndex int         `json:"marketIndex"`
	Bids        []DLOBEntry `json:"bids"`
	Asks        []DLOBEntry `json:"asks"`
	Slot        uint64      `json:"slot"`
	FetchedAt   time.Time   `json:"fetchedAt"`
}
```

### Step 3: Define DriftClient Interface

Create file `projects/agent-prediction/internal/adapters/drift/client.go`:

```go
package drift

import "context"

// Client defines the interface for interacting with Drift BET prediction markets.
// Read-only endpoints (list, get, positions) use public REST APIs.
// Write endpoints (place order, cancel) require Solana wallet signing via the Drift SDK gateway.
type Client interface {
	// ListBETMarkets returns all active BET prediction markets.
	ListBETMarkets(ctx context.Context) ([]BETMarket, error)

	// GetBETMarket returns details for a specific BET market by index.
	GetBETMarket(ctx context.Context, marketIndex int) (*BETMarket, error)

	// GetOrderbook returns the current orderbook (DLOB) for a BET market.
	GetOrderbook(ctx context.Context, marketIndex int) (*Orderbook, error)

	// GetPositions returns the user's open BET positions.
	GetPositions(ctx context.Context, userAuthority string) ([]BETPosition, error)

	// PlaceOrder submits a BET market order. Requires wallet signing.
	PlaceOrder(ctx context.Context, req OrderRequest) (*OrderResponse, error)

	// CancelOrder cancels an open order by ID. Requires wallet signing.
	CancelOrder(ctx context.Context, orderID int, marketIndex int) error

	// GetOpenOrders returns the user's open orders for BET markets.
	GetOpenOrders(ctx context.Context, userAuthority string) ([]BETOrder, error)
}
```

### Step 4: Define Error Types

Add to `projects/agent-prediction/internal/adapters/drift/types.go`:

```go
import "errors"

// Sentinel errors for Drift BET client operations.
var (
	ErrMarketNotFound     = errors.New("drift: market not found")
	ErrInsufficientFunds  = errors.New("drift: insufficient funds")
	ErrOrderRejected      = errors.New("drift: order rejected")
	ErrRateLimited        = errors.New("drift: rate limited")
	ErrAPIUnavailable     = errors.New("drift: API unavailable")
	ErrInvalidMarketIndex = errors.New("drift: invalid market index")
	ErrSigningFailed      = errors.New("drift: transaction signing failed")
)
```

### Step 5: Document Findings

Create `projects/agent-prediction/docs/drift-bet-api.md` with:
- Full endpoint documentation with example responses
- Authentication details: public reads (no auth), writes require Solana keypair + Drift SDK transaction building
- Rate limits: document observed limits
- Drift BET market mechanics: perp-style binary outcomes, USDC collateral, Pyth oracle resolution
- Note: For MVP, order placement will go through Drift's gateway API that accepts signed Solana transactions. The agent builds the transaction using `gagliardetto/solana-go` and submits it.

## Done When

- [ ] All requirements met
- [ ] `internal/adapters/drift/types.go` compiles with all Drift BET API types
- [ ] `internal/adapters/drift/client.go` compiles with the `Client` interface
- [ ] `docs/drift-bet-api.md` documents all endpoints, auth, rate limits, and market mechanics
- [ ] The interface covers all operations needed by the MarketAdapter (list, trade, positions, settle)
