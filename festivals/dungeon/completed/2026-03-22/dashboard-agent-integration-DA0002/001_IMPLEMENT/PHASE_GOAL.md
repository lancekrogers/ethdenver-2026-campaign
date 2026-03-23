---
fest_type: phase
fest_id: 001_IMPLEMENT
fest_name: IMPLEMENT
fest_parent: dashboard-agent-integration-DA0002
fest_order: 1
fest_status: completed
fest_created: 2026-03-22T15:56:45.688139-06:00
fest_updated: 2026-03-22T17:07:02.356835-06:00
fest_phase_type: implementation
fest_tracking: true
---


# Phase Goal: 001_IMPLEMENT

**Phase:** 001_IMPLEMENT | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Implement pre-planned features and functionality

**Context:** The dashboard currently fakes all data client-side. This phase connects it to real Go agent binaries by adding a WebSocket server to the coordinator, mocking external dependencies, and wiring agent events through the real pipeline.

## Required Outcomes

Deliverables this phase must produce:

- [ ] Coordinator WebSocket server on :8080/ws accepting dashboard connections
- [ ] Mock implementations for all external dependencies (Hedera, Uniswap, Base RPC, 0G, obey daemon)
- [ ] All agents publishing events to coordinator WebSocket (heartbeats, trades, risk decisions, vault decisions)
- [ ] `just demo up` starting the full stack with mocked externals
- [ ] All 7 dashboard panels showing data from real agent binaries

## Quality Standards

Quality criteria for all work in this phase:

- [ ] All Go code compiles with `go vet` and passes existing tests
- [ ] Mock implementations are toggled by existing env vars (DEFI_MOCK_MODE, etc.)
- [ ] No client-side synthetic generators used when agents are running
- [ ] Docker build succeeds for all services

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_coordinator_websocket | Serve WebSocket on :8080/ws | HTTP server + WS upgrade + event broadcast |
| 02_external_mocks | Mock Hedera, Uniswap, Base RPC, 0G | Mock implementations toggled by env vars |
| 03_daemon_mock | Mock obey daemon for demo mode | gRPC server responding to ping/session create |
| 04_agent_event_routing | Wire agents to coordinator WS | Event publishing from all agent binaries |
| 05_docker_integration | Update Docker + justfiles | `just demo up` starts full stack |
| 06_end_to_end_verification | Verify all panels show real data | E2E verification + demo gif capture |

## Pre-Phase Checklist

Before starting implementation:

- [x] Planning phase complete (FESTIVAL_OVERVIEW.md filled)
- [x] Architecture decisions documented (coordinator serves WS, external mocks, daemon mock)
- [x] Dependencies resolved (all agent repos available as submodules)
- [x] Development environment ready (Go, Docker, just CLI available)

## Phase Progress

### Sequence Completion

- [ ] 01_coordinator_websocket
- [ ] 02_external_mocks
- [ ] 03_daemon_mock
- [ ] 04_agent_event_routing
- [ ] 05_docker_integration
- [ ] 06_end_to_end_verification

## Notes

- The coordinator already has HCS publishing — the WebSocket server reuses same event types
- Dashboard `useWebSocket` hook already expects DaemonEvent JSON on ws://coordinator:8080/ws
- Agent-defi already has structured event types for trades, PnL, heartbeats
- docker-compose.yml already has mock mode env vars (DEFI_MOCK_MODE, NEXT_PUBLIC_USE_MOCK)

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*