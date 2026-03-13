---
fest_type: task
fest_id: 02_profile_page.md
fest_name: profile_page
fest_parent: 01_agent_profile
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.414972-06:00
fest_tracking: true
---

# Task: Agent Profile Page

## Objective

Build the `/agents/[id]` page that displays a full agent profile including identity, strategy description, risk parameters, recent trades, depositor stats, and a prominent "Fund This Agent" CTA.

## Requirements

- [ ] Create the `/agents/[id]` route using Next.js App Router with dynamic params
- [ ] Build an `AgentProfileHeader` component showing agent name, creator address (truncated), status badge, type, creation date, and creator ownership percentage
- [ ] Build a `StrategySection` component displaying the strategy description, strategy allocation breakdown (with percentage bars), platform badges, and accepted assets
- [ ] Build a `RiskProfileSection` component showing max drawdown limit, concentration limit, withdrawal delay, max position size, and daily loss limit
- [ ] Build a `RecentTradesTable` component showing the last 5 trades with platform, market name, side (YES/NO), entry price, and outcome, with a "View All Trades" link
- [ ] Build a `DepositorStats` component showing total depositors, pool size, avg deposit, and share token symbol
- [ ] Include a sticky "Fund This Agent" CTA button that links to the deposit flow

## Implementation

### Step 1: Create the page route at `src/app/agents/[id]/page.tsx`

```typescript
// src/app/agents/[id]/page.tsx

import type { Metadata } from "next";
import { fetchAgentProfile, fetchAgentTrades } from "@/lib/api/agent-client";
import { AgentProfileHeader } from "@/components/agent/AgentProfileHeader";
import { StrategySection } from "@/components/agent/StrategySection";
import { RiskProfileSection } from "@/components/agent/RiskProfileSection";
import { RecentTradesTable } from "@/components/agent/RecentTradesTable";
import { DepositorStats } from "@/components/agent/DepositorStats";
import { NAVChartSection } from "@/components/agent/NAVChartSection";
import { notFound } from "next/navigation";

interface PageProps {
  params: Promise<{ id: string }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { id } = await params;
  try {
    const profile = await fetchAgentProfile(id);
    return {
      title: `${profile.name} — OBEY Agent Economy`,
      description: profile.description,
    };
  } catch {
    return { title: "Agent Not Found — OBEY Agent Economy" };
  }
}

export default async function AgentProfilePage({ params }: PageProps) {
  const { id } = await params;

  let profile;
  let trades;
  try {
    [profile, trades] = await Promise.all([
      fetchAgentProfile(id),
      fetchAgentTrades(id, 1, 5),
    ]);
  } catch {
    notFound();
  }

  return (
    <main className="min-h-screen bg-gray-950 text-gray-100">
      <div className="mx-auto max-w-4xl px-4 py-8">
        <AgentProfileHeader profile={profile} />

        <NAVChartSection agentId={id} />

        <StrategySection
          description={profile.description}
          strategies={profile.strategyBreakdown}
          platforms={profile.platforms}
          acceptedAssets={profile.acceptedAssets}
        />

        <RiskProfileSection
          riskParams={profile.riskParams}
          creatorOwnershipPct={profile.creatorOwnershipPct}
        />

        <RecentTradesTable trades={trades.trades} agentId={id} />

        <DepositorStats stats={profile.depositorStats} />

        {/* Sticky CTA */}
        <div className="fixed bottom-0 left-0 right-0 border-t border-gray-800 bg-gray-950/95 p-4 backdrop-blur-sm">
          <div className="mx-auto flex max-w-4xl items-center justify-between">
            <div>
              <p className="text-sm text-gray-400">Pool Size</p>
              <p className="text-lg font-bold">
                ${profile.depositorStats.poolSize.toLocaleString()}
              </p>
            </div>
            <a
              href={`/agents/${id}/deposit`}
              className="rounded-lg bg-green-600 px-8 py-3 font-semibold text-white transition-colors hover:bg-green-500"
            >
              Fund This Agent
            </a>
          </div>
        </div>
      </div>
    </main>
  );
}
```

### Step 2: Build `AgentProfileHeader` at `src/components/agent/AgentProfileHeader.tsx`

