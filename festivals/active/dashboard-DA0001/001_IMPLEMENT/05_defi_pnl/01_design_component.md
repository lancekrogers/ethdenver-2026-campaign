---
fest_type: task
fest_id: 01_design_component.md
fest_name: design_component
fest_parent: 05_defi_pnl
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design DeFi P&L Component

**Task Number:** 01 | **Sequence:** 05_defi_pnl | **Autonomy:** medium

## Objective

Design the DeFi P&L panel that shows Base trading performance with revenue vs costs breakdown. This task produces the component wireframe, props interface, chart specification, summary card layout, and trade history table design.

## Requirements

- [ ] Define the component props interface
- [ ] Design the visual wireframe with chart, summary cards, and trade table
- [ ] Specify the chart type, axes, and data mapping
- [ ] Design the summary cards layout
- [ ] Design the trade history table columns
- [ ] Design empty, loading, and error states

## Implementation

### Step 1: Define the component props interface

```typescript
import { PnLSummary, PnLDataPoint, Trade, ConnectionState } from '@/lib/data/types';

interface DeFiPnLProps {
  /** Aggregated P&L summary */
  summary: PnLSummary | null;
  /** Time-series data for the P&L chart */
  chartData: PnLDataPoint[];
  /** Recent trades for the history table */
  trades: Trade[];
  /** Connection state of the data source */
  connectionState: ConnectionState;
  /** Whether data is loading */
  isLoading: boolean;
  /** Error from the data source */
  error: Error | null;
  /** Optional CSS class */
  className?: string;
}
```

### Step 2: Design the visual wireframe

```
+-----------------------------------------------+
| DeFi P&L (Base)                   [Connected] |
+-----------------------------------------------+
| +----------+ +----------+ +---------+         |
| | Revenue  | | Costs    | | Net P&L |         |
| | $1,234   | | $456     | | +$778   |         |
| +----------+ +----------+ +---------+         |
| +----------+ +----------+                     |
| | Trades   | | Win Rate |                     |
| | 42       | | 71.4%    |                     |
| +----------+ +----------+                     |
|                                               |
| Revenue vs Costs                              |
| $                                             |
| 1500|        ____--- Revenue                  |
| 1000|   ___--                                 |
|  500| _--      ____--- Costs                  |
|    0|__________________________________________> |
|     Jan  Feb  Mar  Apr                        |
|                                               |
| Recent Trades                                 |
| Pair    | Side | Amount | Price | P&L  | Time |
| ETH/USDC| Buy | 0.5   | 3200  | +$12 | 14:32|
| ETH/USDC| Sell | 0.3   | 3215  | +$4  | 14:28|
| ETH/USDC| Buy | 1.0   | 3190  | -$8  | 14:15|
+-----------------------------------------------+
```

### Step 3: Specify the chart

**Chart type**: Dual-line chart (using Recharts `<LineChart>`)

**Data**: Array of `PnLDataPoint` objects with timestamp, cumulativeRevenue, cumulativeCosts, cumulativeProfit

**Lines:**

- Revenue line: `stroke="#22c55e"` (green-500) with smooth curve
- Costs line: `stroke="#ef4444"` (red-500) with smooth curve
- Optional: Profit fill area between the two lines

**Axes:**

- X-axis: timestamp formatted as HH:MM or date depending on range
- Y-axis: dollar values with $ prefix
- Grid: subtle gray grid lines (`stroke="#374151"` gray-700)

**Tooltip**: On hover, show timestamp, revenue, costs, and net profit

**Legend**: Small legend below chart showing line colors and labels

**Recharts components needed:**

- `LineChart`, `Line`, `XAxis`, `YAxis`, `CartesianGrid`, `Tooltip`, `Legend`, `ResponsiveContainer`

**Chart container**: `ResponsiveContainer width="100%" height={200}`

### Step 4: Design summary cards

Five summary cards in a grid row:

1. **Total Revenue**: Dollar amount in green (`text-green-400`), label "Revenue" in gray
2. **Total Costs**: Dollar amount in red (`text-red-400`), label "Costs" in gray
3. **Net Profit**: Dollar amount in green if positive, red if negative. Label "Net P&L"
4. **Trade Count**: Plain number in white, label "Trades"
5. **Win Rate**: Percentage with color based on value (green > 60%, yellow 40-60%, red < 40%). Label "Win Rate"

Each card: `bg-gray-800 rounded-lg p-3 text-center`

- Value: `text-lg font-bold`
- Label: `text-xs text-gray-500 uppercase tracking-wider mt-1`

Layout: `grid grid-cols-5 gap-2` (or `grid-cols-3` + `grid-cols-2` for two rows)

### Step 5: Design the trade history table

**Columns:**

| Column | Width | Alignment | Format |
|--------|-------|-----------|--------|
| Pair | auto | left | e.g. "ETH/USDC" |
| Side | narrow | center | "Buy" (green) / "Sell" (red) |
| Amount | auto | right | numeric with 4 decimal places |
| Price | auto | right | $ formatted |
| P&L | auto | right | +$XX.XX (green) or -$XX.XX (red) |
| Time | narrow | right | HH:MM format |

**Table styling:**

- Header: `text-xs text-gray-500 uppercase tracking-wider border-b border-gray-700`
- Rows: `text-sm text-gray-300 border-b border-gray-800`
- Alternating row backgrounds: optional for readability
- Scrollable: `max-h-[200px] overflow-y-auto`
- Show most recent trades first (descending by timestamp)
- Limit to 50 most recent trades

### Step 6: Design loading, empty, and error states

**Loading state**: Skeleton cards and placeholder chart area with `animate-pulse`

**Empty state**: "No trading data available" with sub-text "DeFi P&L will display once the DeFi agent begins trading on Base."

**Error state**: Panel header with error message

## Done When

- [ ] Props interface defined
- [ ] Visual wireframe documented
- [ ] Chart specification complete (type, lines, axes, tooltip, library)
- [ ] Summary cards layout and formatting defined
- [ ] Trade history table columns and styling defined
- [ ] Loading, empty, and error states designed
- [ ] Recharts chosen as chart library
- [ ] Design ready for implementation
