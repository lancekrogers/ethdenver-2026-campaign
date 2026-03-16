---
fest_type: task
fest_id: 01_llm_strategy.md
fest_name: 02_llm_strategy
fest_parent: 02_agent_runtime
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:24:37.75117-06:00
fest_tracking: true
---

# Task: LLM Trading Strategy

## Objective

Implement an LLM-based trading strategy using Claude API that analyzes market data and produces buy/sell/hold signals with JSON parsing, plus a real ClaudeClient for the Anthropic Messages API.

## Requirements

- [ ] Create `internal/strategy/llm.go` with LLMClient interface, LLMConfig, LLMStrategy struct
- [ ] Implement Evaluate() that sends market data prompt to LLM and parses JSON response (action, confidence, size, reason)
- [ ] Create `internal/strategy/claude.go` with ClaudeClient implementing LLMClient via Anthropic Messages API
- [ ] Create `internal/strategy/llm_test.go` with mockLLM: test buy signal, hold signal, context cancellation
- [ ] Strategy implements the existing trading.Strategy interface (Name, MaxPosition, Evaluate)

## Dependencies

- None for this sequence — uses existing `trading.Strategy` interface from `internal/base/trading/strategy.go`.
- Uses types from `internal/base/trading/models.go`: `SignalBuy`, `SignalSell`, `SignalHold`, `Signal`, `MarketState`.
- The `trading.Strategy` interface requires: `Name() string`, `MaxPosition() float64`, `Evaluate(ctx context.Context, market MarketState) (*Signal, error)`.

## Implementation Steps

### Step 1: Create `projects/agent-defi/internal/strategy/llm_test.go`

Create the directory if needed: `mkdir -p projects/agent-defi/internal/strategy`

Write the test file first (TDD). This file contains a `mockLLM` and three tests:

```go
package strategy

import (
	"context"
	"fmt"
	"testing"

	"github.com/lancekrogers/agent-defi/internal/base/trading"
)

type mockLLM struct {
	response string
	err      error
}

func (m *mockLLM) Complete(ctx context.Context, prompt string) (string, error) {
	if err := ctx.Err(); err != nil {
		return "", err
	}
	return m.response, m.err
}

func TestLLMStrategy_BuySignal(t *testing.T) {
	mock := &mockLLM{
		response: `{"action":"buy","confidence":0.85,"size":0.5,"reason":"bullish momentum"}`,
	}
	s := NewLLMStrategy(LLMConfig{
		Model:       "test",
		MaxPosition: 1.0,
	}, mock)

	market := trading.MarketState{
		Pair:  "WETH/USDC",
		Price: 3000.0,
	}

	signal, err := s.Evaluate(context.Background(), market)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if signal.Type != trading.SignalBuy {
		t.Fatalf("expected buy, got %s", signal.Type)
	}
	if signal.Confidence != 0.85 {
		t.Fatalf("expected confidence 0.85, got %f", signal.Confidence)
	}
	if signal.SuggestedSize != 0.5 {
		t.Fatalf("expected size 0.5, got %f", signal.SuggestedSize)
	}
}

func TestLLMStrategy_HoldSignal(t *testing.T) {
	mock := &mockLLM{
		response: `{"action":"hold","confidence":0.6,"size":0,"reason":"uncertain market"}`,
	}
	s := NewLLMStrategy(LLMConfig{
		Model:       "test",
		MaxPosition: 1.0,
	}, mock)

	market := trading.MarketState{
		Pair:  "WETH/USDC",
		Price: 3000.0,
	}

	signal, err := s.Evaluate(context.Background(), market)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if signal.Type != trading.SignalHold {
		t.Fatalf("expected hold, got %s", signal.Type)
	}
}

func TestLLMStrategy_ContextCancellation(t *testing.T) {
	mock := &mockLLM{
		response: `{"action":"buy","confidence":0.9,"size":1.0,"reason":"test"}`,
	}
	s := NewLLMStrategy(LLMConfig{
		Model:       "test",
		MaxPosition: 1.0,
	}, mock)

	ctx, cancel := context.WithCancel(context.Background())
	cancel()

	_, err := s.Evaluate(ctx, trading.MarketState{})
	if err == nil {
		t.Fatal("expected error on cancelled context")
	}
	fmt.Println("context cancellation correctly returned error:", err)
}
```

### Step 2: Run Tests (Expect Failure)

```bash
cd projects/agent-defi && go test ./internal/strategy/... -v
```

This will fail because `llm.go` does not exist yet. Confirms the test file compiles once production code is added.

### Step 3: Create `projects/agent-defi/internal/strategy/llm.go`

