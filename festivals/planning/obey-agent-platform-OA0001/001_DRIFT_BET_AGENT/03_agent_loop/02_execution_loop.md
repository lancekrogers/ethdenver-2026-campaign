---
fest_type: task
fest_id: 02_execution_loop.md
fest_name: execution_loop
fest_parent: 03_agent_loop
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.316866-06:00
fest_tracking: true
---

# Task: Core Execution Loop

## Objective

Implement the main agent execution loop that orchestrates the full trading cycle: fetch markets, analyze with LLM, generate signals, filter through risk manager, execute trades, settle resolved positions, and report status -- following the exact patterns from `agent-defi/internal/agent/agent.go`.

## Requirements

- [ ] Agent struct with dependency injection (same pattern as agent-defi)
- [ ] Trading loop on configurable interval (default 15 minutes)
- [ ] P&L reporting loop on separate interval
- [ ] Health/heartbeat loop
- [ ] Graceful shutdown on context cancellation
- [ ] HCS task handling from coordinator
- [ ] Atomic trade counters for observability
- [ ] Full cycle: fetch -> analyze -> risk-filter -> execute -> settle -> report

## Implementation

### Step 1: Implement the Agent

Update file `projects/agent-prediction/internal/agent/agent.go`:

```go
package agent

import (
	"context"
	"fmt"
	"log/slog"
	"sync/atomic"
	"time"

	"github.com/lancekrogers/agent-prediction/internal/adapters"
	"github.com/lancekrogers/agent-prediction/internal/hcs"
	"github.com/lancekrogers/agent-prediction/internal/portfolio"
	"github.com/lancekrogers/agent-prediction/internal/risk"
	"github.com/lancekrogers/agent-prediction/internal/strategies"
)

// Agent orchestrates the prediction market agent lifecycle.
// All dependencies are injected at construction time.
type Agent struct {
	cfg       Config
	log       *slog.Logger
	adapter   adapters.MarketAdapter
	strategy  strategies.Strategy
	riskMgr   *risk.Manager
	portfolio *portfolio.Tracker
	handler   *hcs.Handler

	startTime       time.Time
	completedTrades atomic.Int64
	failedTrades    atomic.Int64
	cycleCount      atomic.Int64
}

// New creates a prediction market Agent with all required dependencies.
func New(
	cfg Config,
	log *slog.Logger,
	adapter adapters.MarketAdapter,
	strategy strategies.Strategy,
	riskMgr *risk.Manager,
	portfolio *portfolio.Tracker,
	handler *hcs.Handler,
) *Agent {
	return &Agent{
		cfg:       cfg,
		log:       log,
		adapter:   adapter,
		strategy:  strategy,
		riskMgr:   riskMgr,
		portfolio: portfolio,
		handler:   handler,
	}
}

// Run starts the agent and blocks until the context is cancelled.
// It starts HCS subscription, trading loop, P&L report loop, and health loop.
func (a *Agent) Run(ctx context.Context) error {
	a.startTime = time.Now()
	a.log.Info("starting prediction market agent",
		"agent_id", a.cfg.AgentID,
		"strategy", a.strategy.Name(),
		"platform", a.adapter.Name(),
		"mock_mode", a.cfg.MockMode,
		"trading_interval", a.cfg.TradingInterval)

	// Step 1: Start HCS subscription for coordinator tasks (if configured).
	if a.handler != nil {
		go func() {
			if err := a.handler.StartSubscription(ctx); err != nil && ctx.Err() == nil {
				a.log.Error("HCS subscription failed", "error", err)
			}
		}()
	}

	// Step 2: Start background loops.
	go a.tradingLoop(ctx)
	go a.pnlReportLoop(ctx)
	go a.healthLoop(ctx)

	// Step 3: Process coordinator commands from HCS.
	if a.handler != nil {
		for {
			select {
			case <-ctx.Done():
				return a.shutdown()
			case task := <-a.handler.Tasks():
				a.handleCoordinatorTask(ctx, task)
			}
		}
	}

	// If no HCS handler, just wait for shutdown.
	<-ctx.Done()
	return a.shutdown()
}

// shutdown logs final stats and returns.
func (a *Agent) shutdown() error {
	a.log.Info("shutting down prediction market agent",
		"agent_id", a.cfg.AgentID,
		"completed_trades", a.completedTrades.Load(),
		"failed_trades", a.failedTrades.Load(),
		"cycles", a.cycleCount.Load(),
		"uptime", time.Since(a.startTime))
	return nil
}

// tradingLoop periodically runs the full trading cycle.
func (a *Agent) tradingLoop(ctx context.Context) {
	// Run one cycle immediately on startup.
	if err := a.executeTradingCycle(ctx); err != nil {
		a.log.Warn("initial trading cycle failed", "error", err)
	}

	ticker := time.NewTicker(a.cfg.TradingInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := a.executeTradingCycle(ctx); err != nil {
				a.log.Warn("trading cycle failed", "error", err)
				a.failedTrades.Add(1)
			}
		}
	}
}

// executeTradingCycle runs one complete cycle: fetch -> analyze -> trade -> settle -> report.
func (a *Agent) executeTradingCycle(ctx context.Context) error {
	if err := ctx.Err(); err != nil {
		return fmt.Errorf("agent: context cancelled before cycle: %w", err)
	}

	cycleNum := a.cycleCount.Add(1)
	a.log.Info("starting trading cycle", "cycle", cycleNum)
	start := time.Now()

	// 1. Fetch active markets from Drift BET.
	markets, err := a.adapter.ListMarkets(ctx)
	if err != nil {
		return fmt.Errorf("agent: fetch markets failed: %w", err)
	}
	a.log.Info("fetched markets", "count", len(markets))

	// 2. Evaluate strategy — LLM analysis, signal generation.
	signals, err := a.strategy.Evaluate(ctx, markets)
	if err != nil {
		return fmt.Errorf("agent: strategy evaluation failed: %w", err)
	}
	a.log.Info("strategy generated signals", "count", len(signals))

	// 3. Filter signals through risk manager.
	currentPositions, _ := a.adapter.Positions(ctx)
	portfolioNAV := a.portfolio.NAV()

	approved, err := a.riskMgr.FilterSignals(ctx, signals, currentPositions, portfolioNAV)
	if err != nil {
		return fmt.Errorf("agent: risk filter failed: %w", err)
	}
	a.log.Info("risk-approved signals", "approved", len(approved), "rejected", len(signals)-len(approved))

	// 4. Execute approved trades.
	for _, signal := range approved {
		if err := ctx.Err(); err != nil {
			return fmt.Errorf("agent: context cancelled during execution: %w", err)
		}

		// Convert position size from portfolio fraction to USD amount
		tradeSize := signal.Size * portfolioNAV
		signal.Size = tradeSize

		txSig, err := a.adapter.PlaceOrder(ctx, signal)
		if err != nil {
			a.log.Warn("trade execution failed",
				"market", signal.MarketID,
				"error", err)
			a.failedTrades.Add(1)
			continue
		}

		a.completedTrades.Add(1)
		a.portfolio.RecordTrade(signal, txSig)
		a.log.Info("trade executed",
			"market", signal.MarketID,
			"direction", signal.Direction,
			"size_usd", tradeSize,
			"edge", signal.Edge,
			"tx", txSig)
	}

	// 5. Settle resolved positions.
	if err := a.adapter.Settle(ctx); err != nil {
		a.log.Warn("settlement check failed", "error", err)
	}

	// 6. Update portfolio NAV from current positions.
	positions, err := a.adapter.Positions(ctx)
	if err == nil {
		a.portfolio.UpdatePositions(positions)
	}

	a.log.Info("trading cycle complete",
		"cycle", cycleNum,
		"duration", time.Since(start),
		"completed_trades", a.completedTrades.Load())

	return nil
}

// pnlReportLoop periodically reports P&L to the coordinator via HCS.
func (a *Agent) pnlReportLoop(ctx context.Context) {
	ticker := time.NewTicker(a.cfg.PnLReportInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if a.handler == nil {
				continue
			}

			report := a.portfolio.Report()
			msg := hcs.PnLReportMessage{
				AgentID:      a.cfg.AgentID,
				NAV:          report.NAV,
				TotalReturn:  report.TotalReturn,
				WinRate:      report.WinRate,
				TradeCount:   int(a.completedTrades.Load()),
				OpenPositions: report.OpenPositions,
				ActiveStrategy: a.strategy.Name(),
				PeriodStart:  a.startTime,
				PeriodEnd:    time.Now(),
			}

			if err := a.handler.PublishPnL(ctx, msg); err != nil {
				a.log.Error("failed to publish P&L report", "error", err)
			} else {
				a.log.Info("P&L report published",
					"nav", report.NAV,
					"return", report.TotalReturn,
					"trades", a.completedTrades.Load())
			}
		}
	}
}

// healthLoop periodically publishes agent health status.
func (a *Agent) healthLoop(ctx context.Context) {
	ticker := time.NewTicker(a.cfg.HealthInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if a.handler == nil {
				continue
			}

			a.handler.PublishHealth(ctx, hcs.HealthStatus{
				AgentID:        a.cfg.AgentID,
				Status:         "trading",
				ActiveStrategy: a.strategy.Name(),
				NAV:            a.portfolio.NAV(),
				UptimeSeconds:  int64(time.Since(a.startTime).Seconds()),
				TradeCount:     int(a.completedTrades.Load()),
				CycleCount:     int(a.cycleCount.Load()),
			})
		}
	}
}

// handleCoordinatorTask processes an incoming task from the coordinator.
func (a *Agent) handleCoordinatorTask(ctx context.Context, task hcs.TaskAssignment) {
	a.log.Info("processing coordinator task", "task_id", task.TaskID, "type", task.TaskType)
	start := time.Now()

	var taskErr error
	switch task.TaskType {
	case "execute_cycle":
		taskErr = a.executeTradingCycle(ctx)
	case "update_strategy":
		a.log.Info("strategy update requested (not implemented in MVP)")
	default:
		taskErr = fmt.Errorf("agent: unknown task type: %s", task.TaskType)
	}

	status := "completed"
	errMsg := ""
	if taskErr != nil {
		status = "failed"
		errMsg = taskErr.Error()
	}

	a.handler.PublishResult(ctx, hcs.TaskResult{
		TaskID:     task.TaskID,
		Status:     status,
		Error:      errMsg,
		DurationMs: time.Since(start).Milliseconds(),
	})
}
```

