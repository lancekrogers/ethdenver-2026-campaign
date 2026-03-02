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
4. Evaluates the trade against 8 risk gates
5. Writes an approved/denied decision receipt on-chain (CRE EVM write capability)
6. Returns constrained trade parameters to the calling agent

Every decision is an immutable on-chain record. Agents can only execute trades that CRE approves, within CRE-specified constraints (max position, slippage cap, TTL).

### Why This Wins

Our structural advantage over every other submission:

- **We have a real agent economy.** 3 working agents across 3 chains (Hedera, 0G, Base), built for ETHDenver. No other team has a live multi-agent system to plug CRE into. Their workflows will be isolated fetch-and-write pipelines. Ours operates inside a production-like system.
- **Substantive logic, not a passthrough.** 8 risk gates (7 active + 1 configurable) vs the typical 1-2 if-statements other teams will submit.
- **CRE capabilities breadth.** We use 5 CRE capabilities (HTTP trigger, cron trigger, HTTP fetch, EVM read, EVM write). Most teams will use 2-3.
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
├── risk.go                      # Risk evaluation logic (8 gates)
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
├── demo/
│   └── e2e.sh                             # Curls HTTP trigger with realistic payload
├── README.md                              # Setup + simulation instructions
├── justfile                               # Build/simulate/test commands
└── foundry.toml                           # Foundry config for contract
```

This lives at `projects/cre-risk-router/` in the Obey Agent Economy monorepo. The submission README directs judges to this directory and provides clear setup instructions.

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
│  4. Evaluate 8 risk gates    │
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

**Cron Trigger (secondary):** Simulation entry point only. Generates a synthetic `RiskRequest` with hardcoded realistic parameters and evaluates it through the same pipeline. Exists so `cre workflow simulate` works without an external HTTP client. In production the cron trigger would be removed or disabled; the HTTP trigger is the real integration point.

### External Data in Simulation

The workflow fetches live data from two external sources:
1. **CoinGecko API** (market data via HTTP capability)
2. **Chainlink price feed** (on-chain read via EVM capability)

Both are live calls, not mocks. This is intentional — judges want to see real CRE capabilities exercised, not stubbed. However, this means simulation requires network access and a responsive testnet.

**Reproducibility safeguards:**
- If CoinGecko returns an error or rate-limits, the workflow uses the Chainlink oracle price as the sole price source, skips Gate 5 (deviation check), and Gate 6 uses a conservative fallback volatility of 10% (meaning `volatility_factor ≈ 0.90`, reducing positions by ~10%). The remaining gates evaluate normally.
- If the Chainlink feed read fails, Gate 4 (oracle health) denies the trade with `chainlink_feed_unavailable`. This is a valid denied-scenario outcome, not a simulation failure — the workflow still completes and writes a denied receipt on-chain.
- The cron trigger's synthetic request uses fresh `runtime.Now()` timestamps, so Gate 3 (staleness) always passes in simulation.

In other words: the workflow produces a valid result (approved or denied) regardless of external data availability. It never crashes — it either approves with constraints or denies with a reason. Both outcomes produce an on-chain write.

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
    ChainlinkPrice uint64   `json:"chainlink_price"`       // 8 decimal precision (native Chainlink)
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
    MaxPositionBps   int     `json:"default_max_position_bps"`    // default 10000 (100%, configurable ceiling)
    DecisionTTLSec   int     `json:"decision_ttl_seconds"`        // default 300
    PriceDevMaxBps   int     `json:"price_deviation_max_bps"`     // default 500 (5%)
    VolatilityScale  float64 `json:"volatility_scale_factor"`     // default 1.0
    OracleStalenessSec int   `json:"oracle_staleness_seconds"`    // default 3600
    FeedDecimals     int     `json:"feed_decimals"`               // default 8 (Chainlink USD pairs)
    EnableHeartbeat  bool    `json:"enable_heartbeat_gate"`       // default false (standalone mode)
    HeartbeatURL     string  `json:"heartbeat_mirror_node_url"`   // Hedera Mirror Node
    HeartbeatTTLSec  int     `json:"heartbeat_ttl_seconds"`       // default 600
}
```

---

## 6. Risk Evaluation Logic (8 Gates)

The core differentiator. Each gate independently evaluates one dimension. A trade must pass all active gates to be approved. Denied decisions still get written on-chain with the denial reason.

### Gate Summary

