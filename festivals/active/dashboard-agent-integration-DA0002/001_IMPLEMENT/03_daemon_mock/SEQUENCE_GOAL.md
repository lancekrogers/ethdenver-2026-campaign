---
fest_type: sequence
fest_id: 03_daemon_mock
fest_name: daemon mock
fest_parent: 001_IMPLEMENT
fest_order: 3
fest_status: pending
fest_created: 2026-03-22T15:58:02.57287-06:00
fest_tracking: true
fest_working_dir: "projects/agent-coordinator"
---

# Sequence Goal: 03_daemon_mock

**Sequence:** 03_daemon_mock | **Phase:** 001_IMPLEMENT | **Status:** Pending

## Sequence Objective

**Primary Goal:** Create a lightweight mock obey daemon that responds to gRPC ping and session create requests in demo mode, so agents that depend on the daemon don't fail at startup.

**Contribution to Phase Goal:** The vault-agent and other agents use the obey daemon for session management. In demo mode we don't want to pollute real sessions, so a mock daemon responds with success but doesn't create real sessions.

## Success Criteria

### Required Deliverables

- [ ] **Mock gRPC server**: Listens on /tmp/obey-mock.sock (or configurable path), responds to Ping and SessionCreate RPCs
- [ ] **Ping response**: Returns success with daemon version info
- [ ] **SessionCreate response**: Returns a fake session ID without starting a real agent session
- [ ] **Docker service**: Runs as a container in demo profile

### Quality Standards

- [ ] **Protocol compatibility**: Uses the same protobuf definitions as the real obey daemon
- [ ] **Startup time**: Mock daemon starts in <1 second

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Agents start cleanly with mock daemon in demo mode
- [ ] Real obey daemon is used in live mode (mock daemon not started)

## Dependencies

### Prerequisites

- None (can be built independently)

### Provides

- Mock daemon service: Used by 04_agent_event_routing so vault-agent can run in demo mode
- Docker service: Used by 05_docker_integration for demo stack
