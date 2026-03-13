---
fest_type: task
fest_id: 02_arbitrage_strategy.md
fest_name: arbitrage_strategy
fest_parent: 02_cross_platform
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.588363-06:00
fest_tracking: true
---

# Task: Cross-Platform Arbitrage Strategy

## Objective

Implement the `ArbitrageStrategy` that consumes `EquivalentGroup` data from the EventMatcher, identifies price discrepancies between platforms, calculates risk-adjusted position sizes, and generates trade signals for the agent execution loop.

## Requirements

- [ ] Implements the `Strategy` interface: `Name() string`, `Analyze(ctx, StrategyInput) ([]Signal, error)`
- [ ] Minimum edge threshold: configurable, default 3% (0.03) spread to trigger arb
- [ ] Only trade groups where `ResolutionMatch == true` (compatible resolution rules)
- [ ] Position sizing: max capital per arb opportunity as percentage of NAV (configurable)
- [ ] Generate paired signals: buy cheap on platform A, sell expensive (or buy NO) on platform B
- [ ] Account for fees on both platforms when calculating net edge
- [ ] Account for bridging costs (Solana <-> Polygon, Solana <-> Base) in edge calculation
- [ ] Spread monitoring: track spread history for each equivalent group

## Implementation

### Step 1: Define ArbitrageStrategy

Create `projects/agent-prediction/internal/strategies/arbitrage.go`:

```go
package strategies

import (
    "context"
    "fmt"
    "math"

    "github.com/lancekrogers/agent-prediction/internal/engine"
)

// ArbitrageConfig holds configuration for the arbitrage strategy.
type ArbitrageConfig struct {
    MinEdge        float64 // minimum spread to trade (default 0.03 = 3%)
    MaxExposure    float64 // max capital per arb as fraction of NAV (default 0.05 = 5%)
    PolymarketFee  float64 // Polymarket taker fee (default 0.02 = 2%)
    LimitlessFee   float64 // Limitless fee (default 0.01 = 1%)
    DriftFee       float64 // Drift BET fee (default 0.001 = 0.1%)
    BridgeCostUSD  float64 // estimated bridge cost per bridge (default 0.10)
}

// DefaultArbitrageConfig returns sensible defaults.
func DefaultArbitrageConfig() ArbitrageConfig {
    return ArbitrageConfig{
        MinEdge:       0.03,
        MaxExposure:   0.05,
        PolymarketFee: 0.02,
        LimitlessFee:  0.01,
        DriftFee:      0.001,
        BridgeCostUSD: 0.10,
    }
}

// ArbitrageStrategy scans for price discrepancies across platforms.
type ArbitrageStrategy struct {
    matcher *engine.EventMatcher
    config  ArbitrageConfig
}

// NewArbitrageStrategy creates an arbitrage scanner.
func NewArbitrageStrategy(matcher *engine.EventMatcher, config ArbitrageConfig) *ArbitrageStrategy {
    return &ArbitrageStrategy{
        matcher: matcher,
        config:  config,
    }
}

func (s *ArbitrageStrategy) Name() string { return "arbitrage" }
```

### Step 2: Implement the Analyze method

