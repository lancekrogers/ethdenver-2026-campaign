---
fest_type: task
fest_id: 03_resolution_analysis.md
fest_name: resolution_analysis
fest_parent: 02_analysis_pipeline
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.297874-06:00
fest_tracking: true
---

# Task: LLM-Powered Resolution Rule Analysis

## Objective

Implement the resolution rule analysis engine that uses Claude to parse prediction market resolution rules, identify edge cases, compare rules against market titles, and detect mispricing opportunities where traders misread the resolution criteria.

## Requirements

- [ ] Resolution rule parser that uses Claude to extract structured conditions
- [ ] Title-vs-rule divergence detector (key edge-finding strategy)
- [ ] Probability estimation combining resolution analysis with current data
- [ ] Structured output types for rule analysis results
- [ ] Caching of analysis results to avoid redundant LLM calls for the same market
- [ ] System prompts optimized for prediction market analysis

## Implementation

### Step 1: Define Resolution Analysis Types

Create file `projects/agent-prediction/internal/analysis/resolution.go`:

```go
package analysis

import (
	"context"
	"crypto/sha256"
	"fmt"
	"sync"
	"time"

	"github.com/lancekrogers/agent-prediction/internal/adapters"
)

// RuleAnalysis contains the structured output from resolution rule parsing.
type RuleAnalysis struct {
	// YesConditions lists the specific conditions that trigger YES resolution.
	YesConditions []string `json:"yes_conditions"`

	// NoConditions lists the specific conditions that trigger NO resolution.
	NoConditions []string `json:"no_conditions"`

	// EdgeCases describes scenarios where the title might mislead traders.
	EdgeCases []string `json:"edge_cases"`

	// DataSources lists what data would definitively resolve this market.
	DataSources []string `json:"data_sources"`

	// Ambiguities notes any ambiguous language in the resolution rules.
	Ambiguities []string `json:"ambiguities"`

	// ResolutionTimeline describes when and how resolution will occur.
	ResolutionTimeline string `json:"resolution_timeline"`

	// TitleRuleDivergence is 0.0-1.0 indicating how much the title differs
	// from actual resolution rules. Higher = more potential for mispricing.
	TitleRuleDivergence float64 `json:"title_rule_divergence"`

	// RuleClarity is 0.0-1.0 indicating how clear/unambiguous the rules are.
	RuleClarity float64 `json:"rule_clarity"`
}

// ProbabilityEstimate is the LLM's assessment of a market's true probability.
type ProbabilityEstimate struct {
	// Probability is the estimated true probability (0.0-1.0).
	Probability float64 `json:"probability"`

	// Confidence is how confident the model is in this estimate (0.0-1.0).
	Confidence float64 `json:"confidence"`

	// Reasoning explains the logic behind the estimate.
	Reasoning string `json:"reasoning"`

	// KeyFactors lists the main factors influencing the estimate.
	KeyFactors []string `json:"key_factors"`

	// InformationGaps lists what data is missing that would improve the estimate.
	InformationGaps []string `json:"information_gaps"`
}

// AnalysisResult combines rule analysis with probability estimation.
type AnalysisResult struct {
	MarketID      string
	RuleAnalysis  RuleAnalysis
	Estimate      ProbabilityEstimate
	MarketPrice   float64
	Edge          float64 // estimate - market price
	AnalyzedAt    time.Time
}

// ResolutionAnalyzer performs LLM-powered market analysis.
type ResolutionAnalyzer struct {
	llm   LLMClient

	// Cache analyzed results by market content hash
	cacheMu sync.RWMutex
	cache   map[string]*AnalysisResult
	cacheTTL time.Duration
}

// NewResolutionAnalyzer creates a resolution analyzer with the given LLM client.
func NewResolutionAnalyzer(llm LLMClient, cacheTTL time.Duration) *ResolutionAnalyzer {
	if cacheTTL == 0 {
		cacheTTL = 30 * time.Minute
	}
	return &ResolutionAnalyzer{
		llm:      llm,
		cache:    make(map[string]*AnalysisResult),
		cacheTTL: cacheTTL,
	}
}

// AnalyzeRules parses the resolution rules for a market and extracts structured conditions.
func (a *ResolutionAnalyzer) AnalyzeRules(ctx context.Context, market adapters.NormalizedMarket) (*RuleAnalysis, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("resolution: context cancelled: %w", err)
	}

	prompt := fmt.Sprintf(`Analyze these prediction market resolution rules precisely.

Market Question: %s

Resolution Rules:
%s

Respond with a JSON object containing:
{
  "yes_conditions": ["list of specific conditions that trigger YES"],
  "no_conditions": ["list of specific conditions that trigger NO"],
  "edge_cases": ["scenarios where the title suggests one outcome but rules specify another"],
  "data_sources": ["what data sources would definitively resolve this"],
  "ambiguities": ["any ambiguous language in the rules"],
  "resolution_timeline": "when and how resolution occurs",
  "title_rule_divergence": 0.0-1.0,
  "rule_clarity": 0.0-1.0
}

