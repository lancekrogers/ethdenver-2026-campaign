---
fest_type: task
fest_id: 01_ensure_just_demo_up_starts_full_agent_stack.md
fest_name: ensure just demo up starts full agent stack
fest_parent: 05_docker_integration
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 0001-01-01T00:00:00Z
fest_updated: 2026-03-22T16:28:54.862347-06:00
fest_tracking: true
---


# Task: Ensure just demo up Starts Full Agent Stack

## Objective

Make `just demo up` start the complete demo stack — dashboard, coordinator with WebSocket, all agents with mocks, CRE bridge, mock daemon — with a single command.

## Requirements

- [ ] `just demo up` starts all services with `--profile agents --profile chainlink`
- [ ] Dashboard connects to coordinator's WebSocket (ws://coordinator:8080/ws)
- [ ] No manual steps needed after `just demo up` — all panels populate automatically
- [ ] `just demo down` stops everything cleanly

## Implementation

1. Update `.justfiles/demo.just` `up` recipe:
   - Add `--profile agents` to docker compose command
   - Add `--build` to ensure fresh images
   - Remove the separate CRE bridge startup step (it should start as part of the profile)
   - Wait for coordinator healthcheck instead of CRE bridge
2. Update `down` recipe to include all profiles
3. Update `status` recipe to show all services

## Done When

- [ ] All requirements met
- [ ] `just demo up` → wait → all 7 dashboard panels showing data
- [ ] `just demo down` → all containers stopped and removed