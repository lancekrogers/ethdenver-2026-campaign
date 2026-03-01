# CRE Risk Router — Product & Implementation Spec

**Project:** CRE Risk Router for Obey Agent Economy
**Hackathon:** Chainlink Convergence (agents-only, Moltbook)
**Category:** `#cre-ai`
**Deadline:** March 8, 2026, 11:59 PM ET
**Prizes:** 1st $3,500 / 2nd $1,500

---

## 1. What We're Building

A standalone CRE (Chainlink Runtime Environment) workflow in Go that acts as an **AI-powered risk decision layer** for autonomous DeFi agents. The workflow:

1. Receives a trade risk-check request (HTTP trigger)
2. Fetches live market data (CRE HTTP capability)
3. Reads a Chainlink price feed on-chain (CRE EVM read capability)
4. Evaluates the trade against 7 risk gates
5. Writes an approved/denied decision receipt on-chain (CRE EVM write capability)
6. Returns constrained trade parameters to the calling agent

Every decision is an immutable on-chain record. Agents can only execute trades that CRE approves, within CRE-specified constraints (max position, slippage cap, TTL).

### Why This Wins

Our structural advantage over every other submission:

- **We have a real agent economy.** 3 working agents across 3 chains (Hedera, 0G, Base), built for ETHDenver. No other team has a live multi-agent system to plug CRE into. Their workflows will be isolated fetch-and-write pipelines. Ours operates inside a production-like system.
- **Substantive logic, not a passthrough.** 7 risk gates vs the typical 1-2 if-statements other teams will submit.
- **CRE capabilities breadth.** We use 5+ CRE capabilities (HTTP trigger, cron trigger, HTTP fetch, EVM read, EVM write, consensus, report generation). Most teams will use 2-3.
- **Denied scenarios prove it works.** We demonstrate approval, denial (multiple reasons), and constraint reduction. Most teams only show happy path.
- **4-chain context.** CRE testnet + Hedera + 0G + Base. Nobody matches this.

---

## 2. Hackathon Requirements Checklist

| Requirement | How We Satisfy | Evidence |
|---|---|---|
| CRE-based workflow, CRE CLI compatible | Standalone Go workflow with `InitWorkflow()` | `workflow.go` |
| Written in Go or TypeScript | Go | `go.mod` |
| Working `cre workflow simulate` from clean clone | Tested simulation with clear setup instructions | README + logs |
| At least one on-chain write (not read-only) | `RiskDecisionReceipt.sol` on CRE-supported testnet | Contract address |
| Transaction hash in simulation output | `cre workflow simulate . --broadcast` | Tx hash in logs |
| Public repository | Standalone repo or public subdir | GitHub link |
| Execution logs/screenshots | Captured simulation output | Evidence artifacts |
| Valid Moltbook post format | Exact title/body format with `#cre-ai` | Post draft |
| No secrets in repo | `.env.example` template, `secrets.yaml` declarations | Verified |
| CRE Experience Feedback section | Written after building | Non-empty section |
| Human registration form completed | `https://forms.gle/xk1PcnRmky2k7yDF7` | Before submission |

---

## 3. Project Structure

New standalone project. Self-contained so judges can evaluate it independently.

```
cre-risk-router/
├── workflow.go                  # CRE workflow entry point (InitWorkflow + handlers)
├── risk.go                      # Risk evaluation logic (7 gates)
├── types.go                     # RiskRequest, RiskDecision, MarketData types
├── helpers.go                   # Hashing, position sizing, slippage calc
├── config.json                  # CRE config (endpoints, networks, thresholds)
├── secrets.yaml                 # Secret declarations
├── .env.example                 # Template for local secrets
├── go.mod
├── go.sum
├── contracts/
│   └── evm/
│       └── src/
│           ├── RiskDecisionReceipt.sol    # On-chain receipt contract
│           └── abi/
│               └── RiskDecisionReceipt.json
├── test/
│   └── RiskDecisionReceipt.t.sol          # Foundry tests
├── scenarios/                             # Pre-built simulation scenarios
│   ├── approved_trade.json
│   ├── denied_low_confidence.json
│   ├── denied_high_risk.json
│   ├── denied_stale_signal.json
│   └── denied_price_deviation.json
├── README.md                              # Setup + simulation instructions
├── justfile                               # Build/simulate/test commands
└── foundry.toml                           # Foundry config for contract
```

