---
fest_type: task
fest_id: 04_polymarket_tests.md
fest_name: polymarket_tests
fest_parent: 01_polymarket_adapter
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.569494-06:00
fest_tracking: true
---

# Task: Polymarket Adapter Integration Tests

## Objective

Build a comprehensive integration test suite for the Polymarket adapter that validates the full order lifecycle against a mock CLOB server and optionally against the real Polymarket Mumbai testnet.

## Requirements

- [ ] Mock CLOB server (`httptest.Server`) that simulates order placement, fills, and cancellations
- [ ] Mock Gamma server that returns realistic market data
- [ ] Full lifecycle test: list markets -> analyze -> place order -> check position -> cancel -> verify
- [ ] Order matching simulation: mock server that matches orders against a fake order book
- [ ] WebSocket integration test: connect, subscribe, receive order book update, disconnect
- [ ] Error scenario tests: expired orders, insufficient balance, invalid signatures, rate limiting
- [ ] Optional testnet integration test (skipped by default, run with `-tags=integration`)
- [ ] Benchmark tests for order signing throughput (EIP-712 is the hot path)

## Implementation

### Step 1: Build mock CLOB server

Create `internal/adapters/polymarket/testutil_test.go`:

```go
package polymarket_test

import (
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "sync"
)

// MockCLOBServer simulates the Polymarket CLOB API for testing.
type MockCLOBServer struct {
    server     *httptest.Server
    orders     map[string]*MockOrder
    orderBook  map[string]*MockOrderBook
    mu         sync.Mutex
    orderCount int
}

type MockOrder struct {
    ID        string `json:"id"`
    TokenID   string `json:"tokenID"`
    Price     string `json:"price"`
    Size      string `json:"size"`
    Side      string `json:"side"`
    Status    string `json:"status"` // "live", "matched", "cancelled"
}

type MockOrderBook struct {
    Bids []OrderBookEntry
    Asks []OrderBookEntry
}

func NewMockCLOBServer() *MockCLOBServer {
    mock := &MockCLOBServer{
        orders:    make(map[string]*MockOrder),
        orderBook: make(map[string]*MockOrderBook),
    }

    mux := http.NewServeMux()

    // POST /order — place order
    mux.HandleFunc("POST /order", func(w http.ResponseWriter, r *http.Request) {
        mock.mu.Lock()
        defer mock.mu.Unlock()
        mock.orderCount++
        orderID := fmt.Sprintf("order-%d", mock.orderCount)

        var req SignedOrder
        json.NewDecoder(r.Body).Decode(&req)

        order := &MockOrder{
            ID:      orderID,
            TokenID: req.Order.TokenID,
            Price:   req.Order.Price,
            Size:    req.Order.Size,
            Side:    string(req.Order.Side),
            Status:  "live",
        }
        mock.orders[orderID] = order

        // Simulate matching against order book
        mock.tryMatch(order)

        json.NewEncoder(w).Encode(map[string]string{
            "id":     orderID,
            "status": order.Status,
        })
    })

    // DELETE /order — cancel order
    mux.HandleFunc("DELETE /order", func(w http.ResponseWriter, r *http.Request) {
        mock.mu.Lock()
        defer mock.mu.Unlock()
        var req struct{ ID string `json:"id"` }
        json.NewDecoder(r.Body).Decode(&req)
        if order, ok := mock.orders[req.ID]; ok {
            order.Status = "cancelled"
        }
        w.WriteHeader(http.StatusOK)
    })

    // GET /book — order book
    mux.HandleFunc("GET /book", func(w http.ResponseWriter, r *http.Request) {
        tokenID := r.URL.Query().Get("token_id")
        mock.mu.Lock()
        book := mock.orderBook[tokenID]
        mock.mu.Unlock()
        if book == nil {
            book = &MockOrderBook{
                Bids: []OrderBookEntry{{Price: "0.50", Size: "100"}},
                Asks: []OrderBookEntry{{Price: "0.52", Size: "100"}},
            }
        }
        json.NewEncoder(w).Encode(book)
    })

    // GET /positions
    mux.HandleFunc("GET /positions", func(w http.ResponseWriter, r *http.Request) {
        mock.mu.Lock()
        defer mock.mu.Unlock()
        var positions []Position
        for _, o := range mock.orders {
            if o.Status == "matched" {
                positions = append(positions, Position{
                    AssetID:  o.TokenID,
                    Size:     o.Size,
                    AvgPrice: o.Price,
                    Side:     o.Side,
                })
            }
        }
        json.NewEncoder(w).Encode(positions)
    })

    mock.server = httptest.NewServer(mux)
    return mock
}

func (m *MockCLOBServer) URL() string { return m.server.URL }
func (m *MockCLOBServer) Close()      { m.server.Close() }

// SetOrderBook configures the mock order book for a token.
func (m *MockCLOBServer) SetOrderBook(tokenID string, bids, asks []OrderBookEntry) {
    m.mu.Lock()
    defer m.mu.Unlock()
    m.orderBook[tokenID] = &MockOrderBook{Bids: bids, Asks: asks}
}

func (m *MockCLOBServer) tryMatch(order *MockOrder) {
    // Simple matching: if order price crosses the spread, mark as matched
    book := m.orderBook[order.TokenID]
    if book == nil { return }
    // ... matching logic
}
```

