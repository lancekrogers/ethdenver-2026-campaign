# 01 - CRE AI Core Feature Design

## Working Title

`CRE Risk Router: AI-Driven, Simulated, and On-Chain-Proven Agent Execution`

## Problem To Solve

The current agent economy can execute tasks end-to-end, but decisioning is mostly local to each agent. For Chainlink Convergence, we need a **CRE-native control layer** that demonstrates:

1. AI-powered workflow decisioning (`#cre-ai`)
2. deterministic simulation (`cre simulate`)
3. verifiable execution with at least one on-chain write

## Reuse Map (Current Assets -> Chainlink Upgrade)

| Existing asset | Current behavior | Chainlink upgrade |
|---|---|---|
| `projects/agent-coordinator` | Assigns tasks over HCS and settles payments | Add CRE workflow runner + simulation gate before assignment |
| `projects/agent-inference` | Produces inference output and reports result | Emit structured signal payload used by CRE risk logic |
| `projects/agent-defi` | Executes strategy loop + reports P&L | Require CRE decision receipt before trade execution |
| `projects/contracts` | Foundry-based contract workflow exists | Add small workflow receipt contract for on-chain run proofs |
| `projects/dashboard` | Shows HCS, activity, P&L, inference | Add CRE run timeline + simulation outcome panel |

## P0 Feature Set (Ship First)

### Feature A: CRE Workflow Gate in Coordinator

**Intent:** No trade task is dispatched until CRE simulation/decision succeeds.

**Design:**

- Add `internal/chainlink/cre/` package in `agent-coordinator` with:
  - `Simulate(ctx, workflowInput)` -> simulation result
  - `Execute(ctx, workflowInput)` -> run ID + decision payload
- Coordinator sequence:
  1. receive/prepare task intent
  2. call `cre simulate ...` (one-shot)
  3. if simulation pass: execute workflow + publish assignment
  4. if fail: publish `quality_gate` reject event with reason

**Integration points:**

- `projects/agent-coordinator/cmd/coordinator/main.go`
- `projects/agent-coordinator/internal/coordinator/assign.go`
- `projects/agent-coordinator/internal/coordinator/result_handler.go`

### Feature B: Structured AI Signal Contract

**Intent:** Inference output becomes machine-usable CRE input, not freeform text only.

**Design:**

- Extend inference `task_result` payload with:
  - `signal` (`buy|sell|hold`)
  - `signal_confidence` (`0.0 - 1.0`)
  - `risk_score` (`0 - 100`)
  - `explanation_hash` (hash of model rationale stored off-chain/0G)

**Integration points:**

- `projects/agent-inference/internal/hcs/messages.go`
- `projects/agent-inference/internal/agent/agent.go`

### Feature C: Execution Guard in DeFi Agent

**Intent:** Prevent blind execution; require CRE decision and constraints.

**Design:**

- Add CRE decision envelope expected by DeFi agent:
  - `approved: bool`
  - `max_position_usd`
  - `max_slippage_bps`
  - `ttl_seconds`
  - `run_id`
- DeFi agent only executes if:
  - decision is approved,
  - decision TTL is valid,
  - strategy parameters are within CRE limits.

**Integration points:**

- `projects/agent-defi/internal/hcs/messages.go`
- `projects/agent-defi/internal/agent/agent.go`
- `projects/agent-defi/internal/base/trading/strategy.go`

### Feature D: On-Chain Workflow Receipt

**Intent:** Satisfy hackathon evidence with a clear CRE run write on testnet.

**Design:**

- Add new contract in `projects/contracts/src/ChainlinkWorkflowReceipt.sol`:
  - `recordRun(bytes32 runId, bytes32 simulationId, bytes32 decisionHash, string metadataURI)`
  - emits `RunRecorded(runId, simulationId, decisionHash, sender)`
- Coordinator writes one receipt per accepted CRE run.

**Integration points:**

- `projects/contracts/src/`
- `projects/contracts/script/` deployment + interaction script
- `projects/agent-coordinator/internal/chainlink/` writer adapter

## Event/Message Extensions

Add new message types across coordinator/agents/dashboard parsers:

- `cre_simulation`
- `cre_decision`
- `cre_execution_receipt`

Primary parsing points:

- `projects/agent-coordinator/internal/hedera/hcs/message.go`
- `projects/agent-defi/internal/hcs/messages.go`
- `projects/agent-inference/internal/hcs/messages.go`
- `projects/dashboard/src/lib/data/types.ts`
- `projects/dashboard/src/hooks/useLiveData.ts`

## End-to-End Flow (P0)

1. Coordinator receives/creates a trade-worthy task.
2. Inference agent emits structured signal.
3. Coordinator runs `cre simulate ...` using signal + market state.
4. CRE returns decision constraints.
5. Coordinator assigns DeFi task with CRE decision payload.
6. DeFi executes under CRE constraints.
7. Coordinator writes `recordRun(...)` on-chain.
8. Dashboard shows simulation -> decision -> execution -> receipt timeline.

## P1 Stretch (Only If P0 Stable)

### P1-A: Tokenized Strategy Receipts (`#defi-tokenization`)

- Mint transferable strategy receipts linked to CRE run IDs.
- Keep as optional; do not delay core #cre-ai submission.

### P1-B: Scenario Bank for Judge Interactivity

- Pre-build 3-5 named simulation scenarios:
  - high volatility
  - stale oracle data
  - low liquidity
  - contradictory AI signal

## Non-Goals

- Replacing Hedera HCS backbone
- Migrating all agent logic to new chains
- Building a full production risk engine

## Acceptance Criteria

1. At least one successful `cre simulate` run is captured in logs/artifacts.
2. DeFi trade execution path is visibly gated by CRE decision payload.
3. One contract write records the CRE run/decision hash on testnet.
4. Dashboard exposes CRE run status in a dedicated view.
5. Evidence is sufficient for one Moltbook submission post with `#cre-ai`.

