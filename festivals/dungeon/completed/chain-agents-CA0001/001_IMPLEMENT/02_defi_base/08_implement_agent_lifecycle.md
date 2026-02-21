---
fest_type: task
fest_id: 08_implement_agent_lifecycle.md
fest_name: implement_agent_lifecycle
fest_parent: 02_defi_base
fest_order: 8
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Agent Lifecycle

## Objective

Wire all packages together into the DeFi agent's main loop and binary entry point. The lifecycle manages startup, identity registration, trading strategy execution, P&L reporting, HCS communication, and graceful shutdown. This task produces a runnable `agent-defi` binary.

**Project:** `agent-defi` at `projects/agent-defi/`
**Packages:** `internal/agent/agent.go`, `internal/agent/config.go`, `cmd/agent-defi/main.go`

## Requirements

- [ ] Implement the Agent struct that orchestrates all Base and HCS packages
- [ ] Register agent identity on startup via ERC-8004
- [ ] Run trading strategy loop: evaluate -> execute -> record -> report
- [ ] Publish periodic P&L reports to coordinator via HCS
- [ ] Respond to coordinator task assignments via HCS
- [ ] Implement graceful shutdown on SIGINT/SIGTERM
- [ ] Wire dependency injection in `cmd/agent-defi/main.go`

## Implementation

### Step 1: Implement agent configuration

In `internal/agent/config.go`:

```go
package agent

import (
    "fmt"
    "os"
    "time"

    "agent-defi/internal/base/identity"
    "agent-defi/internal/base/payment"
    "agent-defi/internal/base/trading"
    "agent-defi/internal/base/attribution"
    "agent-defi/internal/hcs"
)

// Config holds all configuration for the DeFi agent.
type Config struct {
    // AgentID is the unique identifier for this agent instance.
    AgentID string

    // DaemonAddr is the address of the daemon client for registration.
    DaemonAddr string

    // TradingInterval is how often the strategy evaluates market conditions.
    TradingInterval time.Duration

    // PnLReportInterval is how often P&L reports are published via HCS.
    PnLReportInterval time.Duration

    // HealthInterval is how often health updates are sent via HCS.
    HealthInterval time.Duration

    // Identity holds ERC-8004 identity configuration.
    Identity identity.RegistryConfig

    // Payment holds x402 payment protocol configuration.
    Payment payment.ProtocolConfig

    // Trading holds trade executor configuration.
    Trading trading.ExecutorConfig

    // Attribution holds ERC-8021 builder attribution configuration.
    Attribution attribution.Config

    // HCS holds Hedera Consensus Service handler configuration.
    HCS hcs.HandlerConfig
}

// LoadConfig reads configuration from environment variables.
func LoadConfig() (*Config, error) {
    cfg := &Config{}

    cfg.AgentID = os.Getenv("DEFI_AGENT_ID")
    if cfg.AgentID == "" {
        return nil, fmt.Errorf("config: DEFI_AGENT_ID is required")
    }

    cfg.DaemonAddr = os.Getenv("DEFI_DAEMON_ADDR")
    if cfg.DaemonAddr == "" {
        cfg.DaemonAddr = "localhost:9090"
    }

    // Parse intervals with defaults
    cfg.TradingInterval = parseDurationOrDefault(os.Getenv("DEFI_TRADING_INTERVAL"), 60*time.Second)
    cfg.PnLReportInterval = parseDurationOrDefault(os.Getenv("DEFI_PNL_REPORT_INTERVAL"), 5*time.Minute)
    cfg.HealthInterval = parseDurationOrDefault(os.Getenv("DEFI_HEALTH_INTERVAL"), 30*time.Second)

    // Base chain configuration
    cfg.Identity.ChainRPC = os.Getenv("BASE_RPC_ENDPOINT")
    cfg.Identity.ChainID = 84532 // Base Sepolia
    cfg.Identity.ContractAddress = os.Getenv("BASE_IDENTITY_CONTRACT")
    cfg.Identity.PrivateKey = os.Getenv("BASE_PRIVATE_KEY")

    cfg.Trading.ChainRPC = os.Getenv("BASE_RPC_ENDPOINT")
    cfg.Trading.ChainID = 84532
    cfg.Trading.PrivateKey = os.Getenv("BASE_PRIVATE_KEY")
    cfg.Trading.DEXRouterAddress = os.Getenv("BASE_DEX_ROUTER")

    cfg.Attribution.BuilderCode = []byte(os.Getenv("BASE_BUILDER_CODE"))
    cfg.Attribution.Enabled = os.Getenv("BASE_ATTRIBUTION_ENABLED") != "false"

    // Hedera HCS configuration
    // HEDERA_TASK_TOPIC, HEDERA_RESULT_TOPIC, HEDERA_HEALTH_TOPIC
    // HEDERA_OPERATOR_ID, HEDERA_OPERATOR_KEY, HEDERA_NETWORK

    return cfg, nil
}

func parseDurationOrDefault(s string, defaultVal time.Duration) time.Duration {
    if s == "" {
        return defaultVal
    }
    d, err := time.ParseDuration(s)
    if err != nil {
        return defaultVal
    }
    return d
}
```

