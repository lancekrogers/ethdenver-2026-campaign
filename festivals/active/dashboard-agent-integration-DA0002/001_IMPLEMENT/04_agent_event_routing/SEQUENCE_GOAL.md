---
fest_type: sequence
fest_id: 04_agent_event_routing
fest_name: agent event routing
fest_parent: 001_IMPLEMENT
fest_order: 4
fest_status: pending
fest_tracking: true
fest_working_dir: "projects/agent-coordinator"
---

# Sequence Goal: 04_agent_event_routing

**Sequence:** 04_agent_event_routing | **Phase:** 001_IMPLEMENT | **Status:** Pending

## Sequence Objective

**Primary Goal:** Wire all Go agents (coordinator, defi, inference, cre-risk-router) to publish their events through the coordinator's WebSocket hub so the dashboard receives real agent data.

**Contribution to Phase Goal:** This is where the actual integration happens — agents produce real events that flow through the coordinator to the dashboard. Without this, the WebSocket server has no events to broadcast.

## Success Criteria

### Required Deliverables

- [ ] **Coordinator event interface**: A `Publisher` interface that agents use to emit DaemonEvents to the hub
- [ ] **Agent-defi events**: Heartbeats, trade results, PnL reports, vault decisions published to hub
- [ ] **CRE risk router events**: Risk check requested/approved/denied events published to hub
- [ ] **Agent-inference events**: Heartbeats with compute metrics, inference job results published to hub
- [ ] **Vault decision events**: Ritual GO/NO_GO decisions from the festruntime pipeline published to hub

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] All 4 event sources (coordinator, defi, inference, cre) produce events visible in dashboard

## Dependencies

### Prerequisites

- 01_coordinator_websocket: Hub with Broadcast() must exist
- 02_external_mocks: Mocks must exist so agents can run
- 03_daemon_mock: Mock daemon must exist so vault-agent can run

### Provides

- Event flow: Used by 06_end_to_end_verification to validate all panels
