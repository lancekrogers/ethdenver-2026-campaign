# Festival TODO - Bounty Completion (BC0001)

**Goal**: Finish all 7 ETHDenver 2026 bounty tracks by wiring remaining stubs, implementing Solidity contracts, adding 0G templates, and polishing for public release.
**Status**: Active

---

## Festival Progress Overview

### Phase Completion Status

- [ ] 001_IMPLEMENT — Complete all remaining implementation work across 7 sequences
- [ ] 002_REVIEW — Verify bounty qualification for all 7 tracks

### Current Work Status

```
Active Phase: 001_IMPLEMENT
Active Sequences: 01_coordinator_schedule_wiring, 02_base_tx_signing, 03_contracts_implementation, 04_0g_templates, 05_hiero_plugin_polish, 06_docker_verify, 07_readme_polish
Blockers: None
```

---

## Phase Progress

### 001_IMPLEMENT

**Status**: Not Started

#### Sequences

- [ ] **01_coordinator_schedule_wiring** — Wire Hedera Scheduled Transactions into the coordinator's schedule service
  - [ ] 01_wire_schedule_service — Implement ScheduleService using Hedera SDK scheduled transactions
  - [ ] 02_testing — Test the schedule wiring with unit and integration tests
  - [ ] 03_review — Review code quality and correctness
  - [ ] 04_iterate — Iterate on any review findings
  - [ ] 05_fest_commit — Commit and mark sequence complete

- [ ] **02_base_tx_signing** — Wire real Base Sepolia tx signing into the agent-defi executor
  - [ ] 01_add_ethutil_package — Add ethutil package with key loading and tx signing helpers
  - [ ] 02_wire_executor_signing — Wire signing into the swap executor
  - [ ] 03_wire_register_signing — Wire signing into the register/deregister flow
  - [ ] 04_wire_x402_signing — Wire signing into the x402 payment flow
  - [ ] 05_wire_market_state — Wire market state into the defi agent's decision loop
  - [ ] 06_testing — Test all signing paths
  - [ ] 07_review — Review code quality and correctness
  - [ ] 08_iterate — Iterate on any review findings
  - [ ] 09_fest_commit — Commit and mark sequence complete

- [ ] **03_contracts_implementation** — Implement AgentSettlement.sol and ReputationDecay.sol with Forge tests and deploy scripts
  - [ ] 01_forge_setup — Set up Forge project structure and dependencies
  - [ ] 02_implement_settlement — Implement AgentSettlement.sol
  - [ ] 03_implement_reputation — Implement ReputationDecay.sol
  - [ ] 04_write_tests — Write Forge tests for both contracts
  - [ ] 05_deploy_script — Write deploy scripts for Hedera testnet and Base Sepolia
  - [ ] 06_testing — Run tests and verify coverage
  - [ ] 07_review — Review code quality and correctness
  - [ ] 08_iterate — Iterate on any review findings
  - [ ] 09_fest_commit — Commit and mark sequence complete

- [ ] **04_0g_templates** — Create 0g-agent and 0g-inft-build camp templates in the hiero-plugin for 0G Track 4
  - [ ] 01_create_0g_agent_template — Create Go scaffold with 0G Compute, Storage, and chain client stubs
  - [ ] 02_create_0g_inft_template — Create ERC-7857 iNFT scaffold with AES-256-GCM and 0G DA publisher
  - [ ] 03_register_templates — Register both templates in the plugin manifest and command handlers

- [ ] **05_hiero_plugin_polish** — Verify all plugin tests pass and update submission docs
  - [ ] 01_verify_tests — Run all 37+ tests and fix any failures
  - [ ] 02_update_docs — Update submission.md, architecture.md, and usage-guide.md with 0G template content

- [ ] **06_docker_verify** — Verify Docker orchestration works end-to-end with mock mode and healthchecks
  - [ ] 01_verify_builds — Run `just docker build-all` and fix any Dockerfile failures
  - [ ] 02_verify_mock_mode — Run `just demo` and verify all 5 dashboard panels render in mock mode
  - [ ] 03_add_healthchecks — Add healthcheck blocks to docker-compose.yml for all 4 services

- [ ] **07_readme_polish** — Review and update all 7 READMEs with verified quick-start instructions
  - [ ] 01_review_readmes — Read root + 6 project READMEs and apply accuracy fixes
  - [ ] 02_verify_quickstarts — Walk through each README's quick-start and confirm commands work

### 002_REVIEW

**Status**: Not Started

#### Sequences

- [ ] Bounty qualification verification for all 7 tracks (sequences TBD — created during review phase)

---

## Blockers

None currently.

---

## Decision Log

- 2026-02-21: Structured BC0001 with 7 implementation sequences covering coordinator wiring, Base signing, contracts, 0G templates, plugin polish, Docker verification, and README polish.
- 2026-02-21: Seq 04 (0g_templates) placed before Seq 05 (hiero_plugin_polish) since polish depends on templates existing.
- 2026-02-21: Seq 06 (docker_verify) depends on Seq 01 and 02 completing so Go changes compile into Docker images.

---

*Detailed progress available via `fest status`*
