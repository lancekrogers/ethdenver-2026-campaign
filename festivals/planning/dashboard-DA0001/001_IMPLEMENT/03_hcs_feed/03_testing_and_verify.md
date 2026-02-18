---
fest_type: task
fest_id: 03_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 03_hcs_feed
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 03 | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Verify the HCS Feed panel component works correctly through testing. Focus on message rendering, auto-scroll behavior, filtering, and connection status.

## Requirements

- [ ] All unit tests pass
- [ ] Auto-scroll and scroll-lock behavior verified
- [ ] Message filtering works correctly
- [ ] Timestamp parsing handles Hedera format

## Test Categories

### Unit Tests

```bash
cd $(fgo) && npm test -- --testPathPattern="HCSFeed|MessageTypeBadge"
```

**Specific tests to write or verify:**

1. **MessageTypeBadge tests**:
   - Renders correct colors for each message type
   - Replaces underscores with spaces in display text

2. **HCSFeed tests** (`src/components/panels/__tests__/HCSFeed.test.tsx`):
   - Loading state: renders skeleton when isLoading=true
   - Empty state: renders "No HCS messages" when messages array is empty
   - Error state: renders error message
   - Data state: renders correct number of message rows
   - Message row: displays timestamp, sender, type badge, and payload
   - Timestamp parsing: correctly formats Hedera consensus timestamps (seconds.nanoseconds)
   - Connection indicator: shows correct state (connected/disconnected/error)
   - Filtering: hiding a message type removes those messages from the list
   - Filtering: re-enabling a type shows those messages again

### Manual Verification

1. [ ] **Auto-scroll**: Render with messages arriving every second. Verify feed scrolls down automatically.
2. [ ] **Scroll-lock**: Scroll up while messages arrive. Verify feed stops auto-scrolling.
3. [ ] **New messages indicator**: While scroll-locked, verify "N new messages" button appears.
4. [ ] **Resume scroll**: Click "new messages" button, verify feed scrolls to bottom and resumes auto-scroll.
5. [ ] **Filter**: Open filter dropdown, uncheck "heartbeat". Verify heartbeat messages disappear from feed.
6. [ ] **Large message set**: Load 500+ messages, verify rendering performance is acceptable.

## Coverage Requirements

- Minimum coverage: 70% for new component code

## Error Handling Verification

- [ ] Component does not crash with empty messages array
- [ ] Component handles messages with missing fields gracefully
- [ ] Invalid timestamps do not crash the component
- [ ] Malformed payload JSON displays gracefully (show raw text)

## Definition of Done

- [ ] All automated tests pass
- [ ] Manual verification complete
- [ ] Coverage meets requirement
- [ ] Error handling verified
- [ ] No regressions

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Manual tests: [ ] Pass / [ ] Fail
- Coverage: ____%
