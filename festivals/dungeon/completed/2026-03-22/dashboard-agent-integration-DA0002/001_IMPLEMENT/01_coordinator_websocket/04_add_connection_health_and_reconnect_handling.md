---
fest_type: task
fest_id: 01_add_connection_health_and_reconnect_handling.md
fest_name: add connection health and reconnect handling
fest_parent: 01_coordinator_websocket
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-22T15:58:29.174288-06:00
fest_updated: 2026-03-22T16:16:59.280617-06:00
fest_tracking: true
---


# Task: Add Connection Health and Reconnect Handling

## Objective

Add ping/pong keepalive to WebSocket connections and ensure the dashboard can reconnect after coordinator restart.

## Requirements

- [ ] Server sends ping frames every 30s to each client
- [ ] Clients that don't respond to ping within 10s are disconnected
- [ ] Hub logs client connect/disconnect events for observability
- [ ] Connection count available via /health endpoint (JSON: `{"status":"ok","clients":N}`)

## Implementation

1. In the client read pump, set pong handler and read deadline (40s)
2. In the client write pump, send ping every 30s using a ticker
3. On pong received, reset read deadline
4. In /health handler, return client count from hub.ClientCount()
5. Add structured logging (slog) for connect/disconnect events with client address

## Done When

- [ ] All requirements met
- [ ] Idle connections are cleaned up after 40s without pong
- [ ] /health returns client count
- [ ] Dashboard auto-reconnects after coordinator restart (verify with existing dashboard reconnect logic)