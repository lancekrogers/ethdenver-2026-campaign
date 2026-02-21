# Implementation Plan: Get It Working, Record the Demo

## Overview

Get the three-agent autonomous economy running end-to-end with real chain execution, visualized in the dashboard, captured in a demo video.

## Phase: 003_EXECUTE

### Sequence 01: dashboard_verify (2 tasks)

Confirm dashboard compiles and runs. Configure for live Hedera data.

#### Task 01: Build and verify dashboard

- `cd projects/dashboard && just build` (or `npm run build`)
- If build fails, fix issues
- Run in mock mode: `NEXT_PUBLIC_USE_MOCK=true npm run dev`
- Verify all 5 panels render: festival progress, HCS feed, agent activity, DeFi P&L, inference metrics
- **Autonomy:** high — straightforward build verification

#### Task 02: Configure live data sources

- Create `projects/dashboard/.env.local`:
  ```
  NEXT_PUBLIC_USE_MOCK=false
  NEXT_PUBLIC_HEDERA_TOPIC_IDS=0.0.7999404,0.0.7999405
  NEXT_PUBLIC_HEDERA_MIRROR_NODE_URL=https://testnet.mirrornode.hedera.com
  ```
- Run dashboard and verify HCS feed shows historical messages from prior testnet runs
- **Autonomy:** high

---

### Sequence 02: unblock_0g (5 tasks + quality gates)

Get inference agent running real 0G Compute inference.

#### Task 01: Set serving contract address

- Set `ZG_SERVING_CONTRACT=0xa79F4c8311FF93C06b8CfB403690cc987c93F91E` in `projects/agent-inference/.env`
- **Autonomy:** high

#### Task 02: Fix serving contract ABI in broker.go

- **File:** `projects/agent-inference/internal/zerog/compute/broker.go`
- Current ABI uses `getServiceCount()` and `getService(uint256 index)` — these don't exist on the real contract
- Real contract (from 0G SDK TypeChain types) exposes:
  - `getAllServices(uint256 offset, uint256 limit) returns (ServiceStruct[], uint256 total)`
  - `getService(address provider) returns (ServiceStruct)`
  - `ServiceStruct` = `{provider address, name string, serviceType string, url string, model string, ...}`
- Update the ABI JSON and `listFromChain()` to call `getAllServices(0, 100)` instead of iterating by index
- Update `ServiceInfo` struct mapping if fields differ
- Run existing tests to ensure they still pass
- **Autonomy:** medium — requires careful ABI matching

#### Task 03: Test 0G Compute inference

- Run inference agent with real config
- Verify it connects to 0G Galileo testnet
- Verify `listFromChain()` discovers at least one provider
- Submit a test inference request
- Document results (success or specific failure)
- **Autonomy:** medium — may encounter issues with provider availability

#### Task 04: Test 0G Storage

- Verify 0G Storage upload/download with Flow contract at `0x22E03a6A89B950F1c82ec5e74F8eCa321a105296`
- Test storing inference results
- **Autonomy:** medium

#### Task 05: Test iNFT minting

- Check if ERC-7857 iNFT contract exists on 0G Chain or needs deployment
- If needs deployment: deploy using go-ethereum or foundry
- Test minting an agent iNFT with encrypted metadata
- **Autonomy:** low — may need user help with contract deployment

#### Quality gates: testing → review → iterate → commit

---

### Sequence 03: unblock_base (5 tasks + quality gates)

Get DeFi agent executing real trades on Base Sepolia.

#### Task 01: Configure contract addresses

- Set in `projects/agent-defi/.env`:
  ```
  DEFI_DEX_ROUTER=0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4
  DEFI_ERC8004_CONTRACT=0x8004A818BFB912233c491871b3d84c89A494BD9e
  DEFI_BUILDER_CODE=<agent-wallet-address>
  ```
- **Autonomy:** high

#### Task 02: Implement real trade execution

- **File:** `projects/agent-defi/internal/base/trading/executor.go`
- Replace stub function selector `0xa9059cbb` with Uniswap V3 `exactInputSingle`:
  - Selector: `0x414bf389`
  - Params: `tokenIn, tokenOut, fee (3000 for 0.3%), recipient, amountIn, amountOutMinimum, sqrtPriceLimitX96`
  - ABI-encode using `abi.Pack` or manual encoding
