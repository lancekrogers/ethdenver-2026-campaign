---
fest_type: sequence
fest_id: 05_daemon_client
fest_name: daemon_client
fest_parent: 001_IMPLEMENT
fest_order: 5
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 05_daemon_client

**Sequence:** 05_daemon_client | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Build a shared daemon client package at `pkg/daemon/` that wraps the obey daemon gRPC API. This package is imported by all three agents (coordinator + 2 worker agents) and provides a DI-friendly interface for daemon operations.

**Contribution to Phase Goal:** The daemon client is the bridge between the agent-coordinator and the obey daemon. The daemon provides the runtime environment for agents; this client package lets our agents register with the daemon, execute tasks, and send heartbeats. Without it, the coordinator and agents cannot interact with the daemon infrastructure.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Client Interface**: DI-friendly `DaemonClient` interface in `pkg/daemon/client.go` with Execute, Register, and Heartbeat methods
- [ ] **gRPC Implementation**: Concrete gRPC client wrapping the daemon proto definitions in `pkg/daemon/grpc.go`
- [ ] **Connection Management**: Proper gRPC connection lifecycle with context-aware dial and graceful shutdown

### Quality Standards

- [ ] **Context Propagation**: All client methods accept `context.Context`
- [ ] **Error Wrapping**: All errors include operation name and relevant IDs
- [ ] **DI-Friendly**: Interface defined separately from implementation; consumers depend on the interface
- [ ] **Table-Driven Tests**: Tests cover connection errors, context cancellation, and method behavior

### Completion Criteria

- [ ] All tasks completed
- [ ] Quality gates passed
- [ ] Package importable from any agent in the project

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_design_client_interface.md | Design DaemonClient interface | Establishes the contract for daemon interaction |
| 02_implement_grpc_client.md | Implement gRPC client | Delivers the concrete daemon client |
| 03_testing_and_verify.md | Test client operations | Quality gate |
| 04_code_review.md | Review code quality | Quality gate |
| 05_review_results_iterate.md | Address findings | Quality gate |

## Dependencies

### Prerequisites (from other sequences)

- **01_hcs_service**: Project linked, Go module configured
- The obey daemon proto definitions must be available (either as a dependency or vendored)

### Provides (to other sequences)

- **DaemonClient Package**: Used by 04_coordinator for daemon communication and 06_integration for E2E testing

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Daemon proto definitions not yet finalized | Medium | High | Define a minimal proto surface; iterate when daemon API stabilizes |
| gRPC version conflicts with other dependencies | Low | Medium | Pin gRPC and protobuf versions in go.mod |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: DaemonClient interface designed
- [ ] **Milestone 2**: gRPC client implementation complete
- [ ] **Milestone 3**: All quality gates passed

## Quality Gates

### Testing and Verification

- [ ] Unit tests with mock gRPC server
- [ ] Context cancellation verified

### Code Review

- [ ] DI-friendly design confirmed
- [ ] `go vet` and `staticcheck` clean

### Iteration Decision

- [ ] Need another iteration? To be determined
