# Festival TODO - dashboard-agent-integration

**Goal**: Integrate real Go agent binaries with the dashboard — demo mode runs actual infrastructure with mocked external deps, not fabricated client-side data
**Status**: Active

---

## Festival Progress Overview

### Phase Completion Status

- [ ] 001_IMPLEMENT: WebSocket server, external mocks, daemon mock, event routing, Docker integration, E2E verification

### Current Work Status

```
Active Phase: 001_IMPLEMENT
Active Sequences: 01_coordinator_websocket
Blockers: None
```

---

## Phase Progress

### 001_IMPLEMENT

**Status**: In Progress

#### Sequences

- [ ] 01_coordinator_websocket — Add HTTP/WebSocket server to coordinator on :8080/ws
- [ ] 02_external_mocks — Mock Hedera, Base RPC, Uniswap, 0G in agent binaries
- [ ] 03_daemon_mock — Lightweight mock obey daemon for demo mode gRPC
- [ ] 04_agent_event_routing — Wire all agents to publish events through coordinator WebSocket
- [ ] 05_docker_integration — Update docker-compose and justfiles for full demo stack
- [ ] 06_end_to_end_verification — Verify all 7 panels show real agent data

---

## Blockers

None currently.

---

## Decision Log

- Mock external dependencies (Hedera, Uniswap, Base RPC, 0G), NOT our own systems
- Mock obey daemon in demo mode to avoid polluting real sessions
- Coordinator serves WebSocket — dashboard already expects ws://coordinator:8080/ws

---

*Detailed progress available via `fest status`*
