---
fest_type: sequence
fest_id: 04_agent_activity
fest_name: agent_activity
fest_parent: 001_IMPLEMENT
fest_order: 4
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 04_agent_activity

**Sequence:** 04_agent_activity | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Build the Agent Activity panel component that displays real-time status of all three agents (coordinator, inference, defi) as individual status cards with heartbeat indicators, current task display, and error state handling.

**Contribution to Phase Goal:** The Agent Activity panel is one of five required dashboard panels. It shows judges that the autonomous agents are alive and working -- each agent card provides at-a-glance status (running, idle, error), heartbeat timing, current task, and uptime. This is the panel that proves the multi-agent system is operational.

## Success Criteria

### Required Deliverables

- [ ] **AgentActivity Component**: Working panel component at `src/components/panels/AgentActivity.tsx`
- [ ] **Agent Cards**: Three status cards for coordinator, inference, and defi agents
- [ ] **Heartbeat Indicator**: Visual pulse showing last heartbeat timing
- [ ] **Task Display**: Current task name and description for each agent
- [ ] **Error State**: Clear error display when an agent enters error state

### Quality Standards

- [ ] **TypeScript Strict Mode**: No type errors
- [ ] **Read-Only**: Component only displays agent status, never sends commands
- [ ] **Responsive**: Cards layout adapts within the dashboard grid

### Completion Criteria

- [ ] All tasks completed
- [ ] Quality gates passed
- [ ] Code review completed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_design_component.md | Design agent cards wireframe | Establishes visual and API contract |
| 02_implement_panel.md | Build the React component | Delivers the working panel |
| 03_testing_and_verify.md | Test the component | Quality gate |
| 04_code_review.md | Review code quality | Quality gate |
| 05_review_results_iterate.md | Address findings | Quality gate |

## Dependencies

### Prerequisites (from other sequences)

- **01_data_layer**: AgentInfo type, useWebSocket hook (provides agent status from heartbeats)

### Provides (to other sequences)

- **AgentActivity component**: Used by 07_demo_polish for the final dashboard layout
