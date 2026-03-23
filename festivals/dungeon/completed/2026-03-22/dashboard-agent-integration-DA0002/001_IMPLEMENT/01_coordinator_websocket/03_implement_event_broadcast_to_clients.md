---
fest_type: task
fest_id: 01_implement_event_broadcast_to_clients.md
fest_name: implement event broadcast to clients
fest_parent: 01_coordinator_websocket
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-22T15:58:29.157665-06:00
fest_updated: 2026-03-22T16:16:49.312428-06:00
fest_tracking: true
---


# Task: Implement Event Broadcast to Clients

## Objective

Implement the Hub's broadcast mechanism that sends DaemonEvent JSON to all connected WebSocket clients.

## Requirements

- [ ] `Hub.Broadcast(event DaemonEvent)` serializes event to JSON and sends to all connected clients
- [ ] Client map protected by sync.RWMutex — broadcast reads, register/unregister writes
- [ ] Slow clients are dropped (write with deadline, remove on error) — broadcast never blocks
- [ ] Hub runs a broadcast loop in its own goroutine, receiving events from a channel

## Implementation

1. In `internal/hub/hub.go`:
   - Hub struct with clients map, mutex, broadcast/register/unregister channels
   - `Hub.Run(ctx context.Context)` goroutine: select on broadcast/register/unregister/ctx.Done()
   - On broadcast: marshal event to JSON, iterate clients, write with 5s deadline, remove failed clients
2. Client struct wraps the websocket.Conn with a send channel for buffered writes
3. Each client gets a writePump goroutine that drains the send channel
4. Hub exposes `ClientCount() int` for the health endpoint

## Done When

- [ ] All requirements met
- [ ] Multiple clients can connect and all receive broadcast events
- [ ] Slow/disconnected clients are removed without blocking other clients
- [ ] No goroutine leaks on client disconnect