# Festival Structure: Get It Working, Record the Demo

## Festival Goal

Three-agent autonomous economy runs end-to-end with real chain execution (Hedera HCS/HTS, 0G Compute, Base DEX), visualized in a working dashboard, captured in a demo video.

## Phase: 003_EXECUTE

Single execution phase with focused sequences.

---

### Sequence 01: dashboard_verify

**Goal:** Confirm the dashboard compiles and runs in mock mode, then configure for live data.

**Tasks:**

1. `01_build_dashboard` — Run `next build` in the dashboard project. If it fails, fix any issues. Verify mock mode works with `NEXT_PUBLIC_USE_MOCK=true`.
2. `02_configure_live_data` — Set up `.env` with Hedera Mirror Node topic IDs (`0.0.7999404`, `0.0.7999405`) and confirm HCS feed panel shows real messages when agents are running.

---

### Sequence 02: unblock_0g

**Goal:** Get the inference agent executing real inference on 0G Compute.

**Tasks:**

1. `01_set_serving_contract` — Set `ZG_SERVING_CONTRACT=0xa79F4c8311FF93C06b8CfB403690cc987c93F91E` in inference agent `.env`.
2. `02_fix_serving_abi` — The broker's ABI uses `getServiceCount()`/`getService(uint256)` but the real contract uses `getAllServices(offset, limit)`/`getService(address)`. Fix `broker.go` to match the actual 0G InferenceServing contract ABI.
3. `03_test_0g_compute` — Run the inference agent, verify it discovers providers, submits an inference job, and receives a result. Document any failures.
4. `04_test_0g_storage` — Verify 0G Storage upload/download works with the Flow contract at `0x22E03...`.
5. `05_test_0g_inft` — Verify iNFT minting works on 0G Chain. May need to deploy the ERC-7857 contract if no pre-deployed one exists.

**Quality gates:** testing, review, iterate, commit

---

### Sequence 03: unblock_base

**Goal:** Get the DeFi agent executing real trades on Base Sepolia.

**Tasks:**

1. `01_configure_contracts` — Set `DEFI_DEX_ROUTER=0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4` (Uniswap V3 SwapRouter02), `DEFI_ERC8004_CONTRACT=0x8004A818BFB912233c491871b3d84c89A494BD9e`, and `DEFI_BUILDER_CODE` in `.env`.
2. `02_fix_executor` — Replace stub trade execution with real Uniswap V3 `exactInputSingle` ABI encoding. Add ERC-20 `approve` flow before swaps. Replace hardcoded market state with real pool queries.
3. `03_fix_identity` — Fix `register.go` `GetIdentity` to use proper ABI encoding instead of `"0x" + agentID`.
4. `04_fund_wallet` — Ensure the DeFi agent wallet has SepoliaETH and test USDC on Base Sepolia.
5. `05_test_base_trades` — Run the DeFi agent, verify it registers identity, executes a real swap, and reports P&L.

**Quality gates:** testing, review, iterate, commit

---

### Sequence 04: e2e_cycle

**Goal:** Run all three agents together in the full economy cycle.

**Tasks:**

1. `01_run_full_cycle` — Start coordinator, inference, and defi agents. Coordinator assigns tasks, agents execute (real 0G inference + real Base trades), results reported via HCS, payment settled via HTS.
2. `02_verify_dashboard` — Confirm dashboard shows live agent activity — HCS feed, agent status, DeFi P&L, inference metrics — all from real data.
3. `03_document_results` — Capture logs, transaction hashes, screenshots. Document the full working cycle.

**Quality gates:** testing, review, iterate, commit

---

### Sequence 05: demo_video

**Goal:** Record the demo video.

**Tasks:**

1. `01_write_script` — Adapt the demo script from `04-demo-and-deliverables.md` to match what actually works.
2. `02_rehearse` — Dry run the demo. Start agents, start dashboard, walk through the script. Note timing and any dead spots.
3. `03_record` — Screen-record the demo. Under 3 minutes. Capture dashboard with live agents.

**Quality gates:** review, commit

---

## Dependency Graph

```
01_dashboard_verify ──┐
02_unblock_0g ────────┤──▶ 04_e2e_cycle ──▶ 05_demo_video
03_unblock_base ──────┘
```

Sequences 01-03 can run in parallel. Sequence 04 depends on all three. Sequence 05 depends on 04.

## Phase: 004_CLEANUP (optional)

### Sequence 01: readme_polish

1. `01_update_readmes` — Update READMEs for coordinator, inference, defi with architecture overview and setup instructions.
2. `02_root_readme` — Create root campaign README with project overview and architecture diagram.
