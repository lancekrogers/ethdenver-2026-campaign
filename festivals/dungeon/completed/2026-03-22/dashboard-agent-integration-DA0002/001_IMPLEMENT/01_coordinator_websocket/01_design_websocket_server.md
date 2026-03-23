---
fest_type: task
fest_id: 04_design_websocket_server.md
fest_name: design websocket server
fest_parent: 01_coordinator_websocket
fest_order: 4
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-22T15:58:29.12355-06:00
fest_updated: 2026-03-22T16:15:49.311855-06:00
fest_tracking: true
---


# Task: Design WebSocket Server

## Objective

Design the WebSocket server architecture for the coordinator — define the interfaces, package structure, and integration points with the existing coordinator codebase.

## Requirements

- [ ] Define a `Hub` interface with `Broadcast(event DaemonEvent)`, `RegisterClient(conn)`, `UnregisterClient(conn)`
- [ ] Define the `DaemonEvent` struct matching what the dashboard expects (type, agentId, agentName, timestamp, payload)
- [ ] Determine where the Hub is instantiated in the coordinator's main.go
- [ ] Document the WebSocket message format (JSON, one event per message)

## Implementation

1. Read `projects/agent-coordinator/cmd/coordinator/main.go` to understand current startup flow
2. Read `projects/dashboard/src/lib/data/types.ts` for the `DaemonEvent` type definition the dashboard expects
3. Create a new package `internal/hub` in agent-coordinator with:
   - `hub.go` — Hub struct, client management, broadcast loop
   - `server.go` — HTTP server with /ws and /health endpoints
   - `types.go` — DaemonEvent struct matching dashboard expectations
4. The Hub should be created in main.go and passed to agents that need to publish events

## Done When

- [ ] All requirements met
- [ ] Hub interface defined with clear method signatures
- [ ] DaemonEvent struct matches dashboard TypeScript types exactly
- [ ] Package structure documented and ready for implementation