```go
package strategy

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/lancekrogers/agent-defi/internal/base/trading"
)

// LLMClient abstracts an LLM completion API.
type LLMClient interface {
	Complete(ctx context.Context, prompt string) (string, error)
}

// LLMConfig configures the LLM-based strategy.
type LLMConfig struct {
	Model       string
	MaxPosition float64
}

// LLMStrategy implements trading.Strategy using an LLM for signal generation.
type LLMStrategy struct {
	cfg    LLMConfig
	client LLMClient
}

// NewLLMStrategy creates a new LLM-based trading strategy.
func NewLLMStrategy(cfg LLMConfig, client LLMClient) *LLMStrategy {
	return &LLMStrategy{cfg: cfg, client: client}
}

func (s *LLMStrategy) Name() string        { return "llm-" + s.cfg.Model }
func (s *LLMStrategy) MaxPosition() float64 { return s.cfg.MaxPosition }

// llmResponse is the expected JSON shape from the LLM.
type llmResponse struct {
	Action     string  `json:"action"`
	Confidence float64 `json:"confidence"`
	Size       float64 `json:"size"`
	Reason     string  `json:"reason"`
}

func (s *LLMStrategy) Evaluate(ctx context.Context, market trading.MarketState) (*trading.Signal, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("llm strategy: context cancelled: %w", err)
	}

	prompt := fmt.Sprintf(`You are a DeFi trading agent. Analyze the following market data and respond with a JSON object containing: action (buy/sell/hold), confidence (0.0-1.0), size (fraction of max position), reason (string).

Market Data:
- Pair: %s
- Current Price: %.6f
- Volume 24h: %.2f
- Liquidity: %.2f

Respond ONLY with valid JSON, no markdown or explanation.`,
		market.Pair, market.Price, market.Volume24h, market.Liquidity)

	raw, err := s.client.Complete(ctx, prompt)
	if err != nil {
		return nil, fmt.Errorf("llm strategy: completion failed: %w", err)
	}

	var resp llmResponse
	if err := json.Unmarshal([]byte(raw), &resp); err != nil {
		return nil, fmt.Errorf("llm strategy: parse response: %w", err)
	}

	signal := &trading.Signal{
		Confidence:    resp.Confidence,
		SuggestedSize: resp.Size,
		Reason:        resp.Reason,
		GeneratedAt:   time.Now(),
	}

	switch resp.Action {
	case "buy":
		signal.Type = trading.SignalBuy
	case "sell":
		signal.Type = trading.SignalSell
	default:
		signal.Type = trading.SignalHold
	}

	return signal, nil
}
```

### Step 4: Create `projects/agent-defi/internal/strategy/claude.go`

```go
package strategy

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

const anthropicAPIURL = "https://api.anthropic.com/v1/messages"

// ClaudeClient implements LLMClient using the Anthropic Messages API.
type ClaudeClient struct {
	apiKey string
	model  string
	http   *http.Client
}

// NewClaudeClient creates a client for the Anthropic Messages API.
// Model defaults to "claude-sonnet-4-6" if empty.
func NewClaudeClient(apiKey, model string) *ClaudeClient {
	if model == "" {
		model = "claude-sonnet-4-6"
	}
	return &ClaudeClient{
		apiKey: apiKey,
		model:  model,
		http:   &http.Client{},
	}
}

type claudeRequest struct {
	Model     string           `json:"model"`
	MaxTokens int              `json:"max_tokens"`
	Messages  []claudeMessage  `json:"messages"`
}

type claudeMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type claudeResponse struct {
	Content []struct {
		Text string `json:"text"`
	} `json:"content"`
}

func (c *ClaudeClient) Complete(ctx context.Context, prompt string) (string, error) {
	if err := ctx.Err(); err != nil {
		return "", fmt.Errorf("claude: context cancelled: %w", err)
	}

	reqBody := claudeRequest{
		Model:     c.model,
		MaxTokens: 256,
		Messages: []claudeMessage{
			{Role: "user", Content: prompt},
		},
	}

	body, err := json.Marshal(reqBody)
	if err != nil {
		return "", fmt.Errorf("claude: marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, anthropicAPIURL, bytes.NewReader(body))
	if err != nil {
		return "", fmt.Errorf("claude: create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("x-api-key", c.apiKey)
	req.Header.Set("anthropic-version", "2023-06-01")

	resp, err := c.http.Do(req)
	if err != nil {
		return "", fmt.Errorf("claude: send request: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("claude: read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("claude: API error %d: %s", resp.StatusCode, string(respBody))
	}

	var cr claudeResponse
	if err := json.Unmarshal(respBody, &cr); err != nil {
		return "", fmt.Errorf("claude: parse response: %w", err)
	}

	if len(cr.Content) == 0 {
		return "", fmt.Errorf("claude: empty response content")
	}

	return cr.Content[0].Text, nil
}
```

### Step 5: Run Tests

```bash
cd projects/agent-defi && go test ./internal/strategy/... -v
```

**Expected output:** All 3 tests PASS:
- `TestLLMStrategy_BuySignal`
- `TestLLMStrategy_HoldSignal`
- `TestLLMStrategy_ContextCancellation`

## Done When

- [ ] All requirements met
- [ ] `cd projects/agent-defi && go test ./internal/strategy/... -v` passes all 3 tests
