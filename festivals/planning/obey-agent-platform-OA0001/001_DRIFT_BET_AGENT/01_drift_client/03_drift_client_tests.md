---
fest_type: task
fest_id: 03_drift_client_tests.md
fest_name: drift_client_tests
fest_parent: 01_drift_client
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.277708-06:00
fest_tracking: true
---

# Task: Drift BET Client Test Suite

## Objective

Write comprehensive tests for the Drift BET HTTP client and MarketAdapter, including unit tests with a mock HTTP server, integration tests against the real API (skipped by default), and table-driven tests for error handling and edge cases.

## Requirements

- [ ] Mock HTTP server for unit tests (no real API calls)
- [ ] Table-driven tests for all Client methods
- [ ] Error case tests: 404, 429, 503, malformed JSON, context cancellation
- [ ] Cache behavior tests: TTL expiration, cache invalidation
- [ ] Rate limiter tests: requests are throttled correctly
- [ ] MarketAdapter bridge tests: correct normalization from Drift types to adapters.NormalizedMarket
- [ ] Integration test (skipped unless DRIFT_INTEGRATION=1) that hits the real API

## Implementation

### Step 1: Create Test File for HTTP Client

Create file `projects/agent-prediction/internal/adapters/drift/http_client_test.go`:

```go
package drift

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

// newTestServer creates an httptest.Server that responds with the given handler.
func newTestServer(t *testing.T, handler http.HandlerFunc) (*httptest.Server, Client) {
	t.Helper()
	srv := httptest.NewServer(handler)
	t.Cleanup(srv.Close)

	client := NewHTTPClient(HTTPClientConfig{
		BaseURL:     srv.URL,
		DLOBBaseURL: srv.URL,
		HTTPTimeout: 5 * time.Second,
		MaxRetries:  1,
		CacheTTL:    100 * time.Millisecond,
		RateLimit:   100, // high limit for tests
	})
	return srv, client
}

func TestListBETMarkets(t *testing.T) {
	tests := []struct {
		name       string
		response   interface{}
		statusCode int
		wantErr    bool
		wantCount  int
	}{
		{
			name: "success with markets",
			response: []BETMarket{
				{MarketIndex: 0, MarketName: "btc-100k", Title: "BTC > $100K by June?", Status: "active", YesPrice: 0.65, NoPrice: 0.35, Volume24h: 50000},
				{MarketIndex: 1, MarketName: "eth-merge", Title: "ETH staking yield > 5%?", Status: "active", YesPrice: 0.30, NoPrice: 0.70, Volume24h: 20000},
			},
			statusCode: 200,
			wantErr:    false,
			wantCount:  2,
		},
		{
			name:       "empty market list",
			response:   []BETMarket{},
			statusCode: 200,
			wantErr:    false,
			wantCount:  0,
		},
		{
			name:       "server error",
			response:   map[string]string{"error": "internal server error"},
			statusCode: 500,
			wantErr:    true,
		},
		{
			name:       "rate limited",
			response:   map[string]string{"error": "too many requests"},
			statusCode: 429,
			wantErr:    true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, client := newTestServer(t, func(w http.ResponseWriter, r *http.Request) {
				w.WriteHeader(tt.statusCode)
				json.NewEncoder(w).Encode(tt.response)
			})

			markets, err := client.ListBETMarkets(context.Background())
			if (err != nil) != tt.wantErr {
				t.Errorf("ListBETMarkets() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !tt.wantErr && len(markets) != tt.wantCount {
				t.Errorf("ListBETMarkets() got %d markets, want %d", len(markets), tt.wantCount)
			}
		})
	}
}

func TestGetBETMarket(t *testing.T) {
	tests := []struct {
		name        string
		marketIndex int
		response    interface{}
		statusCode  int
		wantErr     bool
	}{
		{
			name:        "success",
			marketIndex: 0,
			response:    BETMarket{MarketIndex: 0, Title: "BTC > $100K?", Status: "active", YesPrice: 0.65},
			statusCode:  200,
			wantErr:     false,
		},
		{
			name:        "not found",
			marketIndex: 999,
			response:    map[string]string{"error": "not found"},
			statusCode:  404,
			wantErr:     true,
		},
		{
			name:        "invalid index",
			marketIndex: -1,
			wantErr:     true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, client := newTestServer(t, func(w http.ResponseWriter, r *http.Request) {
				w.WriteHeader(tt.statusCode)
				if tt.response != nil {
					json.NewEncoder(w).Encode(tt.response)
				}
			})

			market, err := client.GetBETMarket(context.Background(), tt.marketIndex)
			if (err != nil) != tt.wantErr {
				t.Errorf("GetBETMarket() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !tt.wantErr && market.MarketIndex != tt.marketIndex {
				t.Errorf("GetBETMarket() index = %d, want %d", market.MarketIndex, tt.marketIndex)
			}
		})
	}
}

func TestContextCancellation(t *testing.T) {
	_, client := newTestServer(t, func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(5 * time.Second) // simulate slow response
		json.NewEncoder(w).Encode([]BETMarket{})
	})

	ctx, cancel := context.WithCancel(context.Background())
	cancel() // cancel immediately

	_, err := client.ListBETMarkets(ctx)
	if err == nil {
		t.Error("ListBETMarkets() should fail with cancelled context")
	}
}

func TestCacheBehavior(t *testing.T) {
	callCount := 0
	_, client := newTestServer(t, func(w http.ResponseWriter, r *http.Request) {
		callCount++
		json.NewEncoder(w).Encode([]BETMarket{
			{MarketIndex: 0, Title: "Market", Status: "active"},
		})
	})

	ctx := context.Background()

	// First call should hit the server
	_, err := client.ListBETMarkets(ctx)
	if err != nil {
		t.Fatalf("first call failed: %v", err)
	}
	if callCount != 1 {
		t.Fatalf("expected 1 server call, got %d", callCount)
	}

	// Second call should use cache
	_, err = client.ListBETMarkets(ctx)
	if err != nil {
		t.Fatalf("second call failed: %v", err)
	}
	if callCount != 1 {
		t.Fatalf("expected 1 server call (cached), got %d", callCount)
	}

	// Wait for cache to expire
	time.Sleep(150 * time.Millisecond)

	// Third call should hit server again
	_, err = client.ListBETMarkets(ctx)
	if err != nil {
		t.Fatalf("third call failed: %v", err)
	}
	if callCount != 2 {
		t.Fatalf("expected 2 server calls after cache expiry, got %d", callCount)
	}
}
```

