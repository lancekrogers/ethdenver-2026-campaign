# 03 — Prediction Market Engine

## Overview

The prediction market engine is the core intelligence layer. It connects to multiple prediction market platforms, analyzes opportunities using LLMs, and executes trades through the vault contract. This is the primary value driver — what makes funded agents profitable.

## Multi-Platform Architecture

```
┌───────────────────────────────────────────────────────────────┐
│                   PREDICTION MARKET ENGINE                     │
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │ Market       │  │ Analysis     │  │ Execution            │ │
│  │ Aggregator   │  │ Pipeline     │  │ Manager              │ │
│  │              │  │              │  │                      │ │
│  │ Normalize    │  │ News ingest  │  │ Order routing        │ │
│  │ Deduplicate  │  │ LLM reason   │  │ Position tracking    │ │
│  │ Cross-ref    │  │ Signal gen   │  │ Settlement           │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────────────┘ │
│         │                 │                  │                 │
│  ┌──────▼─────────────────▼──────────────────▼───────────────┐ │
│  │                 RISK MANAGER                               │ │
│  │  Position sizing │ Drawdown limits │ Correlation check    │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              PLATFORM ADAPTERS                            │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐              │  │
│  │  │Polymarket│  │Limitless │  │Drift BET │              │  │
│  │  │(Polygon) │  │(Base)    │  │(Solana)  │              │  │
│  │  └──────────┘  └──────────┘  └──────────┘              │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
```

## Market Aggregator

### Market Normalization

Different platforms represent markets differently. The aggregator normalizes everything:

```go
type NormalizedMarket struct {
    // Identity
    ID              string          // platform:market_id
    Platform        string
    NativeID        string          // platform-specific ID

    // Content
    Question        string          // "Will X happen by Y?"
    Description     string
    ResolutionRules string          // CRITICAL — this determines outcome, not the question
    Category        string          // politics | crypto | sports | macro | geopolitics
    Tags            []string

    // Outcomes
    Outcomes        []NormalizedOutcome

    // Market State
    Status          MarketStatus    // open | closed | resolved
    Resolution      *Resolution     // nil until resolved
    CreatedAt       time.Time
    ExpiresAt       time.Time
    ResolvedAt      *time.Time

    // Liquidity
    Volume24h       decimal.Decimal
    TotalVolume     decimal.Decimal
    Liquidity       decimal.Decimal // depth available
    Spread          decimal.Decimal // best ask - best bid
}

type NormalizedOutcome struct {
    Name            string          // "Yes" | "No" | custom
    Price           decimal.Decimal // 0.00-1.00 (implied probability)
    BestBid         decimal.Decimal
    BestAsk         decimal.Decimal
    Volume24h       decimal.Decimal
}
```

### Cross-Platform Event Matching

The same real-world event appears on multiple platforms. The aggregator matches them:

```go
type EventMatcher struct {
    llm         LLMClient
    cache       map[string][]NormalizedMarket // eventHash → markets
}

func (m *EventMatcher) FindEquivalentMarkets(
    ctx context.Context,
    markets []NormalizedMarket,
) ([]EquivalentGroup, error) {
    // Step 1: Group by category + time window
    groups := groupByCategoryAndExpiry(markets)

    // Step 2: LLM-assisted matching within groups
    // "Are these two markets asking about the same event?"
    // Market A (Polymarket): "Will the Fed cut rates in March 2026?"
    // Market B (Limitless):  "Federal Reserve March rate decision: cut?"
    // → Same event, different wording

    // Step 3: Verify resolution rules are compatible
    // Two markets asking about the "same" event may have different
    // resolution criteria that make arbitrage unsafe

    // Step 4: Return matched groups with confidence score
    return matched, nil
}

type EquivalentGroup struct {
    EventDescription string
    Markets          []NormalizedMarket  // same event across platforms
    MatchConfidence  decimal.Decimal     // 0.0-1.0
    ResolutionMatch  bool                // true if resolution rules align
}
```

## Analysis Pipeline

### Data Sources

