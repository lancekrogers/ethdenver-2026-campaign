---
fest_type: task
fest_id: 02_gamma_client.md
fest_name: gamma_client
fest_parent: 01_polymarket_adapter
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.568943-06:00
fest_tracking: true
---

# Task: Polymarket Gamma (Market Metadata) Client

## Objective

Implement the Gamma API client that fetches Polymarket market metadata, event details, resolution rules, categories, and search functionality for the market aggregator layer.

## Requirements

- [ ] `GammaClient` struct for Polymarket's Gamma (Strapi) metadata API
- [ ] `ListMarkets` method: paginated market listing with filters (active, category, date range)
- [ ] `GetEvent` method: fetch event details including all associated markets
- [ ] `SearchMarkets` method: text search across market questions and descriptions
- [ ] `GetMarketBySlug` method: fetch market by URL slug
- [ ] Map Gamma market data to the platform's `NormalizedMarket` type (from 03-prediction-market-engine.md)
- [ ] Extract resolution rules, categories, and expiry dates from Gamma responses
- [ ] Handle pagination: Gamma uses offset-based pagination

## Implementation

### Step 1: Define Gamma types

Create `projects/agent-inference/internal/adapters/polymarket/gamma.go`:

```go
package polymarket

import (
    "context"
    "encoding/json"
    "fmt"
    "net/http"
    "net/url"
    "strconv"
    "time"
)

const GammaBaseURL = "https://gamma-api.polymarket.com"

// GammaClient fetches market metadata from Polymarket's Gamma API.
type GammaClient struct {
    baseURL    string
    httpClient *http.Client
}

// GammaEvent represents a Polymarket event (groups related markets).
type GammaEvent struct {
    ID          string        `json:"id"`
    Title       string        `json:"title"`
    Slug        string        `json:"slug"`
    Description string        `json:"description"`
    Category    string        `json:"category"`
    StartDate   string        `json:"startDate"`
    EndDate     string        `json:"endDate"`
    Markets     []GammaMarket `json:"markets"`
    Active      bool          `json:"active"`
}

// GammaMarket represents a single Polymarket market.
type GammaMarket struct {
    ID              string   `json:"id"`
    ConditionID     string   `json:"conditionId"`
    Slug            string   `json:"slug"`
    Question        string   `json:"question"`
    Description     string   `json:"description"`
    ResolutionSource string  `json:"resolutionSource"`
    EndDate         string   `json:"endDate"`
    Active          bool     `json:"active"`
    Closed          bool     `json:"closed"`
    Category        string   `json:"category"`
    Tags            []string `json:"tags"`
    Volume          string   `json:"volume"`         // total volume in USDC
    Volume24hr      string   `json:"volume24hr"`     // 24h volume
    Liquidity       string   `json:"liquidity"`
    OutcomeYes      string   `json:"outcomePrices"`  // JSON array of prices
    Tokens          []GammaToken `json:"clobTokenIds"`
}

// GammaToken maps to a CLOB token (YES/NO outcome).
type GammaToken struct {
    TokenID string `json:"token_id"`
    Outcome string `json:"outcome"`
}

// GammaListParams holds filters for listing markets.
type GammaListParams struct {
    Active   *bool
    Closed   *bool
    Category string
    Limit    int
    Offset   int
    OrderBy  string // "volume24hr", "endDate", "startDate"
}
```

### Step 2: Implement GammaClient

