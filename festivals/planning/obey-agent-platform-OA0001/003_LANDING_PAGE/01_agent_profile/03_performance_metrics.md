---
fest_type: task
fest_id: 03_performance_metrics.md
fest_name: performance_metrics
fest_parent: 01_agent_profile
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.415215-06:00
fest_tracking: true
---

# Task: Performance Metrics and NAV Chart Components

## Objective

Build the interactive NAV chart and performance metrics display components that show real-time agent performance data on the profile page, including period-switchable NAV charts using Recharts and a key metrics summary grid.

## Requirements

- [ ] Build `NAVChartSection` component with a Recharts `AreaChart` displaying NAV over time, using data from `useAgentNAV` hook
- [ ] Implement period toggle buttons (7d, 30d, 90d, All Time) that re-fetch NAV data for the selected period
- [ ] Build `PerformanceMetricsGrid` component displaying key stats: NAV, Total Return, Sharpe Ratio, Max Drawdown, Win Rate, Avg Holding Period
- [ ] Show a loading skeleton while data is fetching
- [ ] Handle error states gracefully with a retry mechanism
- [ ] Format large numbers with appropriate units ($142K, +42.3%, etc.)

## Implementation

### Step 1: Create number formatting utility at `src/lib/utils/formatNumber.ts`