```go
type DataPipeline struct {
    newsFeeds       []NewsFeed          // RSS, API-based news sources
    socialMonitor   SocialMonitor       // Twitter/X, Reddit monitoring
    forecastAgg     ForecastAggregator  // Metaculus, Manifold data
    onChainMonitor  OnChainMonitor      // whale movements, governance votes
    economicData    EconomicDataFeed    // Fed data, employment, CPI
}

// News Feed Integration
type NewsFeed interface {
    Stream(ctx context.Context, categories []string) (<-chan NewsEvent, error)
}

// Social Monitoring
type SocialMonitor interface {
    GetSentiment(ctx context.Context, topic string) (*SentimentResult, error)
    StreamMentions(ctx context.Context, keywords []string) (<-chan SocialMention, error)
}

// External Forecasts
type ForecastAggregator interface {
    GetMetaculusForecast(ctx context.Context, questionID string) (*Forecast, error)
    GetManifoldMarket(ctx context.Context, marketID string) (*ManifoldMarket, error)
}
```

### LLM Analysis Engine

```go
type AnalysisEngine struct {
    llm         LLMClient
    strategies  []Strategy
}

func (e *AnalysisEngine) Analyze(
    ctx context.Context,
    market NormalizedMarket,
    context AnalysisContext,
) (*MarketAnalysis, error) {
    // Step 1: Resolution Rule Analysis
    // Parse the specific resolution rules, not just the question title
    ruleAnalysis, err := e.analyzeResolutionRules(ctx, market)

    // Step 2: Information Aggregation
    // Gather all relevant data for this specific event
    info, err := e.gatherRelevantInfo(ctx, market, context)

    // Step 3: Probability Estimation
    // LLM synthesizes all data into a probability estimate
    estimate, err := e.estimateProbability(ctx, market, ruleAnalysis, info)

    // Step 4: Edge Calculation
    // Compare our estimate to market price
    edge := estimate.Probability.Sub(market.Outcomes[0].Price)

    // Step 5: Confidence Assessment
    // How sure are we in our estimate?
    confidence := e.assessConfidence(ctx, estimate, info)

    return &MarketAnalysis{
        MarketID:       market.ID,
        OurEstimate:    estimate.Probability,
        MarketPrice:    market.Outcomes[0].Price,
        Edge:           edge,
        Confidence:     confidence,
        Reasoning:      estimate.Reasoning,
        DataSources:    info.Sources,
        RuleAnalysis:   ruleAnalysis,
    }, nil
}
```

### Resolution Rule Parser

This is a key differentiator. Markets are often mispriced because traders read the title, not the rules.

```go
func (e *AnalysisEngine) analyzeResolutionRules(
    ctx context.Context,
    market NormalizedMarket,
) (*RuleAnalysis, error) {
    prompt := fmt.Sprintf(`Analyze these prediction market resolution rules precisely.

Market Question: %s

Resolution Rules:
%s

Determine:
1. What EXACTLY triggers a YES resolution? List every specific condition.
2. What EXACTLY triggers a NO resolution?
3. Are there edge cases where the title suggests one outcome but the rules specify another?
4. What data sources would definitively resolve this market?
5. Is there ambiguity in the rules that could lead to disputed resolution?
6. What is the resolution timeline?

Be precise. The rules, not the title, determine the outcome.`,
        market.Question, market.ResolutionRules)

    response, err := e.llm.Complete(ctx, prompt)
    // Parse structured response...
}
```

## Strategy Implementations

### Strategy 1: Cross-Platform Arbitrage Scanner

