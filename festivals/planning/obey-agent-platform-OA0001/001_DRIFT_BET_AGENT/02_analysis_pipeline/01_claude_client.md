---
fest_type: task
fest_id: 01_claude_client.md
fest_name: claude_client
fest_parent: 02_analysis_pipeline
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.297286-06:00
fest_tracking: true
---

# Task: Claude API Client for Market Analysis

## Objective

Implement a Go client for the Anthropic Claude API that provides structured LLM completions for prediction market analysis, resolution rule parsing, and probability estimation.

## Requirements

- [ ] Claude API client with Messages API support (claude-sonnet-4-20250514 model)
- [ ] System prompt management for prediction market analysis context
- [ ] Structured response parsing (JSON mode) for probability estimates
- [ ] Token usage tracking and cost estimation
- [ ] Rate limiting (respect Anthropic API limits)
- [ ] Configurable model, max tokens, and temperature
- [ ] Context propagation and timeout handling

## Implementation

### Step 1: Create the LLM Client Interface

Create file `projects/agent-prediction/internal/analysis/llm.go`:

```go
package analysis

import "context"

// LLMClient abstracts LLM interactions for market analysis.
// This allows swapping Claude for other providers without changing analysis logic.
type LLMClient interface {
	// Complete sends a prompt and returns the LLM's text response.
	Complete(ctx context.Context, req CompletionRequest) (*CompletionResponse, error)

	// CompleteJSON sends a prompt and parses the response as JSON into the target.
	CompleteJSON(ctx context.Context, req CompletionRequest, target interface{}) error
}

// CompletionRequest holds parameters for an LLM completion.
type CompletionRequest struct {
	// SystemPrompt sets the system-level instructions.
	SystemPrompt string

	// UserPrompt is the user message content.
	UserPrompt string

	// MaxTokens limits the response length. Default: 2048.
	MaxTokens int

	// Temperature controls randomness. 0.0 = deterministic, 1.0 = creative.
	// Default: 0.3 for analytical tasks.
	Temperature float64
}

// CompletionResponse contains the LLM response and metadata.
type CompletionResponse struct {
	// Content is the text response from the LLM.
	Content string

	// InputTokens is the number of tokens in the prompt.
	InputTokens int

	// OutputTokens is the number of tokens in the response.
	OutputTokens int

	// Model is the model that generated the response.
	Model string

	// StopReason indicates why generation stopped.
	StopReason string
}
```

### Step 2: Implement the Claude Client

Create file `projects/agent-prediction/internal/analysis/claude.go`:

