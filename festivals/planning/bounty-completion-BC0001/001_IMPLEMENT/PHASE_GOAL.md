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

**Primary Goal:** Complete all remaining implementation work across 3 sequences — coordinator schedule wiring, Base tx signing, and Solidity contracts — so that every targeted ETHDenver bounty track has qualifying on-chain evidence of functionality.

**Context:** The project's core architecture is complete. This phase closes the final implementation gaps: one wiring task in the coordinator, three stub replacements and one data fetch in agent-defi, and two Solidity contracts written from scratch. All work in this phase is independent and can be parallelized across sequences. The output of this phase feeds directly into 002_REVIEW, where bounty qualification is verified track by track.

## Required Outcomes

Deliverables this phase must produce:

- [ ] Coordinator wired with schedule service — all 4 Hedera native services active, heartbeat goroutine running
- [ ] agent-defi ethutil package created with go-ethereum dependency, LoadKey/MakeTransactOpts/DialClient functions
- [ ] executor.go sends real Uniswap V3 swaps on Base Sepolia
- [ ] register.go sends real ERC-8004 registration transaction on Base Sepolia
- [ ] x402.go sends real payment transaction on Base Sepolia
- [ ] GetMarketState fetches live Uniswap V3 prices from on-chain pools
- [ ] AgentSettlement.sol implemented and compiling with settle, batchSettle, and AgentPaid event
- [ ] ReputationDecay.sol implemented and compiling with time-decay reputation logic
- [ ] Forge tests passing for both contracts
- [ ] Deploy script for Hedera testnet EVM outputting deployed addresses

## Quality Standards

Quality criteria for all work in this phase:

- [ ] All Go agents pass `just test` with no failures after changes
- [ ] `forge test` passes with no failures for both contracts
- [ ] All Go files remain under 500 lines; all functions under 50 lines
- [ ] Context propagation used for all I/O operations in Go code
- [ ] Errors wrapped with contextual information, never bare `fmt.Errorf`
- [ ] All Go binaries output to `bin/` directory only

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_coordinator_schedule_wiring | Wire schedule service into coordinator main.go | Coordinator using 4 Hedera native services |
| 02_base_tx_signing | Replace all stub tx signing in agent-defi with real Base Sepolia transactions | agent-defi sends real on-chain txs |
| 03_contracts_implementation | Implement AgentSettlement.sol and ReputationDecay.sol with Forge tests | Both contracts passing `forge test` |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_coordinator_schedule_wiring
- [ ] 02_base_tx_signing
- [ ] 03_contracts_implementation

## Notes

Sequences 01, 02, and 03 have no dependencies on each other and can be worked in parallel. The coordinator wiring (01) is the smallest change — approximately 12 lines added to main.go. The Base tx signing (02) is the largest sequence with 5 implementation tasks but all target isolated files. The contracts (03) start from scratch but scope is tightly bounded to two contracts, tests, and one deploy script.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