```go
type ArbitrageStrategy struct {
    matcher     *EventMatcher
    minEdge     decimal.Decimal  // minimum edge to trade (e.g., 0.03 = 3%)
    maxExposure decimal.Decimal  // max capital per arb opportunity
}

func (s *ArbitrageStrategy) Analyze(
    ctx context.Context,
    input StrategyInput,
) ([]Signal, error) {
    var signals []Signal

    // Find equivalent markets across platforms
    groups, _ := s.matcher.FindEquivalentMarkets(ctx, input.Markets)

    for _, group := range groups {
        if !group.ResolutionMatch {
            continue // rules don't match — unsafe to arb
        }

        // Find price discrepancies
        prices := map[string]decimal.Decimal{}
        for _, m := range group.Markets {
            prices[m.Platform] = m.Outcomes[0].Price // YES price
        }

        // Check all pairs for arb opportunity
        for i, m1 := range group.Markets {
            for _, m2 := range group.Markets[i+1:] {
                p1 := m1.Outcomes[0].Price
                p2 := m2.Outcomes[0].Price
                spread := p1.Sub(p2).Abs()

                if spread.GreaterThan(s.minEdge) {
                    // Buy cheap, sell expensive
                    var buyMarket, sellMarket NormalizedMarket
                    if p1.LessThan(p2) {
                        buyMarket, sellMarket = m1, m2
                    } else {
                        buyMarket, sellMarket = m2, m1
                    }

                    signals = append(signals, Signal{
                        MarketID:     buyMarket.ID,
                        Platform:     buyMarket.Platform,
                        Direction:    Buy,
                        Outcome:      "yes",
                        Confidence:   group.MatchConfidence,
                        EdgeEstimate: spread,
                        Strategy:     "arbitrage",
                        Reasoning: fmt.Sprintf(
                            "Arb: %s YES at %.2f on %s vs %.2f on %s (%.1f%% spread)",
                            group.EventDescription,
                            buyMarket.Outcomes[0].Price,
                            buyMarket.Platform,
                            sellMarket.Outcomes[0].Price,
                            sellMarket.Platform,
                            spread.Mul(decimal.NewFromInt(100)),
                        ),
                    })
                }
            }
        }
    }

    return signals, nil
}
```

### Strategy 2: News Trader

```go
type NewsTraderStrategy struct {
    llm         LLMClient
    newsFeed    NewsFeed
    minEdge     decimal.Decimal
}

func (s *NewsTraderStrategy) Analyze(
    ctx context.Context,
    input StrategyInput,
) ([]Signal, error) {
    var signals []Signal

    // Get recent news events
    events := s.newsFeed.GetRecent(ctx, 30*time.Minute)

    for _, event := range events {
        // LLM: which open markets does this news affect?
        affected, _ := s.identifyAffectedMarkets(ctx, event, input.Markets)

        for _, match := range affected {
            // LLM: what probability should this market be given this news?
            newEstimate, _ := s.estimatePostNewsProb(ctx, event, match.Market)

            edge := newEstimate.Sub(match.Market.Outcomes[0].Price).Abs()
            if edge.GreaterThan(s.minEdge) {
                direction := Buy
                outcome := "yes"
                if newEstimate.LessThan(match.Market.Outcomes[0].Price) {
                    direction = Sell // or buy NO
                    outcome = "no"
                }

                signals = append(signals, Signal{
                    MarketID:     match.Market.ID,
                    Platform:     match.Market.Platform,
                    Direction:    direction,
                    Outcome:      outcome,
                    Confidence:   match.Relevance,
                    EdgeEstimate: edge,
                    Strategy:     "news_trader",
                    Reasoning: fmt.Sprintf(
                        "News: '%s' → %s should be %.2f (currently %.2f)",
                        event.Headline,
                        match.Market.Question,
                        newEstimate,
                        match.Market.Outcomes[0].Price,
                    ),
                })
            }
        }
    }

    return signals, nil
}
```

### Strategy 3: Resolution Hunter

```go
type ResolutionHunterStrategy struct {
    llm     LLMClient
    minEdge decimal.Decimal
}

func (s *ResolutionHunterStrategy) Analyze(
    ctx context.Context,
    input StrategyInput,
) ([]Signal, error) {
    var signals []Signal

    for _, market := range input.Markets {
        // Deep analysis of resolution rules
        analysis, _ := s.analyzeRules(ctx, market)

        // Check if the rules create an edge vs the title interpretation
        if analysis.RuleTitleDivergence.GreaterThan(s.minEdge) {
            signals = append(signals, Signal{
                MarketID:     market.ID,
                Platform:     market.Platform,
                Direction:    analysis.Direction,
                Outcome:      analysis.FavoredOutcome,
                Confidence:   analysis.RuleClarity,
                EdgeEstimate: analysis.RuleTitleDivergence,
                Strategy:     "resolution_hunter",
                Reasoning:    analysis.Explanation,
            })
        }
    }

    return signals, nil
}
```