Be precise. The rules, not the title, determine the outcome. Focus on edge cases where traders reading only the title would misjudge the outcome.`,
		market.Question, market.ResolutionRule)

	var result RuleAnalysis
	err := a.llm.CompleteJSON(ctx, CompletionRequest{
		SystemPrompt: resolutionSystemPrompt,
		UserPrompt:   prompt,
		MaxTokens:    1500,
		Temperature:  0.2,
	}, &result)
	if err != nil {
		return nil, fmt.Errorf("resolution: rule analysis failed: %w", err)
	}

	return &result, nil
}

// EstimateProbability uses the LLM to estimate the true probability of a market outcome.
func (a *ResolutionAnalyzer) EstimateProbability(
	ctx context.Context,
	market adapters.NormalizedMarket,
	rules *RuleAnalysis,
) (*ProbabilityEstimate, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("resolution: context cancelled: %w", err)
	}

	prompt := fmt.Sprintf(`Given this prediction market, estimate the true probability of YES.

Market: %s
Current YES Price: %.2f (market's implied probability)
Category: %s
Expires: %s

Resolution Analysis:
- YES conditions: %v
- NO conditions: %v
- Edge cases: %v
- Rule clarity: %.2f

Based on your knowledge and the resolution rules, estimate the TRUE probability.
Consider: Is the market overpriced or underpriced?

Respond with JSON:
{
  "probability": 0.XX,
  "confidence": 0.XX,
  "reasoning": "explanation",
  "key_factors": ["factor1", "factor2"],
  "information_gaps": ["missing data that would help"]
}`,
		market.Question,
		market.Outcomes[0].Price,
		market.Category,
		market.EndDate,
		rules.YesConditions,
		rules.NoConditions,
		rules.EdgeCases,
		rules.RuleClarity)

	var estimate ProbabilityEstimate
	err := a.llm.CompleteJSON(ctx, CompletionRequest{
		SystemPrompt: probabilitySystemPrompt,
		UserPrompt:   prompt,
		MaxTokens:    1000,
		Temperature:  0.3,
	}, &estimate)
	if err != nil {
		return nil, fmt.Errorf("resolution: probability estimation failed: %w", err)
	}

	return &estimate, nil
}

// FullAnalysis performs both rule analysis and probability estimation with caching.
func (a *ResolutionAnalyzer) FullAnalysis(
	ctx context.Context,
	market adapters.NormalizedMarket,
) (*AnalysisResult, error) {
	// Check cache
	cacheKey := marketHash(market)
	a.cacheMu.RLock()
	if cached, ok := a.cache[cacheKey]; ok && time.Since(cached.AnalyzedAt) < a.cacheTTL {
		a.cacheMu.RUnlock()
		return cached, nil
	}
	a.cacheMu.RUnlock()

	// Analyze rules
	rules, err := a.AnalyzeRules(ctx, market)
	if err != nil {
		return nil, err
	}

	// Estimate probability
	estimate, err := a.EstimateProbability(ctx, market, rules)
	if err != nil {
		return nil, err
	}

	marketPrice := 0.0
	if len(market.Outcomes) > 0 {
		marketPrice = market.Outcomes[0].Price
	}

	result := &AnalysisResult{
		MarketID:     market.ID,
		RuleAnalysis: *rules,
		Estimate:     *estimate,
		MarketPrice:  marketPrice,
		Edge:         estimate.Probability - marketPrice,
		AnalyzedAt:   time.Now(),
	}

	// Update cache
	a.cacheMu.Lock()
	a.cache[cacheKey] = result
	a.cacheMu.Unlock()

	return result, nil
}

// marketHash creates a stable hash of market content for cache keys.
func marketHash(m adapters.NormalizedMarket) string {
	data := fmt.Sprintf("%s:%s:%s", m.ID, m.Question, m.ResolutionRule)
	h := sha256.Sum256([]byte(data))
	return fmt.Sprintf("%x", h[:8])
}

// System prompts for different analysis tasks.
const resolutionSystemPrompt = `You are an expert prediction market analyst specializing in resolution rule interpretation.

Your job is to parse resolution rules with extreme precision. Traders often misread markets because they focus on the title instead of the actual resolution criteria.

Key principles:
1. The RULES determine the outcome, not the title.
2. Look for edge cases where the title implies one thing but the rules specify another.
3. Identify ambiguous language that could lead to disputed resolution.
4. Note specific data sources that would definitively resolve the market.
5. Quantify how much the title diverges from the actual rules (title_rule_divergence).

Always respond with valid JSON.`

const probabilitySystemPrompt = `You are a superforecaster with expertise in calibrated probability estimation.

Your job is to estimate the TRUE probability of prediction market outcomes. You combine:
1. Resolution rule analysis (the rules, not the title, determine outcome)
2. Current world knowledge and recent events
3. Base rates for similar event types
4. Understanding of common forecasting biases

Key principles:
- Be well-calibrated: when you say 70%, events should happen ~70% of the time
- Account for uncertainty explicitly
- Identify where your estimate differs from the market price and explain why
- Flag information gaps that prevent high-confidence estimates
- Extreme probabilities (>0.90 or <0.10) require strong justification

Always respond with valid JSON.`
```

### Step 2: Create Tests

Create file `projects/agent-prediction/internal/analysis/resolution_test.go`:

```go
package analysis

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/lancekrogers/agent-prediction/internal/adapters"
)

// mockLLM implements LLMClient for testing.
type mockLLM struct {
	response string
	err      error
}

func (m *mockLLM) Complete(ctx context.Context, req CompletionRequest) (*CompletionResponse, error) {
	return &CompletionResponse{Content: m.response}, m.err
}

func (m *mockLLM) CompleteJSON(ctx context.Context, req CompletionRequest, target interface{}) error {
	if m.err != nil {
		return m.err
	}
	return json.Unmarshal([]byte(m.response), target)
}

func TestResolutionAnalyzer_FullAnalysis(t *testing.T) {
	// Mock that returns rule analysis first, then probability estimate
	callCount := 0
	llm := &mockLLM{}

	analyzer := NewResolutionAnalyzer(llm, 5*time.Minute)

	market := adapters.NormalizedMarket{
		ID:             "drift_bet:0",
		Question:       "Will BTC exceed $100K by June 2026?",
		ResolutionRule: "Resolves YES if Bitcoin price on CoinGecko exceeds $100,000 at any point before June 30, 2026 23:59 UTC.",
		Outcomes:       []adapters.Outcome{{Price: 0.65}, {Price: 0.35}},
		EndDate:        time.Now().Add(90 * 24 * time.Hour).Format(time.RFC3339),
	}

	// Set up sequential mock responses
	ruleJSON := `{"yes_conditions":["BTC > $100K on CoinGecko before June 30 2026"],"no_conditions":["BTC never exceeds $100K before deadline"],"edge_cases":["Uses CoinGecko specifically, not other exchanges"],"data_sources":["CoinGecko API"],"ambiguities":[],"resolution_timeline":"Resolves immediately upon price crossing $100K, or NO on June 30 2026","title_rule_divergence":0.1,"rule_clarity":0.9}`

	// First call: rule analysis
	llm.response = ruleJSON
	rules, err := analyzer.AnalyzeRules(context.Background(), market)
	if err != nil {
		t.Fatalf("AnalyzeRules() error: %v", err)
	}

	if len(rules.YesConditions) == 0 {
		t.Error("expected YES conditions to be populated")
	}
	if rules.RuleClarity != 0.9 {
		t.Errorf("expected rule clarity 0.9, got %f", rules.RuleClarity)
	}

	// Second call: probability estimate
	probJSON := `{"probability":0.72,"confidence":0.7,"reasoning":"BTC trending upward","key_factors":["bull market","institutional adoption"],"information_gaps":["macro conditions"]}`
	llm.response = probJSON
	estimate, err := analyzer.EstimateProbability(context.Background(), market, rules)
	if err != nil {
		t.Fatalf("EstimateProbability() error: %v", err)
	}

	if estimate.Probability != 0.72 {
		t.Errorf("expected probability 0.72, got %f", estimate.Probability)
	}

	_ = callCount // used in sequential mock
}

func TestResolutionAnalyzer_CacheHit(t *testing.T) {
	callCount := 0
	llm := &mockLLM{
		response: `{"yes_conditions":["cond"],"no_conditions":[],"edge_cases":[],"data_sources":[],"ambiguities":[],"resolution_timeline":"","title_rule_divergence":0.1,"rule_clarity":0.9}`,
	}

	analyzer := NewResolutionAnalyzer(llm, 5*time.Minute)

	market := adapters.NormalizedMarket{
		ID: "drift_bet:0", Question: "Test?", ResolutionRule: "rule",
		Outcomes: []adapters.Outcome{{Price: 0.50}},
		EndDate:  time.Now().Add(24 * time.Hour).Format(time.RFC3339),
	}

	// First call: should hit LLM
	// Override CompleteJSON to count calls
	origResponse := llm.response
	llm.response = origResponse

	_, err := analyzer.AnalyzeRules(context.Background(), market)
	if err != nil {
		t.Fatalf("first call error: %v", err)
	}
	callCount++

	// The FullAnalysis method handles caching; individual AnalyzeRules does not.
	// Testing cache via FullAnalysis requires two-step mock. This verifies the cache key logic.
	key1 := marketHash(market)
	key2 := marketHash(market)
	if key1 != key2 {
		t.Error("same market should produce same cache key")
	}

	// Different market should produce different key
	market2 := market
	market2.ID = "drift_bet:1"
	key3 := marketHash(market2)
	if key1 == key3 {
		t.Error("different markets should produce different cache keys")
	}
}
```

## Done When

- [ ] All requirements met
- [ ] `internal/analysis/resolution.go` implements `ResolutionAnalyzer` with `AnalyzeRules`, `EstimateProbability`, and `FullAnalysis`
- [ ] System prompts are optimized for rule parsing and probability estimation
- [ ] Analysis results are cached by market content hash with configurable TTL
- [ ] `RuleAnalysis` and `ProbabilityEstimate` types support JSON structured output
- [ ] `go test ./internal/analysis/...` passes with resolution tests green
