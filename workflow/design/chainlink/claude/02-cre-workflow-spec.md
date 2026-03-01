# 02 - CRE Workflow Specification (Go)

## Workflow: `risk-router`

### Entry Point: `workflow.go`

```go
package main

import (
    "github.com/smartcontractkit/chainlink-cre/pkg/cre"
    "github.com/smartcontractkit/chainlink-cre/pkg/capabilities/cron"
    "github.com/smartcontractkit/chainlink-cre/pkg/capabilities/http"
    "github.com/smartcontractkit/chainlink-cre/pkg/capabilities/evm"
)

type Config struct {
    MarketDataURL     string `json:"market_data_url"`
    PriceFeedAddress  string `json:"price_feed_address"`
    ReceiptContract   string `json:"receipt_contract_address"`
    TargetNetwork     string `json:"target_network"`
    SignalConfThresh  float64 `json:"signal_confidence_threshold"`
    MaxRiskScore      int     `json:"max_risk_score"`
    DefaultMaxPosBps  int     `json:"default_max_position_bps"`
    DecisionTTLSec    int     `json:"decision_ttl_seconds"`
}

func main() {
    cre.Run(InitWorkflow)
}

func InitWorkflow(runtime cre.Runtime) []cre.Handler {
    return []cre.Handler{
        // Primary: HTTP trigger for live agent requests
        cre.NewHandler(
            http.NewTrigger(http.TriggerConfig{
                Method: "POST",
                Path:   "/evaluate-risk",
            }),
            onRiskEvaluation,
        ),
        // Secondary: Cron trigger for scheduled risk sweeps (demo/simulation)
        cre.NewHandler(
            cron.NewTrigger(cron.TriggerConfig{
                Schedule: "*/5 * * * *", // every 5 minutes
            }),
            onScheduledRiskSweep,
        ),
    }
}
```

### Risk Evaluation Handler

```go
// RiskRequest is the incoming payload from agent-coordinator or simulation
type RiskRequest struct {
    AgentID            string  `json:"agent_id"`
    TaskID             string  `json:"task_id"`
    Signal             string  `json:"signal"`             // buy|sell|hold
    SignalConfidence   float64 `json:"signal_confidence"`  // 0.0-1.0
    RiskScore          int     `json:"risk_score"`         // 0-100
    MarketPair         string  `json:"market_pair"`        // e.g. USDC/WETH
    RequestedPosition  float64 `json:"requested_position_usd"`
    Timestamp          int64   `json:"timestamp"`
}

// RiskDecision is the output written on-chain and returned to caller
type RiskDecision struct {
    RunID           [32]byte `json:"run_id"`
    DecisionHash    [32]byte `json:"decision_hash"`
    Approved        bool     `json:"approved"`
    MaxPositionUSD  uint64   `json:"max_position_usd"`
    MaxSlippageBps  uint64   `json:"max_slippage_bps"`
    TTLSeconds      uint64   `json:"ttl_seconds"`
    Reason          string   `json:"reason"`
    ChainlinkPrice  uint64   `json:"chainlink_price"`
    Timestamp       int64    `json:"timestamp"`
}

func onRiskEvaluation(
    config *Config,
    runtime cre.Runtime,
    request *http.Request,
) (*RiskDecision, error) {
    // 1. Parse incoming risk request
    var req RiskRequest
    // decode request body into req

    // 2. Fetch market data via HTTP capability
    marketData := fetchMarketData(runtime, config.MarketDataURL, req.MarketPair)

    // 3. Read Chainlink price feed via EVM capability
    chainlinkPrice := readPriceFeed(runtime, config.PriceFeedAddress, config.TargetNetwork)

    // 4. Evaluate risk
    decision := evaluateRisk(config, req, marketData, chainlinkPrice, runtime)

    // 5. Generate signed report for on-chain write
    report := runtime.GenerateReport(decision)

    // 6. Write decision receipt on-chain
    writeTx := writeDecisionOnChain(runtime, config.ReceiptContract, config.TargetNetwork, decision)

    return &decision, nil
}
```

### Risk Evaluation Logic

