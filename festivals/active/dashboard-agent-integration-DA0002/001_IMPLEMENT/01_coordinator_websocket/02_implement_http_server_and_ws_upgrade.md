---
fest_type: task
fest_id: 01_implement_http_server_and_ws_upgrade.md
fest_name: implement http server and ws upgrade
fest_parent: 01_coordinator_websocket
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-22T15:58:29.140642-06:00
fest_updated: 2026-03-22T16:16:38.274305-06:00
fest_tracking: true
---


# Task: Implement HTTP Server and WS Upgrade

## Objective

Implement the HTTP server on :8080 with WebSocket upgrade on /ws and a health endpoint on /health.

## Requirements

- [ ] HTTP server listens on configurable port (default :8080, env var WS_PORT)
- [ ] /ws endpoint upgrades to WebSocket using gorilla/websocket or nhooyr.io/websocket
- [ ] /health endpoint returns 200 OK for Docker healthcheck
- [ ] Server starts in a goroutine from main.go, respects context cancellation

## Implementation

1. Add websocket dependency to go.mod (prefer nhooyr.io/websocket for stdlib compatibility, or gorilla/websocket if already in use)
2. In `internal/hub/server.go`:
   - `func NewServer(ctx context.Context, hub *Hub, addr string) *http.Server`
   - Handler mux with /ws and /health routes
   - /ws handler: upgrade connection, register with hub, read pump in goroutine (for ping/pong), defer unregister
   - /health handler: return JSON `{"status": "ok"}`
3. In main.go: `go hub.NewServer(ctx, h, ":8080").ListenAndServe()`
4. On context cancellation, server.Shutdown() cleanly closes all connections

## Done When

- [ ] All requirements met
- [ ] Server starts on :8080 and accepts WebSocket connections
- [ ] `curl http://localhost:8080/health` returns 200
- [ ] WebSocket client can connect to ws://localhost:8080/ws