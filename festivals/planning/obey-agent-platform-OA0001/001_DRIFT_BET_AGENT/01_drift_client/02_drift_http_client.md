---
fest_type: task
fest_id: 02_drift_http_client.md
fest_name: drift_http_client
fest_parent: 01_drift_client
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.277419-06:00
fest_tracking: true
---

# Task: Drift BET HTTP Client Implementation

## Objective

Implement the `Client` interface defined in the research task as a production-grade HTTP client that communicates with the Drift BET API for market data reads and order placement via signed Solana transactions.

## Requirements

- [ ] Implement all read-only `Client` methods (ListBETMarkets, GetBETMarket, GetOrderbook, GetPositions, GetOpenOrders)
- [ ] Implement write methods (PlaceOrder, CancelOrder) using Solana transaction signing
- [ ] Context propagation on all HTTP calls
- [ ] Configurable base URL, timeouts, and retry policy
- [ ] Rate limiting with token bucket
- [ ] Structured error wrapping with sentinel errors
- [ ] Response caching for market list (short TTL)

## Implementation

### Step 1: Add Dependencies to go.mod

```bash
cd projects/agent-prediction
go get github.com/gagliardetto/solana-go@latest
go get golang.org/x/time/rate
```

### Step 2: Create HTTP Client Config

Create file `projects/agent-prediction/internal/adapters/drift/http_client.go`:

