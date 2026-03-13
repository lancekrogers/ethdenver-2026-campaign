---
fest_type: phase
fest_id: 001_DRIFT_BET_AGENT
fest_name: DRIFT_BET_AGENT
fest_parent: obey-agent-platform-OA0001
fest_order: 1
fest_status: pending
fest_created: 2026-03-13T02:20:11.19072-06:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 001_DRIFT_BET_AGENT

**Phase:** 001_DRIFT_BET_AGENT | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Deliver a live prediction market agent trading on Drift BET (Solana mainnet) with platform seed capital ($5K-$10K), demonstrating profitable autonomous trading with LLM-powered analysis.

**Context:** This is the critical first phase — everything else depends on having a working agent generating real trades on mainnet. The agent proves the core thesis: AI agents have a structural edge in prediction markets through 24/7 operation, resolution rule parsing, and multi-source information aggregation. Without a working agent, the vault, landing page, and token launch have nothing to monetize.

## Required Outcomes

Deliverables this phase must produce:

- [ ] Go HTTP client implementing the MarketAdapter interface for Drift BET (ListMarkets, PlaceOrder, GetPositions, RedeemPosition)
- [ ] Claude-powered analysis pipeline that normalizes market data, parses resolution rules, estimates probabilities, and generates trading signals with edge/confidence scores
- [ ] Agent execution loop running on configurable intervals (15min trading, 5min P&L reporting, 30s health checks) with goroutine-based scheduling
- [ ] Risk manager enforcing position sizing limits, stop-loss at configurable drawdown %, and concentration limits per market
- [ ] Portfolio tracker calculating NAV from Drift position values with P&L reporting via HCS
- [ ] Mock mode with full adapter mocks for dry-run testing without real funds
- [ ] Agent deployed on Solana mainnet, trading live Drift BET markets, monitored for 24h stability
- [ ] HCS integration broadcasting trade events and P&L reports to coordinator topics

## Quality Standards

Quality criteria for all work in this phase:

- [ ] All Go code passes `go vet` and `golangci-lint` with zero warnings
- [ ] Unit test coverage above 80% for client, analysis, and risk management packages
- [ ] Context propagation on all I/O operations with cancellation support
- [ ] Error handling uses project error framework with contextual wrapping
- [ ] Agent maintains stable operation for 24+ hours on mainnet without crashes or goroutine leaks
- [ ] Mock mode produces identical code paths to live mode (only adapter layer differs)

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_drift_client | Implement Go HTTP client for Drift BET API | MarketAdapter implementation with unit/integration tests |
| 02_analysis_pipeline | Build Claude-powered market analysis and signal generation | Analysis engine producing Signal structs with edge, confidence, and reasoning |
| 03_agent_loop | Wire execution loop with risk management and portfolio tracking | Running agent binary with configurable intervals and mock mode |
| 04_mainnet_deployment | Deploy agent to Solana mainnet with monitoring | Live agent trading Drift BET with HCS reporting |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_drift_client
- [ ] 02_analysis_pipeline
- [ ] 03_agent_loop
- [ ] 04_mainnet_deployment

## Notes

- Drift BET was chosen over Polymarket as the first target because it is Solana-native (no bridges, no cross-chain risk, instant settlement). USDC stays on the same chain as future vault contracts.
- The agent runtime is Go, extending existing agent-defi patterns from the codebase. Drift SDK is TypeScript/Python official, so the Go client uses HTTP API access.
- Pyth oracles are used by Drift for resolution, which is the same oracle infrastructure needed for the full vault NAV calculations later.
- The agent wallet holds funds directly in this phase (no vault contract yet). The MVP vault in Phase 002 adds smart contract custody.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