### Step 2: Create Test File for Adapter Bridge

Create file `projects/agent-prediction/internal/adapters/drift/drift_test.go`:

```go
package drift

import (
	"context"
	"testing"
)

// mockClient implements Client for testing the Adapter layer.
type mockClient struct {
	markets   []BETMarket
	positions []BETPosition
	orders    []BETOrder
	placeResp *OrderResponse
	err       error
}

func (m *mockClient) ListBETMarkets(ctx context.Context) ([]BETMarket, error) {
	return m.markets, m.err
}

func (m *mockClient) GetBETMarket(ctx context.Context, marketIndex int) (*BETMarket, error) {
	for _, mkt := range m.markets {
		if mkt.MarketIndex == marketIndex {
			return &mkt, nil
		}
	}
	return nil, ErrMarketNotFound
}

func (m *mockClient) GetOrderbook(ctx context.Context, marketIndex int) (*Orderbook, error) {
	return &Orderbook{MarketIndex: marketIndex}, m.err
}

func (m *mockClient) GetPositions(ctx context.Context, userAuthority string) ([]BETPosition, error) {
	return m.positions, m.err
}

func (m *mockClient) PlaceOrder(ctx context.Context, req OrderRequest) (*OrderResponse, error) {
	return m.placeResp, m.err
}

func (m *mockClient) CancelOrder(ctx context.Context, orderID int, marketIndex int) error {
	return m.err
}

func (m *mockClient) GetOpenOrders(ctx context.Context, userAuthority string) ([]BETOrder, error) {
	return m.orders, m.err
}

func TestAdapterListMarkets(t *testing.T) {
	mock := &mockClient{
		markets: []BETMarket{
			{MarketIndex: 0, Title: "BTC > $100K?", Category: "crypto", Status: "active", YesPrice: 0.65, NoPrice: 0.35, Volume24h: 50000, ExpiryTs: 1750000000, ResolutionRules: "Resolves YES if BTC > $100K"},
			{MarketIndex: 1, Title: "Resolved market", Status: "resolved", YesPrice: 1.0, NoPrice: 0.0},
		},
	}
	adapter := NewAdapter(mock, "testuser")

	markets, err := adapter.ListMarkets(context.Background())
	if err != nil {
		t.Fatalf("ListMarkets() error: %v", err)
	}

	// Should filter out resolved markets
	if len(markets) != 1 {
		t.Fatalf("expected 1 active market, got %d", len(markets))
	}

	m := markets[0]
	if m.ID != "drift_bet:0" {
		t.Errorf("expected ID 'drift_bet:0', got %q", m.ID)
	}
	if m.Platform != "drift_bet" {
		t.Errorf("expected platform 'drift_bet', got %q", m.Platform)
	}
	if len(m.Outcomes) != 2 {
		t.Errorf("expected 2 outcomes, got %d", len(m.Outcomes))
	}
	if m.Outcomes[0].Price != 0.65 {
		t.Errorf("expected YES price 0.65, got %f", m.Outcomes[0].Price)
	}
	if m.ResolutionRule == "" {
		t.Error("expected resolution rule to be set")
	}
}

func TestAdapterPositions(t *testing.T) {
	mock := &mockClient{
		positions: []BETPosition{
			{MarketIndex: 0, BaseAssetAmount: 100, EntryPrice: 0.60},   // long YES
			{MarketIndex: 1, BaseAssetAmount: -50, EntryPrice: 0.40},   // long NO (short YES)
		},
	}
	adapter := NewAdapter(mock, "testuser")

	positions, err := adapter.Positions(context.Background())
	if err != nil {
		t.Fatalf("Positions() error: %v", err)
	}
	if len(positions) != 2 {
		t.Fatalf("expected 2 positions, got %d", len(positions))
	}

	// First position: long YES
	if positions[0].OutcomeID != "yes" {
		t.Errorf("expected outcome 'yes', got %q", positions[0].OutcomeID)
	}
	if positions[0].Size != 100 {
		t.Errorf("expected size 100, got %f", positions[0].Size)
	}

	// Second position: long NO (base asset negative)
	if positions[1].OutcomeID != "no" {
		t.Errorf("expected outcome 'no', got %q", positions[1].OutcomeID)
	}
	if positions[1].Size != 50 {
		t.Errorf("expected size 50, got %f", positions[1].Size)
	}
}
```

