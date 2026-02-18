---
fest_type: gate
fest_id: 03_testing.md
fest_name: Testing and Verification
fest_parent: 05_defi_pnl
fest_order: 3
fest_status: pending
fest_gate_type: testing
fest_created: 2026-02-18T14:21:00-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 03 | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Verify the DeFi P&L panel works correctly. Focus on summary card calculations, chart rendering, trade table formatting, and currency display.

## Test Categories

### Unit Tests

```bash
cd $(fgo) && npm test -- --testPathPattern="DeFiPnL"
```

**Specific tests:**

1. **SummaryCards**: Correct currency formatting. Green/red for positive/negative net P&L. Win rate percentage. Null summary shows skeleton.
2. **TradeTable**: Correct row count (up to 50). Buy=green, sell=red. P&L color coding. Empty trades message.
3. **DeFiPnL integration**: Loading/empty/error states. All sub-components render with data.

### Manual Verification

1. [ ] **Chart rendering**: 20+ PnLDataPoint entries, verify revenue and costs lines.
2. [ ] **Chart tooltip**: Hover shows formatted values.
3. [ ] **Summary cards**: All five cards show correct values.
4. [ ] **Trade table scrolling**: 60 trades, verify scroll and 50 row limit.
5. [ ] **Negative net P&L**: Costs > revenue, verify red display.

## Coverage Requirements

- Minimum coverage: 70% for new component code

## Error Handling Verification

- [ ] Null summary handled
- [ ] Empty chartData handled
- [ ] Very large/small currency values formatted correctly

## Definition of Done

- [ ] All tests pass, manual verification complete, coverage met

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Manual tests: [ ] Pass / [ ] Fail
- Coverage: ____%