| Gate | Name | Type | Default | Capability Used |
|------|------|------|---------|-----------------|
| 1 | Signal Confidence | Hard deny | Active | — (input validation) |
| 2 | Risk Score Ceiling | Hard deny | Active | — (input validation) |
| 3 | Signal Staleness | Hard deny | Active | `runtime.Now()` |
| 4 | Chainlink Oracle Health | Hard deny | Active | EVM read |
| 5 | Price Deviation vs Oracle | Hard deny | Active | EVM read + HTTP fetch |
| 6 | Volatility-Adjusted Sizing | Constraint | Active | HTTP fetch |
| 7 | Hold Signal Filter | Hard deny | Active | — (input validation) |
| 8 | Agent Heartbeat (Circuit Breaker) | Hard deny | **Off by default** | HTTP fetch |

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

Rejects stale signals. Uses `runtime.Now()` for DON-deterministic time.

### Gate 4: Chainlink Oracle Health

```
(roundId, answer, startedAt, updatedAt, answeredInRound) =
    EVM_READ(price_feed_address, "latestRoundData()")

IF answer <= 0:
  DENY "chainlink_feed_invalid"
IF updatedAt == 0:
  DENY "chainlink_feed_not_updated"
IF answeredInRound < roundId:
  DENY "chainlink_round_incomplete"
IF (now - updatedAt) > config.oracle_staleness_seconds (3600):
  DENY "chainlink_feed_stale"
```

Validates oracle health before trusting its price. Uses the full `latestRoundData()` return tuple. This is a gate the Codex design missed entirely — professional Chainlink usage requires these checks.

### Gate 5: Price Deviation vs Oracle

```
chainlink_price = answer  // already in feed_decimals (8 for USD pairs)
market_price = to_feed_decimals(HTTP_FETCH(market_data_url), config.feed_decimals)
deviation_bps = abs(market_price - chainlink_price) / chainlink_price * 10000

IF deviation_bps > config.price_deviation_max_bps (500):
  DENY "price_deviation_exceeds_threshold"
```

If the agent's market data diverges >5% from the Chainlink oracle, something is wrong (stale data, manipulation, API error). The oracle is ground truth. All price math uses 8-decimal precision (matching Chainlink USD feed native format). Market prices from HTTP fetch are converted to 8 decimals before comparison.

### Price Precision Convention

All internal price math uses **8-decimal precision** — the native format of Chainlink USD price feeds. This applies to:
- `RiskDecision.ChainlinkPrice` (Go type: `uint64`, 8 decimals)
- Contract `recordDecision(chainlinkPrice)` parameter (8 decimals)
- Gate 5 deviation comparison (both prices normalized to 8 decimals)
- `DecisionRecorded` event `chainlinkPrice` field (8 decimals)

Market prices from external APIs (CoinGecko) are converted to 8-decimal integer format before any comparison with Chainlink data. `uint64` at 8 decimals supports prices up to ~184 billion, which is sufficient for any asset.

### Gate 6: Volatility-Adjusted Position Sizing

```
abs_volatility = abs(volatility_24h)
volatility_factor = clamp(1.0 - (abs_volatility / 100.0 * config.volatility_scale), 0.1, 1.0)
risk_factor = clamp(1.0 - (risk_score / 100.0), 0.1, 1.0)
dynamic_position = requested_position * volatility_factor * risk_factor

// Enforce config-level BPS cap
bps_cap = requested_position * config.default_max_position_bps / 10000
max_position = min(dynamic_position, bps_cap, requested_position)
```

Doesn't deny, but caps the position size. High volatility + high risk = smaller allowed position. Uses `abs()` on volatility (which can be negative for price drops) and clamps both factors to `[0.1, 1.0]` to prevent positions exceeding the request or going negative. Floor at 10% — if the risk is that extreme, Gates 2 or 4 should deny outright. The final position is also capped by `MaxPositionBps` from config (default 100% — acts as a configurable ceiling that operators can tighten for production use).

### Gate 7: Hold Signal Filter

```
IF signal == "hold":
  DENY "hold_signal_no_trade"
```

A hold signal means "do nothing." CRE enforces this as a hard deny.

### Gate 8: Agent Heartbeat Circuit Breaker (Configurable)

```
IF NOT config.enable_heartbeat_gate:
  SKIP (gate disabled)

agent_heartbeat = HTTP_FETCH(config.heartbeat_mirror_node_url, agent_id)
IF (now - agent_heartbeat.timestamp) > config.heartbeat_ttl_seconds (600):
  DENY "agent_heartbeat_stale"
```