This lives either as:

- A new repo: `github.com/lancekrogers/cre-risk-router` (cleaner for judges)
- A subdir: `projects/cre-risk-router/` in the monorepo (simpler to manage)

Decision: resolve before starting implementation.

---

## 4. CRE Workflow Architecture

### Entry Point

```go
func main() {
    cre.Run(InitWorkflow)
}

func InitWorkflow(runtime cre.Runtime) []cre.Handler {
    return []cre.Handler{
        // HTTP trigger: agent-coordinator sends risk check requests
        cre.NewHandler(httpTrigger("/evaluate-risk", "POST"), onRiskEvaluation),
        // Cron trigger: scheduled sweep for simulation/demo
        cre.NewHandler(cronTrigger("*/5 * * * *"), onScheduledSweep),
    }
}
```

### Data Flow

```
HTTP POST /evaluate-risk
  │ (RiskRequest payload)
  ▼
┌──────────────────────────────┐
│  1. Parse request            │
│  2. HTTP fetch market data   │◄── CoinGecko/similar API
│  3. EVM read price feed      │◄── Chainlink ETH/USD on testnet
│  4. Evaluate 7 risk gates    │
│  5. Generate decision        │
│  6. Write receipt on-chain   │──► RiskDecisionReceipt.sol
│  7. Return decision          │
└──────────────────────────────┘
  │
  ▼
RiskDecision response
  (approved/denied + constraints)
```

### Two Triggers

**HTTP Trigger (primary):** For live agent integration. Agent-coordinator POSTs a `RiskRequest`, gets back a `RiskDecision`.

**Cron Trigger (secondary):** For simulation and demo. Runs every 5 minutes, generates a synthetic `RiskRequest` with realistic parameters, evaluates it through the same pipeline. This ensures `cre workflow simulate` works without needing a live HTTP client.

---

## 5. Types

### RiskRequest (input)

```go
type RiskRequest struct {
    AgentID           string  `json:"agent_id"`             // Which agent is requesting
    TaskID            string  `json:"task_id"`              // Task being evaluated
    Signal            string  `json:"signal"`               // buy | sell | hold
    SignalConfidence  float64 `json:"signal_confidence"`    // 0.0 - 1.0
    RiskScore         int     `json:"risk_score"`           // 0 - 100 (higher = riskier)
    MarketPair        string  `json:"market_pair"`          // e.g. "ETH/USD"
    RequestedPosition float64 `json:"requested_position_usd"`
    Timestamp         int64   `json:"timestamp"`            // Unix seconds
}
```

### RiskDecision (output)

```go
type RiskDecision struct {
    RunID          [32]byte `json:"run_id"`
    DecisionHash   [32]byte `json:"decision_hash"`
    Approved       bool     `json:"approved"`
    MaxPositionUSD uint64   `json:"max_position_usd"`
    MaxSlippageBps uint64   `json:"max_slippage_bps"`
    TTLSeconds     uint64   `json:"ttl_seconds"`
    Reason         string   `json:"reason"`
    ChainlinkPrice uint64   `json:"chainlink_price"`
    Timestamp      int64    `json:"timestamp"`
}
```

### MarketData (fetched via HTTP)

```go
type MarketData struct {
    Price        float64 `json:"current_price"`
    Volume24h    float64 `json:"total_volume"`
    Volatility24h float64 `json:"price_change_percentage_24h"`
    MarketCap    float64 `json:"market_cap"`
}
```

### Config

```go
type Config struct {
    MarketDataURL    string  `json:"market_data_url"`
    PriceFeedAddress string  `json:"price_feed_address"`
    ReceiptContract  string  `json:"receipt_contract_address"`
    TargetNetwork    string  `json:"target_network"`
    ConfidenceThresh float64 `json:"signal_confidence_threshold"` // default 0.6
    MaxRiskScore     int     `json:"max_risk_score"`              // default 75
    MaxPositionBps   int     `json:"default_max_position_bps"`    // default 5000 (50%)
    DecisionTTLSec   int     `json:"decision_ttl_seconds"`        // default 300
    PriceDevMaxBps   int     `json:"price_deviation_max_bps"`     // default 500 (5%)
    VolatilityScale  float64 `json:"volatility_scale_factor"`     // default 1.0
}
```

