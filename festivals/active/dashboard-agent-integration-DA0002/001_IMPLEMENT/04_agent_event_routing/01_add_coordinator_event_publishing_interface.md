---
fest_type: task
fest_id: 01_add_coordinator_event_publishing_interface.md
fest_name: add coordinator event publishing interface
fest_parent: 04_agent_event_routing
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_tracking: true
---

# Task: Add Coordinator Event Publishing Interface

## Objective

Define the Publisher interface that all agents and the coordinator itself use to emit DaemonEvents to the WebSocket hub.

## Requirements

- [ ] `Publisher` interface: `Publish(ctx context.Context, event DaemonEvent) error`
- [ ] Hub implements Publisher by sending to its broadcast channel
- [ ] Coordinator publishes festival_progress events through the Publisher (in addition to HCS)
- [ ] Publisher is injected into agent runners via dependency injection

## Implementation

1. Define `Publisher` interface in `internal/hub/types.go`
2. Hub implements Publisher: `func (h *Hub) Publish(ctx context.Context, event DaemonEvent) error { h.broadcast <- event; return nil }`
3. In main.go, pass the Hub as Publisher to the coordinator's festival progress loop
4. The coordinator already publishes festival_progress to HCS — add a parallel call to Publisher.Publish()

## Done When

- [ ] All requirements met
- [ ] Coordinator publishes festival_progress events to both HCS and WebSocket hub
- [ ] Publisher interface is available for other agents to use