If the requesting agent hasn't sent a heartbeat recently (read from Hedera Mirror Node via HTTP), deny all trades. **Disabled by default** so standalone simulation works from a clean clone without external dependencies. Enabled when connected to the live agent economy.

### Decision Output

Every evaluation (approved or denied) produces a `RiskDecision` that gets:

1. Hashed into `decision_hash` (keccak256 of all fields)
2. Assigned a unique `run_id`: `keccak256(task_id || agent_id || runtime.Now().UnixNano() || runtime.Rand())` — uses CRE's deterministic randomness to avoid collisions under retries
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

### Strategy: Standalone Core, Proven Integration

The CRE workflow ships as a standalone project. Core simulation and on-chain write work without touching existing repos. However, to back up the "real agent economy" claim, P0 includes a concrete integration proof — not just narrative.

### P0: Standalone CRE Workflow + Integration Path Proof (Required)

The workflow runs independently and is simulatable from a clean clone. No changes to existing agent repos are required for the CRE workflow to function.

**But:** the submission must include an integration path proof showing the CRE workflow can be called with a realistic payload from the agent economy context. The `demo/e2e.sh` script constructs a `RiskRequest` matching the exact format `agent-coordinator` would produce (same agent IDs, task ID format, signal structure) and sends it to the running workflow. The resulting on-chain receipt is captured. This is a P0 evidence artifact — it demonstrates the integration path, not a live integrated run.

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

### Scenario 1: Approved — Low Risk

```json
{
  "signal": "buy", "signal_confidence": 0.85, "risk_score": 10,
  "requested_position_usd": 1000, "market_pair": "ETH/USD"
}
```

Assuming ~3% volatility (`volatility_factor ≈ 0.97`, `risk_factor = 0.90`):
Expected: Approved, max position ~$873, slippage 30 bps

### Scenario 2: Denied — Low Confidence

```json
{
  "signal": "buy", "signal_confidence": 0.45, "risk_score": 35,
  "requested_position_usd": 1000, "market_pair": "ETH/USD"
}
```

Expected: Denied, reason `signal_confidence_below_threshold` (0.45 < 0.6 threshold)

### Scenario 3: Denied — High Risk

```json
{
  "signal": "sell", "signal_confidence": 0.9, "risk_score": 82,
  "requested_position_usd": 2000, "market_pair": "ETH/USD"
}
```

Expected: Denied, reason `risk_score_exceeds_maximum` (82 > 75 ceiling)

### Scenario 4: Denied — Stale Signal

```json
{
  "signal": "buy", "signal_confidence": 0.8, "risk_score": 40,
  "requested_position_usd": 1000, "timestamp": "<now - 600>"
}
```

Expected: Denied, reason `signal_expired` (600s > 300s TTL)

### Scenario 5: Approved — Heavy Constraint

```json
{
  "signal": "buy", "signal_confidence": 0.75, "risk_score": 55,
  "requested_position_usd": 5000, "market_pair": "ETH/USD"
}
```

Assuming ~8% volatility (`volatility_factor ≈ 0.92`, `risk_factor = 0.45`):
Expected: Approved, max position ~$2070 (down from $5000 requested)

---

## 10. Deliverables (Priority Ordered)

### Phase 0 — CRE Validation Gate (Day 1, blocks everything)

This is the single most important step. If basic CRE simulation doesn't work, the entire plan must be reassessed before writing any Risk Router code.

1. **Install CRE CLI** — `curl -sSL https://cre.chain.link/install | sh` (or equivalent)
2. **CRE auth** — `cre login`, `cre account link-key` if required, `cre whoami`
3. **Hello-world workflow** — Minimal cron trigger that logs a string, no business logic
4. **Dry-run simulation** — `cre workflow simulate .` on hello-world — does it pass?
5. **Add trivial EVM write** — Deploy a 1-function contract on testnet, add EVM write to hello-world
6. **Broadcast simulation** — `cre workflow simulate . --broadcast` — does it produce a tx hash?
7. **Document findings** — Which testnets work, what auth is needed, exact SDK import paths, any gotchas

If steps 4-6 fail: diagnose, adapt, or pivot approach before building anything else.

### P0 — Ship or DQ (Days 2-5)

