# 01 - CRE Risk Router Architecture

## High-Level Architecture

```
                        ┌─────────────────────────────┐
                        │   CRE Risk Router Workflow   │
                        │   (standalone Go program)    │
                        │                              │
  Trigger ──────────►   │  1. HTTP Trigger (incoming)  │
  (agent-coordinator    │  2. Fetch market data (HTTP) │
   sends risk check     │  3. Read price feeds (EVM)   │
   request via HTTP)    │  4. AI signal evaluation     │
                        │  5. Risk scoring logic       │
                        │  6. Generate signed report   │
                        │  7. Write decision on-chain  │
                        │                              │
                        └──────────┬──────────────────┘
                                   │
                    ┌──────────────┼──────────────────┐
                    ▼              ▼                   ▼
             Decision Event   On-Chain Receipt    HTTP Callback
             (EVM log)        (tx hash proof)     (to coordinator)
                    │                                  │
                    ▼                                  ▼
             agent-defi                        agent-coordinator
             (consumes via                     (receives decision,
              EVM log or                        updates HCS topic)
              HTTP poll)
```

## Why This Architecture

### Hackathon Requirements Alignment

| Requirement | How We Satisfy |
|---|---|
| CRE-based workflow | Standalone Go workflow with `InitWorkflow()` |
| `cre workflow simulate` | Workflow is simulatable from clean clone |
| On-chain write | `RiskDecisionReceipt.sol` on CRE-supported testnet |
| Transaction hash | `--broadcast` flag produces verifiable tx |
| `#cre-ai` use case | AI inference signals drive risk decisions |

### Integration with Existing Economy

The CRE workflow is a **new standalone project** that bridges Chainlink CRE with the existing agent economy. It does NOT modify the core agent repos. Instead:

- **agent-coordinator** sends HTTP requests to trigger the CRE workflow
- **CRE workflow** processes the request, writes decision on-chain, and returns result
- **agent-defi** can optionally read decisions from on-chain events
- **dashboard** can display CRE decision events

This is strategically important: it keeps existing agent code stable while adding a new CRE-native component.

## New Project: `cre-risk-router`

A new project in `projects/cre-risk-router/` that is a proper CRE workflow.

```
projects/cre-risk-router/
├── workflow.go              # Main CRE workflow (InitWorkflow + handlers)
├── config.json              # CRE configuration (endpoints, networks)
├── secrets.yaml             # Secret declarations for simulation
├── .env                     # Local dev secrets
├── go.mod
├── go.sum
├── contracts/
│   └── evm/
│       └── src/
│           └── abi/
│               └── RiskDecisionReceipt.json   # ABI for on-chain target
├── README.md                # Setup + simulation instructions
└── justfile                 # Build/simulate/test commands
```

## CRE Workflow Components

### Trigger: HTTP

The workflow is triggered by an HTTP POST from the agent-coordinator (or manually for simulation). The HTTP trigger provides cryptographic signature verification.

**Trigger payload:**
```json
{
  "agent_id": "agent-defi-001",
  "task_id": "task-abc-123",
  "signal": "buy",
  "signal_confidence": 0.85,
  "risk_score": 35,
  "market_pair": "USDC/WETH",
  "requested_position_usd": 1000,
  "timestamp": 1741000000
}
```

### Capabilities Used

1. **HTTP Client** - Fetch current market data (price, volume, volatility) from external APIs
2. **EVM Client** - Read on-chain state (Chainlink price feeds on testnet, contract balances)
3. **Consensus** - Median aggregation across DON nodes for deterministic results

### Risk Evaluation Logic

The workflow evaluates the incoming signal against multiple risk dimensions:

1. **Signal quality gate**: confidence threshold (reject if < 0.6)
2. **Market risk check**: volatility assessment from market data
3. **Position sizing**: cap position based on risk score
4. **Staleness check**: reject if signal older than TTL (300s)
5. **Price deviation**: compare agent's implied price vs Chainlink feed

Output: `RiskDecision` struct with `approved`, `max_position_usd`, `max_slippage_bps`, `ttl_seconds`, `run_id`, `decision_hash`

### Target: On-Chain Write

Write the `RiskDecision` to `RiskDecisionReceipt.sol` on a CRE-supported testnet.

**Function:** `recordDecision(bytes32 runId, bytes32 decisionHash, bool approved, uint256 maxPositionUsd, uint256 maxSlippageBps, uint256 ttlSeconds)`

**Event:** `DecisionRecorded(bytes32 indexed runId, bytes32 decisionHash, bool approved, address indexed sender, uint256 timestamp)`

### Target: HTTP Callback (optional)

POST the decision back to the agent-coordinator endpoint for immediate consumption.

## Simulation Strategy

For the hackathon, the workflow must be simulatable standalone:

```bash
# From clean clone
cd projects/cre-risk-router
cp .env.example .env
# Set any required API keys
cre workflow simulate . --broadcast
```

The simulation:
1. Uses a mock/cron trigger for deterministic replay (HTTP trigger can be simulated)
2. Fetches real market data via HTTP
3. Reads Chainlink price feed on testnet
4. Evaluates risk decision
5. Writes receipt on-chain (with `--broadcast`)
6. Produces tx hash in output

## Network Selection

**Primary target: Arbitrum Sepolia** (or Base Sepolia)
- Well-supported by CRE
- Chainlink price feeds available on testnet
- Low gas costs for testnet writes
- Already used by many CRE examples

Need to verify exact CRE-supported networks via `cre` CLI docs.

## What Makes This Strong for Judges

1. **Real utility** - Risk gating for autonomous agents is a genuine CRE use case, not a toy demo
2. **Multi-chain story** - CRE workflow on EVM testnet, agents on Hedera/0G/Base
3. **AI integration** - Inference signals from 0G compute feed into CRE risk logic
4. **Production architecture** - Decoupled workflow that could scale to real agent operations
5. **Clean simulation** - One command, reproducible, clear tx hash output
