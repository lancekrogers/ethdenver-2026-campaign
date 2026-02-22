---
fest_type: sequence
fest_id: 06_docker_verify
fest_name: docker verify
fest_parent: bounty-completion-BC0001
fest_order: 6
fest_status: pending
fest_created: 2026-02-21T16:43:00.415294-07:00
fest_tracking: true
---

# Sequence Goal: 06_docker_verify

**Sequence:** 06_docker_verify | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-21T16:43:00-07:00

## Sequence Objective

**Primary Goal:** Verify that all four Docker images build cleanly, that the dashboard renders correctly in mock mode via `just demo`, and that docker-compose.yml includes healthcheck blocks for every service so the system can be reliably demonstrated and judged end-to-end.

**Contribution to Phase Goal:** Docker orchestration is the primary delivery mechanism for the multi-agent system; if images fail to build or services start in an unhealthy state, judges cannot run the demo, making all other implementation work invisible.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **All 4 Docker images build**: `just docker build-all` completes without error for coordinator, inference, defi, and dashboard images.
- [ ] **Mock mode dashboard verified**: `just demo` starts the stack and all 5 dashboard panels (agent status, economy cycle, Hedera transactions, P&L, network graph) render with mock data.
- [ ] **Healthchecks added**: docker-compose.yml contains a `healthcheck` block for each of the four services (coordinator, inference, defi, dashboard) with appropriate test commands, intervals, and retries.

### Quality Standards

- [ ] **Deterministic builds**: Each Dockerfile uses pinned base image tags (no `latest`) and multi-stage builds so images are reproducible.
- [ ] **Healthcheck correctness**: Each healthcheck uses the correct endpoint or binary check for that service (e.g., HTTP `/health` for dashboard, `grpc_health_probe` or HTTP for Go agents) and a timeout short enough to detect failures quickly.

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Documentation updated

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_verify_builds | Run `just docker build-all` and fix any Dockerfile failures | Confirms all images are buildable from a clean state |
| 02_verify_mock_mode | Run `just demo` and verify all 5 dashboard panels render | Confirms the demo experience works end-to-end without live testnet |
| 03_add_healthchecks | Add healthcheck blocks to docker-compose.yml for all 4 services | Enables Docker to report service health and makes the orchestration production-grade |

## Dependencies

### Prerequisites (from other sequences)

- Seq 01 (coordinator_schedule_wiring): Coordinator Go changes must compile so the coordinator Docker image builds correctly.
- Seq 02 (base_tx_signing): agent-defi Go changes must compile so the defi Docker image builds correctly.

### Provides (to other sequences)

- Verified Docker orchestration stack: Used by Seq 07 (readme_polish) to confirm quick-start instructions are accurate, and required by the submission phase for the live demo.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Go module cache missing in Docker build context causes slow or failed builds | Med | Med | Ensure Dockerfiles use `go mod download` as a separate layer before `COPY . .` |
| Mock mode requires env vars that are not set in the demo compose file | Low | High | Check docker-compose.demo.yml for all required `MOCK_*` env vars before running `just demo` |
| Healthcheck endpoint not implemented in one of the agents | Med | High | Verify each agent exposes a `/health` or equivalent before writing the healthcheck block |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: All 4 Docker images build successfully from a clean Docker cache
- [ ] **Milestone 2**: `just demo` shows all 5 dashboard panels populated with mock data
- [ ] **Milestone 3**: docker-compose.yml has healthcheck blocks for all 4 services and `docker compose ps` shows all services as healthy

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete
- [ ] Performance benchmarks met

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed
- [ ] Standards compliance verified

### Iteration Decision

- [ ] Need another iteration? No
- [ ] If yes, new tasks created: N/A
