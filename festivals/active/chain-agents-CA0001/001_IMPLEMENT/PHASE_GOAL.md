---
fest_type: phase
fest_id: 001_IMPLEMENT
fest_name: IMPLEMENT
fest_parent: chain-agents-CA0001
fest_order: 1
fest_status: pending
fest_created: 2026-02-18T13:40:55.709505-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 001_IMPLEMENT

**Phase:** 001_IMPLEMENT | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Deliver two fully functional agents -- an inference agent integrated with 0G services and a DeFi agent integrated with Base -- that communicate with the coordinator via HCS to form a working autonomous economy.

**Context:** This phase depends on the hedera-foundation festival (HF0001) completing HCS messaging and HTS payment infrastructure. Once those foundations are in place, the inference and DeFi agents can be built in parallel and then verified together with the coordinator in an integration sequence.

## Required Outcomes

Deliverables this phase must produce:

- [ ] agent-inference connects to 0G Compute broker and executes decentralized GPU inference jobs
- [ ] agent-inference persists memory and results to 0G Storage
- [ ] agent-inference mints ERC-7857 iNFT with encrypted metadata on 0G Chain
- [ ] agent-inference publishes inference audit trail via 0G DA
- [ ] agent-inference subscribes to HCS for task assignments and publishes results back to coordinator
- [ ] agent-defi registers identity via ERC-8004 on Base
- [ ] agent-defi implements x402 payment protocol for machine-to-machine transactions
- [ ] agent-defi includes ERC-8021 builder attribution codes in transactions
- [ ] agent-defi executes autonomous trading strategies on Base with net-positive economics
- [ ] agent-defi subscribes to HCS for task assignments and publishes P&L reports back to coordinator
- [ ] Full three-agent cycle verified: coordinator assigns via HCS -> agents execute -> agents report back via HCS

<!-- Add more required outcomes as needed -->

## Quality Standards

Quality criteria for all work in this phase:

- [ ] All packages have table-driven tests with context cancellation coverage
- [ ] HCS message handlers tested with integration tests covering publish, subscribe, and error recovery
- [ ] Code passes go vet, staticcheck, and project linting with zero warnings
- [ ] Context propagation through all I/O operations with proper cancellation handling
- [ ] Error wrapping with contextual information at every boundary (no bare fmt.Errorf)
- [ ] Interfaces kept small and focused (3-5 methods max)

<!-- Add more quality standards as needed -->

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| inference_0g | Integrate agent-inference with all 0G services and HCS communication | Working inference agent that receives tasks, runs GPU compute, stores results, mints iNFTs, and reports back |
| defi_base | Integrate agent-defi with Base chain, ERC standards, and HCS communication | Working DeFi agent that registers identity, trades autonomously, generates profit, and reports P&L |
| integration_verify | Verify the full three-agent autonomous economy works end-to-end | Demonstrated coordinator -> inference -> DeFi cycle on testnets |

<!-- Add rows as sequences are created -->

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] inference_0g: 0G Compute, Storage, iNFT, DA, and HCS integration
- [ ] defi_base: ERC-8004, x402, ERC-8021, trading, and HCS integration
- [ ] integration_verify: three-agent end-to-end cycle on testnets

<!-- Track sequence completion here -->

## Notes

- The inference_0g and defi_base sequences can run in parallel since they are independent codebases with no cross-dependency until integration verification.
- Both agents consume the shared daemon client package established in the hedera-foundation festival. They are consumers only and must not modify daemon internals.
- 0G SDK compatibility with the Go toolchain should be validated before starting the inference sequence. If the SDK is TypeScript-only, a Go wrapper or direct API integration will be needed.
- The DeFi agent must demonstrate revenue exceeding costs to qualify for the Base self-sustaining agent bounty. This requires careful tracking of gas costs, trade fees, and trading returns.
- Integration verification depends on both agent sequences completing and on Hedera testnet and 0G/Base testnets being accessible.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