---

## 6. Risk Evaluation Logic (7 Gates)

The core differentiator. Each gate independently evaluates one dimension. A trade must pass all gates to be approved. Denied decisions still get written on-chain with the denial reason.

### Gate 1: Signal Confidence Threshold

```
IF signal_confidence < config.confidence_threshold (0.6):
  DENY "signal_confidence_below_threshold"
```

Rejects low-quality AI signals. An inference agent that's unsure shouldn't trigger trades.

### Gate 2: Risk Score Ceiling

```
IF risk_score > config.max_risk_score (75):
  DENY "risk_score_exceeds_maximum"
```

Rejects trades that the inference agent itself flagged as high-risk.

### Gate 3: Signal Staleness

```
IF (now - request.timestamp) > config.decision_ttl_seconds (300):
  DENY "signal_expired"
```

Rejects stale signals. Markets move; a 10-minute-old buy signal is dangerous.

### Gate 4: Price Deviation vs Chainlink Oracle

```
chainlink_price = EVM_READ(price_feed_address, "latestRoundData()")
market_price = HTTP_FETCH(market_data_url)
deviation_bps = abs(market_price - chainlink_price) / chainlink_price * 10000

IF deviation_bps > config.price_deviation_max_bps (500):
  DENY "price_deviation_exceeds_threshold"
```

If the agent's market data diverges significantly from the Chainlink oracle, something is wrong (stale data, manipulation, API error). This is the key Chainlink integration - using the oracle as ground truth.

### Gate 5: Volatility-Adjusted Position Sizing

```
volatility_factor = 1.0 - (volatility_24h / 100.0 * config.volatility_scale)
risk_factor = 1.0 - (risk_score / 100.0)
max_position = requested_position * volatility_factor * risk_factor
```

Doesn't deny, but caps the position size. High volatility + high risk = smaller allowed position.

### Gate 6: Hold Signal Filter

```
IF signal == "hold":
  DENY "hold_signal_no_trade"
```

A hold signal means "do nothing." CRE enforces this as a hard deny.

### Gate 7: Agent Health Check (Circuit Breaker)

```
agent_heartbeat = HTTP_FETCH(mirror_node_api, agent_id, "heartbeat")
IF (now - agent_heartbeat.timestamp) > heartbeat_ttl (600):
  DENY "agent_heartbeat_stale"
```

If the requesting agent hasn't sent a heartbeat recently (read from Hedera Mirror Node via HTTP), deny all trades. This is the circuit breaker element borrowed from Idea #6 in the exploration.

### Decision Output

Every evaluation (approved or denied) produces a `RiskDecision` that gets:

1. Hashed into `decision_hash` (keccak256 of all fields)
2. Assigned a unique `run_id` (derived from task_id + timestamp)
3. Written on-chain to `RiskDecisionReceipt.sol`

---

## 7. Smart Contract: RiskDecisionReceipt.sol

Deployed on a CRE-supported EVM testnet. Simple, auditable, functional.

### Interface

```solidity
function recordDecision(
    bytes32 runId,
    bytes32 decisionHash,
    bool approved,
    uint256 maxPositionUsd,     // 6 decimal precision
    uint256 maxSlippageBps,
    uint256 ttlSeconds,
    uint256 chainlinkPrice      // 8 decimal precision (matches Chainlink)
) external;

function isDecisionValid(bytes32 runId) external view returns (bool);
function getRunCount() external view returns (uint256);
```

### Events

```solidity
event DecisionRecorded(
    bytes32 indexed runId,
    bytes32 indexed decisionHash,
    bool approved,
    uint256 maxPositionUsd,
    uint256 maxSlippageBps,
    uint256 chainlinkPrice,
    address indexed recorder,
    uint256 timestamp
);
```

### Storage

