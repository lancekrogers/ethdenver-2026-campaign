---
fest_type: task
fest_id: 03_testing_and_verify.md
fest_name: testing_and_verify
fest_parent: 02_festival_view
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 03 | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Verify the Festival View panel component works correctly through comprehensive testing. This includes the main FestivalView component, sub-components (PhaseRow, SequenceRow, TaskRow), and utility components (ProgressBar, StatusBadge).

## Requirements

- [ ] All unit tests pass
- [ ] Component renders correctly with mock data
- [ ] Error and loading states render correctly
- [ ] Expand/collapse interactions work

## Test Categories

### Unit Tests

```bash
cd $(fgo) && npm test -- --testPathPattern="FestivalView|ProgressBar|StatusBadge"
```

**Specific tests to write or verify:**

1. **ProgressBar tests** (`src/components/ui/__tests__/ProgressBar.test.tsx`):
   - Renders with 0% (empty bar)
   - Renders with 50% (half-filled, blue color)
   - Renders with 100% (full bar, green color)
   - Clamps values above 100 to 100
   - Clamps values below 0 to 0
   - Applies size variants correctly (sm/md)

2. **StatusBadge tests** (`src/components/ui/__tests__/StatusBadge.test.tsx`):
   - Renders correct text for each status (pending, active, completed, blocked, failed)
   - Applies correct CSS classes for each status

3. **FestivalView tests** (`src/components/panels/__tests__/FestivalView.test.tsx`):
   - Loading state: renders skeleton when isLoading=true and data=null
   - Error state: renders error message when error is provided
   - Empty state: renders "No festival data" when data=null and not loading
   - Data state: renders phase names from provided data
   - Data state: renders sequence names under expanded phases
   - Expand/collapse: clicking a phase toggles sequence visibility
   - Expand/collapse: clicking a sequence toggles task visibility
   - Progress bars: show correct percentages from data
   - Status badges: show correct status for tasks
   - Overall completion: header shows correct overall percentage

### Manual Verification

1. [ ] **Render with mock data**: Create a FestivalProgress object with 2 phases, 3 sequences each, and 5 tasks each. Render FestivalView and visually inspect the tree layout.
2. [ ] **Expand/collapse**: Click phases to collapse/expand sequences. Click sequences to collapse/expand tasks. Verify smooth interaction.
3. [ ] **Loading state**: Pass `isLoading={true} data={null}` and verify skeleton renders.
4. [ ] **Error state**: Pass `error={new Error("Connection failed")}` and verify error message renders.
5. [ ] **Long names**: Test with task names longer than the panel width. Verify truncation works.
6. [ ] **Dark theme**: Verify all text is readable on dark background. No white-on-white or invisible elements.

## Coverage Requirements

- Minimum coverage: 70% for new component code

```bash
cd $(fgo) && npm test -- --coverage --testPathPattern="FestivalView|ProgressBar|StatusBadge"
```

## Error Handling Verification

- [ ] Component does not crash when data is null
- [ ] Component does not crash when phases array is empty
- [ ] Component does not crash when a sequence has zero tasks
- [ ] Invalid percentage values (negative, > 100) are handled gracefully

## Definition of Done

- [ ] All automated tests pass
- [ ] Manual verification complete
- [ ] Coverage meets 70% requirement
- [ ] Error handling verified
- [ ] No regressions introduced

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Manual tests: [ ] Pass / [ ] Fail
- Coverage: ____%
