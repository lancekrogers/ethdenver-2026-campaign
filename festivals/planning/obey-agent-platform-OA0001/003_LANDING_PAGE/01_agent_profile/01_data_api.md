---
fest_type: task
fest_id: 01_data_api.md
fest_name: data_api
fest_parent: 01_agent_profile
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.41465-06:00
fest_tracking: true
---

# Task: Agent Data API Routes

## Objective

Build the Next.js API route handlers that serve agent profile data, NAV history, trade history, and performance metrics from the backend to the frontend.

## Requirements

- [ ] Create `GET /api/v1/agents/[id]` route returning full agent profile (name, creator, type, status, strategy, platforms, accepted assets, risk parameters, depositor stats)
- [ ] Create `GET /api/v1/agents/[id]/nav` route returning current NAV and historical NAV data points with period filtering (7d, 30d, 90d, all)
- [ ] Create `GET /api/v1/agents/[id]/trades` route returning paginated trade history (market, platform, side, price, outcome, timestamp)
- [ ] Create `GET /api/v1/agents/[id]/metrics` route returning computed performance metrics (Sharpe ratio, max drawdown, win rate, avg holding period, total return)
- [ ] Define TypeScript types for all API response shapes in a shared types file
- [ ] Implement error handling with proper HTTP status codes (404 for unknown agent, 500 for backend failures)

## Implementation

### Step 1: Create shared types at `src/lib/types/agent.ts`

```typescript
// src/lib/types/agent.ts

export interface AgentProfile {
  id: string;
  name: string;
  creator: string;         // wallet address
  type: "prediction_market" | "defi" | "hybrid";
  status: "active" | "paused" | "stopped";
  createdAt: string;       // ISO date
  description: string;
  strategyBreakdown: StrategyAllocation[];
  platforms: Platform[];
  acceptedAssets: string[];
  riskParams: RiskParams;
  depositorStats: DepositorStats;
  creatorOwnershipPct: number;
}

export interface StrategyAllocation {
  name: string;
  pct: number;
}

export interface Platform {
  name: string;            // "Polymarket" | "Limitless" | "Drift BET"
  active: boolean;
}

export interface RiskParams {
  maxDrawdownPct: number;
  concentrationLimitPct: number;
  withdrawalDelayHours: number;
  maxPositionSizePct: number;
  dailyLossLimitPct: number;
}

export interface DepositorStats {
  totalDepositors: number;
  poolSize: number;        // USD value
  avgDeposit: number;
  shareTokenSymbol: string;
}

export interface NAVDataPoint {
  timestamp: string;
  nav: number;
  sharePrice: number;
}

export interface NAVResponse {
  currentNav: number;
  currentSharePrice: number;
  totalShares: number;
  history: NAVDataPoint[];
}

export interface AgentTrade {
  id: string;
  timestamp: string;
  platform: string;
  market: string;
  side: "YES" | "NO";
  price: number;
  amount: number;
  outcome: "won" | "lost" | "open" | "pending_resolution";
  pnl: number | null;
  txHash: string;
}

export interface TradesResponse {
  trades: AgentTrade[];
  total: number;
  page: number;
  pageSize: number;
}

export interface PerformanceMetrics {
  totalReturn: number;     // percentage
  nav: number;
  sharpeRatio: number;
  maxDrawdownPct: number;
  winRate: number;         // percentage
  avgHoldingDays: number;
  totalTrades: number;
  openPositions: number;
  profitFactor: number;
}

export type NavPeriod = "7d" | "30d" | "90d" | "all";
```

### Step 2: Create backend client at `src/lib/api/agent-client.ts`

This client abstracts the backend HTTP calls. For MVP, it calls the Go backend API. During development, it can return mock data.

```typescript
// src/lib/api/agent-client.ts

import type {
  AgentProfile,
  NAVResponse,
  TradesResponse,
  PerformanceMetrics,
  NavPeriod,
} from "@/lib/types/agent";

const BACKEND_URL = process.env.BACKEND_API_URL ?? "http://localhost:8080";

async function fetchBackend<T>(path: string): Promise<T> {
  const res = await fetch(`${BACKEND_URL}${path}`, {
    next: { revalidate: 30 },  // ISR: revalidate every 30s
    headers: { "Content-Type": "application/json" },
  });

  if (!res.ok) {
    throw new BackendError(res.status, `Backend returned ${res.status}`);
  }

  return res.json() as Promise<T>;
}

export class BackendError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = "BackendError";
  }
}

export async function fetchAgentProfile(agentId: string): Promise<AgentProfile> {
  return fetchBackend<AgentProfile>(`/api/v1/agents/${agentId}`);
}

export async function fetchAgentNAV(agentId: string, period: NavPeriod = "30d"): Promise<NAVResponse> {
  return fetchBackend<NAVResponse>(`/api/v1/agents/${agentId}/nav?period=${period}`);
}

export async function fetchAgentTrades(
  agentId: string,
  page = 1,
  pageSize = 20,
): Promise<TradesResponse> {
  return fetchBackend<TradesResponse>(
    `/api/v1/agents/${agentId}/trades?page=${page}&pageSize=${pageSize}`,
  );
}

export async function fetchAgentMetrics(agentId: string): Promise<PerformanceMetrics> {
  return fetchBackend<PerformanceMetrics>(`/api/v1/agents/${agentId}/metrics`);
}
```