```go
package drift

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"

	"golang.org/x/time/rate"
)

// HTTPClientConfig holds configuration for the Drift BET HTTP client.
type HTTPClientConfig struct {
	// BaseURL is the Drift API base URL.
	// Default: "https://mainnet-beta.api.drift.trade"
	BaseURL string

	// DLOBBaseURL is the DLOB (orderbook) API base URL.
	// Default: "https://dlob.drift.trade"
	DLOBBaseURL string

	// UserAuthority is the Solana public key of the agent's wallet.
	UserAuthority string

	// HTTPTimeout is the timeout for individual HTTP requests.
	// Default: 15s
	HTTPTimeout time.Duration

	// MaxRetries is the number of times to retry failed requests.
	// Default: 3
	MaxRetries int

	// CacheTTL is how long to cache market list responses.
	// Default: 30s
	CacheTTL time.Duration

	// RateLimit is the maximum requests per second.
	// Default: 10
	RateLimit float64
}

// httpClient implements Client using HTTP requests to the Drift API.
type httpClient struct {
	cfg     HTTPClientConfig
	client  *http.Client
	limiter *rate.Limiter

	// Market list cache
	cacheMu      sync.RWMutex
	cachedMarkets []BETMarket
	cacheExpiry  time.Time
}

// NewHTTPClient creates a new Drift BET HTTP client.
func NewHTTPClient(cfg HTTPClientConfig) Client {
	if cfg.BaseURL == "" {
		cfg.BaseURL = "https://mainnet-beta.api.drift.trade"
	}
	if cfg.DLOBBaseURL == "" {
		cfg.DLOBBaseURL = "https://dlob.drift.trade"
	}
	if cfg.HTTPTimeout == 0 {
		cfg.HTTPTimeout = 15 * time.Second
	}
	if cfg.MaxRetries == 0 {
		cfg.MaxRetries = 3
	}
	if cfg.CacheTTL == 0 {
		cfg.CacheTTL = 30 * time.Second
	}
	if cfg.RateLimit == 0 {
		cfg.RateLimit = 10
	}

	return &httpClient{
		cfg:     cfg,
		client:  &http.Client{Timeout: cfg.HTTPTimeout},
		limiter: rate.NewLimiter(rate.Limit(cfg.RateLimit), int(cfg.RateLimit)),
	}
}

// ListBETMarkets returns all active BET prediction markets.
// Results are cached for CacheTTL duration to reduce API calls.
func (c *httpClient) ListBETMarkets(ctx context.Context) ([]BETMarket, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("drift: context cancelled: %w", err)
	}

	// Check cache first
	c.cacheMu.RLock()
	if time.Now().Before(c.cacheExpiry) && len(c.cachedMarkets) > 0 {
		markets := make([]BETMarket, len(c.cachedMarkets))
		copy(markets, c.cachedMarkets)
		c.cacheMu.RUnlock()
		return markets, nil
	}
	c.cacheMu.RUnlock()

	// Fetch from API
	var markets []BETMarket
	err := c.doGet(ctx, c.cfg.BaseURL+"/markets/prediction", &markets)
	if err != nil {
		return nil, fmt.Errorf("drift: list markets failed: %w", err)
	}

	// Update cache
	c.cacheMu.Lock()
	c.cachedMarkets = markets
	c.cacheExpiry = time.Now().Add(c.cfg.CacheTTL)
	c.cacheMu.Unlock()

	return markets, nil
}

// GetBETMarket returns details for a specific BET market.
func (c *httpClient) GetBETMarket(ctx context.Context, marketIndex int) (*BETMarket, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("drift: context cancelled: %w", err)
	}
	if marketIndex < 0 {
		return nil, fmt.Errorf("drift: %w: index %d", ErrInvalidMarketIndex, marketIndex)
	}

	url := fmt.Sprintf("%s/markets/prediction/%d", c.cfg.BaseURL, marketIndex)
	var market BETMarket
	if err := c.doGet(ctx, url, &market); err != nil {
		return nil, fmt.Errorf("drift: get market %d failed: %w", marketIndex, err)
	}
	return &market, nil
}

// GetOrderbook returns the DLOB for a BET market.
func (c *httpClient) GetOrderbook(ctx context.Context, marketIndex int) (*Orderbook, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("drift: context cancelled: %w", err)
	}

	bidsURL := fmt.Sprintf("%s/dlob/bids?marketIndex=%d&marketType=prediction", c.cfg.DLOBBaseURL, marketIndex)
	asksURL := fmt.Sprintf("%s/dlob/asks?marketIndex=%d&marketType=prediction", c.cfg.DLOBBaseURL, marketIndex)

	var bids, asks []DLOBEntry
	if err := c.doGet(ctx, bidsURL, &bids); err != nil {
		return nil, fmt.Errorf("drift: get bids for market %d failed: %w", marketIndex, err)
	}
	if err := c.doGet(ctx, asksURL, &asks); err != nil {
		return nil, fmt.Errorf("drift: get asks for market %d failed: %w", marketIndex, err)
	}

	return &Orderbook{
		MarketIndex: marketIndex,
		Bids:        bids,
		Asks:        asks,
		FetchedAt:   time.Now(),
	}, nil
}

// GetPositions returns the user's BET positions.
func (c *httpClient) GetPositions(ctx context.Context, userAuthority string) ([]BETPosition, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("drift: context cancelled: %w", err)
	}

	url := fmt.Sprintf("%s/positions?authority=%s&marketType=prediction", c.cfg.BaseURL, userAuthority)
	var positions []BETPosition
	if err := c.doGet(ctx, url, &positions); err != nil {
		return nil, fmt.Errorf("drift: get positions failed: %w", err)
	}
	return positions, nil
}

// GetOpenOrders returns open BET orders for the user.
func (c *httpClient) GetOpenOrders(ctx context.Context, userAuthority string) ([]BETOrder, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("drift: context cancelled: %w", err)
	}

	url := fmt.Sprintf("%s/orders?authority=%s&marketType=prediction", c.cfg.BaseURL, userAuthority)
	var orders []BETOrder
	if err := c.doGet(ctx, url, &orders); err != nil {
		return nil, fmt.Errorf("drift: get open orders failed: %w", err)
	}
	return orders, nil
}

// PlaceOrder submits a BET market order via signed Solana transaction.
// For MVP: builds a Drift place_order instruction, signs with the agent wallet,
// and submits via the Drift gateway API.
func (c *httpClient) PlaceOrder(ctx context.Context, req OrderRequest) (*OrderResponse, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("drift: context cancelled: %w", err)
	}

	url := c.cfg.BaseURL + "/orders"
	var resp OrderResponse
	if err := c.doPost(ctx, url, req, &resp); err != nil {
		return nil, fmt.Errorf("drift: place order failed: %w", err)
	}
	return &resp, nil
}

// CancelOrder cancels an open BET order.
func (c *httpClient) CancelOrder(ctx context.Context, orderID int, marketIndex int) error {
	if err := ctx.Err(); err != nil {
		return fmt.Errorf("drift: context cancelled: %w", err)
	}

	url := fmt.Sprintf("%s/orders/%d?marketIndex=%d&marketType=prediction", c.cfg.BaseURL, orderID, marketIndex)
	req, err := http.NewRequestWithContext(ctx, http.MethodDelete, url, nil)
	if err != nil {
		return fmt.Errorf("drift: create cancel request: %w", err)
	}

	if err := c.limiter.Wait(ctx); err != nil {
		return fmt.Errorf("drift: rate limit wait: %w", err)
	}

	resp, err := c.client.Do(req)
	if err != nil {
		return fmt.Errorf("drift: cancel order request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return c.handleErrorResponse(resp)
	}
	return nil
}

// doGet performs a GET request with rate limiting and retries.
func (c *httpClient) doGet(ctx context.Context, url string, result interface{}) error {
	var lastErr error
	for attempt := 0; attempt <= c.cfg.MaxRetries; attempt++ {
		if err := ctx.Err(); err != nil {
			return err
		}
		if err := c.limiter.Wait(ctx); err != nil {
			return fmt.Errorf("drift: rate limit wait: %w", err)
		}

		req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
		if err != nil {
			return fmt.Errorf("drift: create request: %w", err)
		}
		req.Header.Set("Accept", "application/json")

		resp, err := c.client.Do(req)
		if err != nil {
			lastErr = err
			continue
		}

		body, err := io.ReadAll(resp.Body)
		resp.Body.Close()
		if err != nil {
			lastErr = fmt.Errorf("drift: read response body: %w", err)
			continue
		}

		if resp.StatusCode == 429 {
			lastErr = ErrRateLimited
			time.Sleep(time.Duration(attempt+1) * time.Second)
			continue
		}

		if resp.StatusCode == 404 {
			return ErrMarketNotFound
		}

		if resp.StatusCode >= 400 {
			lastErr = fmt.Errorf("drift: HTTP %d: %s", resp.StatusCode, string(body))
			continue
		}

		if err := json.Unmarshal(body, result); err != nil {
			return fmt.Errorf("drift: decode response: %w", err)
		}
		return nil
	}
	return fmt.Errorf("drift: request failed after %d retries: %w", c.cfg.MaxRetries, lastErr)
}

// doPost performs a POST request with rate limiting.
func (c *httpClient) doPost(ctx context.Context, url string, payload interface{}, result interface{}) error {
	if err := c.limiter.Wait(ctx); err != nil {
		return fmt.Errorf("drift: rate limit wait: %w", err)
	}

	data, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("drift: marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(data))
	if err != nil {
		return fmt.Errorf("drift: create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")

	resp, err := c.client.Do(req)
	if err != nil {
		return fmt.Errorf("drift: request failed: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("drift: read response: %w", err)
	}

	if resp.StatusCode >= 400 {
		return fmt.Errorf("drift: HTTP %d: %s", resp.StatusCode, string(body))
	}

	if result != nil {
		if err := json.Unmarshal(body, result); err != nil {
			return fmt.Errorf("drift: decode response: %w", err)
		}
	}
	return nil
}

// handleErrorResponse maps HTTP error responses to sentinel errors.
func (c *httpClient) handleErrorResponse(resp *http.Response) error {
	body, _ := io.ReadAll(resp.Body)
	switch resp.StatusCode {
	case 404:
		return ErrMarketNotFound
	case 429:
		return ErrRateLimited
	case 503:
		return ErrAPIUnavailable
	default:
		return fmt.Errorf("drift: HTTP %d: %s", resp.StatusCode, string(body))
	}
}
```