### Step 2: Create the Entry Point

Create file `projects/agent-prediction/cmd/agent/main.go`:

```go
package main

import (
	"context"
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"github.com/lancekrogers/agent-prediction/internal/adapters/drift"
	"github.com/lancekrogers/agent-prediction/internal/agent"
	"github.com/lancekrogers/agent-prediction/internal/analysis"
	"github.com/lancekrogers/agent-prediction/internal/portfolio"
	"github.com/lancekrogers/agent-prediction/internal/risk"
	"github.com/lancekrogers/agent-prediction/internal/strategies"
)

func main() {
	// Load config
	cfg, err := agent.LoadFromEnv()
	if err != nil {
		slog.Error("config load failed", "error", err)
		os.Exit(1)
	}
	if err := cfg.Validate(); err != nil {
		slog.Error("config validation failed", "error", err)
		os.Exit(1)
	}

	// Setup logger
	logLevel := slog.LevelInfo
	switch cfg.LogLevel {
	case "debug":
		logLevel = slog.LevelDebug
	case "warn":
		logLevel = slog.LevelWarn
	case "error":
		logLevel = slog.LevelError
	}
	log := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: logLevel}))

	// Create dependencies
	driftClient := drift.NewHTTPClient(drift.HTTPClientConfig{
		BaseURL:       cfg.DriftBaseURL,
		DLOBBaseURL:   cfg.DriftDLOBURL,
		UserAuthority: cfg.WalletAuthority,
	})
	adapter := drift.NewAdapter(driftClient, cfg.WalletAuthority)

	llm := analysis.NewClaudeClient(analysis.ClaudeConfig{
		APIKey:  cfg.ClaudeAPIKey,
		Model:   cfg.ClaudeModel,
	})

	normalizer := analysis.NewNormalizer(analysis.NormalizerConfig{})
	analyzer := analysis.NewResolutionAnalyzer(llm, 0)

	strategy := strategies.NewResolutionHunterStrategy(
		strategies.ResolutionHunterConfig{
			MinEdge:        cfg.MinEdge,
			MinConfidence:  cfg.MinConfidence,
			MaxSignals:     cfg.MaxSignalsPerCycle,
			MaxPositionPct: cfg.MaxPositionPct,
			KellyFraction:  cfg.KellyFraction,
		},
		normalizer, analyzer, log,
	)

	riskMgr := risk.NewManager(risk.Config{
		MaxPositionPct:   cfg.MaxPositionPct,
		MaxDrawdownPct:   cfg.MaxDrawdownPct,
		DailyLossLimit:   cfg.DailyLossLimit,
		MaxOpenPositions: cfg.MaxOpenPositions,
	})

	tracker := portfolio.NewTracker(cfg.SeedCapitalUSD)

	// Create agent (no HCS handler for initial launch; add later)
	a := agent.New(cfg, log, adapter, strategy, riskMgr, tracker, nil)

	// Setup graceful shutdown
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-sigCh
		log.Info("received shutdown signal")
		cancel()
	}()

	// Run
	if err := a.Run(ctx); err != nil {
		log.Error("agent exited with error", "error", err)
		os.Exit(1)
	}
}
```

## Done When

- [ ] All requirements met
- [ ] `internal/agent/agent.go` implements the full `Agent` struct with dependency injection
- [ ] `Run()` starts trading loop, P&L loop, and health loop concurrently
- [ ] `executeTradingCycle()` performs the full fetch -> analyze -> risk -> trade -> settle -> report cycle
- [ ] Graceful shutdown on context cancellation with stats logging
- [ ] HCS task handling works for coordinator-initiated cycles
- [ ] `cmd/agent/main.go` wires all dependencies and starts the agent
- [ ] `go build ./cmd/agent/` succeeds