```go
func evaluateRisk(
    config *Config,
    req RiskRequest,
    market MarketData,
    chainlinkPrice uint64,
    runtime cre.Runtime,
) RiskDecision {
    now := runtime.Now()
    runID := generateRunID(req.TaskID, now)

    // Gate 1: Signal confidence threshold
    if req.SignalConfidence < config.SignalConfThresh {
        return denyDecision(runID, "signal_confidence_below_threshold")
    }

    // Gate 2: Risk score ceiling
    if req.RiskScore > config.MaxRiskScore {
        return denyDecision(runID, "risk_score_exceeds_maximum")
    }

    // Gate 3: Signal staleness (TTL check)
    signalAge := now.Unix() - req.Timestamp
    if signalAge > int64(config.DecisionTTLSec) {
        return denyDecision(runID, "signal_expired")
    }

    // Gate 4: Price deviation check
    // Compare agent's implied market price vs Chainlink oracle price
    // Reject if deviation > 5% (potential stale/manipulated data)
    if priceDeviation(market.Price, chainlinkPrice) > 500 { // 5% in bps
        return denyDecision(runID, "price_deviation_exceeds_threshold")
    }

    // Gate 5: Volatility-adjusted position sizing
    maxPosition := calculateMaxPosition(
        req.RequestedPosition,
        market.Volatility24h,
        req.RiskScore,
        config.DefaultMaxPosBps,
    )

    // Gate 6: Hold signal = no trade
    if req.Signal == "hold" {
        return denyDecision(runID, "hold_signal_no_trade")
    }

    // Approved: compute constrained parameters
    slippageBps := calculateSlippage(market.Volatility24h, market.Liquidity)

    decision := RiskDecision{
        RunID:          runID,
        Approved:       true,
        MaxPositionUSD: uint64(maxPosition),
        MaxSlippageBps: slippageBps,
        TTLSeconds:     uint64(config.DecisionTTLSec),
        Reason:         "approved_within_risk_parameters",
        ChainlinkPrice: chainlinkPrice,
        Timestamp:      now.Unix(),
    }
    decision.DecisionHash = hashDecision(decision)
    return decision
}
```

### Helper Functions

```go
func fetchMarketData(runtime cre.Runtime, baseURL, pair string) MarketData {
    // Use CRE HTTP capability to fetch market data
    // This ensures deterministic execution across DON nodes
    resp := runtime.HTTPClient().Get(baseURL + "/v1/market/" + pair)
    // parse response into MarketData
    return resp.Await()
}

func readPriceFeed(runtime cre.Runtime, feedAddr, network string) uint64 {
    // Use CRE EVM capability to read Chainlink price feed
    // latestRoundData() on the price feed contract
    client := runtime.EVMClient(network)
    result := client.CallContract(feedAddr, "latestRoundData()")
    return result.Await()
}

func writeDecisionOnChain(
    runtime cre.Runtime,
    contractAddr, network string,
    decision RiskDecision,
) {
    // Use CRE EVM capability to write decision receipt
    client := runtime.EVMClient(network)
    report := runtime.GenerateReport(encodeDecision(decision))
    client.WriteReport(contractAddr, report)
}

func onScheduledRiskSweep(
    config *Config,
    runtime cre.Runtime,
    trigger *cron.Payload,
) (*RiskDecision, error) {
    // For simulation/demo: generate a synthetic risk request
    // representing an agent's periodic risk check
    syntheticReq := RiskRequest{
        AgentID:           "agent-defi-001",
        TaskID:            "sweep-" + runtime.Now().Format("20060102-150405"),
        Signal:            "buy",
        SignalConfidence:   0.82,
        RiskScore:          42,
        MarketPair:        "USDC/WETH",
        RequestedPosition:  1000.0,
        Timestamp:          runtime.Now().Unix(),
    }

    // Use the same evaluation logic
    return onRiskEvaluation(config, runtime, synthesizeHTTPRequest(syntheticReq))
}
```

## Config: `config.json`

```json
{
  "market_data_url": "https://api.coingecko.com/api/v3",
  "price_feed_address": "0x...",
  "receipt_contract_address": "0x...",
  "target_network": "arbitrum-sepolia",
  "signal_confidence_threshold": 0.6,
  "max_risk_score": 75,
  "default_max_position_bps": 5000,
  "decision_ttl_seconds": 300
}
```

## Secrets: `secrets.yaml`

```yaml
secrets:
  - name: MARKET_API_KEY
    description: "API key for market data provider"
  - name: RPC_URL
    description: "RPC endpoint for target network"
```

## Simulation Commands

```bash
# Install CRE CLI
curl -sSL https://cre.chain.link/install | sh

# Initialize project
cre init

# Generate EVM bindings for receipt contract
cre generate-bindings evm

# Dry-run simulation (no on-chain write)
cre workflow simulate .

# Broadcast simulation (produces on-chain tx hash)
cre workflow simulate . --broadcast

# Verbose simulation with target network
cre workflow simulate . --broadcast --target arbitrum-sepolia --verbose
```

## Important SDK Notes

These are based on the CRE documentation and must be followed:

1. **Use `runtime.Now()`** for all timestamps, never `time.Now()` (determinism across DON nodes)
2. **Use `.Await()`** for all async operations (single-threaded environment)
3. **Callback signatures must match trigger types** exactly
4. **Config is loaded from `config.json`** automatically by CRE runtime
5. **Secrets declared in `secrets.yaml`** are accessed via env vars during simulation
6. **`cre generate-bindings evm`** generates type-safe Go bindings from ABI files
