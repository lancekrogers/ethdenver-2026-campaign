# 04 - Integration Bridge: CRE ↔ Agent Economy

## Integration Philosophy

The CRE Risk Router is a **standalone project** that connects to the existing agent economy without modifying core agent code. This approach:

1. Keeps the Chainlink submission self-contained and clean
2. Preserves existing agent stability (ETHDenver work is done)
3. Allows the CRE project to be evaluated independently
4. Still demonstrates real multi-agent integration

## Integration Points

### 1. agent-coordinator → CRE Risk Router (HTTP Trigger)

**Minimal change to coordinator.** Add an optional HTTP call before task assignment.

```
agent-coordinator                       cre-risk-router
       │                                       │
       │  POST /evaluate-risk                   │
       │  {agent_id, signal, risk_score, ...}   │
       ├──────────────────────────────────────►  │
       │                                        │
       │  200 OK                                │
       │  {approved, max_position, run_id, ...} │
       │  ◄─────────────────────────────────────┤
       │                                        │
       │  if approved: assign task via HCS      │
       │  if denied: publish quality_gate event  │
       │                                        │
```

**Coordinator changes (optional, P1):**

File: `projects/agent-coordinator/internal/chainlink/cre/client.go`

```go
type CREClient struct {
    endpoint string
    client   *http.Client
}

func (c *CREClient) EvaluateRisk(ctx context.Context, req RiskRequest) (*RiskDecision, error) {
    // POST to CRE Risk Router HTTP trigger
    // Return decision for coordinator to act on
}
```

File: `projects/agent-coordinator/internal/coordinator/assign.go`

```go
// Before assigning a trade task, optionally check CRE risk router
if c.creClient != nil {
    decision, err := c.creClient.EvaluateRisk(ctx, riskReq)
    if err != nil || !decision.Approved {
        c.publishQualityGate(ctx, task, "cre_risk_denied", decision.Reason)
        return
    }
    // Attach CRE constraints to task assignment
    task.CREConstraints = decision
}
```

### 2. agent-inference → CRE Risk Router (Structured Signals)

**Minimal change to inference.** The inference agent already produces task results via HCS. We extend the result payload to include structured signal fields that the CRE workflow can consume.

File: `projects/agent-inference/internal/hcs/messages.go`

```go
// Extend existing TaskResultPayload with optional structured signal
type TaskResultPayload struct {
    // ... existing fields ...

    // Structured signal for CRE consumption (optional)
    Signal           string  `json:"signal,omitempty"`            // buy|sell|hold
    SignalConfidence float64 `json:"signal_confidence,omitempty"` // 0.0-1.0
    RiskScore        int     `json:"risk_score,omitempty"`        // 0-100
    ExplanationHash  string  `json:"explanation_hash,omitempty"`  // hash of rationale
}
```

### 3. agent-defi ← CRE Decision (Execution Guard)

**Minimal change to defi agent.** Before executing a trade, optionally check for a valid CRE decision on-chain or via the coordinator's HCS message.

File: `projects/agent-defi/internal/base/trading/strategy.go`

```go
// Optional CRE constraint enforcement
type CREConstraints struct {
    Approved       bool   `json:"approved"`
    MaxPositionUSD uint64 `json:"max_position_usd"`
    MaxSlippageBps uint64 `json:"max_slippage_bps"`
    TTLSeconds     uint64 `json:"ttl_seconds"`
    RunID          string `json:"run_id"`
}

func (s *MeanReversionStrategy) ApplyCREConstraints(constraints *CREConstraints) {
    if constraints == nil {
        return // No CRE gate, proceed with local strategy
    }
    if !constraints.Approved {
        // Log and skip trade
        return
    }
    // Cap position and slippage to CRE limits
    s.MaxPositionSize = min(s.MaxPositionSize, float64(constraints.MaxPositionUSD))
    s.MaxSlippage = min(s.MaxSlippage, float64(constraints.MaxSlippageBps)/10000)
}
```

