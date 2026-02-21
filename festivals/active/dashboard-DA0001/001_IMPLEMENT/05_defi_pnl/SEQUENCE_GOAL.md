---
fest_type: sequence
fest_id: 05_defi_pnl
fest_name: defi_pnl
fest_parent: 001_IMPLEMENT
fest_order: 5
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 05_defi_pnl

**Sequence:** 05_defi_pnl | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Build the DeFi P&L panel component that visualizes Base chain trading performance with a revenue vs costs line chart, P&L summary cards, and a trade history table.

**Contribution to Phase Goal:** The DeFi P&L panel is one of five required dashboard panels. It shows judges the financial performance of the autonomous DeFi agent trading on Base -- total revenue, total costs, net profit, win rate, and a visual timeline of cumulative P&L. This is the panel that demonstrates the economic viability of the agent economy.

## Success Criteria

### Required Deliverables

- [ ] **DeFiPnL Component**: Working panel component at `src/components/panels/DeFiPnL.tsx`
- [ ] **P&L Chart**: Revenue vs costs line chart showing cumulative performance over time
- [ ] **Summary Cards**: Total revenue, total costs, net profit, trade count, win rate
- [ ] **Trade History**: Scrollable table of recent trades with pair, side, amount, P&L

### Quality Standards

- [ ] **TypeScript Strict Mode**: No type errors
- [ ] **Read-Only**: Component only displays trading data, never executes trades
- [ ] **Chart Library**: Use Recharts (lightweight, React-native charting library) or equivalent

### Completion Criteria

- [ ] All tasks completed
- [ ] Quality gates passed
- [ ] Code review completed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_design_component.md | Design the panel wireframe | Establishes visual and API contract |
| 02_implement_panel.md | Build the React component | Delivers the working panel |
| 03_testing_and_verify.md | Test the component | Quality gate |
| 04_code_review.md | Review code quality | Quality gate |
| 05_review_results_iterate.md | Address findings | Quality gate |

## Dependencies

### Prerequisites (from other sequences)

- **01_data_layer**: Trade, PnLSummary, PnLDataPoint types from data layer

### Provides (to other sequences)

- **DeFiPnL component**: Used by 07_demo_polish for the final dashboard layout
