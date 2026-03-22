---
fest_type: festival
fest_id: DA0002
fest_name: dashboard-agent-integration
fest_status: active
fest_created: 2026-03-22T15:56:45.679946-06:00
fest_updated: 2026-03-22T15:58:51.779982-06:00
fest_tracking: true
---

# dashboard-agent-integration

**Status:** Active | **Created:** 2026-03-22T15:56:45-06:00

## Festival Objective

**Primary Goal:** Integrate the real Go agent binaries with the dashboard so demo mode runs actual agent infrastructure with mocked external dependencies, not client-side fabricated data.

**Vision:** The dashboard proves our systems work. In demo mode, the coordinator serves a WebSocket on :8080/ws, agents publish real events through it, and external services (Hedera, Uniswap, Base RPC, 0G, obey daemon) are mocked. In live mode, the same pipeline connects to real external services. `just demo up` starts everything.

## Success Criteria

### Functional Success

- [ ] Coordinator serves WebSocket on :8080/ws and pushes DaemonEvent JSON to connected dashboard clients
- [ ] All 7 dashboard panels receive data from real agent binaries in demo mode
- [ ] External dependencies (Hedera HCS/HTS, Base RPC, Uniswap V3, 0G, obey daemon) are mocked in demo mode
- [ ] `just demo up` starts the full agent stack with mocked externals — no separate commands needed
- [ ] Live mode connects to real Hedera Mirror Node, real Base Sepolia RPC, real obey daemon

### Quality Success

- [ ] Zero client-side synthetic event generators used when agents are running — all dashboard data comes from real agent events
- [ ] All Go agent binaries compile and pass tests with mock external dependencies enabled
- [ ] Docker build succeeds for all services and `just demo up` → `just demo down` cycle completes cleanly

## Progress Tracking

### Phase Completion

- [ ] 001_IMPLEMENT: Add WebSocket server to coordinator, create external mocks, mock obey daemon, wire agent events, update Docker/justfiles, verify end-to-end

## Complete When

- [ ] All phases completed
- [ ] `just demo up` starts coordinator + agents + dashboard with mocked externals and all 7 panels show real agent data
- [ ] `just live up` connects to real external services without code changes
