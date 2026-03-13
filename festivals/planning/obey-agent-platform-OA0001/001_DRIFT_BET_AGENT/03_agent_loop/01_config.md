---
fest_type: task
fest_id: 01_config.md
fest_name: config
fest_parent: 03_agent_loop
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:04.316569-06:00
fest_tracking: true
---

# Task: Agent Configuration System

## Objective

Implement the configuration system for the prediction market agent, including environment variable loading, config validation, and sensible defaults for all operational parameters, following the same patterns as `agent-defi/internal/agent/agent.go`.

## Requirements

- [ ] Config struct covering all agent operational parameters
- [ ] Environment variable loading with `PRED_` prefix
- [ ] Config validation with clear error messages
- [ ] Sensible defaults for MVP (single platform, conservative risk)
- [ ] Mock mode flag for testing without real API calls
- [ ] Config for Drift BET client, Claude API, risk limits, and HCS

## Implementation

### Step 1: Create Config Package

Create file `projects/agent-prediction/internal/agent/config.go`:

```go
package agent

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

// Config holds all configuration for the prediction market agent.
type Config struct {
	// Identity
	AgentID   string
	AgentType string // always "prediction_market" for this agent

	// Drift BET
	DriftBaseURL     string
	DriftDLOBURL     string
	SolanaRPCURL     string
	SolanaPrivateKey string // base58-encoded private key
	WalletAuthority  string // Solana public key

	// Claude API
	ClaudeAPIKey    string
	ClaudeModel     string
	ClaudeMaxTokens int

	// Trading
	TradingInterval   time.Duration // how often to run the trading cycle
	MaxPositionPct    float64       // max single position as % of portfolio
	MaxPortfolioRisk  float64       // max total exposure as % of portfolio
	MinEdge           float64       // minimum edge to trade
	MinConfidence     float64       // minimum confidence to trade
	KellyFraction     float64       // fraction of Kelly criterion for sizing
	MaxSignalsPerCycle int          // max signals to act on per cycle

	// Risk
	MaxDrawdownPct float64 // halt trading at this drawdown %
	DailyLossLimit float64 // max daily loss as % of portfolio
	MaxOpenPositions int   // maximum concurrent open positions

	// HCS
	HCSTaskTopicID   string
	HCSResultTopicID string
	HCSOperatorID    string
	HCSOperatorKey   string

	// Reporting
	PnLReportInterval time.Duration
	HealthInterval    time.Duration

	// Operational
	MockMode    bool   // run without real trading
	LogLevel    string // debug, info, warn, error
	InitialNAV  float64 // starting portfolio value in USD

	// Portfolio seed capital (USD amount in the wallet)
	SeedCapitalUSD float64
}

// DefaultConfig returns a Config with sensible MVP defaults.
func DefaultConfig() Config {
	return Config{
		AgentID:   "obey-predictor-01",
		AgentType: "prediction_market",

		DriftBaseURL: "https://mainnet-beta.api.drift.trade",
		DriftDLOBURL: "https://dlob.drift.trade",
		SolanaRPCURL: "https://api.mainnet-beta.solana.com",

		ClaudeModel:     "claude-sonnet-4-20250514",
		ClaudeMaxTokens: 2048,

		TradingInterval:    15 * time.Minute,
		MaxPositionPct:     0.05, // 5% max per position
		MaxPortfolioRisk:   0.60, // 60% max total exposure
		MinEdge:            0.05, // 5% minimum edge
		MinConfidence:      0.50, // 50% minimum confidence
		KellyFraction:      0.25, // quarter Kelly
		MaxSignalsPerCycle: 3,

		MaxDrawdownPct:   0.15, // 15% max drawdown
		DailyLossLimit:   0.05, // 5% daily loss limit
		MaxOpenPositions: 10,

		PnLReportInterval: 30 * time.Minute,
		HealthInterval:    5 * time.Minute,

		MockMode:       false,
		LogLevel:       "info",
		SeedCapitalUSD: 5000,
	}
}

// LoadFromEnv populates config from environment variables with PRED_ prefix.
// Environment variables override defaults. Missing required vars cause an error.
func LoadFromEnv() (Config, error) {
	cfg := DefaultConfig()

	// Identity
	if v := os.Getenv("PRED_AGENT_ID"); v != "" {
		cfg.AgentID = v
	}

	// Drift BET
	if v := os.Getenv("PRED_DRIFT_BASE_URL"); v != "" {
		cfg.DriftBaseURL = v
	}
	if v := os.Getenv("PRED_DRIFT_DLOB_URL"); v != "" {
		cfg.DriftDLOBURL = v
	}
	if v := os.Getenv("PRED_SOLANA_RPC_URL"); v != "" {
		cfg.SolanaRPCURL = v
	}
	if v := os.Getenv("PRED_SOLANA_PRIVATE_KEY"); v != "" {
		cfg.SolanaPrivateKey = v
	}
	if v := os.Getenv("PRED_WALLET_AUTHORITY"); v != "" {
		cfg.WalletAuthority = v
	}

	// Claude API
	if v := os.Getenv("PRED_CLAUDE_API_KEY"); v != "" {
		cfg.ClaudeAPIKey = v
	}
	if v := os.Getenv("PRED_CLAUDE_MODEL"); v != "" {
		cfg.ClaudeModel = v
	}

	// Trading
	if v := os.Getenv("PRED_TRADING_INTERVAL"); v != "" {
		d, err := time.ParseDuration(v)
		if err != nil {
			return cfg, fmt.Errorf("config: invalid PRED_TRADING_INTERVAL %q: %w", v, err)
		}
		cfg.TradingInterval = d
	}
	if v := os.Getenv("PRED_MAX_POSITION_PCT"); v != "" {
		f, err := strconv.ParseFloat(v, 64)
		if err != nil {
			return cfg, fmt.Errorf("config: invalid PRED_MAX_POSITION_PCT %q: %w", v, err)
		}
		cfg.MaxPositionPct = f
	}
	if v := os.Getenv("PRED_MIN_EDGE"); v != "" {
		f, err := strconv.ParseFloat(v, 64)
		if err != nil {
			return cfg, fmt.Errorf("config: invalid PRED_MIN_EDGE %q: %w", v, err)
		}
		cfg.MinEdge = f
	}
	if v := os.Getenv("PRED_KELLY_FRACTION"); v != "" {
		f, err := strconv.ParseFloat(v, 64)
		if err != nil {
			return cfg, fmt.Errorf("config: invalid PRED_KELLY_FRACTION %q: %w", v, err)
		}
		cfg.KellyFraction = f
	}

	// Risk
	if v := os.Getenv("PRED_MAX_DRAWDOWN_PCT"); v != "" {
		f, err := strconv.ParseFloat(v, 64)
		if err != nil {
			return cfg, fmt.Errorf("config: invalid PRED_MAX_DRAWDOWN_PCT %q: %w", v, err)
		}
		cfg.MaxDrawdownPct = f
	}
	if v := os.Getenv("PRED_DAILY_LOSS_LIMIT"); v != "" {
		f, err := strconv.ParseFloat(v, 64)
		if err != nil {
			return cfg, fmt.Errorf("config: invalid PRED_DAILY_LOSS_LIMIT %q: %w", v, err)
		}
		cfg.DailyLossLimit = f
	}

	// HCS
	if v := os.Getenv("PRED_HCS_TASK_TOPIC"); v != "" {
		cfg.HCSTaskTopicID = v
	}
	if v := os.Getenv("PRED_HCS_RESULT_TOPIC"); v != "" {
		cfg.HCSResultTopicID = v
	}
	if v := os.Getenv("PRED_HCS_OPERATOR_ID"); v != "" {
		cfg.HCSOperatorID = v
	}
	if v := os.Getenv("PRED_HCS_OPERATOR_KEY"); v != "" {
		cfg.HCSOperatorKey = v
	}

	// Operational
	if v := os.Getenv("PRED_MOCK_MODE"); v == "true" || v == "1" {
		cfg.MockMode = true
	}
	if v := os.Getenv("PRED_LOG_LEVEL"); v != "" {
		cfg.LogLevel = v
	}
	if v := os.Getenv("PRED_SEED_CAPITAL"); v != "" {
		f, err := strconv.ParseFloat(v, 64)
		if err != nil {
			return cfg, fmt.Errorf("config: invalid PRED_SEED_CAPITAL %q: %w", v, err)
		}
		cfg.SeedCapitalUSD = f
	}

	return cfg, nil
}

// Validate checks that all required configuration fields are set and within valid ranges.
func (c Config) Validate() error {
	if c.AgentID == "" {
		return fmt.Errorf("config: agent_id is required")
	}

	// In mock mode, we don't require real credentials
	if !c.MockMode {
		if c.SolanaPrivateKey == "" {
			return fmt.Errorf("config: PRED_SOLANA_PRIVATE_KEY is required (set PRED_MOCK_MODE=true for testing)")
		}
		if c.ClaudeAPIKey == "" {
			return fmt.Errorf("config: PRED_CLAUDE_API_KEY is required (set PRED_MOCK_MODE=true for testing)")
		}
	}

	if c.TradingInterval < 1*time.Minute {
		return fmt.Errorf("config: trading_interval must be >= 1m, got %v", c.TradingInterval)
	}

	if c.MaxPositionPct <= 0 || c.MaxPositionPct > 1 {
		return fmt.Errorf("config: max_position_pct must be 0-1, got %f", c.MaxPositionPct)
	}

	if c.MaxDrawdownPct <= 0 || c.MaxDrawdownPct > 1 {
		return fmt.Errorf("config: max_drawdown_pct must be 0-1, got %f", c.MaxDrawdownPct)
	}

	if c.KellyFraction <= 0 || c.KellyFraction > 1 {
		return fmt.Errorf("config: kelly_fraction must be 0-1, got %f", c.KellyFraction)
	}

	if c.SeedCapitalUSD <= 0 {
		return fmt.Errorf("config: seed_capital must be > 0, got %f", c.SeedCapitalUSD)
	}

	return nil
}
```