```typescript
// src/lib/utils/formatNumber.ts

export function formatUSD(value: number): string {
  if (Math.abs(value) >= 1_000_000) {
    return `$${(value / 1_000_000).toFixed(1)}M`;
  }
  if (Math.abs(value) >= 1_000) {
    return `$${(value / 1_000).toFixed(0)}K`;
  }
  return `$${value.toLocaleString("en-US", { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`;
}

export function formatUSDFull(value: number): string {
  return `$${value.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

export function formatPercent(value: number, showSign = true): string {
  const sign = showSign && value > 0 ? "+" : "";
  return `${sign}${value.toFixed(1)}%`;
}

export function formatSharpe(value: number): string {
  return value.toFixed(1);
}
```

### Step 2: Build `NAVChartSection` at `src/components/agent/NAVChartSection.tsx`

This is a client component because it uses hooks and interactive state.

```typescript
// src/components/agent/NAVChartSection.tsx
"use client";

import { useState } from "react";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
} from "recharts";
import { useAgentNAV } from "@/hooks/useAgentNAV";
import { useAgentMetrics } from "@/hooks/useAgentMetrics";
import { PerformanceMetricsGrid } from "./PerformanceMetricsGrid";
import { formatUSDFull } from "@/lib/utils/formatNumber";
import type { NavPeriod } from "@/lib/types/agent";

interface Props {
  agentId: string;
}

const PERIODS: { label: string; value: NavPeriod }[] = [
  { label: "7D", value: "7d" },
  { label: "30D", value: "30d" },
  { label: "90D", value: "90d" },
  { label: "All Time", value: "all" },
];

function ChartSkeleton() {
  return (
    <div className="h-64 animate-pulse rounded-lg bg-gray-800" />
  );
}

function MetricsSkeleton() {
  return (
    <div className="grid grid-cols-3 gap-4 sm:grid-cols-6">
      {Array.from({ length: 6 }).map((_, i) => (
        <div key={i} className="space-y-2">
          <div className="h-3 w-16 animate-pulse rounded bg-gray-800" />
          <div className="h-6 w-20 animate-pulse rounded bg-gray-800" />
        </div>
      ))}
    </div>
  );
}

interface ChartTooltipProps {
  active?: boolean;
  payload?: Array<{ value: number }>;
  label?: string;
}

function ChartTooltip({ active, payload, label }: ChartTooltipProps) {
  if (!active || !payload?.length) return null;
  return (
    <div className="rounded-lg border border-gray-700 bg-gray-900 px-3 py-2 shadow-lg">
      <p className="text-xs text-gray-400">{label}</p>
      <p className="text-sm font-bold text-white">{formatUSDFull(payload[0].value)}</p>
    </div>
  );
}

export function NAVChartSection({ agentId }: Props) {
  const [period, setPeriod] = useState<NavPeriod>("30d");
  const { nav, loading: navLoading, error: navError } = useAgentNAV(agentId, period);
  const { metrics, loading: metricsLoading, error: metricsError } = useAgentMetrics(agentId);

  const chartData = nav?.history.map((pt) => ({
    date: new Date(pt.timestamp).toLocaleDateString("en-US", {
      month: "short",
      day: "numeric",
    }),
    nav: pt.nav,
  })) ?? [];

  return (
    <section className="mb-6 rounded-lg border border-gray-800 bg-gray-900 p-6">
      {/* Metrics Grid */}
      {metricsLoading ? (
        <MetricsSkeleton />
      ) : metricsError ? (
        <p className="mb-4 text-sm text-red-400">Failed to load metrics.</p>
      ) : metrics ? (
        <PerformanceMetricsGrid metrics={metrics} />
      ) : null}

      {/* Period Toggle */}
      <div className="mb-4 mt-6 flex items-center gap-1">
        {PERIODS.map((p) => (
          <button
            key={p.value}
            onClick={() => setPeriod(p.value)}
            className={`rounded-md px-3 py-1 text-xs font-medium transition-colors ${
              period === p.value
                ? "bg-blue-600 text-white"
                : "text-gray-400 hover:bg-gray-800 hover:text-gray-200"
            }`}
          >
            {p.label}
          </button>
        ))}
      </div>

      {/* Chart */}
      {navLoading ? (
        <ChartSkeleton />
      ) : navError ? (
        <div className="flex h-64 items-center justify-center">
          <div className="text-center">
            <p className="text-sm text-red-400">Failed to load chart data.</p>
            <button
              onClick={() => setPeriod(period)}
              className="mt-2 text-xs text-blue-400 hover:text-blue-300"
            >
              Retry
            </button>
          </div>
        </div>
      ) : (
        <ResponsiveContainer width="100%" height={256}>
          <AreaChart data={chartData}>
            <defs>
              <linearGradient id="navGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3} />
                <stop offset="95%" stopColor="#3b82f6" stopOpacity={0} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke="#1f2937" />
            <XAxis
              dataKey="date"
              tick={{ fill: "#6b7280", fontSize: 11 }}
              axisLine={{ stroke: "#374151" }}
              tickLine={false}
            />
            <YAxis
              tick={{ fill: "#6b7280", fontSize: 11 }}
              axisLine={false}
              tickLine={false}
              tickFormatter={(v: number) =>
                v >= 1000 ? `$${(v / 1000).toFixed(0)}K` : `$${v}`
              }
            />
            <Tooltip content={<ChartTooltip />} />
            <Area
              type="monotone"
              dataKey="nav"
              stroke="#3b82f6"
              strokeWidth={2}
              fill="url(#navGradient)"
            />
          </AreaChart>
        </ResponsiveContainer>
      )}
    </section>
  );
}
```

### Step 3: Build `PerformanceMetricsGrid` at `src/components/agent/PerformanceMetricsGrid.tsx`

```typescript
// src/components/agent/PerformanceMetricsGrid.tsx

import type { PerformanceMetrics } from "@/lib/types/agent";
import { formatUSD, formatPercent, formatSharpe } from "@/lib/utils/formatNumber";

interface Props {
  metrics: PerformanceMetrics;
}

export function PerformanceMetricsGrid({ metrics }: Props) {
  const items = [
    { label: "NAV", value: formatUSD(metrics.nav), color: "text-white" },
    {
      label: "Total Return",
      value: formatPercent(metrics.totalReturn),
      color: metrics.totalReturn >= 0 ? "text-green-400" : "text-red-400",
    },
    { label: "Sharpe", value: formatSharpe(metrics.sharpeRatio), color: "text-white" },
    {
      label: "Max Drawdown",
      value: formatPercent(-Math.abs(metrics.maxDrawdownPct), false),
      color: "text-red-400",
    },
    {
      label: "Win Rate",
      value: `${metrics.winRate.toFixed(0)}%`,
      color: metrics.winRate >= 50 ? "text-green-400" : "text-yellow-400",
    },
    {
      label: "Avg Holding",
      value: `${metrics.avgHoldingDays.toFixed(1)} days`,
      color: "text-white",
    },
  ];

  return (
    <div className="grid grid-cols-3 gap-4 sm:grid-cols-6">
      {items.map((item) => (
        <div key={item.label}>
          <p className="text-xs text-gray-500">{item.label}</p>
          <p className={`text-lg font-bold ${item.color}`}>{item.value}</p>
        </div>
      ))}
    </div>
  );
}
```

### Step 4: Create `useAgentMetrics` hook at `src/hooks/useAgentMetrics.ts`

```typescript
// src/hooks/useAgentMetrics.ts
"use client";

import { useState, useEffect } from "react";
import type { PerformanceMetrics } from "@/lib/types/agent";

export function useAgentMetrics(agentId: string) {
  const [metrics, setMetrics] = useState<PerformanceMetrics | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);

    fetch(`/api/v1/agents/${agentId}/metrics`)
      .then((res) => {
        if (!res.ok) throw new Error(`Failed to load metrics (${res.status})`);
        return res.json();
      })
      .then((data) => {
        if (!cancelled) {
          setMetrics(data);
          setLoading(false);
        }
      })
      .catch((err) => {
        if (!cancelled) {
          setError(err);
          setLoading(false);
        }
      });

    return () => { cancelled = true; };
  }, [agentId]);

  return { metrics, loading, error };
}
```

## Done When

- [ ] All requirements met
- [ ] `NAVChartSection` renders a Recharts `AreaChart` with NAV data, blue gradient fill, and gray grid lines
- [ ] Clicking period toggles (7D, 30D, 90D, All Time) triggers a re-fetch and re-renders the chart with the correct data range
- [ ] `PerformanceMetricsGrid` displays all 6 metrics (NAV, Total Return, Sharpe, Max Drawdown, Win Rate, Avg Holding) with color-coded values
- [ ] Loading skeletons appear during fetch, then fade into real data
- [ ] Error state shows a "Failed to load" message with a Retry button
- [ ] Large numbers are formatted correctly ($142K, +42.3%, 2.1, etc.)
- [ ] Chart tooltip shows the exact NAV value with full dollar formatting on hover
