---
fest_type: task
fest_id: 01_update_docker_compose_for_demo_mode_agents.md
fest_name: update docker compose for demo mode agents
fest_parent: 05_docker_integration
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_tracking: true
---

# Task: Update Docker Compose for Demo Mode Agents

## Objective

Update docker-compose.yml so the demo profile starts all agents with mock external dependencies enabled.

## Requirements

- [ ] Demo profile starts: dashboard, coordinator (with WS), agent-defi, agent-inference, cre-bridge, mock-daemon
- [ ] All mock env vars set to true in demo profile (DEFI_MOCK_MODE, MOCK_HCS, ZG_MOCK_MODE)
- [ ] Dashboard built with NEXT_PUBLIC_USE_MOCK=false (since real agents are running — no need for client-side synthetic data)
- [ ] Coordinator healthcheck updated to check /health on :8080
- [ ] Service dependencies ensure coordinator starts before agents, mock-daemon starts before vault-dependent agents

## Implementation

1. Update coordinator service to expose port 8080
2. Add mock-daemon service to agents profile
3. Set all mock env vars in agent services for demo profile
4. Change dashboard NEXT_PUBLIC_USE_MOCK default to false when agents profile is active
5. Add depends_on with healthcheck conditions

## Done When

- [ ] All requirements met
- [ ] `docker compose --profile agents --profile chainlink config` shows correct env vars for demo mode
- [ ] All services start in dependency order