### 4. Dashboard ← CRE Events (Display Panel)

**Add CRE panel to dashboard.** Read on-chain events from `RiskDecisionReceipt` contract.

File: `projects/dashboard/src/lib/data/types.ts`

```typescript
// CRE-specific event types
interface CREDecisionEvent {
  runId: string;
  decisionHash: string;
  approved: boolean;
  maxPositionUsd: number;
  maxSlippageBps: number;
  chainlinkPrice: number;
  recorder: string;
  timestamp: number;
  txHash: string;
}
```

File: `projects/dashboard/src/components/panels/CREPanel.tsx`

```
┌──────────────────────────────────────────┐
│  CRE Risk Router                         │
│                                          │
│  Run ID: 0xabc...def                     │
│  Status: ✅ Approved                     │
│  Max Position: $1,000                    │
│  Slippage Cap: 50 bps                    │
│  Chainlink Price: $2,500.00              │
│  TTL: 300s (4:32 remaining)              │
│  Tx: 0x123...789 ↗                       │
│                                          │
│  ┌─────────────────────────────────────┐ │
│  │ Timeline                            │ │
│  │ Signal → Simulation → Decision →    │ │
│  │ On-Chain Receipt → DeFi Execution   │ │
│  └─────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

## Priority Ordering

### P0: Ship for Hackathon (Required)

1. **`cre-risk-router` project** - Standalone CRE workflow that works with `cre workflow simulate --broadcast`
2. **`RiskDecisionReceipt.sol`** - Deployed on CRE-supported testnet with verified tx hash
3. **Submission post** - Moltbook post with proper format and evidence

### P1: Integration Demo (If Time Allows)

1. **Coordinator CRE client** - HTTP call to CRE Risk Router before task assignment
2. **Inference structured signals** - Add signal fields to task result payload
3. **DeFi execution guard** - Apply CRE constraints before trade

### P2: Polish (Stretch)

1. **Dashboard CRE panel** - Visual timeline of CRE decisions
2. **Scenario bank** - Pre-built simulation scenarios for demo

## Why This Ordering Matters

The hackathon judges evaluate:

1. Does `cre workflow simulate` work from a clean clone? (P0-1)
2. Is there an on-chain write with a tx hash? (P0-2)
3. Is the submission properly formatted? (P0-3)
4. Is the project interesting and well-integrated? (P1+)

Getting P0 done cleanly is worth more than partial P1 work. The existing agent economy provides compelling demo context even without direct integration code.

## HCS Message Extensions (P1)

If we add CRE integration to the coordinator, new HCS message types:

```go
const (
    MessageTypeCRESimulation       MessageType = "cre_simulation"
    MessageTypeCREDecision         MessageType = "cre_decision"
    MessageTypeCREExecutionReceipt MessageType = "cre_execution_receipt"
)
```

These would be published on the existing HCS status topic (`0.0.7999405`) so the dashboard can consume them.

## End-to-End Demo Flow (with P1 integration)

```
1. agent-inference produces structured signal:
   {signal: "buy", confidence: 0.85, risk_score: 35}

2. agent-coordinator receives signal, calls CRE Risk Router:
   POST /evaluate-risk → {approved: true, max_position: 1000, run_id: 0xabc}

3. CRE Risk Router:
   a. Fetches market data via HTTP
   b. Reads Chainlink ETH/USD price feed on testnet
   c. Evaluates risk gates
   d. Writes RiskDecisionReceipt on Arbitrum Sepolia → tx 0x123
   e. Returns decision to coordinator

4. agent-coordinator publishes cre_decision on HCS

5. agent-defi receives task assignment with CRE constraints:
   - Max position: $1,000
   - Max slippage: 50 bps
   - TTL: 300s
   - Executes trade within constraints

6. Dashboard shows full timeline:
   Signal → CRE Simulation → Decision (tx 0x123) → Trade Execution
```
