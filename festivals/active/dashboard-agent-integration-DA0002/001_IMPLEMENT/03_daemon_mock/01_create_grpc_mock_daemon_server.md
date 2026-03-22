---
fest_type: task
fest_id: 01_create_grpc_mock_daemon_server.md
fest_name: create grpc mock daemon server
fest_parent: 03_daemon_mock
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-22T15:58:29.12355-06:00
fest_updated: 2026-03-22T16:23:44.551573-06:00
fest_tracking: true
---


# Task: Create gRPC Mock Daemon Server

## Objective

Create a lightweight Go binary that serves the obey daemon's gRPC interface on a Unix socket, responding to health checks and session requests without creating real sessions.

## Requirements

- [ ] Implements the obey daemon's protobuf service definition (Ping, SessionCreate at minimum)
- [ ] Listens on a Unix socket (default /tmp/obey-mock.sock, configurable via OBEY_SOCKET env var)
- [ ] Starts quickly and runs indefinitely until SIGTERM
- [ ] Can be built as a standalone binary or Docker service

## Implementation

1. Check the obey daemon's proto definitions — look at how agent-defi's obey.go calls the daemon to understand the expected RPC methods
2. Create a minimal Go main package (e.g., `cmd/mock-daemon/main.go` in agent-coordinator or a standalone location)
3. Implement the gRPC server with the required service methods
4. Use `net.Listen("unix", socketPath)` for the Unix socket
5. Handle graceful shutdown on SIGTERM/SIGINT

## Done When

- [ ] All requirements met
- [ ] `obey ping --socket /tmp/obey-mock.sock` returns success
- [ ] Mock daemon binary compiles and starts in <1 second