```go
package analysis

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync/atomic"
	"time"

	"golang.org/x/time/rate"
)

// ClaudeConfig holds configuration for the Claude API client.
type ClaudeConfig struct {
	// APIKey is the Anthropic API key. Required.
	APIKey string

	// Model is the Claude model to use. Default: "claude-sonnet-4-20250514".
	Model string

	// BaseURL is the API base URL. Default: "https://api.anthropic.com".
	BaseURL string

	// MaxTokens is the default max tokens per request. Default: 2048.
	MaxTokens int

	// Temperature is the default temperature. Default: 0.3.
	Temperature float64

	// HTTPTimeout is the timeout for API requests. Default: 60s.
	HTTPTimeout time.Duration

	// RateLimit is max requests per minute. Default: 50.
	RateLimit float64
}

// claudeClient implements LLMClient using the Anthropic Claude Messages API.
type claudeClient struct {
	cfg     ClaudeConfig
	client  *http.Client
	limiter *rate.Limiter

	totalInputTokens  atomic.Int64
	totalOutputTokens atomic.Int64
	totalRequests     atomic.Int64
}

// NewClaudeClient creates a new Claude API client.
func NewClaudeClient(cfg ClaudeConfig) LLMClient {
	if cfg.Model == "" {
		cfg.Model = "claude-sonnet-4-20250514"
	}
	if cfg.BaseURL == "" {
		cfg.BaseURL = "https://api.anthropic.com"
	}
	if cfg.MaxTokens == 0 {
		cfg.MaxTokens = 2048
	}
	if cfg.Temperature == 0 {
		cfg.Temperature = 0.3
	}
	if cfg.HTTPTimeout == 0 {
		cfg.HTTPTimeout = 60 * time.Second
	}
	if cfg.RateLimit == 0 {
		cfg.RateLimit = 50.0 / 60.0 // 50 requests per minute
	}

	return &claudeClient{
		cfg:     cfg,
		client:  &http.Client{Timeout: cfg.HTTPTimeout},
		limiter: rate.NewLimiter(rate.Limit(cfg.RateLimit), 5),
	}
}

// claudeRequest is the Anthropic Messages API request body.
type claudeRequest struct {
	Model       string           `json:"model"`
	MaxTokens   int              `json:"max_tokens"`
	Temperature float64          `json:"temperature"`
	System      string           `json:"system,omitempty"`
	Messages    []claudeMessage  `json:"messages"`
}

type claudeMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

// claudeResponse is the Anthropic Messages API response body.
type claudeResponse struct {
	ID           string `json:"id"`
	Type         string `json:"type"`
	Role         string `json:"role"`
	Content      []struct {
		Type string `json:"type"`
		Text string `json:"text"`
	} `json:"content"`
	Model        string `json:"model"`
	StopReason   string `json:"stop_reason"`
	Usage        struct {
		InputTokens  int `json:"input_tokens"`
		OutputTokens int `json:"output_tokens"`
	} `json:"usage"`
}

// Complete sends a prompt to Claude and returns the text response.
func (c *claudeClient) Complete(ctx context.Context, req CompletionRequest) (*CompletionResponse, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("claude: context cancelled: %w", err)
	}

	if err := c.limiter.Wait(ctx); err != nil {
		return nil, fmt.Errorf("claude: rate limit wait: %w", err)
	}

	maxTokens := req.MaxTokens
	if maxTokens == 0 {
		maxTokens = c.cfg.MaxTokens
	}
	temperature := req.Temperature
	if temperature == 0 {
		temperature = c.cfg.Temperature
	}

	apiReq := claudeRequest{
		Model:       c.cfg.Model,
		MaxTokens:   maxTokens,
		Temperature: temperature,
		System:      req.SystemPrompt,
		Messages: []claudeMessage{
			{Role: "user", Content: req.UserPrompt},
		},
	}

	body, err := json.Marshal(apiReq)
	if err != nil {
		return nil, fmt.Errorf("claude: marshal request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost,
		c.cfg.BaseURL+"/v1/messages", bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("claude: create request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("x-api-key", c.cfg.APIKey)
	httpReq.Header.Set("anthropic-version", "2023-06-01")

	resp, err := c.client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("claude: request failed: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("claude: read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("claude: API error HTTP %d: %s", resp.StatusCode, string(respBody))
	}

	var apiResp claudeResponse
	if err := json.Unmarshal(respBody, &apiResp); err != nil {
		return nil, fmt.Errorf("claude: decode response: %w", err)
	}

	content := ""
	if len(apiResp.Content) > 0 {
		content = apiResp.Content[0].Text
	}

	// Track token usage
	c.totalInputTokens.Add(int64(apiResp.Usage.InputTokens))
	c.totalOutputTokens.Add(int64(apiResp.Usage.OutputTokens))
	c.totalRequests.Add(1)

	return &CompletionResponse{
		Content:      content,
		InputTokens:  apiResp.Usage.InputTokens,
		OutputTokens: apiResp.Usage.OutputTokens,
		Model:        apiResp.Model,
		StopReason:   apiResp.StopReason,
	}, nil
}

// CompleteJSON sends a prompt that requests JSON output and parses it into target.
func (c *claudeClient) CompleteJSON(ctx context.Context, req CompletionRequest, target interface{}) error {
	// Append JSON instruction to the user prompt
	req.UserPrompt = req.UserPrompt + "\n\nRespond with valid JSON only. No markdown, no explanation outside the JSON."

	resp, err := c.Complete(ctx, req)
	if err != nil {
		return err
	}

	// Strip any markdown code fences that Claude might add despite instructions
	content := resp.Content
	content = stripCodeFences(content)

	if err := json.Unmarshal([]byte(content), target); err != nil {
		return fmt.Errorf("claude: failed to parse JSON response: %w (response: %s)", err, content)
	}
	return nil
}

// stripCodeFences removes ```json ... ``` wrappers from LLM output.
func stripCodeFences(s string) string {
	// Find opening fence
	for i := 0; i < len(s); i++ {
		if s[i] == '{' || s[i] == '[' {
			// Find the matching close
			depth := 0
			for j := i; j < len(s); j++ {
				switch s[j] {
				case '{', '[':
					depth++
				case '}', ']':
					depth--
					if depth == 0 {
						return s[i : j+1]
					}
				}
			}
			return s[i:]
		}
	}
	return s
}
```

