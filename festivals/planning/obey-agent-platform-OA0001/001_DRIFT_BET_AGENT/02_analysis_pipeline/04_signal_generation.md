---
fest_type: task
fest_id: 04_signal_generation.md
fest_name: signal_generation
fest_parent: 02_analysis_pipeline
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.298134-06:00
fest_tracking: true
---

# Task: Signal Generation Strategy

## Objective

Implement the `ResolutionHunterStrategy` that uses the analysis pipeline to generate trading signals for mispriced Drift BET markets, producing buy/sell signals with edge estimates, confidence scores, and position size recommendations.

## Requirements

- [ ] Implement `strategies.Strategy` interface as `ResolutionHunterStrategy`
- [ ] Integrate normalizer filtering with resolution analysis
- [ ] Generate signals only when edge exceeds minimum threshold
- [ ] Position sizing based on Kelly criterion (fraction of edge * confidence)
- [ ] Rank signals by expected value (edge * confidence) and return top N
- [ ] Skip markets already held (avoid doubling down without explicit logic)
- [ ] Logging of all analyzed markets and rejected signals for debugging

## Implementation

### Step 1: Implement the Resolution Hunter Strategy

Create file `projects/agent-prediction/internal/strategies/resolution_hunter.go`:

```go
package strategies

import (
	"context"
	"fmt"
	"log/slog"
	"sort"

	"github.com/lancekrogers/agent-prediction/internal/adapters"
	"github.com/lancekrogers/agent-prediction/internal/analysis"
)

// ResolutionHunterConfig configures the resolution hunter strategy.
type ResolutionHunterConfig struct {
	// MinEdge is the minimum estimated edge to generate a signal.
	// Default: 0.05 (5%)
	MinEdge float64

	// MinConfidence is the minimum confidence to generate a signal.
	// Default: 0.5
	MinConfidence float64

	// MaxSignals is the maximum number of signals to return per cycle.
	// Default: 5
	MaxSignals int

	// MaxPositionPct is the maximum position size as fraction of portfolio.
	// Default: 0.05 (5%)
	MaxPositionPct float64

	// KellyFraction is the fraction of full Kelly to use for sizing.
	// Full Kelly is aggressive; 0.25 (quarter Kelly) is conservative.
	// Default: 0.25
	KellyFraction float64
}

// ResolutionHunterStrategy finds mispriced markets by analyzing resolution rules.
// It uses Claude to parse resolution criteria, identify divergences between
// market titles and actual rules, and estimate true probabilities.
type ResolutionHunterStrategy struct {
	cfg        ResolutionHunterConfig
	normalizer *analysis.Normalizer
	analyzer   *analysis.ResolutionAnalyzer
	log        *slog.Logger
}

// NewResolutionHunterStrategy creates a new resolution hunter strategy.
func NewResolutionHunterStrategy(
	cfg ResolutionHunterConfig,
	normalizer *analysis.Normalizer,
	analyzer *analysis.ResolutionAnalyzer,
	log *slog.Logger,
) *ResolutionHunterStrategy {
	if cfg.MinEdge == 0 {
		cfg.MinEdge = 0.05
	}
	if cfg.MinConfidence == 0 {
		cfg.MinConfidence = 0.5
	}
	if cfg.MaxSignals == 0 {
		cfg.MaxSignals = 5
	}
	if cfg.MaxPositionPct == 0 {
		cfg.MaxPositionPct = 0.05
	}
	if cfg.KellyFraction == 0 {
		cfg.KellyFraction = 0.25
	}
	return &ResolutionHunterStrategy{
		cfg:        cfg,
		normalizer: normalizer,
		analyzer:   analyzer,
		log:        log,
	}
}

// Name returns the strategy identifier.
func (s *ResolutionHunterStrategy) Name() string {
	return "resolution_hunter"
}

// Evaluate analyzes markets through the resolution pipeline and returns trading signals.
func (s *ResolutionHunterStrategy) Evaluate(
	ctx context.Context,
	markets []adapters.NormalizedMarket,
) ([]adapters.Signal, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("resolution_hunter: context cancelled: %w", err)
	}

	// Step 1: Filter and enrich markets
	enriched, err := s.normalizer.Filter(ctx, markets)
	if err != nil {
		return nil, fmt.Errorf("resolution_hunter: filter markets: %w", err)
	}

	s.log.Info("resolution_hunter: filtered markets",
		"input", len(markets),
		"passed", len(enriched))

	// Step 2: Analyze each market with LLM
	type scoredSignal struct {
		signal        adapters.Signal
		expectedValue float64
	}

	var candidates []scoredSignal

	for _, em := range enriched {
		if err := ctx.Err(); err != nil {
			return nil, fmt.Errorf("resolution_hunter: context cancelled during analysis: %w", err)
		}

		result, err := s.analyzer.FullAnalysis(ctx, em.NormalizedMarket)
		if err != nil {
			s.log.Warn("resolution_hunter: analysis failed, skipping",
				"market", em.ID, "error", err)
			continue
		}

		edge := result.Edge
		absEdge := edge
		if absEdge < 0 {
			absEdge = -absEdge
		}

		s.log.Info("resolution_hunter: analyzed market",
			"market", em.ID,
			"question", em.Question,
			"market_price", result.MarketPrice,
			"our_estimate", result.Estimate.Probability,
			"edge", edge,
			"confidence", result.Estimate.Confidence)

		// Step 3: Filter by minimum edge and confidence
		if absEdge < s.cfg.MinEdge {
			s.log.Debug("resolution_hunter: edge too small",
				"market", em.ID, "edge", absEdge, "min", s.cfg.MinEdge)
			continue
		}
		if result.Estimate.Confidence < s.cfg.MinConfidence {
			s.log.Debug("resolution_hunter: confidence too low",
				"market", em.ID, "confidence", result.Estimate.Confidence)
			continue
		}

		// Step 4: Determine direction
		direction := "buy"
		outcomeID := ""
		if len(em.Outcomes) > 0 {
			outcomeID = em.Outcomes[0].ID // YES outcome
		}

		if edge < 0 {
			// Our estimate is lower than market price: market is overpriced
			// Buy NO (or sell YES)
			direction = "buy"
			if len(em.Outcomes) > 1 {
				outcomeID = em.Outcomes[1].ID // NO outcome
			}
			edge = -edge // make positive for sizing
		}

		// Step 5: Position sizing using fractional Kelly
		// Kelly fraction = (p * b - q) / b where p = our prob, b = odds, q = 1-p
		// For binary prediction markets: kelly = edge / (1 - market_price)
		kellySize := edge / (1 - result.MarketPrice)
		if kellySize > 1 {
			kellySize = 1
		}
		positionPct := kellySize * s.cfg.KellyFraction
		if positionPct > s.cfg.MaxPositionPct {
			positionPct = s.cfg.MaxPositionPct
		}

		expectedValue := edge * result.Estimate.Confidence

		signal := adapters.Signal{
			MarketID:  em.ID,
			Platform:  em.Platform,
			Direction: direction,
			OutcomeID: outcomeID,
			Size:      positionPct, // As fraction of portfolio; agent loop converts to USD
			Edge:      edge,
			Reason: fmt.Sprintf(
				"Resolution hunter: %s — estimate %.2f vs market %.2f (edge %.1f%%, confidence %.0f%%)",
				em.Question,
				result.Estimate.Probability,
				result.MarketPrice,
				edge*100,
				result.Estimate.Confidence*100,
			),
		}

		candidates = append(candidates, scoredSignal{
			signal:        signal,
			expectedValue: expectedValue,
		})
	}

	// Step 6: Rank by expected value and return top N
	sort.Slice(candidates, func(i, j int) bool {
		return candidates[i].expectedValue > candidates[j].expectedValue
	})

	maxSignals := s.cfg.MaxSignals
	if len(candidates) < maxSignals {
		maxSignals = len(candidates)
	}

	signals := make([]adapters.Signal, maxSignals)
	for i := 0; i < maxSignals; i++ {
		signals[i] = candidates[i].signal
	}

	s.log.Info("resolution_hunter: generated signals",
		"candidates", len(candidates),
		"returned", len(signals))

	return signals, nil
}
```

