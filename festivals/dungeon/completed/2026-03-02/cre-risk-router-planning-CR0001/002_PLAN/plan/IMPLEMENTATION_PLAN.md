# CRE Risk Router — Implementation Plan

## Overview

Build a standalone CRE workflow in Go that evaluates trade risk for autonomous DeFi agents, writes decision receipts on-chain, and submit to the Chainlink Convergence Hackathon by March 8, 2026.

The implementation festival has 6 phases, executed sequentially. Each phase has 2-3 sequences. Tasks within a sequence execute in the order indicated by their number prefix; same-numbered tasks can run in parallel.

**Source of truth:** `inputs/spec.md` (full product spec)

---

## Phase 001: CRE_VALIDATION

**Type:** implementation
**Goal:** Validate CRE CLI works end-to-end. Hard gate — blocks all subsequent phases.
**Traces to:** Requirements 0.1-0.7

### Sequence 01_cli_setup

**Goal:** Install CRE CLI, authenticate, and run a basic simulation.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | install_cre_cli | 0.1 | Install CRE CLI via official installer. Verify `cre --version`. |
| 02 | authenticate | 0.2 | Run `cre login`, `cre account link-key` if needed, `cre whoami`. Document auth requirements. |
| 03 | hello_world_workflow | 0.3 | Create minimal Go CRE workflow: cron trigger, logs a string. `go.mod`, `workflow.go`, `config.json`. |
| 04 | dry_run_simulation | 0.4 | Run `cre workflow simulate .` on hello-world. Must pass without errors. |

### Sequence 02_evm_validation

**Goal:** Validate EVM write capability and broadcast mode.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | deploy_trivial_contract | 0.5 | Deploy a 1-function Solidity contract to a CRE-supported testnet via Foundry. |
| 02 | add_evm_write | 0.5 | Add EVM write to hello-world workflow calling the trivial contract. |
| 03 | broadcast_simulation | 0.6 | Run `cre workflow simulate . --broadcast`. Must produce a tx hash. |
| 04 | document_findings | 0.7 | Document: supported testnets, auth flow, SDK import paths, EVM write patterns, any gotchas. |

**Gate decision:** If tasks 04 (dry run) or 03 (broadcast) fail after debugging, stop and reassess approach before continuing.

---

## Phase 002: FOUNDATION

**Type:** implementation
**Goal:** Scaffold the CRE Risk Router project and deploy the receipt contract.
**Traces to:** Requirements P0.1-P0.4

### Sequence 01_project_scaffold

**Goal:** Create the project structure with all config files.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | init_project | P0.1 | `camp project new cre-risk-router` to create submodule. Create private GitHub repo (`gh repo create lancekrogers/cre-risk-router --private`), set as remote. Scaffold `go.mod`, directory structure per spec Section 3. `config.json` with all Config fields and defaults. `secrets.yaml` declarations. `.env.example` template. Make repo public before submission. |
| 02 | justfile | P0.1 | Build/simulate/test/deploy recipes. `just simulate`, `just broadcast`, `just test`, `just deploy`. |

### Sequence 02_contract

**Goal:** Write, test, and deploy RiskDecisionReceipt.sol.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | receipt_contract | P0.2 | Write `RiskDecisionReceipt.sol` per spec Section 7. Interface: `recordDecision()`, `isDecisionValid()`, `getRunCount()`. Events, storage, duplicate prevention. |
| 02 | foundry_tests | P0.2 | 4 tests: approved decision, denied decision, duplicate rejection, TTL expiry. |
| 03 | deploy_testnet | P0.3 | Deploy to CRE-supported testnet (determined in Phase 001). Capture contract address. Update `config.json`. |
| 04 | evm_bindings | P0.4 | Run `cre generate-bindings evm` from contract ABI. Verify generated Go code compiles. |

---

## Phase 003: RISK_LOGIC

**Type:** implementation
**Goal:** Implement all 8 risk gates, types, and helpers.
**Traces to:** Requirements P0.5-P0.12

### Sequence 01_types_and_helpers

**Goal:** Define all data types and utility functions.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | types | P0.5-P0.10 | `types.go`: `RiskRequest`, `RiskDecision`, `MarketData`, `Config` per spec Section 5. 8-decimal precision on `ChainlinkPrice`. |
| 01 | helpers | P0.11 | `helpers.go`: `generateRunID()` (keccak256 with runtime.Rand), `hashDecision()`, `calculateSlippage()`, `toFeedDecimals()`, `clamp()`. |

### Sequence 02_risk_gates

**Goal:** Implement each gate in `risk.go`.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | gates_1_3 | P0.5 | Gate 1 (confidence threshold), Gate 2 (risk score ceiling), Gate 3 (signal staleness with `runtime.Now()`). |
| 01 | gate_4 | P0.6 | Gate 4 (oracle health): full `latestRoundData()` validation — answer > 0, updatedAt > 0, answeredInRound >= roundId, staleness check. |
| 01 | gate_5 | P0.7 | Gate 5 (price deviation): 8-decimal normalization, BPS deviation calculation, threshold check. |
| 02 | gate_6 | P0.8 | Gate 6 (volatility sizing): abs(), clamp(0.1, 1.0) on both factors, BPS cap enforcement, min(dynamic, bps_cap, requested). |
| 02 | gate_7 | P0.9 | Gate 7 (hold signal filter): simple deny on "hold". |
| 02 | gate_8 | P0.10 | Gate 8 (heartbeat): configurable via `enable_heartbeat_gate`, Hedera Mirror Node HTTP fetch, TTL check. Off by default. |

