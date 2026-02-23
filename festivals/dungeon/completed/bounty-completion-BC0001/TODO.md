# Festival TODO - Bounty Completion (BC0001)

**Goal**: Close remaining implementation gaps across the ETHDenver multi-agent economy project so every targeted bounty track has qualifying evidence of functionality.
**Status**: Active

---

## Festival Progress Overview

### Phase Completion Status

- [ ] 001_IMPLEMENT — Fix bugs, implement missing contracts, wire auth, polish system (7 sequences)
- [ ] 002_REVIEW — Verify bounty qualification for all targeted tracks

### Current Work Status

```
Active Phase: 001_IMPLEMENT
Active Sequences: 01_base_agent_bugfixes, 02_erc7857_inft_contract, 03_zerog_compute_payment, 04_hiero_submission_prep, 05_system_polish, 06_doc_accuracy, 07_contracts_hip1215
Blockers: None
```

---

## Phase Progress

### 001_IMPLEMENT

**Status**: Not Started

#### Sequences

- [ ] **01_base_agent_bugfixes** — Fix 4 bugs in agent-defi that produce wrong trading outputs
  - [ ] 01_fix_strategy_moving_average — Replace hardcoded `price * 0.98` with real SMA calculation
  - [ ] 02_wire_x402_into_trading_loop — Call x402 payment in executeTradingCycle()
  - [ ] 03_fix_pnl_accuracy — Compute gas costs from tx receipts instead of $0.50 stub
  - [ ] 04_fix_getidentity_decode — Decode on-chain GetIdentity response instead of returning hardcoded stub

- [ ] **02_erc7857_inft_contract** — Implement ERC-7857 iNFT Solidity contract for 0G Track 3
  - [ ] 01_implement_erc7857_contract — Write iNFT721.sol with updateVerifiable() and tokenURI()
  - [ ] 02_write_forge_tests — Write Forge tests for mint, update, and verification flow
  - [ ] 03_deploy_and_configure — Add deploy script and wire ZG_INFT_CONTRACT env var

- [ ] **03_zerog_compute_payment** — Wire 0G session auth and populate empty environment variables
  - [ ] 01_implement_session_auth — Build signed Bearer token construction and 401 retry in broker
  - [ ] 02_configure_env_vars — Fill empty ZG_* variables with valid Galileo testnet values

- [ ] **04_hiero_submission_prep** — Polish hiero-plugin docs, tests, PR branch, and demo script
  - [ ] 01_update_plugin_docs — Update submission.md, architecture.md, usage-guide.md with 0G content
  - [ ] 02_add_0g_test_coverage — Add test cases for 0G template generation edge cases
  - [ ] 03_create_hiero_pr — Create clean PR branch with conventional commits
  - [ ] 04_record_demo_video — Write demo walkthrough script

- [ ] **05_system_polish** — Fix coordinator topic keys and add Docker healthchecks
  - [ ] 01_coordinator_topic_keys — Load HEDERA_TOPIC_SUBMIT_KEY and pass to HCS client
  - [ ] 02_docker_healthchecks — Add healthcheck blocks to all 4 services in docker-compose.yml

- [ ] **06_doc_accuracy** — Audit and fix all READMEs, add root quickstart
  - [ ] 01_fix_all_stale_readmes — Audit all 6 project READMEs against actual codebase
  - [ ] 02_add_root_quickstart — Add 5-minute quickstart to root README

- [ ] **07_contracts_hip1215** — Add HIP-1215 scheduled transaction support to Solidity contracts
  - [ ] 01_integrate_hip1215_scheduling — Add IHederaScheduleService interface and scheduling functions
  - [ ] 02_add_hedera_rpc_profile — Add Hedera testnet RPC profile to foundry.toml
  - [ ] 03_update_forge_tests — Add Forge tests mocking the HIP-1215 system contract

### 002_REVIEW

**Status**: Not Started

#### Sequences

- [ ] Bounty qualification verification for all targeted tracks (sequences TBD — created during review phase)

---

## Blockers

None currently.

---

## Execution Order

Sequences 01, 02, 07 can run in parallel (no dependencies).
Sequence 03 depends on 02 (iNFT contract provides ZG_INFT_CONTRACT needed for minting).
Sequence 04 soft-depends on 02 (iNFT contract should exist before plugin demo).
Sequence 05 depends on 01 (DeFi agent must build for Docker healthchecks).
Sequence 06 runs last (earlier sequences change code that READMEs reference).

---

## Decision Log

- 2026-02-21: Original plan had 7 sequences based on incomplete codebase audit. Deleted and rebuilt with 7 new sequences based on thorough audit of actual remaining gaps.
- 2026-02-21: Discovered contracts (AgentSettlement, ReputationDecay) and hiero-plugin templates already exist — removed from plan. Added actual missing work: DeFi agent bugs, ERC-7857 iNFT, 0G session auth, HIP-1215 scheduling.
- 2026-02-21: Ordered sequences so code changes (01-03, 07) happen before polish (04-06).

---

*Detailed progress available via `fest status`*
