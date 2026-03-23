---
fest_type: sequence
fest_id: 01_coordinator_websocket
fest_name: coordinator websocket
fest_parent: 001_IMPLEMENT
fest_order: 1
fest_status: completed
fest_created: 2026-03-22T15:58:02.57287-06:00
fest_updated: 2026-03-22T16:18:33.005372-06:00
fest_tracking: true
fest_working_dir: projects/agent-coordinator
---


# Sequence Goal: 01_coordinator_websocket

**Sequence:** 01_coordinator_websocket | **Phase:** 001_IMPLEMENT | **Status:** Pending

## Sequence Objective

**Primary Goal:** Add an HTTP/WebSocket server to the agent-coordinator that accepts dashboard connections on :8080/ws and broadcasts DaemonEvent JSON to all connected clients.

**Contribution to Phase Goal:** The coordinator WebSocket is the central data path — without it, no agent events reach the dashboard. Every other sequence depends on this being in place.

## Success Criteria

### Required Deliverables

- [ ] **HTTP server**: Listens on :8080 with /ws endpoint and /health for Docker healthcheck
- [ ] **WebSocket upgrade**: Accepts WS connections, maintains client set, handles disconnects
- [ ] **Event broadcast**: `Broadcast(event DaemonEvent)` method that JSON-serializes and sends to all connected clients

### Quality Standards

- [ ] **Concurrent safety**: Client map protected by mutex, broadcast doesn't block on slow clients
- [ ] **Health endpoint**: GET /health returns 200 for Docker healthcheck

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 04_design_websocket_server | Design the WS server architecture | Defines interfaces and integration points |
| 03_implement_http_server_and_ws_upgrade | Build HTTP server + WS upgrade handler | Core server infrastructure |
| 02_implement_event_broadcast_to_clients | Implement broadcast to connected clients | Event delivery to dashboard |
| 01_add_connection_health_and_reconnect | Health endpoint + connection management | Production readiness |

## Dependencies

### Prerequisites (from other sequences)

- None — this is the foundational sequence

### Provides (to other sequences)

- WebSocket broadcast interface: Used by 04_agent_event_routing to publish events
- HTTP server: Used by 05_docker_integration for healthcheck

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: HTTP server starts on :8080 with /health endpoint
- [ ] **Milestone 2**: WebSocket upgrade working, clients can connect
- [ ] **Milestone 3**: Broadcast sends DaemonEvent JSON to all connected clients