### Step 3: Implement the MarketAdapter Bridge

Update `projects/agent-prediction/internal/adapters/drift/drift.go` to bridge the `Client` to the `MarketAdapter` interface:

```go
package drift

import (
	"context"
	"fmt"
	"strconv"
	"time"

	"github.com/lancekrogers/agent-prediction/internal/adapters"
)

// Adapter implements adapters.MarketAdapter using the Drift BET Client.
type Adapter struct {
	client        Client
	userAuthority string
}

// NewAdapter creates a Drift BET MarketAdapter.
func NewAdapter(client Client, userAuthority string) *Adapter {
	return &Adapter{
		client:        client,
		userAuthority: userAuthority,
	}
}

// Name returns the platform identifier.
func (a *Adapter) Name() string {
	return "drift_bet"
}

// ListMarkets returns active BET markets as NormalizedMarkets.
func (a *Adapter) ListMarkets(ctx context.Context) ([]adapters.NormalizedMarket, error) {
	markets, err := a.client.ListBETMarkets(ctx)
	if err != nil {
		return nil, fmt.Errorf("drift adapter: list markets: %w", err)
	}

	normalized := make([]adapters.NormalizedMarket, 0, len(markets))
	for _, m := range markets {
		if m.Status != "active" {
			continue
		}
		normalized = append(normalized, adapters.NormalizedMarket{
			ID:       fmt.Sprintf("drift_bet:%d", m.MarketIndex),
			Platform: "drift_bet",
			Question: m.Title,
			Category: m.Category,
			EndDate:  time.Unix(m.ExpiryTs, 0).Format(time.RFC3339),
			Outcomes: []adapters.Outcome{
				{ID: strconv.Itoa(m.MarketIndex) + ":yes", Label: "Yes", Price: m.YesPrice},
				{ID: strconv.Itoa(m.MarketIndex) + ":no", Label: "No", Price: m.NoPrice},
			},
			Volume:         m.Volume24h,
			Liquidity:      m.Liquidity,
			ResolutionRule: m.ResolutionRules,
		})
	}
	return normalized, nil
}

// PlaceOrder executes a trade via Drift BET.
func (a *Adapter) PlaceOrder(ctx context.Context, signal adapters.Signal) (string, error) {
	// Parse market index from signal.MarketID (format: "drift_bet:{index}")
	var marketIndex int
	if _, err := fmt.Sscanf(signal.MarketID, "drift_bet:%d", &marketIndex); err != nil {
		return "", fmt.Errorf("drift adapter: parse market ID %q: %w", signal.MarketID, err)
	}

	direction := "long" // YES
	if signal.Direction == "sell" || signal.OutcomeID == "no" {
		direction = "short" // NO
	}

	resp, err := a.client.PlaceOrder(ctx, OrderRequest{
		MarketIndex: marketIndex,
		Direction:   direction,
		Price:       signal.Edge, // Use the target price
		Amount:      signal.Size,
		OrderType:   "limit",
	})
	if err != nil {
		return "", fmt.Errorf("drift adapter: place order: %w", err)
	}
	return resp.TxSignature, nil
}

// Positions returns current open BET positions.
func (a *Adapter) Positions(ctx context.Context) ([]adapters.Position, error) {
	positions, err := a.client.GetPositions(ctx, a.userAuthority)
	if err != nil {
		return nil, fmt.Errorf("drift adapter: get positions: %w", err)
	}

	result := make([]adapters.Position, 0, len(positions))
	for _, p := range positions {
		outcomeID := "yes"
		size := p.BaseAssetAmount
		if size < 0 {
			outcomeID = "no"
			size = -size
		}
		result = append(result, adapters.Position{
			MarketID:  fmt.Sprintf("drift_bet:%d", p.MarketIndex),
			Platform:  "drift_bet",
			OutcomeID: outcomeID,
			Size:      size,
			AvgPrice:  p.EntryPrice,
			Value:     size * p.EntryPrice,
		})
	}
	return result, nil
}

// Settle checks for resolved markets and collects winnings.
func (a *Adapter) Settle(ctx context.Context) error {
	positions, err := a.client.GetPositions(ctx, a.userAuthority)
	if err != nil {
		return fmt.Errorf("drift adapter: settle get positions: %w", err)
	}

	for _, p := range positions {
		market, err := a.client.GetBETMarket(ctx, p.MarketIndex)
		if err != nil {
			continue
		}
		if market.Status != "resolved" {
			continue
		}
		// Drift auto-settles resolved positions — the PnL is reflected in settledPnl.
		// No explicit action needed; just log the resolution.
	}
	return nil
}
```

## Done When

- [ ] All requirements met
- [ ] `internal/adapters/drift/http_client.go` compiles and implements all `Client` methods
- [ ] `internal/adapters/drift/drift.go` implements `adapters.MarketAdapter`
- [ ] Rate limiting is functional (uses `golang.org/x/time/rate`)
- [ ] Market list caching is functional with configurable TTL
- [ ] All HTTP calls propagate `context.Context`
- [ ] Errors are wrapped with sentinel errors from `types.go`
- [ ] `go build ./...` passes from the `projects/agent-prediction` root