### Step 2: Implement the Agent struct

In `internal/agent/agent.go`:

```go
package agent

import (
    "context"
    "log/slog"
    "time"

    "agent-defi/internal/base/identity"
    "agent-defi/internal/base/payment"
    "agent-defi/internal/base/trading"
    "agent-defi/internal/hcs"
)

// Agent orchestrates the DeFi agent lifecycle.
type Agent struct {
    cfg       Config
    log       *slog.Logger
    identity  identity.IdentityRegistry
    payment   payment.PaymentProtocol
    executor  trading.TradeExecutor
    strategy  trading.Strategy
    pnl       *trading.PnLTracker
    hcs       *hcs.Handler

    startTime      time.Time
    completedTrades int
}

// New creates a new Agent with all dependencies injected.
func New(cfg Config, log *slog.Logger,
    id identity.IdentityRegistry,
    pay payment.PaymentProtocol,
    exec trading.TradeExecutor,
    strat trading.Strategy,
    pnl *trading.PnLTracker,
    h *hcs.Handler) *Agent {
    return &Agent{
        cfg:      cfg,
        log:      log,
        identity: id,
        payment:  pay,
        executor: exec,
        strategy: strat,
        pnl:      pnl,
        hcs:      h,
    }
}
```

### Step 3: Implement the main lifecycle

```go
// Run starts the DeFi agent and blocks until the context is cancelled.
func (a *Agent) Run(ctx context.Context) error {
    a.startTime = time.Now()
    a.log.Info("starting DeFi agent", "agent_id", a.cfg.AgentID)

    // Step 1: Register agent identity on Base
    id, err := a.identity.Register(ctx, identity.RegistrationRequest{
        AgentID:   a.cfg.AgentID,
        AgentType: "defi",
    })
    if err != nil {
        // If already registered, that is OK -- retrieve existing identity
        a.log.Warn("identity registration failed, checking if already registered", "error", err)
        existing, verifyErr := a.identity.GetIdentity(ctx, a.cfg.AgentID)
        if verifyErr != nil {
            return fmt.Errorf("agent: failed to register or retrieve identity: %w", err)
        }
        id = existing
    }
    a.log.Info("agent identity ready", "agent_id", id.AgentID, "tx", id.TxHash)

    // Step 2: Start HCS subscription
    go func() {
        if err := a.hcs.StartSubscription(ctx); err != nil {
            a.log.Error("HCS subscription failed", "error", err)
        }
    }()

    // Step 3: Start background goroutines
    go a.tradingLoop(ctx)
    go a.pnlReportLoop(ctx)
    go a.healthLoop(ctx)

    // Step 4: Process coordinator commands from HCS
    for {
        select {
        case <-ctx.Done():
            a.log.Info("shutting down DeFi agent", "completed_trades", a.completedTrades)
            return ctx.Err()
        case task := <-a.hcs.Tasks():
            a.handleCoordinatorTask(ctx, task)
        }
    }
}
```

