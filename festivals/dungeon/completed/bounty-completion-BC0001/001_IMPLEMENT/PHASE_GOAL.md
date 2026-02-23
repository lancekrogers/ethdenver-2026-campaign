---
fest_type: phase
fest_id: 001_IMPLEMENT
fest_name: IMPLEMENT
fest_parent: bounty-completion-BC0001
fest_order: 1
fest_status: pending
fest_created: 2026-02-21T16:42:29.558487-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 001_IMPLEMENT

**Phase:** 001_IMPLEMENT | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Complete all remaining implementation work across 7 sequences — fixing DeFi agent bugs, implementing ERC-7857 iNFT contract, wiring 0G session auth, prepping hiero submission, polishing infrastructure, fixing documentation, and adding HIP-1215 scheduling — so that every targeted ETHDenver bounty track has qualifying evidence of functionality.

**Context:** The project's core architecture is complete. This phase closes specific bugs and missing features rather than building new systems. Sequences 01-03 are the critical path (unblocking the most bounty tracks). Sequences 04-07 are polish and infrastructure. The output of this phase feeds directly into 002_REVIEW, where bounty qualification is verified track by track.

## Required Outcomes

Deliverables this phase must produce:

- [ ] DeFi agent mean-reversion uses real SMA (not `price * 0.98`)
- [ ] x402 payment wired into trading cycle in `executeTradingCycle()`
- [ ] GetIdentity decodes on-chain response instead of returning hardcoded stub
- [ ] P&L tracking computes actual gas costs from transaction receipts
- [ ] ERC-7857 iNFT Solidity contract implemented with `updateVerifiable()` and `tokenURI()`
- [ ] Forge tests for iNFT contract passing
- [ ] 0G inference broker constructs signed `app-sk-<base64(msg:sig)>` Bearer tokens
- [ ] All empty `ZG_*` env vars populated with valid Galileo testnet values
- [ ] Hiero plugin docs updated, test coverage expanded, PR branch created
- [ ] Coordinator reads `HEDERA_TOPIC_SUBMIT_KEY` from environment
- [ ] Docker healthchecks on all 4 services in docker-compose.yml
- [ ] All 6 project READMEs accurate and copy-paste-ready
- [ ] Root README quickstart section added
- [ ] HIP-1215 `scheduleBatchSettle` and `scheduleDecay` functions in contracts
- [ ] Hedera RPC profile added to foundry.toml

## Quality Standards

Quality criteria for all work in this phase:

- [ ] All Go agents pass `just test` with no failures after changes
- [ ] `forge test` passes with no failures for all contracts
- [ ] All Go files remain under 500 lines; all functions under 50 lines
- [ ] Context propagation used for all I/O operations in Go code
- [ ] Errors wrapped with contextual information, never bare `fmt.Errorf`
- [ ] All Go binaries output to `bin/` directory only

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_base_agent_bugfixes | Fix 4 specific bugs in agent-defi that produce wrong outputs | DeFi agent produces correct trading behavior |
| 02_erc7857_inft_contract | Implement ERC-7857 iNFT Solidity contract from scratch | iNFT contract compiling and passing Forge tests |
| 03_zerog_compute_payment | Wire 0G session auth and populate env vars | Inference requests authenticate with 0G providers |
| 04_hiero_submission_prep | Polish plugin docs, tests, PR branch, demo script | Hiero plugin submission-ready for Track 4 |
| 05_system_polish | Fix coordinator topic keys and add Docker healthchecks | System runs reliably end-to-end |
| 06_doc_accuracy | Audit and fix all READMEs, add root quickstart | Judges can follow docs successfully |
| 07_contracts_hip1215 | Add HIP-1215 scheduled transaction support to contracts | Contracts leverage Hedera-native scheduling |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_base_agent_bugfixes
- [ ] 02_erc7857_inft_contract
- [ ] 03_zerog_compute_payment
- [ ] 04_hiero_submission_prep
- [ ] 05_system_polish
- [ ] 06_doc_accuracy
- [ ] 07_contracts_hip1215

## Notes

Sequences 01, 02, 03, and 07 have no dependencies on each other and can be worked in parallel. Sequence 04 soft-depends on 02 (iNFT contract should exist before demoing plugin). Sequence 05 depends on 01 (DeFi agent must build for Docker healthchecks). Sequence 06 should run last since earlier sequences change code that READMEs reference.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