### Strategy 4: Market Maker

```go
type MarketMakerStrategy struct {
    targetSpread decimal.Decimal // e.g., 0.02 (2 cents)
    maxInventory decimal.Decimal // max position per side
}

func (s *MarketMakerStrategy) Analyze(
    ctx context.Context,
    input StrategyInput,
) ([]Signal, error) {
    var signals []Signal

    for _, market := range input.Markets {
        // Only market-make on Polymarket (maker rebates)
        if market.Platform != "polymarket" { continue }

        // Only in liquid markets with reasonable spreads
        if market.Spread.GreaterThan(decimal.NewFromFloat(0.05)) { continue }
        if market.Volume24h.LessThan(decimal.NewFromInt(10000)) { continue }

        // Quote both sides
        mid := market.Outcomes[0].Price
        bidPrice := mid.Sub(s.targetSpread.Div(decimal.NewFromInt(2)))
        askPrice := mid.Add(s.targetSpread.Div(decimal.NewFromInt(2)))

        // Check current inventory — lean quotes away from heavy side
        currentPos := findPosition(input.Positions, market.ID)
        // Adjust bid/ask based on inventory...

        signals = append(signals,
            Signal{
                MarketID:  market.ID, Platform: market.Platform,
                Direction: Buy, Outcome: "yes", Price: bidPrice,
                Strategy:  "market_maker", OrderType: GTC,
            },
            Signal{
                MarketID:  market.ID, Platform: market.Platform,
                Direction: Sell, Outcome: "yes", Price: askPrice,
                Strategy:  "market_maker", OrderType: GTC,
            },
        )
    }

    return signals, nil
}
```

## Risk Manager

```go
type RiskManager struct {
    config RiskConfig
}

type RiskConfig struct {
    MaxPositionPct      decimal.Decimal  // max single position as % of NAV (e.g., 5%)
    MaxPlatformPct      decimal.Decimal  // max exposure per platform (e.g., 40%)
    MaxCategoryPct      decimal.Decimal  // max exposure per category (e.g., 30%)
    MaxCorrelation      decimal.Decimal  // max correlation between positions
    MaxDrawdownPct      decimal.Decimal  // halt trading at this drawdown
    MinLiquidity        decimal.Decimal  // minimum market liquidity to enter
    MaxSlippage         decimal.Decimal  // max acceptable slippage
    DailyLossLimit      decimal.Decimal  // max daily loss as % of NAV
}

func (r *RiskManager) FilterSignals(
    ctx context.Context,
    signals []Signal,
    portfolio Portfolio,
) ([]Signal, error) {
    var approved []Signal

    for _, signal := range signals {
        // 1. Position size check
        positionValue := signal.Size.Mul(signal.Price)
        if positionValue.Div(portfolio.NAV).GreaterThan(r.config.MaxPositionPct) {
            signal.Size = portfolio.NAV.Mul(r.config.MaxPositionPct).Div(signal.Price)
        }

        // 2. Platform exposure check
        platformExposure := portfolio.ExposureByPlatform(signal.Platform)
        if platformExposure.Add(positionValue).Div(portfolio.NAV).GreaterThan(r.config.MaxPlatformPct) {
            continue // skip — too much on this platform
        }

        // 3. Category concentration check
        market := portfolio.GetMarket(signal.MarketID)
        categoryExposure := portfolio.ExposureByCategory(market.Category)
        if categoryExposure.Add(positionValue).Div(portfolio.NAV).GreaterThan(r.config.MaxCategoryPct) {
            continue
        }

        // 4. Liquidity check
        if market.Liquidity.LessThan(r.config.MinLiquidity) {
            continue
        }

        // 5. Daily loss limit check
        if portfolio.DailyPnL.Neg().Div(portfolio.NAV).GreaterThan(r.config.DailyLossLimit) {
            continue // stop trading for the day
        }

        // 6. Drawdown check
        drawdown := portfolio.HighWaterMark.Sub(portfolio.NAV).Div(portfolio.HighWaterMark)
        if drawdown.GreaterThan(r.config.MaxDrawdownPct) {
            return nil, ErrMaxDrawdownReached
        }

        approved = append(approved, signal)
    }

    return approved, nil
}
```

