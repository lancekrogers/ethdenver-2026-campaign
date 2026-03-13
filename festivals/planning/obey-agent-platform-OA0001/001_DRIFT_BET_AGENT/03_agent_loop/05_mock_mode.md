---
fest_type: task
fest_id: 05_mock_mode.md
fest_name: mock_mode
fest_parent: 03_agent_loop
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.317491-06:00
fest_tracking: true
---

# Task: Mock Mode for Development and Testing

## Objective

Implement a mock mode that allows the entire agent to run end-to-end without real API calls (no Drift BET, no Claude, no Solana), using synthetic market data and deterministic LLM responses for rapid development, testing, and demos.

## Requirements

- [ ] Mock MarketAdapter that returns synthetic Drift BET markets
- [ ] Mock LLMClient that returns deterministic analysis results
- [ ] Mock order execution that simulates fills and P&L
- [ ] Controlled randomness for realistic-looking market dynamics
- [ ] Agent detects `MockMode=true` and swaps in all mock dependencies
- [ ] Mock mode logs clearly indicate "[MOCK]" in all outputs
- [ ] Full agent loop runs successfully in mock mode with `just run-mock`

## Implementation

### Step 1: Create Mock Market Adapter

Create file `projects/agent-prediction/internal/adapters/mock/mock.go`:

```go
package mock

import (
	"context"
	"fmt"
	"math/rand"
	"sync"
	"time"

	"github.com/lancekrogers/agent-prediction/internal/adapters"
)

// AdapterConfig configures the mock market adapter.
type AdapterConfig struct {
	// NumMarkets is how many synthetic markets to generate.
	NumMarkets int

	// Seed controls randomness for reproducible tests.
	Seed int64

	// FillRate is the probability that an order fills (0.0-1.0).
	FillRate float64
}

// Adapter implements adapters.MarketAdapter with synthetic data.
type Adapter struct {
	cfg     AdapterConfig
	rng     *rand.Rand
	mu      sync.RWMutex
	markets []adapters.NormalizedMarket
	orders  []adapters.Signal
	fills   int
}

// NewAdapter creates a mock market adapter.
func NewAdapter(cfg AdapterConfig) *Adapter {
	if cfg.NumMarkets == 0 {
		cfg.NumMarkets = 10
	}
	if cfg.Seed == 0 {
		cfg.Seed = time.Now().UnixNano()
	}
	if cfg.FillRate == 0 {
		cfg.FillRate = 0.9
	}

	rng := rand.New(rand.NewSource(cfg.Seed))
	a := &Adapter{
		cfg: cfg,
		rng: rng,
	}
	a.markets = a.generateMarkets()
	return a
}

// Name returns the platform identifier.
func (a *Adapter) Name() string {
	return "mock_drift_bet"
}

// ListMarkets returns synthetic prediction markets with drifting prices.
func (a *Adapter) ListMarkets(ctx context.Context) ([]adapters.NormalizedMarket, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}

	a.mu.Lock()
	defer a.mu.Unlock()

	// Drift prices slightly each call to simulate real market movement
	for i := range a.markets {
		for j := range a.markets[i].Outcomes {
			drift := (a.rng.Float64() - 0.5) * 0.02 // +/- 1%
			newPrice := a.markets[i].Outcomes[j].Price + drift
			if newPrice < 0.02 {
				newPrice = 0.02
			}
			if newPrice > 0.98 {
				newPrice = 0.98
			}
			a.markets[i].Outcomes[j].Price = newPrice
		}
		// Keep YES + NO roughly summing to 1.0
		if len(a.markets[i].Outcomes) >= 2 {
			a.markets[i].Outcomes[1].Price = 1.0 - a.markets[i].Outcomes[0].Price
		}
	}

	result := make([]adapters.NormalizedMarket, len(a.markets))
	copy(result, a.markets)
	return result, nil
}

// PlaceOrder simulates order execution with configurable fill rate.
func (a *Adapter) PlaceOrder(ctx context.Context, signal adapters.Signal) (string, error) {
	if err := ctx.Err(); err != nil {
		return "", err
	}

	a.mu.Lock()
	defer a.mu.Unlock()

	// Simulate fill probability
	if a.rng.Float64() > a.cfg.FillRate {
		return "", fmt.Errorf("mock: order not filled (simulated)")
	}

	a.orders = append(a.orders, signal)
	a.fills++
	txSig := fmt.Sprintf("mock_tx_%d_%d", time.Now().UnixNano(), a.fills)
	return txSig, nil
}

// Positions returns mock positions from filled orders.
func (a *Adapter) Positions(ctx context.Context) ([]adapters.Position, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}

	a.mu.RLock()
	defer a.mu.RUnlock()

	var positions []adapters.Position
	for _, order := range a.orders {
		// Find current market price
		currentPrice := 0.5
		for _, m := range a.markets {
			if m.ID == order.MarketID && len(m.Outcomes) > 0 {
				currentPrice = m.Outcomes[0].Price
				break
			}
		}

		positions = append(positions, adapters.Position{
			MarketID:  order.MarketID,
			Platform:  "mock_drift_bet",
			OutcomeID: order.OutcomeID,
			Size:      order.Size,
			AvgPrice:  order.Edge,
			Value:     order.Size * currentPrice,
		})
	}
	return positions, nil
}

// Settle simulates settlement (no-op in mock mode).
func (a *Adapter) Settle(ctx context.Context) error {
	return nil
}

// generateMarkets creates synthetic prediction markets.
func (a *Adapter) generateMarkets() []adapters.NormalizedMarket {
	templates := []struct {
		question string
		category string
		rules    string
	}{
		{"Will BTC exceed $100K by June 2026?", "crypto", "Resolves YES if Bitcoin price on CoinGecko exceeds $100,000 at any point before June 30, 2026 23:59 UTC."},
		{"Will ETH surpass $5,000 by Q3 2026?", "crypto", "Resolves YES if Ethereum price on CoinMarketCap exceeds $5,000 at any time before September 30, 2026."},
		{"Will the Fed cut rates in March 2026?", "macro", "Resolves YES if the Federal Reserve announces a federal funds rate cut at the March 2026 FOMC meeting."},
		{"Will Trump sign a crypto executive order by April?", "politics", "Resolves YES if the President signs an executive order specifically addressing cryptocurrency regulation before April 30, 2026."},
		{"Will SOL reach $300 by May 2026?", "crypto", "Resolves YES if Solana SOL token exceeds $300 on any major exchange before May 31, 2026."},
		{"Will US GDP growth exceed 3% in Q1 2026?", "macro", "Resolves YES if BEA advance estimate of Q1 2026 real GDP growth exceeds 3.0% annualized."},
		{"Will there be a ceasefire in Ukraine by summer?", "geopolitics", "Resolves YES if a formal ceasefire agreement is signed by all parties before June 21, 2026."},
		{"Will Lakers win the 2026 NBA Championship?", "sports", "Resolves YES if the Los Angeles Lakers win the 2025-2026 NBA Finals."},
		{"Will inflation drop below 2% in 2026?", "macro", "Resolves YES if any monthly CPI-U year-over-year reading in 2026 is below 2.0%."},
		{"Will a new AI model beat GPT-5 on MMLU by June?", "crypto", "Resolves YES if a publicly available model scores higher than GPT-5 on MMLU benchmark before June 30, 2026."},
	}

	markets := make([]adapters.NormalizedMarket, 0, a.cfg.NumMarkets)
	for i := 0; i < a.cfg.NumMarkets && i < len(templates); i++ {
		tmpl := templates[i]
		yesPrice := 0.30 + a.rng.Float64()*0.40 // 0.30 - 0.70

		markets = append(markets, adapters.NormalizedMarket{
			ID:             fmt.Sprintf("drift_bet:%d", i),
			Platform:       "drift_bet",
			Question:       tmpl.question,
			Category:       tmpl.category,
			EndDate:        time.Now().Add(time.Duration(7+a.rng.Intn(60)) * 24 * time.Hour).Format(time.RFC3339),
			Volume:         float64(5000 + a.rng.Intn(95000)),
			Liquidity:      float64(2000 + a.rng.Intn(48000)),
			ResolutionRule: tmpl.rules,
			Outcomes: []adapters.Outcome{
				{ID: fmt.Sprintf("%d:yes", i), Label: "Yes", Price: yesPrice},
				{ID: fmt.Sprintf("%d:no", i), Label: "No", Price: 1.0 - yesPrice},
			},
		})
	}
	return markets
}
```