### Step 2: Full lifecycle integration test

Create `internal/adapters/polymarket/integration_test.go`:

```go
func TestFullOrderLifecycle(t *testing.T) {
    mock := NewMockCLOBServer()
    defer mock.Close()
    mockGamma := NewMockGammaServer()
    defer mockGamma.Close()

    // Create adapter pointing to mock servers
    adapter := newTestAdapter(t, mock.URL(), mockGamma.URL())

    ctx := context.Background()

    // Step 1: List markets
    markets, err := adapter.ListMarkets(ctx, MarketFilters{Active: true})
    require.NoError(t, err)
    require.NotEmpty(t, markets)

    // Step 2: Get order book for first market
    market := markets[0]
    book, err := adapter.clob.GetOrderBook(ctx, market.Tokens[0].TokenID)
    require.NoError(t, err)
    require.NotEmpty(t, book.Bids)

    // Step 3: Place a buy order
    result, err := adapter.PlaceOrder(ctx, OrderRequest{
        TokenID:     market.Tokens[0].TokenID,
        Price:       "0.55",
        Size:        "10",
        Side:        Buy,
        TimeInForce: GTC,
    })
    require.NoError(t, err)
    require.NotEmpty(t, result.OrderID)

    // Step 4: Check positions
    positions, err := adapter.clob.GetPositions(ctx)
    require.NoError(t, err)

    // Step 5: Cancel order
    err = adapter.clob.CancelOrder(ctx, result.OrderID)
    require.NoError(t, err)
}
```

### Step 3: Error scenario tests

```go
func TestOrderExpired(t *testing.T) {
    // Place order with expiration in the past
    // Expect rejection
}

func TestInvalidSignature(t *testing.T) {
    // Tamper with signature after signing
    // Expect authentication error
}

func TestRateLimitExceeded(t *testing.T) {
    // Send requests exceeding rate limit
    // Verify 429 response handling
}

func TestOrderBelowMinimumSize(t *testing.T) {
    // Place order with size below market minimum
    // Expect validation error
}

func TestNetworkTimeout(t *testing.T) {
    // Use slow mock server
    // Verify context timeout triggers clean abort
}
```

### Step 4: Benchmark tests

```go
func BenchmarkEIP712OrderSigning(b *testing.B) {
    key := generateTestKey()
    client, _ := NewCLOBClient(key)
    order := OrderRequest{
        TokenID: "test-token",
        Price:   "0.55",
        Size:    "10",
        Side:    Buy,
    }

    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        _, err := client.signOrder(order)
        if err != nil {
            b.Fatal(err)
        }
    }
}

func BenchmarkHMACRequestSigning(b *testing.B) {
    // Benchmark HMAC-SHA256 request signing throughput
}
```

### Step 5: Optional testnet integration (build tag gated)

```go
//go:build integration

func TestPolymarketTestnet(t *testing.T) {
    // Only runs with: go test -tags=integration
    // Requires POLYMARKET_TESTNET_KEY env var

    key := loadTestnetKey(t)
    adapter, err := NewPolymarketAdapter(key)
    require.NoError(t, err)

    ctx := context.Background()

    // Derive API credentials
    creds, err := adapter.clob.CreateAPICredentials(ctx)
    require.NoError(t, err)
    t.Logf("API Key: %s", creds.APIKey)

    // List real markets
    markets, err := adapter.ListMarkets(ctx, MarketFilters{Limit: 5})
    require.NoError(t, err)
    require.NotEmpty(t, markets)
    t.Logf("Found %d markets", len(markets))
}
```

## Done When

- [ ] All requirements met
- [ ] Mock CLOB server supports order placement, cancellation, order book queries, and position retrieval
- [ ] Full lifecycle test passes: list -> analyze -> place -> position -> cancel
- [ ] Error scenarios covered: expired, bad signature, rate limit, minimum size, timeout
- [ ] Benchmark for EIP-712 signing shows throughput is adequate (>1000 signs/sec)
- [ ] Testnet integration test exists (build-tag gated)
- [ ] `go test ./internal/adapters/polymarket/...` passes (mock tests only, not integration)
