# Festival Structure: Bounty Completion

## Festival Goal

Finish all 7 ETHDenver bounty tracks for public release. Wire remaining stubs (Base tx signing, coordinator schedule service), implement Solidity contracts, add 0G dev tooling templates, and polish for production.

## Phase: 001_IMPLEMENT

Single implementation phase with 7 sequences.

---

### Sequence 01: coordinator_schedule_wiring

**Goal:** Wire the existing schedule service package into coordinator main.go to activate the 4th Hedera native service (Schedule Service) for Track 3.

**Tasks:**

1. `01_wire_schedule_service` — Import the schedule package, instantiate ScheduleService and HeartbeatRunner with config, start the heartbeat goroutine in main.go. Pattern already exists in internal/hedera/schedule/ — just needs ~12 lines of wiring.

**Quality gates:** testing, review, iterate

---

### Sequence 02: base_tx_signing

**Goal:** Add go-ethereum dependency to agent-defi and replace 3 tx signing stubs with real signing following agent-inference's proven pattern. Also wire live Uniswap V3 market data.

**Tasks:**

1. `01_add_ethutil_package` — Run go get github.com/ethereum/go-ethereum. Create internal/base/ethutil/client.go mirroring agent-inference's zerog/chain.go pattern (LoadKey, MakeTransactOpts, DialClient, AddressFromKey).
2. `02_wire_executor_signing` — Replace executor.go:142-161 stub. Use ethutil to build EIP-1559 DynamicFeeTx with existing calldata, sign with crypto.HexToECDSA, send via eth_sendRawTransaction, poll receipt with bind.WaitMined.
3. `03_wire_register_signing` — Replace register.go:177-207 stub. ABI-encode register(bytes32,bytes,bytes) call, build and sign tx, send and poll receipt. Use same ethutil helpers.
4. `04_wire_x402_signing` — Replace x402.go:137-152 stub. Build simple ETH/USDC transfer tx, sign and send, use existing getTransactionReceipt() for confirmation.
5. `05_wire_market_state` — Replace executor.go:269-279 hardcoded values. Implement factory.getPool() + pool.slot0() + pool.observe() via eth_call using existing callRPC infrastructure.

**Quality gates:** testing, review, iterate

---

### Sequence 03: contracts_implementation

**Goal:** Implement AgentSettlement.sol and ReputationDecay.sol for Hedera Track 2 (On-Chain Automation).

**Tasks:**

1. `01_forge_setup` — Install Forge dependencies (OpenZeppelin if needed), verify foundry.toml configuration, ensure build toolchain works.
2. `02_implement_settlement` — Implement AgentSettlement.sol with settle(address agent, uint256 amount, bytes32 taskId), batchSettle(), AgentPaid events, Ownable access control, integration point with HIP-1215 scheduled transactions.
3. `03_implement_reputation` — Implement ReputationDecay.sol with updateReputation(address agent, uint256 delta), getReputation(address agent) with time-decay math using block.timestamp, configurable decay rate.
4. `04_write_tests` — Write Forge tests for both contracts covering settle, batch, decay, access control, and edge cases.
5. `05_deploy_script` — Create Deploy.s.sol script targeting Hedera testnet EVM.

**Quality gates:** testing, review, iterate

---

### Sequence 04: 0g_templates

**Goal:** Create 0G-specific camp templates in the hiero-plugin for 0G Track 4 (Dev Tooling).

**Tasks:**

1. `01_create_0g_agent_template` — Build 0g-agent template: Go project scaffold with 0G Compute broker, Storage client, Chain connection, and config. Based on agent-inference's actual structure.
2. `02_create_0g_inft_template` — Build 0g-inft-build template: ERC-7857 iNFT project with AES-256-GCM encryption, DA audit publisher, and minter scaffold.
3. `03_register_templates` — Register both templates in the plugin's template registry, update manifest.json and command handlers to expose them via hiero camp init --template.

**Quality gates:** testing, review, iterate

---

### Sequence 05: hiero_plugin_polish

**Goal:** Verify hiero-plugin is fully working and submission docs are current.

**Tasks:**

1. `01_verify_tests` — Run all existing tests, fix any failures. Ensure new 0G templates are covered by tests.
2. `02_update_docs` — Update submission.md, architecture.md, and usage-guide.md to reflect 0G template additions and current project state.

**Quality gates:** testing, review, iterate

---

### Sequence 06: docker_verify

**Goal:** Verify Docker orchestration works end-to-end for all services.

**Tasks:**

1. `01_verify_builds` — Run just docker build-all and confirm all 4 Docker images build successfully.
2. `02_verify_mock_mode` — Run just demo to start dashboard in mock mode, verify all 5 panels render correctly.
3. `03_add_healthchecks` — Add Docker healthcheck blocks to docker-compose.yml for all 4 services.

**Quality gates:** testing, review, iterate

---

### Sequence 07: readme_polish

**Goal:** Ensure all READMEs are accurate, complete, and ready for public release.

**Tasks:**

1. `01_review_readmes` — Review root README and all 6 project READMEs for accuracy in setup instructions, architecture descriptions, screenshots, and links.
2. `02_verify_quickstarts` — Walk through each README's quick-start instructions and confirm they actually work.

**Quality gates:** testing, review, iterate

---

## Phase: 002_REVIEW

Final review verifying each bounty track's criteria are fully met against the bounty map in workflow/design/ethdenver-agent-economy/02-bounty-map.md.