- Add ERC-20 `approve(routerAddress, amount)` call before swap
- Replace hardcoded `GetMarketState` with real Uniswap V3 pool `slot0` query via QuoterV2 at `0xC5290058841028F1614F3A6F0F5816cAd0df5E27`
- Update tests
- **Autonomy:** medium — core implementation work

#### Task 03: Fix identity registration

- **File:** `projects/agent-defi/internal/base/identity/register.go`
- Fix `GetIdentity` to use proper ABI encoding (`abi.Pack("getIdentity", agentIDBytes32)`) instead of `"0x" + agentID`
- Fix `Register` to use proper ABI encoding for the registration call
- Update tests
- **Autonomy:** medium

#### Task 04: Fund agent wallet

- Ensure DeFi agent wallet has SepoliaETH (for gas)
- Get test USDC from Circle faucet on Base Sepolia
- Verify balances via `GetBalance`
- **Autonomy:** high — faucet operations

#### Task 05: Test Base trades end-to-end

- Run DeFi agent
- Verify ERC-8004 identity registration succeeds
- Verify at least one real swap executes on Uniswap V3
- Verify PnL tracker records the trade
- Verify ERC-8021 attribution bytes are appended to calldata
- Document results with tx hashes
- **Autonomy:** medium

#### Quality gates: testing → review → iterate → commit

---

### Sequence 04: e2e_cycle (3 tasks + quality gates)

Run all three agents together.

#### Task 01: Run full economy cycle

- Start coordinator, inference agent, DeFi agent
- Coordinator publishes task assignments via HCS
- Inference agent receives task, runs 0G inference, reports result
- DeFi agent receives task, executes Base trade, reports result + PnL
- Coordinator receives results, triggers HTS payment
- Capture all logs
- **Autonomy:** medium

#### Task 02: Verify dashboard shows live data

- Run dashboard with live config
- Confirm HCS feed shows real-time messages
- Confirm agent activity cards update
- Confirm DeFi P&L shows real trade data
- Confirm inference metrics show real job data
- Screenshot the dashboard
- **Autonomy:** high

#### Task 03: Document results

- Save logs from all three agents
- Record transaction hashes (HCS, HTS, Base, 0G)
- Document the complete cycle flow
- **Autonomy:** high

#### Quality gates: testing → review → iterate → commit

---

### Sequence 05: demo_video (3 tasks + quality gates)

Record the demo.

#### Task 01: Write demo script

- Adapt `workflow/design/ethdenver-agent-economy/04-demo-and-deliverables.md` demo script
- Adjust for what actually works
- Target under 3 minutes
- **Autonomy:** high

#### Task 02: Rehearse

- Start all agents + dashboard
- Walk through script, note timing
- Identify dead spots or things that need polish
- **Autonomy:** high

#### Task 03: Record demo video

- Screen-record with agents running live
- Follow the script
- Capture dashboard showing real-time agent activity
- **Autonomy:** high (user may want to record themselves)

#### Quality gates: review → commit

---

## Dependency Graph

```
01_dashboard_verify ──┐
02_unblock_0g ────────┼──▶ 04_e2e_cycle ──▶ 05_demo_video
03_unblock_base ──────┘
```

Sequences 01, 02, 03 are independent and can execute in parallel.
Sequence 04 requires all three to be complete.
Sequence 05 requires 04.

## Risk Register

| Risk | Impact | Mitigation |
|------|--------|-----------|
| No 0G Compute providers available on Galileo | Blocks 0G inference | Check provider count first; may need to set up own provider or use pre-existing |
| Base Sepolia USDC faucet unavailable | Blocks real trades | Use SepoliaETH→WETH swap instead of USDC→WETH |
| Dashboard WebSocket data source not available | No live agent panels | Use Mirror Node data (HCS feed) + mock for other panels |
| iNFT contract not deployed on 0G Chain | Blocks iNFT demo | Deploy using foundry or go-ethereum |
