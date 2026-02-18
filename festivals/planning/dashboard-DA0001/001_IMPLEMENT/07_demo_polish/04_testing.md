---
fest_type: gate
fest_id: 04_testing.md
fest_name: Testing and Verification
fest_parent: 07_demo_polish
fest_order: 4
fest_status: pending
fest_gate_type: testing
fest_created: 2026-02-18T14:21:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 04 | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Verify the complete integrated dashboard works correctly. This is the final testing gate covering layout, mock data, panel integration, and end-to-end data flow.

## Test Categories

### Unit Tests

Run all tests across the project:

```bash
cd $(fgo) && npm test
```

All tests must pass. Zero failures.

### Integration Verification

1. [ ] DashboardLayout renders all 5 panels without errors
2. [ ] Mock mode: all panels receive and display data with `NEXT_PUBLIC_USE_MOCK=true`
3. [ ] An error in one panel does not crash the entire dashboard

### Manual Verification

1. [ ] **Start in mock mode**: `NEXT_PUBLIC_USE_MOCK=true npm run dev`
2. [ ] **Festival View**: Tree view with expandable phases and sequences
3. [ ] **HCS Feed**: Messages appear and auto-scroll works
4. [ ] **Agent Activity**: Three agent cards with heartbeat indicators
5. [ ] **DeFi P&L**: Chart renders, summary cards show values, trade table populated
6. [ ] **Inference Metrics**: Gauge, storage bar, iNFT card, job table
7. [ ] **Layout**: All panels fit in grid without overlap or overflow
8. [ ] **Dark theme**: All text readable, no white backgrounds, consistent styling
9. [ ] **Header**: Shows "Agent Economy Observer" with mock mode indicator
10. [ ] **Mock updates**: Data updates periodically (new messages, heartbeat changes)

### Build Verification

```bash
cd $(fgo) && npm run build
```

Build must succeed without errors.

## Coverage Requirements

- Overall project coverage: 60% minimum

## Error Handling Verification

- [ ] Dashboard does not crash when data is null/empty
- [ ] Individual panel errors do not break the whole dashboard
- [ ] Connection state changes reflected in UI

## Definition of Done

- [ ] All automated tests pass (zero failures)
- [ ] All 10 manual verification items checked
- [ ] Build succeeds
- [ ] Coverage meets 60% requirement

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail (count: ___ passed, ___ failed)
- Manual tests: [ ] Pass / [ ] Fail (10/10 items)
- Build: [ ] Pass / [ ] Fail
- Coverage: ____%
