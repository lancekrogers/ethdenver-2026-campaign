---
fest_type: task
fest_id: 02_implement_panel.md
fest_name: implement_panel
fest_parent: 05_defi_pnl
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement DeFi P&L Panel

**Task Number:** 02 | **Sequence:** 05_defi_pnl | **Autonomy:** medium

## Objective

Build the DeFi P&L panel component at `src/components/panels/DeFiPnL.tsx`. This component renders a revenue vs costs line chart, P&L summary cards, and a trade history table. It follows the design from the previous task.

## Requirements

- [ ] Install Recharts as a dependency
- [ ] Create `src/components/panels/DeFiPnL.tsx` as the main component
- [ ] Implement PnLChart sub-component using Recharts
- [ ] Implement SummaryCards sub-component with five metric cards
- [ ] Implement TradeTable sub-component with scrollable trade history
- [ ] Handle loading, empty, and error states
- [ ] Style with Tailwind CSS dark theme

## Implementation

### Step 1: Install Recharts

From the dashboard project root:

```bash
cd $(fgo) && npm install recharts
```

Recharts is a React-native charting library built on D3. It provides the `LineChart`, `Line`, `XAxis`, `YAxis`, `CartesianGrid`, `Tooltip`, `Legend`, and `ResponsiveContainer` components needed for the P&L chart.

Verify installation:

```bash
cd $(fgo) && grep recharts package.json
```

### Step 2: Implement SummaryCards sub-component

**Props:**
- `summary: PnLSummary | null`

**Implementation:**

Render a grid of five metric cards:

1. **Revenue card:**
   - Value: `$${summary.totalRevenue.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
   - Color: `text-green-400`
   - Label: "Revenue"

2. **Costs card:**
   - Value: formatted same as revenue
   - Color: `text-red-400`
   - Label: "Costs"

3. **Net P&L card:**
   - Value: formatted with + or - prefix
   - Color: `text-green-400` if positive, `text-red-400` if negative
   - Label: "Net P&L"

4. **Trade count card:**
   - Value: `summary.tradeCount`
   - Color: `text-white`
   - Label: "Trades"

5. **Win rate card:**
   - Value: `${summary.winRate.toFixed(1)}%`
   - Color: green if > 60, yellow if 40-60, red if < 40
   - Label: "Win Rate"

Container: `grid grid-cols-5 gap-2`
Each card: `bg-gray-800 rounded-lg p-3 text-center`

When summary is null, render skeleton cards with `animate-pulse`.

### Step 3: Implement PnLChart sub-component

**Props:**
- `data: PnLDataPoint[]`

**Implementation using Recharts:**

```typescript
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
```

Chart structure:
```tsx
<ResponsiveContainer width="100%" height={200}>
  <LineChart data={data} margin={{ top: 5, right: 20, left: 10, bottom: 5 }}>
    <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
    <XAxis
      dataKey="timestamp"
      tickFormatter={(ts: string) => new Date(ts).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}
      stroke="#6b7280"
      tick={{ fontSize: 11 }}
    />
    <YAxis
      tickFormatter={(val: number) => `$${val}`}
      stroke="#6b7280"
      tick={{ fontSize: 11 }}
    />
    <Tooltip
      contentStyle={{ backgroundColor: '#1f2937', border: '1px solid #374151', borderRadius: '8px' }}
      labelFormatter={(ts: string) => new Date(ts).toLocaleString()}
      formatter={(value: number, name: string) => [`$${value.toFixed(2)}`, name]}
    />
    <Legend />
    <Line
      type="monotone"
      dataKey="cumulativeRevenue"
      stroke="#22c55e"
      name="Revenue"
      dot={false}
      strokeWidth={2}
    />
    <Line
      type="monotone"
      dataKey="cumulativeCosts"
      stroke="#ef4444"
      name="Costs"
      dot={false}
      strokeWidth={2}
    />
    <Line
      type="monotone"
      dataKey="cumulativeProfit"
      stroke="#3b82f6"
      name="Net Profit"
      dot={false}
      strokeWidth={2}
      strokeDasharray="5 5"
    />
  </LineChart>