### Step 2: Create Mock LLM Client

Create file `projects/agent-prediction/internal/analysis/mock_llm.go`:

```go
package analysis

import (
	"context"
	"encoding/json"
	"fmt"
	"math/rand"
)

// MockLLMConfig configures the mock LLM client.
type MockLLMConfig struct {
	// Seed for reproducible outputs.
	Seed int64

	// BaseEdge is the average edge the mock LLM "finds" (0.0-0.20).
	BaseEdge float64
}

// mockLLMClient implements LLMClient with deterministic responses.
type mockLLMClient struct {
	rng      *rand.Rand
	baseEdge float64
	calls    int
}

// NewMockLLMClient creates a mock LLM client for testing.
func NewMockLLMClient(cfg MockLLMConfig) LLMClient {
	if cfg.BaseEdge == 0 {
		cfg.BaseEdge = 0.08
	}
	return &mockLLMClient{
		rng:      rand.New(rand.NewSource(cfg.Seed)),
		baseEdge: cfg.BaseEdge,
	}
}

// Complete returns a synthetic text response.
func (m *mockLLMClient) Complete(ctx context.Context, req CompletionRequest) (*CompletionResponse, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}

	m.calls++
	return &CompletionResponse{
		Content:      fmt.Sprintf("[MOCK] Analysis response #%d", m.calls),
		InputTokens:  len(req.UserPrompt) / 4,
		OutputTokens: 200,
		Model:        "mock-claude",
		StopReason:   "end_turn",
	}, nil
}

// CompleteJSON returns structured mock analysis results.
func (m *mockLLMClient) CompleteJSON(ctx context.Context, req CompletionRequest, target interface{}) error {
	if err := ctx.Err(); err != nil {
		return err
	}

	m.calls++

	// Determine which type of response is needed based on the prompt content
	var response string

	// Check if this is a rule analysis request or probability estimation
	if containsAny(req.UserPrompt, "resolution rules", "yes_conditions", "edge_cases") {
		response = fmt.Sprintf(`{
			"yes_conditions": ["Mock condition triggers YES"],
			"no_conditions": ["Mock condition triggers NO"],
			"edge_cases": ["Mock: title might mislead traders"],
			"data_sources": ["Mock data source"],
			"ambiguities": [],
			"resolution_timeline": "Before expiry date",
			"title_rule_divergence": %.2f,
			"rule_clarity": %.2f
		}`, m.rng.Float64()*0.3, 0.7+m.rng.Float64()*0.3)
	} else {
		// Probability estimation
		prob := 0.3 + m.rng.Float64()*0.4 // 0.30-0.70
		conf := 0.5 + m.rng.Float64()*0.4  // 0.50-0.90
		response = fmt.Sprintf(`{
			"probability": %.3f,
			"confidence": %.3f,
			"reasoning": "[MOCK] Based on synthetic analysis",
			"key_factors": ["mock factor 1", "mock factor 2"],
			"information_gaps": ["mock gap"]
		}`, prob, conf)
	}

	return json.Unmarshal([]byte(response), target)
}

func containsAny(s string, substrs ...string) bool {
	for _, sub := range substrs {
		for i := 0; i <= len(s)-len(sub); i++ {
			if s[i:i+len(sub)] == sub {
				return true
			}
		}
	}
	return false
}
```

### Step 3: Wire Mock Mode in Agent Constructor

Update `projects/agent-prediction/cmd/agent/main.go` to conditionally use mocks when `cfg.MockMode` is true. In the `main()` function, after loading config, add a conditional block:

```go
// In main(), after cfg is loaded and validated:
var (
	marketAdapter adapters.MarketAdapter
	llmClient     analysis.LLMClient
)

if cfg.MockMode {
	log.Info("[MOCK] Running in mock mode — no real API calls")
	marketAdapter = mock.NewAdapter(mock.AdapterConfig{NumMarkets: 10, Seed: 42})
	llmClient = analysis.NewMockLLMClient(analysis.MockLLMConfig{Seed: 42})
} else {
	driftClient := drift.NewHTTPClient(drift.HTTPClientConfig{
		BaseURL:       cfg.DriftBaseURL,
		DLOBBaseURL:   cfg.DriftDLOBURL,
		UserAuthority: cfg.WalletAuthority,
	})
	marketAdapter = drift.NewAdapter(driftClient, cfg.WalletAuthority)
	llmClient = analysis.NewClaudeClient(analysis.ClaudeConfig{
		APIKey: cfg.ClaudeAPIKey,
		Model:  cfg.ClaudeModel,
	})
}

// Then use marketAdapter and llmClient to create normalizer, analyzer, strategy...
```

### Step 4: Add Justfile Recipes

Add to `projects/agent-prediction/justfile`:

```just
# Run agent in mock mode (no real API calls)
run-mock:
    PRED_MOCK_MODE=true PRED_AGENT_ID=obey-predictor-mock PRED_LOG_LEVEL=debug go run ./cmd/agent/

# Run agent with real APIs
run:
    go run ./cmd/agent/

# Build binary
build:
    go build -o bin/agent-prediction ./cmd/agent/

# Run all tests
test:
    go test ./... -v -count=1
```

### Step 5: Create Mock Mode Test

Create file `projects/agent-prediction/internal/adapters/mock/mock_test.go`:

```go
package mock

import (
	"context"
	"testing"
)

func TestMockAdapter(t *testing.T) {
	adapter := NewAdapter(AdapterConfig{NumMarkets: 5, Seed: 42, FillRate: 1.0})

	if adapter.Name() != "mock_drift_bet" {
		t.Errorf("expected name 'mock_drift_bet', got %q", adapter.Name())
	}

	markets, err := adapter.ListMarkets(context.Background())
	if err != nil {
		t.Fatalf("ListMarkets() error: %v", err)
	}
	if len(markets) != 5 {
		t.Errorf("expected 5 markets, got %d", len(markets))
	}

	// Verify markets have valid prices
	for _, m := range markets {
		if len(m.Outcomes) < 2 {
			t.Errorf("market %s has %d outcomes, expected 2", m.ID, len(m.Outcomes))
			continue
		}
		yesPrice := m.Outcomes[0].Price
		noPrice := m.Outcomes[1].Price
		if yesPrice < 0.01 || yesPrice > 0.99 {
			t.Errorf("market %s YES price out of range: %f", m.ID, yesPrice)
		}
		sum := yesPrice + noPrice
		if sum < 0.95 || sum > 1.05 {
			t.Errorf("market %s prices don't sum to ~1.0: %f", m.ID, sum)
		}
	}
}

func TestMockAdapter_PriceDrift(t *testing.T) {
	adapter := NewAdapter(AdapterConfig{NumMarkets: 3, Seed: 42})

	markets1, _ := adapter.ListMarkets(context.Background())
	price1 := markets1[0].Outcomes[0].Price

	markets2, _ := adapter.ListMarkets(context.Background())
	price2 := markets2[0].Outcomes[0].Price

	// Prices should drift slightly between calls
	if price1 == price2 {
		t.Error("prices should drift between calls")
	}
}
```

## Done When

- [ ] All requirements met
- [ ] `internal/adapters/mock/mock.go` implements `adapters.MarketAdapter` with synthetic markets
- [ ] Mock adapter generates realistic markets with drifting prices
- [ ] `internal/analysis/mock_llm.go` implements `LLMClient` with deterministic responses
- [ ] Mock LLM returns appropriate JSON for both rule analysis and probability estimation
- [ ] Agent constructor in `cmd/agent/main.go` swaps to mock dependencies when `PRED_MOCK_MODE=true`
- [ ] `just run-mock` starts the agent in mock mode with no external dependencies
- [ ] Mock output clearly marked with "[MOCK]" prefix
- [ ] `go test ./internal/adapters/mock/...` passes
- [ ] Full agent loop completes at least one cycle in mock mode without errors