### Step 3: Create Tests

Create file `projects/agent-prediction/internal/analysis/claude_test.go`:

```go
package analysis

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestClaudeComplete(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("x-api-key") == "" {
			t.Error("missing API key header")
		}
		if r.Header.Get("anthropic-version") != "2023-06-01" {
			t.Error("missing or wrong anthropic-version header")
		}

		json.NewEncoder(w).Encode(claudeResponse{
			ID:   "msg_test",
			Type: "message",
			Role: "assistant",
			Content: []struct {
				Type string `json:"type"`
				Text string `json:"text"`
			}{{Type: "text", Text: "The probability is 0.72"}},
			Model:      "claude-sonnet-4-20250514",
			StopReason: "end_turn",
			Usage:      struct {
				InputTokens  int `json:"input_tokens"`
				OutputTokens int `json:"output_tokens"`
			}{InputTokens: 100, OutputTokens: 20},
		})
	}))
	defer srv.Close()

	client := NewClaudeClient(ClaudeConfig{
		APIKey:  "test-key",
		BaseURL: srv.URL,
	})

	resp, err := client.Complete(context.Background(), CompletionRequest{
		SystemPrompt: "You are a prediction market analyst.",
		UserPrompt:   "What is the probability of X?",
	})
	if err != nil {
		t.Fatalf("Complete() error: %v", err)
	}
	if resp.Content == "" {
		t.Error("expected non-empty content")
	}
	if resp.InputTokens != 100 {
		t.Errorf("expected 100 input tokens, got %d", resp.InputTokens)
	}
}

func TestClaudeCompleteJSON(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(claudeResponse{
			Content: []struct {
				Type string `json:"type"`
				Text string `json:"text"`
			}{{Type: "text", Text: `{"probability": 0.72, "confidence": 0.85}`}},
			Usage: struct {
				InputTokens  int `json:"input_tokens"`
				OutputTokens int `json:"output_tokens"`
			}{InputTokens: 100, OutputTokens: 30},
		})
	}))
	defer srv.Close()

	client := NewClaudeClient(ClaudeConfig{APIKey: "test-key", BaseURL: srv.URL})

	var result struct {
		Probability float64 `json:"probability"`
		Confidence  float64 `json:"confidence"`
	}
	err := client.CompleteJSON(context.Background(), CompletionRequest{
		UserPrompt: "Estimate probability",
	}, &result)
	if err != nil {
		t.Fatalf("CompleteJSON() error: %v", err)
	}
	if result.Probability != 0.72 {
		t.Errorf("expected probability 0.72, got %f", result.Probability)
	}
}

func TestStripCodeFences(t *testing.T) {
	tests := []struct {
		input string
		want  string
	}{
		{`{"a": 1}`, `{"a": 1}`},
		{"```json\n{\"a\": 1}\n```", `{"a": 1}`},
		{"Here is the JSON:\n{\"a\": 1}\nDone.", `{"a": 1}`},
	}
	for _, tt := range tests {
		got := stripCodeFences(tt.input)
		if got != tt.want {
			t.Errorf("stripCodeFences(%q) = %q, want %q", tt.input, got, tt.want)
		}
	}
}
```

## Done When

- [ ] All requirements met
- [ ] `internal/analysis/llm.go` defines the `LLMClient` interface with `Complete` and `CompleteJSON`
- [ ] `internal/analysis/claude.go` implements `LLMClient` using the Anthropic Messages API
- [ ] Rate limiting is active (uses `golang.org/x/time/rate`)
- [ ] Token usage tracking works (atomic counters)
- [ ] `CompleteJSON` correctly parses JSON from LLM responses, including stripping code fences
- [ ] `go test ./internal/analysis/...` passes