### Step 2: Create Tests

Create file `projects/agent-prediction/internal/strategies/resolution_hunter_test.go`:

```go
package strategies

import (
	"context"
	"encoding/json"
	"log/slog"
	"os"
	"testing"
	"time"

	"github.com/lancekrogers/agent-prediction/internal/adapters"
	"github.com/lancekrogers/agent-prediction/internal/analysis"
)

// mockLLM for strategy tests
type mockLLM struct {
	responses []string
	callIdx   int
}

func (m *mockLLM) Complete(ctx context.Context, req analysis.CompletionRequest) (*analysis.CompletionResponse, error) {
	resp := m.responses[m.callIdx%len(m.responses)]
	m.callIdx++
	return &analysis.CompletionResponse{Content: resp}, nil
}

func (m *mockLLM) CompleteJSON(ctx context.Context, req analysis.CompletionRequest, target interface{}) error {
	resp := m.responses[m.callIdx%len(m.responses)]
	m.callIdx++
	return json.Unmarshal([]byte(resp), target)
}

func TestResolutionHunterStrategy(t *testing.T) {
	ruleResp := `{"yes_conditions":["BTC > $100K"],"no_conditions":["BTC <= $100K"],"edge_cases":[],"data_sources":["CoinGecko"],"ambiguities":[],"resolution_timeline":"June 2026","title_rule_divergence":0.1,"rule_clarity":0.9}`
	probResp := `{"probability":0.80,"confidence":0.75,"reasoning":"Bull market","key_factors":["momentum"],"information_gaps":[]}`

	llm := &mockLLM{responses: []string{ruleResp, probResp}}
	normalizer := analysis.NewNormalizer(analysis.NormalizerConfig{
		MinVolume24h: 100, // low for tests
		MinLiquidity: 100,
	})
	analyzer := analysis.NewResolutionAnalyzer(llm, 5*time.Minute)
	log := slog.New(slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{Level: slog.LevelDebug}))

	strategy := NewResolutionHunterStrategy(
		ResolutionHunterConfig{
			MinEdge:       0.05,
			MinConfidence: 0.5,
			MaxSignals:    3,
		},
		normalizer,
		analyzer,
		log,
	)

	if strategy.Name() != "resolution_hunter" {
		t.Errorf("expected name 'resolution_hunter', got %q", strategy.Name())
	}

	markets := []adapters.NormalizedMarket{
		{
			ID:             "drift_bet:0",
			Platform:       "drift_bet",
			Question:       "Will BTC exceed $100K?",
			Category:       "crypto",
			EndDate:        time.Now().Add(14 * 24 * time.Hour).Format(time.RFC3339),
			Volume:         50000,
			Liquidity:      10000,
			ResolutionRule: "Resolves YES if BTC > $100K on CoinGecko",
			Outcomes: []adapters.Outcome{
				{ID: "0:yes", Label: "Yes", Price: 0.65},
				{ID: "0:no", Label: "No", Price: 0.35},
			},
		},
	}

	signals, err := strategy.Evaluate(context.Background(), markets)
	if err != nil {
		t.Fatalf("Evaluate() error: %v", err)
	}

	// Market price 0.65, our estimate 0.80 → edge 0.15 → should generate signal
	if len(signals) == 0 {
		t.Fatal("expected at least 1 signal")
	}

	sig := signals[0]
	if sig.MarketID != "drift_bet:0" {
		t.Errorf("expected market drift_bet:0, got %s", sig.MarketID)
	}
	if sig.Direction != "buy" {
		t.Errorf("expected direction 'buy' (YES is underpriced), got %s", sig.Direction)
	}
	if sig.Edge < 0.10 {
		t.Errorf("expected edge >= 0.10, got %f", sig.Edge)
	}
}

func TestResolutionHunterStrategy_NoEdge(t *testing.T) {
	// Market price matches estimate — no signal expected
	ruleResp := `{"yes_conditions":["cond"],"no_conditions":["cond"],"edge_cases":[],"data_sources":[],"ambiguities":[],"resolution_timeline":"","title_rule_divergence":0.0,"rule_clarity":0.9}`
	probResp := `{"probability":0.65,"confidence":0.75,"reasoning":"matches market","key_factors":[],"information_gaps":[]}`

	llm := &mockLLM{responses: []string{ruleResp, probResp}}
	normalizer := analysis.NewNormalizer(analysis.NormalizerConfig{MinVolume24h: 100, MinLiquidity: 100})
	analyzer := analysis.NewResolutionAnalyzer(llm, 5*time.Minute)
	log := slog.New(slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{Level: slog.LevelWarn}))

	strategy := NewResolutionHunterStrategy(
		ResolutionHunterConfig{MinEdge: 0.05},
		normalizer, analyzer, log,
	)

	markets := []adapters.NormalizedMarket{{
		ID: "drift_bet:0", Question: "Test?", Category: "crypto",
		EndDate: time.Now().Add(14 * 24 * time.Hour).Format(time.RFC3339),
		Volume: 50000, Liquidity: 10000, ResolutionRule: "rule",
		Outcomes: []adapters.Outcome{{ID: "0:yes", Price: 0.65}, {ID: "0:no", Price: 0.35}},
	}}

	signals, err := strategy.Evaluate(context.Background(), markets)
	if err != nil {
		t.Fatalf("Evaluate() error: %v", err)
	}
	if len(signals) != 0 {
		t.Errorf("expected 0 signals when no edge, got %d", len(signals))
	}
}
```

## Done When

- [ ] All requirements met
- [ ] `internal/strategies/resolution_hunter.go` implements `strategies.Strategy`
- [ ] Strategy integrates normalizer filtering with LLM resolution analysis
- [ ] Signals include edge estimate, confidence, position sizing, and reasoning
- [ ] Position sizing uses fractional Kelly criterion with configurable fraction
- [ ] Signals are ranked by expected value (edge * confidence)
- [ ] `go test ./internal/strategies/...` passes
- [ ] Strategy correctly identifies buy YES vs buy NO based on edge direction