### Step 2: Create Config Tests

Create file `projects/agent-prediction/internal/agent/config_test.go`:

```go
package agent

import (
	"os"
	"testing"
	"time"
)

func TestDefaultConfig(t *testing.T) {
	cfg := DefaultConfig()

	if cfg.AgentID == "" {
		t.Error("default agent ID should not be empty")
	}
	if cfg.TradingInterval != 15*time.Minute {
		t.Errorf("expected 15m trading interval, got %v", cfg.TradingInterval)
	}
	if cfg.MaxPositionPct != 0.05 {
		t.Errorf("expected 0.05 max position, got %f", cfg.MaxPositionPct)
	}
	if cfg.KellyFraction != 0.25 {
		t.Errorf("expected 0.25 kelly fraction, got %f", cfg.KellyFraction)
	}
}

func TestLoadFromEnv(t *testing.T) {
	os.Setenv("PRED_AGENT_ID", "test-agent")
	os.Setenv("PRED_MOCK_MODE", "true")
	os.Setenv("PRED_TRADING_INTERVAL", "5m")
	os.Setenv("PRED_MAX_POSITION_PCT", "0.10")
	defer func() {
		os.Unsetenv("PRED_AGENT_ID")
		os.Unsetenv("PRED_MOCK_MODE")
		os.Unsetenv("PRED_TRADING_INTERVAL")
		os.Unsetenv("PRED_MAX_POSITION_PCT")
	}()

	cfg, err := LoadFromEnv()
	if err != nil {
		t.Fatalf("LoadFromEnv() error: %v", err)
	}

	if cfg.AgentID != "test-agent" {
		t.Errorf("expected agent ID 'test-agent', got %q", cfg.AgentID)
	}
	if !cfg.MockMode {
		t.Error("expected mock mode to be true")
	}
	if cfg.TradingInterval != 5*time.Minute {
		t.Errorf("expected 5m interval, got %v", cfg.TradingInterval)
	}
	if cfg.MaxPositionPct != 0.10 {
		t.Errorf("expected 0.10 max position, got %f", cfg.MaxPositionPct)
	}
}

func TestConfigValidation(t *testing.T) {
	tests := []struct {
		name    string
		modify  func(*Config)
		wantErr bool
	}{
		{"valid mock config", func(c *Config) { c.MockMode = true }, false},
		{"missing agent ID", func(c *Config) { c.AgentID = ""; c.MockMode = true }, true},
		{"missing solana key (non-mock)", func(c *Config) { c.SolanaPrivateKey = "" }, true},
		{"invalid position pct", func(c *Config) { c.MockMode = true; c.MaxPositionPct = 2.0 }, true},
		{"invalid kelly fraction", func(c *Config) { c.MockMode = true; c.KellyFraction = 0 }, true},
		{"interval too short", func(c *Config) { c.MockMode = true; c.TradingInterval = 10 * time.Second }, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			cfg := DefaultConfig()
			tt.modify(&cfg)
			err := cfg.Validate()
			if (err != nil) != tt.wantErr {
				t.Errorf("Validate() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}
```

