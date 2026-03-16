---
fest_type: task
fest_id: 05_entry_point.md
fest_name: 05_entry_point
fest_parent: 02_agent_runtime
fest_order: 5
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-13T19:24:37.807432-06:00
fest_updated: 2026-03-15T19:39:19.001312-06:00
fest_tracking: true
---


# Task: vault-agent Entry Point

## Objective

Create the vault-agent binary entry point that wires all components (vault client, strategy, risk manager, trading loop) with environment-based configuration and graceful shutdown.

## Requirements

- [ ] Create `cmd/vault-agent/main.go`
- [ ] Load config from environment: VAULT_RPC_URL, VAULT_ADDRESS, AGENT_PRIVATE_KEY, ANTHROPIC_API_KEY, TOKEN_IN, TOKEN_OUT, LLM_MODEL
- [ ] Wire vault.NewClient, strategy.NewLLMStrategy with ClaudeClient, risk.NewManager, loop.New
- [ ] Default parameters: 5-minute interval, 1000 USD max position, 10000 USD daily volume, 10% drawdown halt
- [ ] Graceful shutdown via signal.NotifyContext (SIGINT, SIGTERM)
- [ ] Add justfile recipe: `vault-agent: go run ./cmd/vault-agent/`

## Dependencies

- All prior agent runtime tasks must be complete: `05_vault_client`, `04_llm_strategy`, `03_risk_manager`, `02_trading_loop`.
- Imports all four internal packages: `vault`, `strategy`, `risk`, `loop`.

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `VAULT_RPC_URL` | No | `https://sepolia.base.org` | Base Sepolia RPC endpoint |
| `VAULT_ADDRESS` | **Yes** | — | Deployed ObeyVault contract address |
| `AGENT_PRIVATE_KEY` | **Yes** | — | Hex-encoded private key for the agent wallet |
| `ANTHROPIC_API_KEY` | **Yes** | — | Anthropic API key for Claude |
| `TOKEN_IN` | **Yes** | — | Address of input token (e.g., USDC) |
| `TOKEN_OUT` | **Yes** | — | Address of output token (e.g., WETH) |
| `LLM_MODEL` | No | `claude-sonnet-4-6` | Claude model to use |
| `AGENT_WALLET_ADDRESS` | No | — | Agent wallet address (informational logging) |
| `DEX_ROUTER` | No | — | DEX router address (for future use) |

## Default Configuration Values

- **ChainID:** 84532 (Base Sepolia)
- **Interval:** 5 minutes
- **MaxPositionUSD:** 1000
- **MaxDailyVolumeUSD:** 10000
- **MaxDrawdownPct:** 10% (0.10)
- **InitialNAV:** 10000

## Implementation Steps

### Step 1: Create `projects/agent-defi/cmd/vault-agent/main.go`

Create the directory if needed: `mkdir -p projects/agent-defi/cmd/vault-agent`

```go
package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/lancekrogers/agent-defi/internal/loop"
	"github.com/lancekrogers/agent-defi/internal/risk"
	"github.com/lancekrogers/agent-defi/internal/strategy"
	"github.com/lancekrogers/agent-defi/internal/vault"
)

func main() {
	// --- Load environment variables ---
	rpcURL := envOrDefault("VAULT_RPC_URL", "https://sepolia.base.org")
	vaultAddr := requireEnv("VAULT_ADDRESS")
	privKey := requireEnv("AGENT_PRIVATE_KEY")
	anthropicKey := requireEnv("ANTHROPIC_API_KEY")
	tokenIn := requireEnv("TOKEN_IN")
	tokenOut := requireEnv("TOKEN_OUT")
	llmModel := envOrDefault("LLM_MODEL", "claude-sonnet-4-6")

	// --- Wire vault client ---
	vaultClient := vault.NewClient(vault.Config{
		RPCURL:       rpcURL,
		ChainID:      84532, // Base Sepolia
		VaultAddress: vaultAddr,
		PrivateKey:   privKey,
	})

	// --- Wire LLM strategy ---
	claudeClient := strategy.NewClaudeClient(anthropicKey, llmModel)
	strat := strategy.NewLLMStrategy(strategy.LLMConfig{
		Model:       llmModel,
		MaxPosition: 1000, // 1000 USD max position
	}, claudeClient)

	// --- Wire risk manager ---
	riskMgr := risk.NewManager(risk.Config{
		MaxPositionUSD:    1000,
		MaxDailyVolumeUSD: 10000,
		MaxDrawdownPct:    0.10,
		InitialNAV:        10000,
	})

	// --- Wire trading loop ---
	// NOTE: Pass a real trading.TradeExecutor for GetMarketState in production.
	// For now, the executor must be injected before running.
	runner := loop.New(loop.Config{
		Interval: 5 * time.Minute,
		TokenIn:  tokenIn,
		TokenOut: tokenOut,
	}, vaultClient, nil, strat, riskMgr)

	// --- Graceful shutdown via signal.NotifyContext ---
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	log.Println("vault-agent: starting")
	log.Printf("vault-agent: rpc=%s vault=%s model=%s", rpcURL, vaultAddr, llmModel)
	log.Printf("vault-agent: tokenIn=%s tokenOut=%s", tokenIn, tokenOut)

	if err := runner.Run(ctx); err != nil && err != context.Canceled {
		log.Fatalf("vault-agent: fatal: %v", err)
	}

	log.Println("vault-agent: shutdown complete")
}

func requireEnv(key string) string {
	val := os.Getenv(key)
	if val == "" {
		log.Fatalf("vault-agent: required env var %s is not set", key)
	}
	return val
}

func envOrDefault(key, fallback string) string {
	val := os.Getenv(key)
	if val == "" {
		return fallback
	}
	return val
}
```

### Step 2: Verify Compilation

```bash
cd projects/agent-defi && go build ./cmd/vault-agent/
```

**Expected output:** Clean build, no errors. Binary written to current directory or `$GOPATH/bin`.

### Step 3: Add Justfile Recipe

Add the following recipe to the agent-defi justfile (either `projects/agent-defi/justfile` or the appropriate modular justfile):

```just
# Run the vault agent
vault-agent:
    go run ./cmd/vault-agent/
```

## Done When

- [ ] All requirements met
- [ ] `cd projects/agent-defi && go build ./cmd/vault-agent/` compiles successfully