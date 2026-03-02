# Requirements

## Phase 0 — CRE Validation Gate (Blocks Everything)

Must complete before any Risk Router code is written. If this fails, the entire approach is reassessed.

| # | Requirement | Acceptance Criteria |
|---|---|---|
| 0.1 | Install CRE CLI | `cre --version` returns a version string |
| 0.2 | CRE authentication | `cre whoami` succeeds (or determine auth isn't required) |
| 0.3 | Hello-world workflow | Minimal cron-trigger workflow that logs a string |
| 0.4 | Dry-run simulation | `cre workflow simulate .` passes on hello-world |
| 0.5 | Trivial EVM write | Deploy 1-function contract on testnet, add EVM write to hello-world |
| 0.6 | Broadcast simulation | `cre workflow simulate . --broadcast` produces tx hash |
| 0.7 | Document findings | Supported testnets, auth requirements, SDK import paths, gotchas |

**Gate rule:** If 0.4-0.6 fail after diagnosis, pivot approach before building anything else.

## P0 — Ship or DQ (Required for Valid Submission)

### P0-A: Project Foundation

| # | Requirement | Acceptance Criteria |
|---|---|---|
| P0.1 | CRE project scaffold | `go.mod`, `workflow.go`, `config.json`, `secrets.yaml`, `.env.example` |
| P0.2 | RiskDecisionReceipt.sol | Contract compiles, 4 Foundry tests pass |
| P0.3 | Contract deployment | Deployed to CRE-supported testnet, address captured |
| P0.4 | EVM bindings | `cre generate-bindings evm` produces Go bindings from ABI |

### P0-B: Core Logic

| # | Requirement | Acceptance Criteria |
|---|---|---|
| P0.5 | Risk evaluation — Gates 1-3 | Input validation gates (confidence, risk score, staleness) |
| P0.6 | Risk evaluation — Gate 4 | Chainlink oracle health with full `latestRoundData()` validation |
| P0.7 | Risk evaluation — Gate 5 | Price deviation check with 8-decimal precision |
| P0.8 | Risk evaluation — Gate 6 | Volatility-adjusted position sizing with BPS cap, clamping, abs() |
| P0.9 | Risk evaluation — Gate 7 | Hold signal filter |
| P0.10 | Risk evaluation — Gate 8 | Configurable heartbeat gate (off by default) |
| P0.11 | Decision output | `run_id` generation, `decision_hash`, on-chain write |
| P0.12 | CoinGecko fallback | When HTTP fails: Gate 5 skipped, Gate 6 uses 10% fallback volatility |

### P0-C: Workflow Integration

| # | Requirement | Acceptance Criteria |
|---|---|---|
| P0.13 | HTTP trigger handler | Parses `RiskRequest`, runs evaluation, returns `RiskDecision` |
| P0.14 | Cron trigger handler | Generates synthetic request, runs same pipeline |
| P0.15 | Successful dry-run | `cre workflow simulate .` passes end-to-end |
| P0.16 | Successful broadcast | `cre workflow simulate . --broadcast` produces tx hash |

### P0-D: Submission Artifacts

| # | Requirement | Acceptance Criteria |
|---|---|---|
| P0.17 | README | Clone-to-simulate in under 5 commands |
| P0.18 | Integration demo | `demo/e2e.sh` curls HTTP trigger with coordinator-format payload |
| P0.19 | Simulation scenarios | 5 JSON scenarios with expected outcomes documented |
| P0.20 | Evidence capture | Logs with tx hash, block explorer link |
| P0.21 | Submission post | Moltbook format with all 10 required sections |
| P0.22 | Registration form | Human operator form completed |
| P0.23 | Publish | Post published before March 8 11:59 PM ET |

## P1 — Competitive Edge (If P0 Stable by Day 5)

| # | Requirement | Acceptance Criteria |
|---|---|---|
| P1.1 | Coordinator CRE client | HTTP client in `agent-coordinator/internal/chainlink/cre/` |
| P1.2 | Inference signal fields | `signal`, `signal_confidence`, `risk_score` in task results |
| P1.3 | DeFi execution guard | CRE constraint enforcement in `agent-defi` strategy |
| P1.4 | HCS message types | `cre_simulation`, `cre_decision`, `cre_execution_receipt` |

## P2 — Polish (Stretch)

| # | Requirement | Acceptance Criteria |
|---|---|---|
| P2.1 | Dashboard CRE panel | Decision timeline in Next.js dashboard |
| P2.2 | Contract verification | Verified on block explorer |
| P2.3 | Demo video/GIF | Visual evidence of simulation run |