```solidity
mapping(bytes32 => Decision) public decisions;  // runId => Decision struct
mapping(bytes32 => bool) public recorded;        // duplicate prevention
bytes32[] public runIds;                         // enumeration
uint256 public totalDecisions;
uint256 public totalApproved;
uint256 public totalDenied;
```

### Tests (Foundry)

4 core tests:

1. Record approved decision - verify storage, events, counters
2. Record denied decision - verify denial counters
3. Reject duplicate runId - `require(!recorded[runId])`
4. Decision expiry - `isDecisionValid` returns false after TTL via `vm.warp`

### Deployment

Deploy via Foundry to CRE-supported testnet:

```bash
forge create src/RiskDecisionReceipt.sol:RiskDecisionReceipt \
  --rpc-url $TESTNET_RPC --private-key $DEPLOYER_KEY
```

Verify on block explorer for judge inspection.

---

## 8. Integration with Existing Agent Economy

### Strategy: Standalone First, Bridge Second

The CRE workflow ships as a standalone project. Integration with existing agents is P1 work that makes the demo richer but isn't required for hackathon qualification.

### P0: Standalone CRE Workflow (Required)

No changes to existing repos. The workflow runs independently and is simulatable from a clean clone. The submission describes how it fits into the agent economy but doesn't require live integration.

### P1: Coordinator Bridge (If Time Allows)

Add a thin HTTP client to `agent-coordinator` that calls the CRE Risk Router before assigning trade tasks:

```
agent-coordinator/internal/chainlink/cre/
├── client.go     # HTTP client to CRE Risk Router
└── models.go     # RiskRequest/RiskDecision types
```

Wire into `assign.go`: if CRE client is configured and decision is denied, publish a `quality_gate` event instead of assigning the task.

### P1: Inference Signal Fields (If Time Allows)

Add optional structured fields to inference `task_result` payload:

- `signal` (buy|sell|hold)
- `signal_confidence` (0.0-1.0)
- `risk_score` (0-100)
- `explanation_hash`

These are the fields the CRE workflow expects as input.

### P1: DeFi Execution Guard (If Time Allows)

Add optional CRE constraint enforcement in `agent-defi` trading strategy:

- If CRE constraints are present, cap position/slippage to CRE limits
- If CRE decision is absent, fall back to local strategy (backwards compatible)

### P2: Dashboard Panel (Stretch)

Add a CRE panel showing decision timeline:

```
Signal → Risk Evaluation → Decision (tx hash) → Execution
```

---

## 9. Simulation Scenarios

Pre-built JSON scenarios for repeatable demos:

### Scenario 1: Approved Trade

```json
{
  "signal": "buy", "signal_confidence": 0.85, "risk_score": 35,
  "requested_position_usd": 1000, "market_pair": "ETH/USD"
}
```

Expected: Approved, max position $1000, slippage 50 bps

### Scenario 2: Denied — Low Confidence

```json
{
  "signal": "buy", "signal_confidence": 0.45, "risk_score": 35,
  "requested_position_usd": 1000, "market_pair": "ETH/USD"
}
```

Expected: Denied, reason `signal_confidence_below_threshold`

### Scenario 3: Denied — High Risk

```json
{
  "signal": "sell", "signal_confidence": 0.9, "risk_score": 82,
  "requested_position_usd": 2000, "market_pair": "ETH/USD"
}
```

Expected: Denied, reason `risk_score_exceeds_maximum`

### Scenario 4: Denied — Stale Signal

```json
{
  "signal": "buy", "signal_confidence": 0.8, "risk_score": 40,
  "requested_position_usd": 1000, "timestamp": "<now - 600>"
}
```

Expected: Denied, reason `signal_expired`

### Scenario 5: Constrained — Volatility Reduction

```json
{
  "signal": "buy", "signal_confidence": 0.75, "risk_score": 55,
  "requested_position_usd": 5000, "market_pair": "ETH/USD"
}
```

Expected: Approved, max position reduced to ~$2250 (volatility + risk factor applied)

---

## 10. Deliverables (Priority Ordered)

### P0 — Ship or DQ (Days 1-5)

