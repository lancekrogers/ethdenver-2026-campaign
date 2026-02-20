---
fest_type: phase
fest_id: 001_IMPLEMENT
fest_name: IMPLEMENT
fest_parent: hedera-foundation-HF0001
fest_order: 1
fest_status: pending
fest_created: 2026-02-18T13:40:53.491512-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 001_IMPLEMENT

**Phase:** 001_IMPLEMENT | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Deliver the complete Hedera integration layer (HCS, HTS, Schedule Service) and coordinator agent logic as a working Go codebase in the agent-coordinator project.

**Context:** This is the sole implementation phase for the hedera-foundation festival. It produces all code required for the Hedera Track 3 bounty submission. The obey daemon is an external dependency consumed via a shared client package. All Hedera interaction uses native services with zero Solidity.

## Required Outcomes

Deliverables this phase must produce:

- [ ] HCS service package: topic creation, message publish, message subscribe with context-aware streaming
- [ ] HTS service package: token creation, token transfer between agent accounts with proper error wrapping
- [ ] Schedule Service package: heartbeat transaction on a configurable interval with context cancellation support
- [ ] Coordinator engine: task assignment from festival plan, progress monitoring with quality gates, payment flow via HTS
- [ ] Daemon client package: shared consumer-only client for the obey daemon API with dependency injection
- [ ] Integration test demonstrating the full cycle: festival plan -> HCS task assignment -> result collection -> HTS payment
- [ ] Hedera testnet configuration and account setup for development and demo

<!-- Add more required outcomes as needed -->

## Quality Standards

Quality criteria for all work in this phase:

- [ ] All packages pass context.Context as first parameter for I/O operations
- [ ] Errors are wrapped with operational context using the project error framework
- [ ] Table-driven tests cover happy path, error cases, and context cancellation
- [ ] No file exceeds 500 lines, no function exceeds 50 lines
- [ ] Dependencies are injected, no global state
- [ ] Zero Solidity -- all Hedera interaction uses native SDK services only
- [ ] Code passes go vet and staticcheck with no warnings

<!-- Add more quality standards as needed -->

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_hcs_service | Wrap HCS topic and message operations | HCS package with create, publish, subscribe |
| 02_hts_service | Wrap HTS token operations | HTS package with token create and transfer |
| 03_schedule_service | Implement heartbeat via Schedule Service | Schedule package with configurable interval heartbeat |
| 04_coordinator | Build task orchestration engine | Coordinator with assign, monitor, gate, pay logic |
| 05_daemon_client | Shared daemon API consumer package | Client package with DI-friendly interface |
| 06_integration | End-to-end cycle test on testnet | Full plan-to-payment integration test |

<!-- Add rows as sequences are created -->

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_hcs_service
- [ ] 02_hts_service
- [ ] 03_schedule_service
- [ ] 04_coordinator
- [ ] 05_daemon_client
- [ ] 06_integration

<!-- Track sequence completion here -->

## Notes

- The obey daemon is an external dependency. The daemon client package in this phase is consumer-only -- it wraps the daemon API for use by the coordinator, but does not modify daemon internals.
- All development and testing targets Hedera testnet. Mainnet deployment is out of scope.
- The Hedera Go SDK is the primary dependency for HCS/HTS/Schedule operations. Confirm SDK version compatibility before starting sequences.
- The coordinator should be designed for demonstrability: a clean, end-to-end run from plan to payment is the key hackathon deliverable.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
