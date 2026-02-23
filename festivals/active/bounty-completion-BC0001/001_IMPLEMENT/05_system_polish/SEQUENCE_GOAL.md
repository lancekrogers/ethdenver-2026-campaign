---
fest_type: sequence
fest_id: 05_system_polish
fest_name: system polish
fest_parent: 001_IMPLEMENT
fest_order: 5
fest_status: pending
fest_created: 2026-02-21T17:48:56.743337-07:00
fest_tracking: true
---

# Sequence Goal: 05_system_polish

**Sequence:** 05_system_polish | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-21T17:48:56-07:00

## Sequence Objective

**Primary Goal:** Fix the coordinator's missing HCS topic key configuration and add Docker healthchecks to docker-compose.yml so the full system runs reliably end-to-end.

**Contribution to Phase Goal:** Bounty judges will run `docker compose up` to verify the system works. Without healthchecks, compose can't report service health. Without the coordinator's topic key fix, HCS message submission fails silently. These are the last two infrastructure gaps blocking a clean demo.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Topic key config**: Coordinator reads `HEDERA_TOPIC_SUBMIT_KEY` from environment and passes it to HCS client, so message submission doesn't fail with "INVALID_SIGNATURE"
- [ ] **Docker healthchecks**: All 4 services in docker-compose.yml (coordinator, defi, inference, dashboard) have healthcheck blocks that docker reports as healthy

### Quality Standards

- [ ] **Coordinator builds**: `cd projects/agent-coordinator && just build` succeeds
- [ ] **Docker healthy**: `docker compose up -d && docker compose ps` shows all services as "healthy" within 60 seconds

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_coordinator_topic_keys | Add HEDERA_TOPIC_SUBMIT_KEY env loading and pass to HCS client | HCS messages authenticate correctly |
| 02_docker_healthchecks | Add healthcheck blocks to all 4 services in docker-compose.yml | `docker compose ps` shows healthy status |

## Dependencies

### Prerequisites (from other sequences)

- 01_base_agent_bugfixes: DeFi agent must build cleanly before Docker healthchecks can pass

### Provides (to other sequences)

- Working Docker orchestration: Used by 06_doc_accuracy for verifying quickstart instructions

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Healthcheck ports differ from actual service ports | Medium | Low | Read each Dockerfile to confirm exposed port before writing healthcheck |
| Topic key format mismatch (hex vs DER) | Low | Medium | Check Hedera SDK docs for expected key format |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Coordinator topic key config compiles and passes unit test
- [ ] **Milestone 2**: All 4 Docker healthchecks added and reporting healthy

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed

### Iteration Decision

- [ ] Need another iteration? No
- [ ] If yes, new tasks created: N/A