```go
// NewGammaClient creates a Gamma metadata client.
func NewGammaClient() *GammaClient {
    return &GammaClient{
        baseURL:    GammaBaseURL,
        httpClient: &http.Client{Timeout: 30 * time.Second},
    }
}

// ListMarkets returns markets with optional filters and pagination.
func (g *GammaClient) ListMarkets(ctx context.Context, params GammaListParams) ([]GammaMarket, error) {
    u, _ := url.Parse(g.baseURL + "/markets")
    q := u.Query()
    if params.Active != nil {
        q.Set("active", strconv.FormatBool(*params.Active))
    }
    if params.Closed != nil {
        q.Set("closed", strconv.FormatBool(*params.Closed))
    }
    if params.Category != "" {
        q.Set("tag", params.Category)
    }
    if params.Limit > 0 {
        q.Set("limit", strconv.Itoa(params.Limit))
    }
    if params.Offset > 0 {
        q.Set("offset", strconv.Itoa(params.Offset))
    }
    if params.OrderBy != "" {
        q.Set("order", params.OrderBy)
    }
    u.RawQuery = q.Encode()

    req, err := http.NewRequestWithContext(ctx, http.MethodGet, u.String(), nil)
    if err != nil {
        return nil, fmt.Errorf("creating request: %w", err)
    }

    resp, err := g.httpClient.Do(req)
    if err != nil {
        return nil, fmt.Errorf("listing markets: %w", err)
    }
    defer resp.Body.Close()

    var markets []GammaMarket
    if err := json.NewDecoder(resp.Body).Decode(&markets); err != nil {
        return nil, fmt.Errorf("decoding markets: %w", err)
    }
    return markets, nil
}

// GetEvent fetches an event by ID including all its markets.
func (g *GammaClient) GetEvent(ctx context.Context, eventID string) (*GammaEvent, error) {
    req, err := http.NewRequestWithContext(ctx, http.MethodGet,
        g.baseURL+"/events/"+eventID, nil)
    if err != nil {
        return nil, err
    }

    resp, err := g.httpClient.Do(req)
    if err != nil {
        return nil, fmt.Errorf("getting event: %w", err)
    }
    defer resp.Body.Close()

    var event GammaEvent
    if err := json.NewDecoder(resp.Body).Decode(&event); err != nil {
        return nil, fmt.Errorf("decoding event: %w", err)
    }
    return &event, nil
}

// SearchMarkets performs a text search across market questions.
func (g *GammaClient) SearchMarkets(ctx context.Context, query string, limit int) ([]GammaMarket, error) {
    u, _ := url.Parse(g.baseURL + "/markets")
    q := u.Query()
    q.Set("_q", query)
    q.Set("limit", strconv.Itoa(limit))
    q.Set("active", "true")
    u.RawQuery = q.Encode()

    req, err := http.NewRequestWithContext(ctx, http.MethodGet, u.String(), nil)
    if err != nil {
        return nil, err
    }

    resp, err := g.httpClient.Do(req)
    if err != nil {
        return nil, fmt.Errorf("searching markets: %w", err)
    }
    defer resp.Body.Close()

    var markets []GammaMarket
    if err := json.NewDecoder(resp.Body).Decode(&markets); err != nil {
        return nil, fmt.Errorf("decoding search results: %w", err)
    }
    return markets, nil
}
```

### Step 3: Implement NormalizedMarket conversion

```go
// ToNormalizedMarket converts a GammaMarket to the platform's normalized format.
func (m *GammaMarket) ToNormalizedMarket() NormalizedMarket {
    volume24h, _ := strconv.ParseFloat(m.Volume24hr, 64)
    totalVolume, _ := strconv.ParseFloat(m.Volume, 64)
    liquidity, _ := strconv.ParseFloat(m.Liquidity, 64)

    status := MarketStatusOpen
    if m.Closed {
        status = MarketStatusClosed
    }

    endDate, _ := time.Parse(time.RFC3339, m.EndDate)

    outcomes := make([]NormalizedOutcome, 0, len(m.Tokens))
    for _, t := range m.Tokens {
        outcomes = append(outcomes, NormalizedOutcome{
            Name:    t.Outcome,
            TokenID: t.TokenID,
        })
    }

    return NormalizedMarket{
        ID:              "polymarket:" + m.ConditionID,
        Platform:        "polymarket",
        NativeID:        m.ConditionID,
        Question:        m.Question,
        Description:     m.Description,
        ResolutionRules: m.ResolutionSource,
        Category:        m.Category,
        Tags:            m.Tags,
        Outcomes:        outcomes,
        Status:          status,
        ExpiresAt:       endDate,
        Volume24h:       volume24h,
        TotalVolume:     totalVolume,
        Liquidity:       liquidity,
    }
}
```

### Step 4: Write tests

Create `internal/adapters/polymarket/gamma_test.go`:

1. `TestListMarkets` — mock Gamma API, verify pagination params and market parsing
2. `TestGetEvent` — mock returns event with 3 markets, verify all parsed
3. `TestSearchMarkets` — mock returns filtered results
4. `TestToNormalizedMarket` — verify conversion: question, category, volume, status, outcomes
5. `TestPagination` — verify offset/limit params are correctly built into URL
6. `TestEmptyMarketList` — verify graceful handling of empty array response

## Done When

- [ ] All requirements met
- [ ] `ListMarkets` supports filtering by active/closed, category, and pagination
- [ ] `GetEvent` returns event with all associated markets
- [ ] `SearchMarkets` searches by text query
- [ ] `ToNormalizedMarket` correctly maps Gamma fields to platform's normalized format
- [ ] Resolution rules extracted from `resolutionSource` field
- [ ] `go test ./internal/adapters/polymarket/...` passes