## Position Management

### NAV Calculation for Prediction Markets

```go
func (p *PortfolioManager) CalculateNAV(ctx context.Context) (decimal.Decimal, error) {
    nav := decimal.Zero

    // 1. Cash balances across all chains
    for chain, balance := range p.cashBalances {
        nav = nav.Add(balance) // USDC is always $1
    }

    // 2. Open prediction market positions
    for _, pos := range p.positions {
        if pos.Status == Resolved {
            if pos.Won {
                nav = nav.Add(pos.Size) // $1.00 per share (pending redemption)
            }
            // Lost positions = $0
            continue
        }

        // Open positions valued at current market price
        currentPrice, err := p.getAdapter(pos.Platform).GetPositionValue(ctx, pos)
        nav = nav.Add(pos.Size.Mul(currentPrice))
    }

    // 3. In-transit bridge funds
    for _, bridge := range p.pendingBridges {
        nav = nav.Add(bridge.Amount) // count funds being bridged
    }

    return nav, nil
}
```

### Settlement Pipeline

```go
func (p *PortfolioManager) SettlePipeline(ctx context.Context) error {
    for _, pos := range p.positions {
        adapter := p.getAdapter(pos.Platform)

        // Check if market resolved
        market, _ := adapter.GetMarket(ctx, pos.MarketID)
        if market.Status != Resolved { continue }

        // Redeem winning positions
        if pos.Won(market.Resolution) {
            result, err := adapter.RedeemPosition(ctx, pos.ID)
            if err != nil { continue }

            // Bridge winnings back to Solana vault
            p.bridgeToVault(ctx, result.Amount, pos.Platform)

            // Report to HCS
            p.coordinator.ReportResolution(ctx, pos, result)
        }

        // Mark position as settled
        pos.Status = Settled
    }

    return nil
}
```

## Training Pipeline (Manifold Markets)

Before deploying real capital, agents train on Manifold Markets (play money):

```go
type TrainingPipeline struct {
    manifold    ManifoldClient
    strategies  []Strategy
    metrics     TrainingMetrics
}

func (t *TrainingPipeline) Run(ctx context.Context, config TrainingConfig) (*TrainingReport, error) {
    // 1. Create Manifold bot account
    // 2. Run strategies against live Manifold markets (no real money)
    // 3. Track: accuracy, calibration, P&L (in play money), Sharpe ratio
    // 4. Compare strategy performance
    // 5. Generate report: which strategies work, optimal parameters

    for round := 0; round < config.Rounds; round++ {
        markets, _ := t.manifold.GetActiveMarkets(ctx)
        input := StrategyInput{Markets: normalize(markets)}

        for _, strategy := range t.strategies {
            signals, _ := strategy.Analyze(ctx, input)
            for _, signal := range signals {
                // Execute on Manifold (play money)
                t.manifold.PlaceBet(ctx, signal.MarketID, signal.Direction, signal.Size)
            }
        }

        // Wait for resolution, score results
        t.scoreRound(ctx, round)
    }

    return t.metrics.GenerateReport(), nil
}
```

## Performance Metrics

```go
type AgentMetrics struct {
    // Core
    NAV                decimal.Decimal
    NAVHistory         []NAVSnapshot       // time series
    TotalReturn        decimal.Decimal     // (current_nav - initial) / initial
    AnnualizedReturn   decimal.Decimal

    // Risk
    SharpeRatio        decimal.Decimal     // (return - risk_free) / volatility
    MaxDrawdown        decimal.Decimal     // worst peak-to-trough
    Volatility         decimal.Decimal     // daily return std dev
    WinRate            decimal.Decimal     // % of resolved positions that won

    // Activity
    TotalTrades        int64
    OpenPositions      int64
    MarketsTracked     int64
    PlatformsActive    []string
    AvgHoldingPeriod   time.Duration

    // Strategy Attribution
    PnLByStrategy      map[string]decimal.Decimal
    TradesByStrategy    map[string]int64
    WinRateByStrategy   map[string]decimal.Decimal
}
```