```typescript
// src/components/agent/AgentProfileHeader.tsx

import type { AgentProfile } from "@/lib/types/agent";

interface Props {
  profile: AgentProfile;
}

function truncateAddress(addr: string): string {
  if (addr.length <= 12) return addr;
  return `${addr.slice(0, 6)}...${addr.slice(-4)}`;
}

const STATUS_COLORS: Record<string, string> = {
  active: "bg-green-500/20 text-green-400 border-green-500/30",
  paused: "bg-yellow-500/20 text-yellow-400 border-yellow-500/30",
  stopped: "bg-red-500/20 text-red-400 border-red-500/30",
};

export function AgentProfileHeader({ profile }: Props) {
  const statusClass = STATUS_COLORS[profile.status] ?? STATUS_COLORS.stopped;

  return (
    <div className="mb-8">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white">{profile.name}</h1>
          <p className="mt-1 text-sm text-gray-400">
            Creator:{" "}
            <span className="font-mono text-gray-300">
              {truncateAddress(profile.creator)}
            </span>
          </p>
          <div className="mt-2 flex items-center gap-3 text-sm text-gray-400">
            <span className="capitalize">{profile.type.replace("_", " ")}</span>
            <span>Since {new Date(profile.createdAt).toLocaleDateString("en-US", { month: "short", year: "numeric" })}</span>
            <span>Creator Ownership: {profile.creatorOwnershipPct}%</span>
          </div>
        </div>
        <span className={`rounded-full border px-3 py-1 text-xs font-medium capitalize ${statusClass}`}>
          {profile.status}
        </span>
      </div>
    </div>
  );
}
```

### Step 3: Build `StrategySection` at `src/components/agent/StrategySection.tsx`

```typescript
// src/components/agent/StrategySection.tsx

import type { StrategyAllocation, Platform } from "@/lib/types/agent";

interface Props {
  description: string;
  strategies: StrategyAllocation[];
  platforms: Platform[];
  acceptedAssets: string[];
}

export function StrategySection({ description, strategies, platforms, acceptedAssets }: Props) {
  return (
    <section className="mb-6 rounded-lg border border-gray-800 bg-gray-900 p-6">
      <h2 className="mb-4 text-lg font-semibold text-white">Strategy</h2>
      <p className="mb-4 text-sm leading-relaxed text-gray-300">{description}</p>

      {strategies.length > 0 && (
        <div className="mb-4">
          <p className="mb-2 text-xs font-medium uppercase tracking-wider text-gray-500">
            Allocation
          </p>
          <div className="space-y-2">
            {strategies.map((s) => (
              <div key={s.name} className="flex items-center gap-3">
                <span className="w-32 text-sm text-gray-300">{s.name}</span>
                <div className="h-2 flex-1 overflow-hidden rounded-full bg-gray-800">
                  <div
                    className="h-full rounded-full bg-blue-500"
                    style={{ width: `${s.pct}%` }}
                  />
                </div>
                <span className="w-10 text-right text-sm text-gray-400">{s.pct}%</span>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="flex flex-wrap gap-4">
        <div>
          <p className="mb-1 text-xs font-medium uppercase tracking-wider text-gray-500">
            Platforms
          </p>
          <div className="flex gap-2">
            {platforms.map((p) => (
              <span
                key={p.name}
                className={`rounded-full px-2 py-0.5 text-xs ${
                  p.active
                    ? "bg-green-500/20 text-green-400"
                    : "bg-gray-700 text-gray-500"
                }`}
              >
                {p.name} {p.active ? "\u25CF" : "\u25CB"}
              </span>
            ))}
          </div>
        </div>

        <div>
          <p className="mb-1 text-xs font-medium uppercase tracking-wider text-gray-500">
            Accepted Assets
          </p>
          <div className="flex gap-2">
            {acceptedAssets.map((a) => (
              <span key={a} className="rounded-full bg-gray-800 px-2 py-0.5 text-xs text-gray-300">
                {a}
              </span>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
```

### Step 4: Build `RiskProfileSection` at `src/components/agent/RiskProfileSection.tsx`

```typescript
// src/components/agent/RiskProfileSection.tsx

import type { RiskParams } from "@/lib/types/agent";

interface Props {
  riskParams: RiskParams;
  creatorOwnershipPct: number;
}

export function RiskProfileSection({ riskParams, creatorOwnershipPct }: Props) {
  const items = [
    { label: "Max Drawdown Limit", value: `${riskParams.maxDrawdownPct}%` },
    { label: "Concentration Limit", value: `${riskParams.concentrationLimitPct}%` },
    { label: "Withdrawal Delay", value: `${riskParams.withdrawalDelayHours} hours` },
    { label: "Max Position Size", value: `${riskParams.maxPositionSizePct}% NAV` },
    { label: "Daily Loss Limit", value: `${riskParams.dailyLossLimitPct}% NAV` },
    { label: "Creator Ownership", value: `${creatorOwnershipPct}%` },
  ];

  return (
    <section className="mb-6 rounded-lg border border-gray-800 bg-gray-900 p-6">
      <h2 className="mb-4 text-lg font-semibold text-white">Risk Profile</h2>
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
        {items.map((item) => (
          <div key={item.label}>
            <p className="text-xs text-gray-500">{item.label}</p>
            <p className="text-sm font-medium text-gray-200">{item.value}</p>
          </div>
        ))}
      </div>
    </section>
  );
}
```

### Step 5: Build `RecentTradesTable` at `src/components/agent/RecentTradesTable.tsx`