### Step 3: Create .env.example

Create file `projects/agent-prediction/.env.example`:

```bash
# Prediction Market Agent Configuration
# Copy to .env and fill in values

# Identity
PRED_AGENT_ID=obey-predictor-01

# Drift BET (Solana)
PRED_SOLANA_RPC_URL=https://api.mainnet-beta.solana.com
PRED_SOLANA_PRIVATE_KEY=  # base58-encoded Solana keypair
PRED_WALLET_AUTHORITY=    # Solana public key

# Claude API
PRED_CLAUDE_API_KEY=      # Anthropic API key
PRED_CLAUDE_MODEL=claude-sonnet-4-20250514

# Trading Parameters
PRED_TRADING_INTERVAL=15m
PRED_MAX_POSITION_PCT=0.05
PRED_MIN_EDGE=0.05
PRED_KELLY_FRACTION=0.25
PRED_SEED_CAPITAL=5000

# Risk Limits
PRED_MAX_DRAWDOWN_PCT=0.15
PRED_DAILY_LOSS_LIMIT=0.05

# HCS (Hedera Consensus Service)
PRED_HCS_TASK_TOPIC=0.0.XXXXX
PRED_HCS_RESULT_TOPIC=0.0.XXXXX
PRED_HCS_OPERATOR_ID=0.0.XXXXX
PRED_HCS_OPERATOR_KEY=

# Operational
PRED_MOCK_MODE=false
PRED_LOG_LEVEL=info
```

## Done When

- [ ] All requirements met
- [ ] `internal/agent/config.go` defines `Config` struct with all parameters
- [ ] `LoadFromEnv()` correctly loads all `PRED_*` environment variables
- [ ] `Validate()` catches invalid configurations with clear error messages
- [ ] Mock mode bypasses credential requirements
- [ ] `DefaultConfig()` provides conservative MVP defaults
- [ ] `.env.example` documents all configuration variables
- [ ] `go test ./internal/agent/...` passes