</ResponsiveContainer>
```

When data array is empty, render a placeholder: "Chart will appear when trading data is available."

### Step 4: Implement TradeTable sub-component

**Props:**
- `trades: Trade[]`

**Implementation:**

1. **Container**: `overflow-y-auto max-h-[200px]`

2. **Table header**: `<thead>` with sticky header:
   ```
   <tr className="text-xs text-gray-500 uppercase tracking-wider border-b border-gray-700 sticky top-0 bg-gray-900">
   ```
   Columns: Pair, Side, Amount, Price, P&L, Gas, Time

3. **Table rows**: Map over trades (sorted by timestamp descending, limited to 50):
   ```tsx
   {trades.slice(0, 50).map(trade => (
     <tr key={trade.id} className="text-sm text-gray-300 border-b border-gray-800 hover:bg-gray-800/50">
       <td>{trade.pair}</td>
       <td className={trade.side === 'buy' ? 'text-green-400' : 'text-red-400'}>
         {trade.side.toUpperCase()}
       </td>
       <td className="text-right font-mono">{trade.amount.toFixed(4)}</td>
       <td className="text-right font-mono">${trade.price.toLocaleString()}</td>
       <td className={`text-right font-mono ${trade.pnl >= 0 ? 'text-green-400' : 'text-red-400'}`}>
         {trade.pnl >= 0 ? '+' : ''}${trade.pnl.toFixed(2)}
       </td>
       <td className="text-right font-mono text-gray-500">${trade.gasCost.toFixed(4)}</td>
       <td className="text-right text-gray-500">
         {new Date(trade.timestamp).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}
       </td>
     </tr>
   ))}
   ```

4. **Empty table**: If no trades, show a row spanning all columns: "No trades recorded yet."

### Step 5: Implement the main DeFiPnL component

**Panel container**: `bg-gray-900 rounded-lg border border-gray-800 p-4 flex flex-col`

**Layout:**
1. **Panel header**: "DeFi P&L (Base)" title with connection indicator
2. **Summary cards**: SummaryCards component at the top
3. **Chart section**: Label "Revenue vs Costs" then PnLChart component
4. **Trade table section**: Label "Recent Trades" then TradeTable component

**Spacing**: Use `space-y-4` for vertical spacing between sections

**Loading state**: Skeleton summary cards, skeleton chart area, skeleton table rows

**Empty state**: "No trading data available" with sub-text

**Error state**: Panel header with error message

### Step 6: Verify compilation

```bash
npx tsc --noEmit
```

Must pass with zero errors. Recharts has its own type definitions included.

## Critical Constraints

- **READ-ONLY**: This component only displays trading data. It never executes trades, approves transactions, or interacts with the Base chain.
- **Chart Performance**: Recharts handles reasonable data sizes well. If chartData exceeds 1000 points, downsample before rendering (e.g., take every Nth point).
- **Currency Formatting**: Always use `toFixed(2)` for dollar amounts and `toLocaleString()` for large numbers. No floating point display artifacts.

## Done When

- [ ] Recharts installed as a dependency
- [ ] `src/components/panels/DeFiPnL.tsx` exists and exports the DeFiPnL component
- [ ] Summary cards display revenue, costs, net P&L, trade count, and win rate
- [ ] Line chart renders revenue and costs lines with proper styling
- [ ] Chart tooltip shows formatted values on hover
- [ ] Trade history table displays recent trades with correct formatting
- [ ] Buy/sell sides are color-coded (green/red)
- [ ] P&L values are color-coded (green for profit, red for loss)
- [ ] Loading, empty, and error states render correctly
- [ ] Dark theme styling throughout
- [ ] `npx tsc --noEmit` passes with zero errors
- [ ] No file exceeds 500 lines