### Step 4: Implement the trading loop

```go
// tradingLoop periodically evaluates market conditions and executes trades.
func (a *Agent) tradingLoop(ctx context.Context) {
    ticker := time.NewTicker(a.cfg.TradingInterval)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            return
        case <-ticker.C:
            if err := a.evaluateAndTrade(ctx); err != nil {
                a.log.Error("trading cycle failed", "error", err)
            }
        }
    }
}

// evaluateAndTrade runs one cycle of the trading strategy.
func (a *Agent) evaluateAndTrade(ctx context.Context) error {
    // 1. Get current market state from the DEX
    state, err := a.executor.GetMarketState(ctx, "WETH/USDC")
    if err != nil {
        return fmt.Errorf("agent: failed to get market state: %w", err)
    }

    // 2. Evaluate strategy
    signal, err := a.strategy.Evaluate(ctx, *state)
    if err != nil {
        return fmt.Errorf("agent: strategy evaluation failed: %w", err)
    }

    // 3. Publish strategy update via HCS
    a.hcs.PublishStrategyUpdate(ctx, hcs.StrategyUpdate{
        AgentID:   a.cfg.AgentID,
        Strategy:  a.strategy.Name(),
        Event:     "signal_generated",
        Details:   fmt.Sprintf("action=%s reason=%s", signal.Action, signal.Reason),
        Timestamp: time.Now(),
    })

    // 4. If hold, do nothing
    if signal.Action == "hold" {
        return nil
    }

    // 5. Build and execute the trade
    trade := a.buildTrade(signal, state)
    result, err := a.executor.Execute(ctx, trade)
    if err != nil {
        return fmt.Errorf("agent: trade execution failed: %w", err)
    }

    // 6. Record in P&L tracker
    a.pnl.RecordTrade(trading.TradeRecord{
        Trade:      trade,
        Result:     *result,
        Strategy:   a.strategy.Name(),
        RecordedAt: time.Now(),
    })

    a.completedTrades++
    a.log.Info("trade executed",
        "side", signal.Action,
        "tx", result.TxHash,
        "gas", result.GasCost.String(),
        "total_trades", a.completedTrades,
    )

    return nil
}
```

### Step 5: Implement P&L reporting loop

```go
// pnlReportLoop periodically publishes P&L reports to the coordinator.
func (a *Agent) pnlReportLoop(ctx context.Context) {
    ticker := time.NewTicker(a.cfg.PnLReportInterval)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            return
        case <-ticker.C:
            report := a.pnl.Report(a.startTime, time.Now())

            msg := hcs.PnLReportMessage{
                AgentID:          a.cfg.AgentID,
                TotalRevenue:     report.TotalRevenue,
                TotalGasCosts:    report.TotalGasCosts,
                TotalFees:        report.TotalFees,
                NetPnL:           report.NetPnL,
                TradeCount:       report.TradeCount,
                WinRate:          report.WinRate,
                IsSelfSustaining: report.IsSelfSustaining,
                PeriodStart:      report.PeriodStart,
                PeriodEnd:        report.PeriodEnd,
                ActiveStrategy:   a.strategy.Name(),
            }

            if err := a.hcs.PublishPnL(ctx, msg); err != nil {
                a.log.Error("failed to publish P&L report", "error", err)
            } else {
                a.log.Info("P&L report published",
                    "net_pnl", report.NetPnL,
                    "self_sustaining", report.IsSelfSustaining,
                    "trades", report.TradeCount,
                )
            }
        }
    }
}
```

### Step 6: Implement health reporting loop

