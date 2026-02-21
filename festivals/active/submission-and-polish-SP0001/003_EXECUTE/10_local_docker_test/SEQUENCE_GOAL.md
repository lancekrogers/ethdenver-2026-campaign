---
fest_type: sequence
fest_id: 10_local_docker_test
fest_name: local_docker_test
fest_parent: 003_EXECUTE
fest_order: 10
fest_status: pending
fest_created: 2026-02-21T12:58:13-07:00
fest_tracking: true
---

# Sequence Goal: 10_local_docker_test

**Sequence:** 10_local_docker_test | **Phase:** 003_EXECUTE | **Status:** Pending | **Created:** 2026-02-21T12:58:13-07:00

## Sequence Objective

**Primary Goal:** Containerize all services (3 Go agents + dashboard) and verify they build, start, and communicate correctly via Docker Compose before deploying to any external environment.

**Contribution to Phase Goal:** This sequence bridges the gap between local/testnet development and deployment. By validating that all services containerize and orchestrate correctly, we ensure the system is deployment-ready before the 004_SUBMIT phase begins deployment work.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Dockerfiles**: Multi-stage Dockerfiles for agent-coordinator, agent-defi, agent-inference, and dashboard
- [ ] **docker-compose.yml**: Compose file orchestrating all 4 services with env vars, networking, and health checks
- [ ] **Local verification**: All services build as images, start in containers, and pass basic connectivity checks

### Quality Standards

- [ ] **Image size**: Multi-stage builds produce minimal runtime images (no Go toolchain in final image)
- [ ] **Health checks**: Each service has a Docker health check that validates it is running and responsive

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_dockerfiles.md | Create multi-stage Dockerfiles for all 4 services | Enables containerized builds for each service |
| 02_docker_compose.md | Create docker-compose.yml orchestrating all services | Defines the local orchestration topology |
| 03_local_verify.md | Build, start, and verify all containers work together | Validates the full containerized stack end-to-end |

## Dependencies

### Prerequisites (from other sequences)

- 01_dashboard_verify through 09_hedera_track4_package: All services should be buildable and functional before containerizing

### Provides (to other sequences)

- **Deployment-ready containers**: Used by 004_SUBMIT deployment sequences as the basis for cloud deployment

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Agents require testnet credentials at runtime | High | Low | Use .env file for Hedera credentials; Docker validates build + startup, not full E2E |
| Dashboard build fails in container | Low | Med | Dashboard already verified in sequence 01; Dockerfile mirrors verified build steps |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: All 4 Dockerfiles created and building successfully
- [ ] **Milestone 2**: docker-compose.yml orchestrates all services with health checks
- [ ] **Milestone 3**: Full stack starts locally, agents connect to testnet, dashboard connects to coordinator WebSocket