### Sequence 03_evaluation_pipeline

**Goal:** Wire gates into the main evaluation function.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | evaluate_risk | P0.11 | `evaluateRisk()` in `risk.go`: runs all active gates sequentially, produces `RiskDecision`, generates `run_id` and `decision_hash`. |
| 02 | fallback_logic | P0.12 | CoinGecko failure handling: skip Gate 5, Gate 6 uses 10% fallback volatility. Chainlink failure: Gate 4 denies with `chainlink_feed_unavailable`. |

---

## Phase 004: WORKFLOW_INTEGRATION

**Type:** implementation
**Goal:** Wire risk logic into CRE handlers and achieve first successful simulation.
**Traces to:** Requirements P0.13-P0.16

### Sequence 01_handlers

**Goal:** Implement CRE workflow trigger handlers.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | http_trigger | P0.13 | `onRiskEvaluation()`: parse `RiskRequest` from HTTP body, fetch market data via HTTP capability, read Chainlink feed via EVM capability, call `evaluateRisk()`, write receipt on-chain, return `RiskDecision`. |
| 02 | cron_trigger | P0.14 | `onScheduledSweep()`: generate synthetic `RiskRequest` with hardcoded realistic parameters, fresh timestamp via `runtime.Now()`, run same pipeline. |

### Sequence 02_simulation

**Goal:** First successful end-to-end simulation with on-chain write.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | dry_run | P0.15 | `cre workflow simulate .` — full pipeline dry run. Debug any issues. |
| 02 | broadcast | P0.16 | `cre workflow simulate . --broadcast` — on-chain tx hash. Verify on block explorer. |
| 03 | debug_iterate | P0.15-P0.16 | Fix any simulation failures. Iterate until both dry-run and broadcast are stable. |

---

## Phase 005: SUBMISSION

**Type:** implementation
**Goal:** Produce all submission artifacts and publish before deadline.
**Traces to:** Requirements P0.17-P0.23

### Sequence 01_documentation

**Goal:** Create README, scenarios, and integration demo.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | readme | P0.17 | README.md: project description, setup instructions (under 5 commands), simulation commands, architecture overview. |
| 01 | scenarios | P0.19 | 5 JSON scenarios in `scenarios/`: approved_trade, denied_low_confidence, denied_high_risk, denied_stale_signal, denied_price_deviation. Each with expected outcome documented. |
| 01 | e2e_demo | P0.18 | `demo/e2e.sh`: curl HTTP trigger with coordinator-format payload (matching agent IDs, task ID format). Capture on-chain receipt. |

### Sequence 02_evidence

**Goal:** Capture simulation evidence for submission.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | capture_logs | P0.20 | Run simulation scenarios, capture logs with tx hash clearly visible. |
| 02 | block_explorer | P0.20 | Verify tx on block explorer, capture screenshot/link. |

### Sequence 03_publish

**Goal:** Draft, review, and publish the Moltbook submission.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | draft_post | P0.21 | Moltbook post with all 10 required sections per spec Section 12. CRE Experience Feedback must be genuine, non-empty. |
| 02 | registration_form | P0.22 | Complete human operator Google Form at `https://forms.gle/xk1PcnRmky2k7yDF7`. |
| 03 | final_review | P0.21 | Triple-check: format matches template, no placeholder text, all sections filled, tx hash present, repo is public. |
| 04 | publish | P0.23 | Publish Moltbook post before March 8, 2026 11:59 PM ET. |

---

## Phase 006: INTEGRATION (P1 — only if P0 stable)

**Type:** implementation
**Goal:** Bridge CRE Risk Router to existing agent economy for competitive edge.
**Traces to:** Requirements P1.1-P1.4

### Sequence 01_coordinator_bridge

**Goal:** Add CRE client to agent-coordinator.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | cre_client | P1.1 | `client.go` + `models.go` in `agent-coordinator/internal/chainlink/cre/`. HTTP client to CRE Risk Router. |
| 02 | wire_assign | P1.1 | In `assign.go`: if CRE client configured, check risk before task assignment. Denied → `quality_gate` event. |

### Sequence 02_agent_signals

**Goal:** Add structured signal fields to inference and DeFi agents.

| # | Task | Requirements | Description |
|---|------|-------------|-------------|
| 01 | inference_fields | P1.2 | Add `signal`, `signal_confidence`, `risk_score`, `explanation_hash` to inference task results. |
| 01 | defi_guard | P1.3 | CRE constraint enforcement in `agent-defi` trading strategy. Backwards compatible. |
| 02 | hcs_messages | P1.4 | Add `cre_simulation`, `cre_decision`, `cre_execution_receipt` HCS message types. |

---

## Dependency Chain

```
001_CRE_VALIDATION ──► 002_FOUNDATION ──► 003_RISK_LOGIC ──► 004_WORKFLOW_INTEGRATION ──► 005_SUBMISSION
                                                                                              │
                                                                                              ▼
                                                                                    006_INTEGRATION (P1)
```

All phases are strictly sequential. No phase starts until the previous one completes and passes its quality gates.
