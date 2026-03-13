---
fest_type: task
fest_id: 02_market_normalization.md
fest_name: market_normalization
fest_parent: 02_analysis_pipeline
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.297625-06:00
fest_tracking: true
---

# Task: Market Normalization Pipeline

## Objective

Implement the market normalization layer that converts raw Drift BET market data into the `adapters.NormalizedMarket` format with enriched metadata, category classification, and filtering for markets worth analyzing.

## Requirements

- [ ] Filter markets by minimum volume, liquidity, and time to expiry
- [ ] Category classification (crypto, politics, sports, macro, geopolitics)
- [ ] Spread calculation from orderbook data
- [ ] Market quality scoring (composite of volume, liquidity, spread, time-to-expiry)
- [ ] Deduplication of markets (same event, different phrasing)
- [ ] Conversion from Drift BET types to `adapters.NormalizedMarket`

## Implementation

### Step 1: Create Market Filter and Normalizer

Create file `projects/agent-prediction/internal/analysis/normalizer.go`:

```go
package analysis

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/lancekrogers/agent-prediction/internal/adapters"
)

// NormalizerConfig controls which markets pass through the normalization filter.
type NormalizerConfig struct {
	// MinVolume24h is the minimum 24h volume in USD to consider a market.
	// Default: 1000
	MinVolume24h float64

	// MinLiquidity is the minimum liquidity depth in USD.
	// Default: 500
	MinLiquidity float64

	// MaxSpread is the maximum bid-ask spread (0.0-1.0) to consider a market.
	// Default: 0.15 (15 cents)
	MaxSpread float64

	// MinTimeToExpiry is the minimum time before market expiry to trade.
	// Default: 2h
	MinTimeToExpiry time.Duration

	// MaxTimeToExpiry is the maximum time before market expiry (skip far-out markets for MVP).
	// Default: 90 days
	MaxTimeToExpiry time.Duration
}

// Normalizer filters and enriches prediction markets for analysis.
type Normalizer struct {
	cfg NormalizerConfig
}

// NewNormalizer creates a market normalizer with the given config.
func NewNormalizer(cfg NormalizerConfig) *Normalizer {
	if cfg.MinVolume24h == 0 {
		cfg.MinVolume24h = 1000
	}
	if cfg.MinLiquidity == 0 {
		cfg.MinLiquidity = 500
	}
	if cfg.MaxSpread == 0 {
		cfg.MaxSpread = 0.15
	}
	if cfg.MinTimeToExpiry == 0 {
		cfg.MinTimeToExpiry = 2 * time.Hour
	}
	if cfg.MaxTimeToExpiry == 0 {
		cfg.MaxTimeToExpiry = 90 * 24 * time.Hour
	}
	return &Normalizer{cfg: cfg}
}

// MarketQuality contains quality metrics for a normalized market.
type MarketQuality struct {
	// Score is a composite quality score from 0.0-1.0.
	Score float64

	// VolumeScore is the volume component (0.0-1.0).
	VolumeScore float64

	// LiquidityScore is the liquidity component (0.0-1.0).
	LiquidityScore float64

	// SpreadScore is the spread component (0.0-1.0, tighter = higher).
	SpreadScore float64

	// TimeScore is the time-to-expiry component (0.0-1.0).
	TimeScore float64
}

// EnrichedMarket wraps a NormalizedMarket with quality metadata.
type EnrichedMarket struct {
	adapters.NormalizedMarket
	Quality  MarketQuality
	Category string
	Spread   float64
	TimeToExpiry time.Duration
}

// Filter returns only markets that meet the minimum quality criteria.
func (n *Normalizer) Filter(ctx context.Context, markets []adapters.NormalizedMarket) ([]EnrichedMarket, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("normalizer: context cancelled: %w", err)
	}

	var enriched []EnrichedMarket
	for _, m := range markets {
		em, ok := n.enrich(m)
		if !ok {
			continue // filtered out
		}
		enriched = append(enriched, em)
	}
	return enriched, nil
}

// enrich evaluates a market against quality criteria and returns an EnrichedMarket.
// Returns false if the market should be filtered out.
func (n *Normalizer) enrich(m adapters.NormalizedMarket) (EnrichedMarket, bool) {
	// Parse expiry time
	expiry, err := time.Parse(time.RFC3339, m.EndDate)
	if err != nil {
		return EnrichedMarket{}, false
	}
	timeToExpiry := time.Until(expiry)

	// Filter: time to expiry
	if timeToExpiry < n.cfg.MinTimeToExpiry || timeToExpiry > n.cfg.MaxTimeToExpiry {
		return EnrichedMarket{}, false
	}

	// Filter: volume
	if m.Volume < n.cfg.MinVolume24h {
		return EnrichedMarket{}, false
	}

	// Filter: liquidity
	if m.Liquidity < n.cfg.MinLiquidity {
		return EnrichedMarket{}, false
	}

	// Calculate spread from outcomes
	spread := 0.0
	if len(m.Outcomes) >= 2 {
		spread = 1.0 - (m.Outcomes[0].Price + m.Outcomes[1].Price)
		if spread < 0 {
			spread = -spread
		}
	}

	// Filter: spread
	if spread > n.cfg.MaxSpread {
		return EnrichedMarket{}, false
	}

	// Classify category
	category := classifyCategory(m.Question, m.Category)

	// Calculate quality scores
	quality := n.calculateQuality(m, spread, timeToExpiry)

	return EnrichedMarket{
		NormalizedMarket: m,
		Quality:          quality,
		Category:         category,
		Spread:           spread,
		TimeToExpiry:     timeToExpiry,
	}, true
}

// calculateQuality computes a composite quality score.
func (n *Normalizer) calculateQuality(m adapters.NormalizedMarket, spread float64, tte time.Duration) MarketQuality {
	// Volume score: log scale, max at $100K
	volumeScore := clamp(m.Volume / 100000, 0, 1)

	// Liquidity score: log scale, max at $50K
	liquidityScore := clamp(m.Liquidity / 50000, 0, 1)

	// Spread score: tighter is better, inverted
	spreadScore := clamp(1.0 - (spread / n.cfg.MaxSpread), 0, 1)

	// Time score: prefer 1-30 day markets for MVP
	tteDays := tte.Hours() / 24
	timeScore := 0.0
	if tteDays >= 1 && tteDays <= 30 {
		timeScore = 1.0
	} else if tteDays < 1 {
		timeScore = tteDays // ramps up from 0 to 1 over 24h
	} else {
		timeScore = clamp(1.0 - (tteDays - 30) / 60, 0, 1) // decays after 30 days
	}

	// Composite: weighted average
	composite := volumeScore*0.3 + liquidityScore*0.25 + spreadScore*0.25 + timeScore*0.2

	return MarketQuality{
		Score:          composite,
		VolumeScore:    volumeScore,
		LiquidityScore: liquidityScore,
		SpreadScore:    spreadScore,
		TimeScore:      timeScore,
	}
}

// classifyCategory determines the market category from question text.
func classifyCategory(question, existingCategory string) string {
	if existingCategory != "" {
		return existingCategory
	}

	q := strings.ToLower(question)

	cryptoKeywords := []string{"btc", "bitcoin", "eth", "ethereum", "sol", "solana", "crypto", "defi", "token", "nft"}
	for _, kw := range cryptoKeywords {
		if strings.Contains(q, kw) {
			return "crypto"
		}
	}

	politicsKeywords := []string{"president", "election", "congress", "senate", "vote", "trump", "biden", "democrat", "republican", "governor"}
	for _, kw := range politicsKeywords {
		if strings.Contains(q, kw) {
			return "politics"
		}
	}

	sportsKeywords := []string{"nba", "nfl", "mlb", "championship", "super bowl", "world cup", "game", "match", "score"}
	for _, kw := range sportsKeywords {
		if strings.Contains(q, kw) {
			return "sports"
		}
	}

	macroKeywords := []string{"fed", "interest rate", "inflation", "gdp", "unemployment", "cpi", "fomc", "rate cut", "rate hike"}
	for _, kw := range macroKeywords {
		if strings.Contains(q, kw) {
			return "macro"
		}
	}

	geoKeywords := []string{"war", "conflict", "sanctions", "tariff", "nato", "un ", "treaty", "ceasefire"}
	for _, kw := range geoKeywords {
		if strings.Contains(q, kw) {
			return "geopolitics"
		}
	}

	return "other"
}

func clamp(v, min, max float64) float64 {
	if v < min {
		return min
	}
	if v > max {
		return max
	}
	return v
}
```

