---
fest_type: sequence
fest_id: 07_deploy
fest_name: deploy
fest_parent: 003_EXECUTE
fest_order: 7
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 07_deploy

**Sequence:** 07_deploy | **Phase:** 003_EXECUTE | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Deploy all three agents to testnet running persistently and deploy the dashboard to a hosting platform with a public URL, so judges can observe live system behavior.

**Contribution to Phase Goal:** This sequence makes the system observable and verifiable by judges. Running agents and a live dashboard are the strongest evidence that the system works. Without this deployment, all documentation is theoretical.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Running Agents**: Coordinator, inference, and defi agents running persistently on testnet
- [ ] **Agent Heartbeats**: All agents producing HCS heartbeat messages at regular intervals
- [ ] **Active Trading**: DeFi agent executing trades and HTS payments settling
- [ ] **Deployed Dashboard**: Dashboard accessible via public URL with WebSocket endpoint configured
- [ ] **Live Data**: All 5 dashboard panels showing real-time agent activity

### Quality Standards

- [ ] Agents survive for at least 1 hour without manual intervention
- [ ] Dashboard loads within 3 seconds
- [ ] WebSocket connection establishes and maintains without frequent disconnects
- [ ] All dashboard panels populate with data within 10 seconds of loading

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_link_project.md | Link back to agent-coordinator for deployment | Enables `fgo` navigation for deployment tasks |
| 02_deploy_agents.md | Deploy all 3 agents to testnet | Makes agents observable by judges |
| 03_deploy_dashboard.md | Deploy dashboard to hosting | Provides public URL for judge access |
| 04_testing_and_verify.md | Quality gate: testing | Verifies deployments are stable and accessible |
| 05_code_review.md | Quality gate: code review | Reviews deployment configuration and stability |
| 06_review_results_iterate.md | Quality gate: iterate | Addresses findings and confirms readiness |

## Dependencies

### Prerequisites (from other sequences)

- 01_e2e_testing: Validates system works before deployment
- 02-06 packaging sequences: READMEs updated with deployment URLs after this sequence

### Provides (to other sequences)

- **Public Dashboard URL**: Used in all bounty submission forms and demo video
- **Running Agents**: Required for demo recording in 08_demo_video

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Hosting platform issues | Low | High | Have backup platform ready (Vercel, Railway, or similar) |
| Agent crashes during judging | Medium | High | Implement process supervisor, health checks, and auto-restart |
| Testnet congestion | Low | Medium | Monitor gas prices, have sufficient testnet funds |