### Step 3: Create Integration Test

Create file `projects/agent-prediction/internal/adapters/drift/integration_test.go`:

```go
//go:build integration

package drift

import (
	"context"
	"os"
	"testing"
	"time"
)

// Run with: DRIFT_INTEGRATION=1 go test -tags=integration -v ./internal/adapters/drift/

func TestIntegration_ListBETMarkets(t *testing.T) {
	if os.Getenv("DRIFT_INTEGRATION") != "1" {
		t.Skip("set DRIFT_INTEGRATION=1 to run integration tests")
	}

	client := NewHTTPClient(HTTPClientConfig{
		HTTPTimeout: 30 * time.Second,
		MaxRetries:  2,
		RateLimit:   5,
	})

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	markets, err := client.ListBETMarkets(ctx)
	if err != nil {
		t.Fatalf("ListBETMarkets() failed: %v", err)
	}

	t.Logf("Found %d BET markets", len(markets))
	for _, m := range markets {
		t.Logf("  [%d] %s — YES: %.2f, NO: %.2f, Vol: $%.0f",
			m.MarketIndex, m.Title, m.YesPrice, m.NoPrice, m.Volume24h)
	}
}
```

### Step 4: Add Test Recipe to Justfile

Verify the project's `justfile` at `projects/agent-prediction/justfile` includes a test recipe. If not, add:

```just
test:
    go test ./... -v -count=1

test-integration:
    DRIFT_INTEGRATION=1 go test -tags=integration -v ./internal/adapters/drift/
```

## Done When

- [ ] All requirements met
- [ ] `go test ./internal/adapters/drift/...` passes with all unit tests green
- [ ] Table-driven tests cover success, error 404/429/503, malformed JSON, and context cancellation
- [ ] Cache tests verify TTL expiry and reuse
- [ ] Adapter bridge tests verify correct NormalizedMarket transformation
- [ ] Mock client enables testing Adapter without real HTTP calls
- [ ] Integration test exists and runs correctly when DRIFT_INTEGRATION=1 is set