```typescript
// src/components/agent/RecentTradesTable.tsx

import type { AgentTrade } from "@/lib/types/agent";

interface Props {
  trades: AgentTrade[];
  agentId: string;
}

const OUTCOME_STYLES: Record<string, string> = {
  won: "text-green-400",
  lost: "text-red-400",
  open: "text-yellow-400",
  pending_resolution: "text-gray-400",
};

export function RecentTradesTable({ trades, agentId }: Props) {
  return (
    <section className="mb-6 rounded-lg border border-gray-800 bg-gray-900 p-6">
      <h2 className="mb-4 text-lg font-semibold text-white">Recent Trades</h2>
      {trades.length === 0 ? (
        <p className="text-sm text-gray-500">No trades yet.</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-800 text-left text-xs uppercase text-gray-500">
                <th className="pb-2 pr-4">Date</th>
                <th className="pb-2 pr-4">Platform</th>
                <th className="pb-2 pr-4">Market</th>
                <th className="pb-2 pr-4">Side</th>
                <th className="pb-2 pr-4">Price</th>
                <th className="pb-2">Outcome</th>
              </tr>
            </thead>
            <tbody>
              {trades.map((t) => (
                <tr key={t.id} className="border-b border-gray-800/50">
                  <td className="py-2 pr-4 text-gray-400">
                    {new Date(t.timestamp).toLocaleDateString("en-US", { month: "short", day: "numeric" })}
                  </td>
                  <td className="py-2 pr-4 text-gray-300">{t.platform}</td>
                  <td className="py-2 pr-4 text-gray-200">{t.market}</td>
                  <td className="py-2 pr-4">
                    <span className={t.side === "YES" ? "text-green-400" : "text-red-400"}>
                      {t.side}
                    </span>
                  </td>
                  <td className="py-2 pr-4 font-mono text-gray-300">@{t.price.toFixed(2)}</td>
                  <td className={`py-2 capitalize ${OUTCOME_STYLES[t.outcome] ?? "text-gray-400"}`}>
                    {t.outcome.replace("_", " ")}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      <a
        href={`/agents/${agentId}/trades`}
        className="mt-3 inline-block text-sm text-blue-400 hover:text-blue-300"
      >
        View All Trades &rarr;
      </a>
    </section>
  );
}
```

### Step 6: Build `DepositorStats` at `src/components/agent/DepositorStats.tsx`

```typescript
// src/components/agent/DepositorStats.tsx

import type { DepositorStats as DepositorStatsType } from "@/lib/types/agent";

interface Props {
  stats: DepositorStatsType;
}

export function DepositorStats({ stats }: Props) {
  return (
    <section className="mb-24 rounded-lg border border-gray-800 bg-gray-900 p-6">
      <h2 className="mb-4 text-lg font-semibold text-white">Depositors</h2>
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
        <div>
          <p className="text-xs text-gray-500">Total Depositors</p>
          <p className="text-xl font-bold text-white">{stats.totalDepositors}</p>
        </div>
        <div>
          <p className="text-xs text-gray-500">Pool Size</p>
          <p className="text-xl font-bold text-white">${stats.poolSize.toLocaleString()}</p>
        </div>
        <div>
          <p className="text-xs text-gray-500">Avg Deposit</p>
          <p className="text-xl font-bold text-white">${stats.avgDeposit.toLocaleString()}</p>
        </div>
        <div>
          <p className="text-xs text-gray-500">Share Token</p>
          <p className="text-xl font-bold text-white">{stats.shareTokenSymbol}</p>
        </div>
      </div>
    </section>
  );
}
```

### Step 7: Create `not-found.tsx` for the agents route

```typescript
// src/app/agents/[id]/not-found.tsx

export default function AgentNotFound() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-gray-950 text-gray-100">
      <div className="text-center">
        <h1 className="text-4xl font-bold">Agent Not Found</h1>
        <p className="mt-2 text-gray-400">
          The agent you are looking for does not exist or has been removed.
        </p>
        <a href="/" className="mt-4 inline-block text-blue-400 hover:text-blue-300">
          Back to Home
        </a>
      </div>
    </main>
  );
}
```

## Done When

- [ ] All requirements met
- [ ] Navigating to `/agents/some-agent-id` renders the full profile page with all sections
- [ ] `AgentProfileHeader` displays name, truncated creator address, status badge, type, date, and ownership
- [ ] `StrategySection` shows description, allocation bars with percentages, platform badges, and accepted assets
- [ ] `RiskProfileSection` renders all 6 risk/ownership fields in a grid
- [ ] `RecentTradesTable` shows the 5 most recent trades with correct columns and "View All" link
- [ ] `DepositorStats` shows all 4 stats fields
- [ ] Sticky "Fund This Agent" CTA is visible at the bottom of the viewport and links to `/agents/[id]/deposit`
- [ ] Unknown agent IDs render the `not-found` page
- [ ] Page has correct `<title>` meta from `generateMetadata`