1. **CRE project scaffold** — `go.mod`, `workflow.go`, `config.json`, `secrets.yaml`, `.env.example`
2. **RiskDecisionReceipt.sol** — Contract, Foundry tests, deploy to CRE-supported testnet, capture address
3. **EVM bindings** — `cre generate-bindings evm` from contract ABI
4. **Risk evaluation logic** — 8 gates in `risk.go`, types in `types.go`, helpers in `helpers.go`
5. **CRE workflow handlers** — HTTP trigger + cron trigger wired to evaluation + EVM write
6. **First successful simulation** — `cre workflow simulate .` dry run passes end-to-end
7. **First on-chain write** — `cre workflow simulate . --broadcast` produces tx hash
8. **README** — Clone-to-simulate in under 5 commands
9. **Integration demo** — `demo/e2e.sh` that curls the HTTP trigger with a realistic payload, shows on-chain receipt

### P0 — Ship or Weak Submission (Days 5-7)

10. **Simulation scenarios** — 5 pre-built JSON scenarios with expected outcomes
11. **Submission post draft** — Exact Moltbook format with all required sections
12. **Evidence capture** — Logs, tx hash, block explorer link
13. **Registration form** — Complete human operator form
14. **Publish Moltbook post** — Before 11:59 PM ET March 8

### P1 — Competitive Edge (If P0 Stable)

15. **Coordinator CRE client** — HTTP bridge in `agent-coordinator`
16. **Inference signal fields** — Structured signal in `agent-inference` task results
17. **DeFi execution guard** — CRE constraint enforcement in `agent-defi`
18. **HCS message types** — `cre_simulation`, `cre_decision`, `cre_execution_receipt`

### P2 — Polish

19. **Dashboard CRE panel**
20. **Contract verification** on block explorer
21. **Demo video/GIF**

---

## 11. Unknowns to Resolve

### Resolved by Phase 0 Validation (Day 1)

These are no longer "unknowns to resolve early" — they are explicit Phase 0 blockers with a test procedure. See Section 10, Phase 0.

- Which testnets CRE supports
- Whether CRE requires authentication/linked key
- How HTTP trigger works in simulation
- Whether `--broadcast` requires a funded wallet
- Exact CRE Go SDK import paths

### Remaining Unknowns (resolve during P0 build)

| Unknown | How to Resolve | Impact if Wrong |
|---|---|---|
| Chainlink price feed addresses on chosen testnet | Check Chainlink data feeds page for testnet | Blocks Gates 4-5, fallback to hardcoded mock |
| `IReceiver` interface for proper CRE writes | Read CRE SDK source / docs | Use direct `recordDecision()` call as fallback |
| Standalone repo vs monorepo subdir? | Decision from Lance | Affects project setup on day 1 |
| CoinGecko API rate limits on free tier | Test during development | May need alternative market data source |

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

## 13. Security & Production Notes

Acknowledged scope boundaries for the hackathon submission:

- **HTTP trigger auth:** In production, CRE HTTP triggers are secured by DON-level cryptographic verification. In simulation mode the trigger is not publicly exposed. Production hardening (rate limiting, caller verification, gas budgets) is out of scope for the testnet demo.
- **On-chain write cost:** Every evaluation (approved or denied) writes to the receipt contract. On testnet this is free. In production, a cost/benefit filter would gate whether denied decisions are worth recording on-chain.
- **Oracle trust:** We trust Chainlink price feeds as ground truth after validating staleness/health (Gate 4). In production, multi-feed aggregation would add robustness.

These are documented so judges see we're aware of production concerns without over-engineering a hackathon entry.

---

## 14. Reference Material

| Resource | URL |
|---|---|
| Hackathon rules | `docs/2026_requirements/moltbook/chainlink/clink-converge-hackathon.md` |
| Hackathon skills repo | `github.com/smartcontractkit/chainlink-agents-hackathon-skills` |
| CRE skills repo | `github.com/smartcontractkit/chainlink-agent-skills/cre-skills` |
| Codex design (reference) | `workflow/design/chainlink/codex/` |
| Claude design (detailed) | `workflow/design/chainlink/claude/` |
| Idea exploration | `workflow/explore/chainlink/idea-exploration.md` |
| Codex review | `workflow/design/chainlink/claude/07-codex-design-review.md` |
| Spec review + response | `workflow/design/cre-risk-router/spec-review-response.md` |
| Registration form | `https://forms.gle/xk1PcnRmky2k7yDF7` |
