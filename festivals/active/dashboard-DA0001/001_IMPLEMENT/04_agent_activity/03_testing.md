---
fest_type: gate
fest_id: 03_testing.md
fest_name: Testing and Verification
fest_parent: 04_agent_activity
fest_order: 3
fest_status: pending
fest_gate_type: testing
fest_created: 2026-02-18T14:21:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 03 | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Verify the Agent Activity panel works correctly. Focus on agent card rendering, heartbeat indicator, status transitions, and formatting utilities.

## Test Categories

### Unit Tests

```bash
cd $(fgo) && npm test -- --testPathPattern="AgentActivity|formatTime"
```

**Specific tests:**

1. **formatTime utilities**: formatUptime for 0s, 45s, 90s, 3661s, 90000s. formatTimeAgo for 5s ago, 120s ago, future timestamp.
2. **AgentActivity**: Loading/empty/data states. Agent ordering (coordinator, inference, defi). Missing agent placeholder. Status indicators (running=green, error=red). Current task display and "No active task" state. Error count display.

### Manual Verification

1. [ ] **Three cards**: Render with mock data, verify correct display.
2. [ ] **Heartbeat updates**: Watch 30+ seconds, verify time ago updates and color transitions (green -> yellow -> red).
3. [ ] **Error state**: Agent with status='error', verify red border and error message.
4. [ ] **Idle state**: Agent with status='idle', verify yellow status and "No active task".
5. [ ] **Large uptime**: 172800 seconds (2 days), verify "2d 0h" format.

## Coverage Requirements

- Minimum coverage: 70% for new code

## Error Handling Verification

- [ ] Empty agents array handled
- [ ] Invalid timestamp in lastHeartbeat handled
- [ ] Negative uptimeSeconds handled (display "0s")

## Definition of Done

- [ ] All tests pass, manual verification complete, coverage met

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Manual tests: [ ] Pass / [ ] Fail
- Coverage: ____%