```go
// healthLoop sends periodic health heartbeats via HCS.
func (a *Agent) healthLoop(ctx context.Context) {
    ticker := time.NewTicker(a.cfg.HealthInterval)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            return
        case <-ticker.C:
            report := a.pnl.Report(a.startTime, time.Now())
            a.hcs.PublishHealth(ctx, hcs.HealthStatus{
                AgentID:        a.cfg.AgentID,
                Status:         "trading",
                ActiveStrategy: a.strategy.Name(),
                CurrentPnL:     report.NetPnL,
                UptimeSeconds:  int64(time.Since(a.startTime).Seconds()),
                TradeCount:     a.completedTrades,
            })
        }
    }
}
```

### Step 7: Implement the entry point

In `cmd/agent-defi/main.go`:

```go
package main

import (
    "context"
    "log/slog"
    "os"
    "os/signal"
    "syscall"

    "agent-defi/internal/agent"
    "agent-defi/internal/base/identity"
    "agent-defi/internal/base/payment"
    "agent-defi/internal/base/trading"
    "agent-defi/internal/base/attribution"
    "agent-defi/internal/hcs"
)

func main() {
    log := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))

    cfg, err := agent.LoadConfig()
    if err != nil {
        log.Error("failed to load config", "error", err)
        os.Exit(1)
    }

    ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
    defer cancel()

    // Initialize all dependencies
    attr, err := attribution.NewEncoder(cfg.Attribution)
    // ... error handling ...

    cfg.Trading.Attribution = attr
    exec, err := trading.NewExecutor(cfg.Trading)
    // ... error handling ...

    id, err := identity.NewRegistry(cfg.Identity)
    pay, err := payment.NewProtocol(cfg.Payment)
    h, err := hcs.NewHandler(cfg.HCS)

    // Create strategy with sensible defaults for testnet
    strategy := &trading.MeanReversionStrategy{
        WindowSize: 20,
        Threshold:  0.02, // 2% deviation
        TradeSize:  big.NewInt(1e16), // 0.01 ETH
    }

    pnl := trading.NewPnLTracker()

    a := agent.New(*cfg, log, id, pay, exec, strategy, pnl, h)

    log.Info("DeFi agent starting", "agent_id", cfg.AgentID)
    if err := a.Run(ctx); err != nil && err != context.Canceled {
        log.Error("agent exited with error", "error", err)
        os.Exit(1)
    }
    log.Info("DeFi agent stopped gracefully")
}
```

### Step 8: Write unit tests

Create `internal/agent/agent_test.go`:

1. **TestAgent_Run_RegistersIdentity**: Mock identity registry, verify Register called on startup
2. **TestAgent_Run_AlreadyRegistered**: Mock Register failure then GetIdentity success
3. **TestAgent_EvaluateAndTrade_BuySignal**: Mock strategy buy, verify trade executed and recorded
4. **TestAgent_EvaluateAndTrade_HoldSignal**: Mock strategy hold, verify no trade executed
5. **TestAgent_EvaluateAndTrade_ExecutionFails**: Mock trade failure, verify error logged
6. **TestAgent_PnLReportLoop**: Verify P&L published at configured interval
7. **TestAgent_GracefulShutdown**: Cancel context, verify all goroutines exit cleanly
8. **TestLoadConfig_RequiredFields**: Verify required env vars checked
9. **TestLoadConfig_DefaultIntervals**: Verify default intervals applied

### Step 9: Verify the full build

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
go build ./...
go test ./... -v -race
go vet ./...
```

## Done When

- [ ] `internal/agent/agent.go` implements the Agent with Run, tradingLoop, pnlReportLoop, healthLoop
- [ ] `internal/agent/config.go` loads all configuration from environment variables
- [ ] `cmd/agent-defi/main.go` wires all dependencies with graceful shutdown
- [ ] Identity registration happens on startup (with recovery for already-registered)
- [ ] Trading loop evaluates strategy and executes trades at configured interval
- [ ] P&L reports published to coordinator via HCS at configured interval
- [ ] Health heartbeats sent at configured interval
- [ ] All dependencies injected via constructor (no global state)
- [ ] Table-driven unit tests cover lifecycle, trading, reporting, and shutdown
- [ ] `go build ./...` produces a runnable binary
- [ ] `go test ./... -race` and `go vet ./...` pass cleanly
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
