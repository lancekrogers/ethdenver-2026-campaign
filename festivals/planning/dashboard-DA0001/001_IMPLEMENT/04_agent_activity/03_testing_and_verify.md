---
fest_type: task
fest_id: 03_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 04_agent_activity
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 03 | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Verify the Agent Activity panel component works correctly through testing. Focus on agent card rendering, heartbeat indicator behavior, status transitions, and formatting utilities.

## Requirements

- [ ] All unit tests pass
- [ ] Agent cards render correctly for all status states
- [ ] Heartbeat indicator updates correctly
- [ ] Time formatting utilities work for edge cases

## Test Categories

### Unit Tests

```bash
cd $(fgo) && npm test -- --testPathPattern="AgentActivity|formatTime"
```

**Specific tests to write or verify:**

1. **formatTime utility tests** (`src/lib/utils/__tests__/formatTime.test.ts`):
   - formatUptime: 0 seconds -> "0s"
   - formatUptime: 45 seconds -> "45s"
   - formatUptime: 90 seconds -> "1m 30s"
   - formatUptime: 3661 seconds -> "1h 1m"
   - formatUptime: 90000 seconds -> "1d 1h"
   - formatTimeAgo: timestamp 5 seconds ago -> "5s ago"
   - formatTimeAgo: timestamp 120 seconds ago -> "2m ago"
   - formatTimeAgo: future timestamp -> "just now"

2. **AgentActivity tests** (`src/components/panels/__tests__/AgentActivity.test.tsx`):
   - Loading state: renders three skeleton cards
   - Empty state: renders "Waiting for agents" when agents array is empty
   - Data state: renders three cards when three agents provided
   - Agent ordering: coordinator card is first, inference second, defi third
   - Missing agent: renders placeholder for agents not in the array
   - Status display: running agent shows green indicator
   - Status display: error agent shows red border and error message
   - Current task: displays task name when present
   - Current task: shows "No active task" when null
   - Error count: shows count in red when > 0

### Manual Verification

1. [ ] **Three cards**: Render with mock data for all three agents. Verify cards display correctly.
2. [ ] **Heartbeat updates**: Provide an agent with lastHeartbeat = now. Watch for 30+ seconds. Verify time ago updates and color transitions from green to yellow to red.
3. [ ] **Error state**: Provide an agent with status='error' and lastError='Connection timeout'. Verify red border and error message.
4. [ ] **Idle state**: Provide an agent with status='idle' and no currentTask. Verify yellow status and "No active task".
5. [ ] **Large uptime**: Provide an agent with uptimeSeconds=172800 (2 days). Verify "2d 0h" displays.

## Coverage Requirements

- Minimum coverage: 70% for new code

## Error Handling Verification

- [ ] Component does not crash with empty agents array
- [ ] Component handles agents with missing fields gracefully
- [ ] Invalid timestamp in lastHeartbeat does not crash the component
- [ ] Negative uptimeSeconds handled gracefully (display "0s")

## Definition of Done

- [ ] All automated tests pass
- [ ] Manual verification complete
- [ ] Coverage meets requirement
- [ ] Error handling verified

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Manual tests: [ ] Pass / [ ] Fail
- Coverage: ____%