```go
func (s *ArbitrageStrategy) Analyze(
    ctx context.Context,
    input engine.StrategyInput,
) ([]engine.Signal, error) {
    if err := ctx.Err(); err != nil {
        return nil, err
    }

    // Get equivalent market groups
    groups, err := s.matcher.FindEquivalentMarkets(ctx, input.Markets)
    if err != nil {
        return nil, fmt.Errorf("finding equivalent markets: %w", err)
    }

    var signals []engine.Signal

    for _, group := range groups {
        // Only arb markets with compatible resolution rules
        if !group.ResolutionMatch {
            continue
        }

        // Compare all pairs within the group
        for i := 0; i < len(group.Markets); i++ {
            for j := i + 1; j < len(group.Markets); j++ {
                m1 := group.Markets[i]
                m2 := group.Markets[j]

                // Get YES prices for both
                p1 := m1.Outcomes[0].Price // YES price on platform 1
                p2 := m2.Outcomes[0].Price // YES price on platform 2

                if p1 == 0 || p2 == 0 {
                    continue
                }

                rawSpread := math.Abs(p1 - p2)

                // Calculate net edge after fees and bridge costs
                fee1 := s.platformFee(m1.Platform)
                fee2 := s.platformFee(m2.Platform)
                bridgeCost := s.bridgeCost(m1.Platform, m2.Platform)

                netEdge := rawSpread - fee1 - fee2 - bridgeCost

                if netEdge < s.config.MinEdge {
                    continue // not enough edge after costs
                }

                // Determine direction: buy cheap, sell expensive
                var buyMarket, sellMarket engine.NormalizedMarket
                if p1 < p2 {
                    buyMarket, sellMarket = m1, m2
                } else {
                    buyMarket, sellMarket = m2, m1
                }

                // Calculate position size
                maxSize := input.PortfolioNAV * s.config.MaxExposure
                // Also constrained by available liquidity on both sides
                buyLiquidity := buyMarket.Liquidity
                sellLiquidity := sellMarket.Liquidity
                size := math.Min(maxSize, math.Min(buyLiquidity*0.1, sellLiquidity*0.1))

                // Generate buy signal (cheap side)
                signals = append(signals, engine.Signal{
                    MarketID:     buyMarket.ID,
                    Platform:     buyMarket.Platform,
                    Direction:    engine.Buy,
                    Outcome:      "yes",
                    Confidence:   group.MatchConfidence,
                    EdgeEstimate: netEdge,
                    Size:         size,
                    Strategy:     "arbitrage",
                    Reasoning: fmt.Sprintf(
                        "Arb: %s — buy YES at %.3f on %s, sell YES at %.3f on %s (%.1f%% net edge after fees/bridge)",
                        group.EventDescription,
                        buyMarket.Outcomes[0].Price, buyMarket.Platform,
                        sellMarket.Outcomes[0].Price, sellMarket.Platform,
                        netEdge*100,
                    ),
                })

                // Generate sell signal (expensive side)
                // On Polymarket this means selling YES shares or buying NO
                signals = append(signals, engine.Signal{
                    MarketID:     sellMarket.ID,
                    Platform:     sellMarket.Platform,
                    Direction:    engine.Sell,
                    Outcome:      "yes",
                    Confidence:   group.MatchConfidence,
                    EdgeEstimate: netEdge,
                    Size:         size,
                    Strategy:     "arbitrage",
                    Reasoning:    fmt.Sprintf("Arb hedge: sell YES at %.3f on %s", sellMarket.Outcomes[0].Price, sellMarket.Platform),
                })
            }
        }
    }

    return signals, nil
}
```

### Step 3: Fee and bridge cost helpers

```go
func (s *ArbitrageStrategy) platformFee(platform string) float64 {
    switch platform {
    case "polymarket":
        return s.config.PolymarketFee
    case "limitless":
        return s.config.LimitlessFee
    case "drift_bet":
        return s.config.DriftFee
    default:
        return 0.02 // conservative default
    }
}

// bridgeCost estimates the cost of moving capital between two platforms.
// Returns the cost as a fraction of position value.
func (s *ArbitrageStrategy) bridgeCost(platform1, platform2 string) float64 {
    // Same chain = no bridge cost
    chain1 := platformChain(platform1)
    chain2 := platformChain(platform2)
    if chain1 == chain2 {
        return 0
    }

    // Cross-chain: fixed USD cost converted to fraction of typical position
    // For a $1000 position, $0.10 bridge cost = 0.0001 (negligible)
    // But for a $50 position, $0.10 = 0.002
    // Use conservative estimate assuming $500 average position
    return s.config.BridgeCostUSD / 500.0
}

func platformChain(platform string) string {
    switch platform {
    case "polymarket":
        return "polygon"
    case "limitless":
        return "base"
    case "drift_bet":
        return "solana"
    default:
        return "unknown"
    }
}
```

### Step 4: Write tests

Create `internal/strategies/arbitrage_test.go`:

1. `TestArbitrageDetectsSpread` — two markets, 5% spread, verify two signals generated (buy + sell)
2. `TestArbitrageIgnoresSmallSpread` — 1% spread, below 3% threshold, verify no signals
3. `TestArbitrageIgnoresIncompatibleRules` — ResolutionMatch=false, verify skipped
4. `TestArbitrageNetEdgeCalculation` — 5% spread, 2%+1% fees, 0.02% bridge = 1.98% net, below 3% threshold
5. `TestArbitragePositionSizing` — verify size is min(maxExposure * NAV, 10% of liquidity)
6. `TestArbitrageMultiplePairs` — 3 platforms, verify all 3 pairs compared
7. `TestArbitragePairedSignals` — verify buy and sell signals reference correct platforms

## Done When

- [ ] All requirements met
- [ ] Strategy only generates signals for groups with `ResolutionMatch == true`
- [ ] Net edge calculation accounts for platform fees and bridge costs
- [ ] Paired buy/sell signals generated with correct platform assignments
- [ ] Position sizing respects max exposure and liquidity constraints
- [ ] `go test ./internal/strategies/...` passes with all arbitrage tests green
