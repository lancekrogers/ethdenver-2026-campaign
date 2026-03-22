---
fest_type: sequence
fest_id: 05_docker_integration
fest_name: docker integration
fest_parent: 001_IMPLEMENT
fest_order: 5
fest_status: completed
fest_created: 0001-01-01T00:00:00Z
fest_updated: 2026-03-22T16:29:10.730115-06:00
fest_tracking: true
fest_working_dir: .
---


# Sequence Goal: 05_docker_integration

**Sequence:** 05_docker_integration | **Phase:** 001_IMPLEMENT | **Status:** Pending

## Sequence Objective

**Primary Goal:** Update docker-compose.yml and justfiles so `just demo up` starts the complete agent stack (coordinator with WebSocket, all agents with mocked externals, mock daemon, dashboard) with a single command.

**Contribution to Phase Goal:** Without Docker integration, the demo requires manual process management. `just demo up` must be the single command that proves the system works.

## Success Criteria

### Required Deliverables

- [ ] **docker-compose.yml updated**: Demo profile starts all services with mock env vars
- [ ] **Justfile rebuild**: `just demo up` rebuilds changed images before starting
- [ ] **Single command**: `just demo up` → all services running → dashboard shows real agent data

### Completion Criteria

- [ ] `just demo up` starts all services and dashboard is accessible on :3000
- [ ] `just demo down` cleanly stops everything
- [ ] `just demo status` shows all services healthy

## Dependencies

### Prerequisites

- All previous sequences (01-04): WebSocket server, mocks, event routing must be implemented

### Provides

- Working demo stack: Used by 06_end_to_end_verification