### Step 3: Create API route handlers

Create Next.js route handlers using the App Router pattern.

**`src/app/api/v1/agents/[id]/route.ts`**

```typescript
import { NextRequest, NextResponse } from "next/server";
import { fetchAgentProfile, BackendError } from "@/lib/api/agent-client";

export async function GET(
  _request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  const { id } = await params;

  try {
    const profile = await fetchAgentProfile(id);
    return NextResponse.json(profile);
  } catch (err) {
    if (err instanceof BackendError) {
      return NextResponse.json(
        { error: err.message },
        { status: err.status },
      );
    }
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 },
    );
  }
}
```

**`src/app/api/v1/agents/[id]/nav/route.ts`**

```typescript
import { NextRequest, NextResponse } from "next/server";
import { fetchAgentNAV, BackendError } from "@/lib/api/agent-client";
import type { NavPeriod } from "@/lib/types/agent";

const VALID_PERIODS: NavPeriod[] = ["7d", "30d", "90d", "all"];

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  const { id } = await params;
  const period = (request.nextUrl.searchParams.get("period") ?? "30d") as NavPeriod;

  if (!VALID_PERIODS.includes(period)) {
    return NextResponse.json(
      { error: `Invalid period. Must be one of: ${VALID_PERIODS.join(", ")}` },
      { status: 400 },
    );
  }

  try {
    const nav = await fetchAgentNAV(id, period);
    return NextResponse.json(nav);
  } catch (err) {
    if (err instanceof BackendError) {
      return NextResponse.json({ error: err.message }, { status: err.status });
    }
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
```

**`src/app/api/v1/agents/[id]/trades/route.ts`**

```typescript
import { NextRequest, NextResponse } from "next/server";
import { fetchAgentTrades, BackendError } from "@/lib/api/agent-client";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  const { id } = await params;
  const page = parseInt(request.nextUrl.searchParams.get("page") ?? "1", 10);
  const pageSize = Math.min(
    parseInt(request.nextUrl.searchParams.get("pageSize") ?? "20", 10),
    100,
  );

  try {
    const trades = await fetchAgentTrades(id, page, pageSize);
    return NextResponse.json(trades);
  } catch (err) {
    if (err instanceof BackendError) {
      return NextResponse.json({ error: err.message }, { status: err.status });
    }
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
```

**`src/app/api/v1/agents/[id]/metrics/route.ts`**

```typescript
import { NextRequest, NextResponse } from "next/server";
import { fetchAgentMetrics, BackendError } from "@/lib/api/agent-client";

export async function GET(
  _request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  const { id } = await params;

  try {
    const metrics = await fetchAgentMetrics(id);
    return NextResponse.json(metrics);
  } catch (err) {
    if (err instanceof BackendError) {
      return NextResponse.json({ error: err.message }, { status: err.status });
    }
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
```

### Step 4: Add `BACKEND_API_URL` to environment config

Add to `.env.local`:

```
BACKEND_API_URL=http://localhost:8080
```

Add to `.env.example`:

```
BACKEND_API_URL=http://localhost:8080
```

### Step 5: Create React hooks for client-side data fetching

**`src/hooks/useAgentProfile.ts`**

```typescript
"use client";

import { useState, useEffect } from "react";
import type { AgentProfile } from "@/lib/types/agent";

export function useAgentProfile(agentId: string) {
  const [profile, setProfile] = useState<AgentProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);

    fetch(`/api/v1/agents/${agentId}`)
      .then((res) => {
        if (!res.ok) throw new Error(`Agent not found (${res.status})`);
        return res.json();
      })
      .then((data) => {
        if (!cancelled) {
          setProfile(data);
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

  return { profile, loading, error };
}
```

**`src/hooks/useAgentNAV.ts`**

```typescript
"use client";

import { useState, useEffect } from "react";
import type { NAVResponse, NavPeriod } from "@/lib/types/agent";

export function useAgentNAV(agentId: string, period: NavPeriod = "30d") {
  const [nav, setNav] = useState<NAVResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);

    fetch(`/api/v1/agents/${agentId}/nav?period=${period}`)
      .then((res) => {
        if (!res.ok) throw new Error(`Failed to load NAV (${res.status})`);
        return res.json();
      })
      .then((data) => {
        if (!cancelled) {
          setNav(data);
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
  }, [agentId, period]);

  return { nav, loading, error };
}
```

## Done When

- [ ] All requirements met
- [ ] `GET /api/v1/agents/[id]` returns a valid `AgentProfile` JSON response
- [ ] `GET /api/v1/agents/[id]/nav?period=30d` returns NAV history with correct period filtering
- [ ] `GET /api/v1/agents/[id]/trades?page=1&pageSize=20` returns paginated trade results
- [ ] `GET /api/v1/agents/[id]/metrics` returns computed `PerformanceMetrics`
- [ ] All routes return proper 404 for unknown agent IDs and 500 for backend failures
- [ ] TypeScript types compile with zero errors
- [ ] React hooks (`useAgentProfile`, `useAgentNAV`) successfully fetch and expose data to components