### Step 2: Create Normalizer Tests

Create file `projects/agent-prediction/internal/analysis/normalizer_test.go`:

```go
package analysis

import (
	"context"
	"testing"
	"time"

	"github.com/lancekrogers/agent-prediction/internal/adapters"
)

func TestNormalizerFilter(t *testing.T) {
	normalizer := NewNormalizer(NormalizerConfig{
		MinVolume24h: 1000,
		MinLiquidity: 500,
		MaxSpread:    0.15,
	})

	futureDate := time.Now().Add(7 * 24 * time.Hour).Format(time.RFC3339)
	pastDate := time.Now().Add(-1 * time.Hour).Format(time.RFC3339)

	markets := []adapters.NormalizedMarket{
		{
			ID: "drift_bet:0", Question: "Will BTC exceed $100K?",
			EndDate: futureDate, Volume: 50000, Liquidity: 10000,
			Outcomes: []adapters.Outcome{{Price: 0.65}, {Price: 0.35}},
		},
		{
			ID: "drift_bet:1", Question: "Low volume market",
			EndDate: futureDate, Volume: 100, Liquidity: 10000,
			Outcomes: []adapters.Outcome{{Price: 0.50}, {Price: 0.50}},
		},
		{
			ID: "drift_bet:2", Question: "Expired market",
			EndDate: pastDate, Volume: 50000, Liquidity: 10000,
			Outcomes: []adapters.Outcome{{Price: 0.50}, {Price: 0.50}},
		},
	}

	enriched, err := normalizer.Filter(context.Background(), markets)
	if err != nil {
		t.Fatalf("Filter() error: %v", err)
	}

	if len(enriched) != 1 {
		t.Fatalf("expected 1 market to pass filter, got %d", len(enriched))
	}
	if enriched[0].ID != "drift_bet:0" {
		t.Errorf("expected market drift_bet:0 to pass, got %s", enriched[0].ID)
	}
}

func TestClassifyCategory(t *testing.T) {
	tests := []struct {
		question string
		want     string
	}{
		{"Will BTC exceed $100K by June?", "crypto"},
		{"Will Trump win the 2028 election?", "politics"},
		{"Will the Fed cut rates in March?", "macro"},
		{"Will NATO expand to include Ukraine?", "geopolitics"},
		{"Will the Lakers win the NBA championship?", "sports"},
		{"Will it rain tomorrow?", "other"},
	}

	for _, tt := range tests {
		got := classifyCategory(tt.question, "")
		if got != tt.want {
			t.Errorf("classifyCategory(%q) = %q, want %q", tt.question, got, tt.want)
		}
	}
}
```

## Done When

- [ ] All requirements met
- [ ] `internal/analysis/normalizer.go` filters markets by volume, liquidity, spread, and time
- [ ] Quality scoring produces a composite 0.0-1.0 score per market
- [ ] Category classification works for crypto, politics, sports, macro, geopolitics
- [ ] `go test ./internal/analysis/...` passes with normalizer tests green
- [ ] Filtered markets are wrapped in `EnrichedMarket` with quality metadata
