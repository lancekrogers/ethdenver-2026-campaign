# CRE Risk Router — Implementation Festival Structure

## Festival Goal

Build and submit the CRE Risk Router to the Chainlink Convergence Hackathon by March 8, 2026.

---

## Phase Breakdown

### 001_CRE_VALIDATION (implementation)

**Goal:** Validate that CRE CLI works end-to-end before building the Risk Router.

This is the hard gate. If basic CRE simulation doesn't work, everything after this is reassessed.

#### 01_cli_setup

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_install_cre_cli.md | Install CRE CLI, verify `cre --version` | No |
| 02_authenticate.md | `cre login`, `cre account link-key`, `cre whoami` | No |
| 03_hello_world_workflow.md | Minimal cron-trigger workflow that logs a string | No |
| 04_dry_run_simulation.md | `cre workflow simulate .` on hello-world | No |

#### 02_evm_validation

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_deploy_trivial_contract.md | Deploy 1-function contract on testnet via Foundry | No |
| 02_add_evm_write.md | Add EVM write to hello-world workflow | No |
| 03_broadcast_simulation.md | `cre workflow simulate . --broadcast` — tx hash? | No |
| 04_document_findings.md | Supported testnets, auth, SDK paths, gotchas | No |

---

### 002_FOUNDATION (implementation)

**Goal:** Scaffold the CRE Risk Router project and deploy the receipt contract.

#### 01_project_scaffold

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_init_project.md | `camp project new cre-risk-router`, create private GitHub repo, set remote. Scaffold `go.mod`, directory structure, `config.json`, `secrets.yaml`, `.env.example`. Make public before submission. | No |
| 02_justfile.md | Build/simulate/test commands | No |

#### 02_contract

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_receipt_contract.md | Write `RiskDecisionReceipt.sol` with full interface, events, storage | No |
| 02_foundry_tests.md | 4 core tests (approved, denied, duplicate, expiry) | No |
| 03_deploy_testnet.md | Deploy to CRE-supported testnet, capture address | No |
| 04_evm_bindings.md | `cre generate-bindings evm` from contract ABI | No |

---

### 003_RISK_LOGIC (implementation)

**Goal:** Implement the 8 risk gates and supporting types/helpers.

#### 01_types_and_helpers

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_types.md | `RiskRequest`, `RiskDecision`, `MarketData`, `Config` structs | Yes |
| 01_helpers.md | Hashing (`run_id`, `decision_hash`), position sizing, slippage calc, decimal conversion | Yes |

#### 02_risk_gates

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_gates_1_3.md | Signal confidence, risk score ceiling, signal staleness | Yes |
| 01_gate_4.md | Chainlink oracle health (full `latestRoundData()` validation) | Yes |
| 01_gate_5.md | Price deviation vs oracle (8-decimal precision) | Yes |
| 02_gate_6.md | Volatility-adjusted position sizing (abs, clamp, BPS cap) | No (depends on helpers) |
| 02_gate_7.md | Hold signal filter | No |
| 02_gate_8.md | Agent heartbeat circuit breaker (configurable, off by default) | No |

#### 03_evaluation_pipeline

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_evaluate_risk.md | Main `evaluateRisk()` function running all gates, producing `RiskDecision` | No |
| 02_fallback_logic.md | CoinGecko failure → skip Gate 5, Gate 6 fallback volatility (10%) | No |

---

### 004_WORKFLOW_INTEGRATION (implementation)

**Goal:** Wire risk logic into CRE workflow handlers and achieve first successful simulation.

#### 01_handlers

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_http_trigger.md | HTTP handler: parse `RiskRequest`, call `evaluateRisk`, EVM write, return `RiskDecision` | No |
| 02_cron_trigger.md | Cron handler: generate synthetic request, run same pipeline | No |

#### 02_simulation

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_dry_run.md | `cre workflow simulate .` — first end-to-end dry run | No |
| 02_broadcast.md | `cre workflow simulate . --broadcast` — first on-chain tx hash | No |
| 03_debug_iterate.md | Fix any issues from simulation, iterate until stable | No |

---

### 005_SUBMISSION (implementation)

**Goal:** Produce all submission artifacts and publish.

#### 01_documentation

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_readme.md | Clone-to-simulate in under 5 commands | Yes |
| 01_scenarios.md | 5 JSON scenarios with expected outcomes | Yes |
| 01_e2e_demo.md | `demo/e2e.sh` — curl HTTP trigger with coordinator-format payload | Yes |

#### 02_evidence

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_capture_logs.md | Simulation logs with tx hash clearly visible | No |
| 02_block_explorer.md | Verify tx on block explorer, capture link | No |

#### 03_publish

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_draft_post.md | Moltbook format with all 10 required sections | No |
| 02_registration_form.md | Complete human operator Google Form | No |
| 03_final_review.md | Triple-check format, no placeholder text, all sections filled | No |
| 04_publish.md | Publish Moltbook post before March 8 11:59 PM ET | No |

---

### 006_INTEGRATION (implementation) — P1, only if P0 stable

**Goal:** Bridge CRE Risk Router to existing agent economy.

#### 01_coordinator_bridge

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_cre_client.md | HTTP client in `agent-coordinator/internal/chainlink/cre/` | No |
| 02_wire_assign.md | CRE check before task assignment in `assign.go` | No |

#### 02_agent_signals

| Task | Description | Parallel? |
|------|-------------|-----------|
| 01_inference_fields.md | Structured signal fields in `agent-inference` task results | Yes |
| 01_defi_guard.md | CRE constraint enforcement in `agent-defi` | Yes |
| 02_hcs_messages.md | `cre_simulation`, `cre_decision`, `cre_execution_receipt` message types | No |

---

## Dependencies

```
001_CRE_VALIDATION → 002_FOUNDATION → 003_RISK_LOGIC → 004_WORKFLOW_INTEGRATION → 005_SUBMISSION
                                                                                       ↓
                                                                            006_INTEGRATION (if time)
```

All phases are sequential. Within phases, sequences are sequential unless noted. Tasks with the same number within a sequence can run in parallel.