1. **CRE project scaffold** — `go.mod`, `workflow.go`, `config.json`, `secrets.yaml`, `.env.example`
2. **CRE CLI setup** — Install CLI, `cre login`, `cre init`, verify basic simulation works
3. **RiskDecisionReceipt.sol** — Contract, tests, deploy to CRE-supported testnet
4. **Risk evaluation logic** — 7 gates in `risk.go`, types in `types.go`
5. **CRE workflow handlers** — HTTP trigger + cron trigger wired to evaluation logic
6. **EVM bindings** — `cre generate-bindings evm` from contract ABI
7. **First successful simulation** — `cre workflow simulate .` dry run passes
8. **First on-chain write** — `cre workflow simulate . --broadcast` produces tx hash
9. **README** — Clone-to-simulate in under 5 commands

### P0 — Ship or Weak Submission (Days 5-7)

1. **Simulation scenarios** — 5 pre-built JSON scenarios with expected outcomes
2. **Submission post draft** — Exact Moltbook format with all required sections
3. **Evidence capture** — Logs, tx hash, block explorer link
4. **Registration form** — Complete human operator form
5. **Publish Moltbook post** — Before 11:59 PM ET March 8

### P1 — Competitive Edge (If P0 Stable)

1. **Coordinator CRE client** — HTTP bridge in `agent-coordinator`
2. **Inference signal fields** — Structured signal in `agent-inference` task results
3. **DeFi execution guard** — CRE constraint enforcement in `agent-defi`
4. **HCS message types** — `cre_simulation`, `cre_decision`, `cre_execution_receipt`

### P2 — Polish

1. **Dashboard CRE panel**
2. **Contract verification** on block explorer
3. **Demo video/GIF**

---

## 11. Unknowns to Resolve Early

These must be answered in the first 1-2 days of implementation:

| Unknown | How to Resolve | Impact if Wrong |
|---|---|---|
| Which testnets does CRE support? | Run `cre --help`, check docs, try simulation | Could block all on-chain work |
| Does CRE require authentication/linked key? | Run `cre login`, `cre account link-key` | Could block simulation |
| How does HTTP trigger work in simulation? | Test with minimal workflow | May need cron-only for simulation |
| Exact CRE Go SDK import paths | Check `go.dev` or CRE docs | Blocks compilation |
| Chainlink price feed addresses on chosen testnet | Check Chainlink docs / data feeds page | Blocks Gate 4 |
| Does `--broadcast` require a funded wallet? | Test with testnet faucet | Blocks on-chain write |
| What is the `IReceiver` interface for proper CRE writes? | Read CRE SDK source / docs | May need direct call fallback |
| Standalone repo vs monorepo subdir? | Decision from Lance | Affects project setup |

---

## 12. Submission Format

### Post Title

```
#chainlink-hackathon-convergence #cre-ai — CRE Risk Router for Autonomous Agent Economy
```

### Post Body (required sections from template)

1. **First line:** `#chainlink-hackathon-convergence #cre-ai`
2. **Project Description:** Problem, architecture, CRE usage
3. **GitHub Repository:** Public link
4. **Setup Instructions:** Clone, install CRE CLI, configure `.env`, simulate
5. **Simulation Commands:** Exact commands with expected output
6. **Workflow Description:** Triggers, capabilities, risk gates, targets
7. **On-Chain Write Explanation:** Network, contract, operation, purpose
8. **Evidence Artifact:** Logs with tx hash clearly visible
9. **CRE Experience Feedback:** Genuine feedback (required, non-empty)
10. **Eligibility Confirmation:** Registration form + uniqueness attestation

---

## 13. Reference Material

| Resource | URL |
|---|---|
| Hackathon rules | `docs/2026_requirements/moltbook/chainlink/clink-converge-hackathon.md` |
| Hackathon skills repo | `github.com/smartcontractkit/chainlink-agents-hackathon-skills` |
| CRE skills repo | `github.com/smartcontractkit/chainlink-agent-skills/cre-skills` |
| Codex design (reference) | `workflow/design/chainlink/codex/` |
| Claude design (detailed) | `workflow/design/chainlink/claude/` |
| Idea exploration | `workflow/explore/chainlink/idea-exploration.md` |
| Codex review | `workflow/design/chainlink/claude/07-codex-design-review.md` |
| Registration form | `https://forms.gle/xk1PcnRmky2k7yDF7` |
