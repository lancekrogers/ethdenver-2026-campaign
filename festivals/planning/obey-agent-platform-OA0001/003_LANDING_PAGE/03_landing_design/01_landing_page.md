---
fest_type: task
fest_id: 01_landing_page.md
fest_name: landing_page
fest_parent: 03_landing_design
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.453875-06:00
fest_tracking: true
---

# Task: Landing Page Design and Implementation

## Objective

Build the main landing page at `/` (obeyplatform.xyz) that showcases the OBEY Predictor agent's live performance, explains the platform value proposition, provides a direct deposit CTA, includes the "How It Works" section, and features a referral link share mechanism.

## Requirements

- [ ] Build a hero section with the OBEY Agent Economy tagline, one-liner value prop ("Fund AI agents that trade prediction markets"), and a primary CTA to view/fund the featured agent
- [ ] Build a featured agent card showing live stats: NAV, Total Return, Win Rate, Sharpe Ratio, Max Drawdown, trade count, and agent status indicator
- [ ] Embed an inline NAV chart (Recharts AreaChart) in the featured agent card showing recent performance
- [ ] Build a recent trades feed showing the last 5 trades with market name, side, price, and outcome
- [ ] Build a "How It Works" section with 4 steps: Deposit USDC, AI Agent Trades, Burn Shares, Refer Friends
- [ ] Build a referral section with a copyable referral link and "earn 10% of platform fees" messaging
- [ ] Build a top navigation bar with logo, wallet connect button, and nav links
- [ ] Wire all live data from the agent data API hooks

## Implementation

### Step 1: Build the top navigation bar at `src/components/layout/Navbar.tsx`

```typescript
// src/components/layout/Navbar.tsx
"use client";

import { ConnectWalletButton } from "@/components/wallet/ConnectWalletButton";

export function Navbar() {
  return (
    <nav className="fixed top-0 left-0 right-0 z-50 border-b border-gray-800 bg-gray-950/95 backdrop-blur-sm">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4">
        <a href="/" className="flex items-center gap-2">
          <span className="text-xl font-bold tracking-tight text-white">
            OBEY
          </span>
          <span className="text-sm text-gray-500">Agent Economy</span>
        </a>

        <div className="hidden items-center gap-6 sm:flex">
          <a href="/agents" className="text-sm text-gray-400 hover:text-white transition-colors">
            Agents
          </a>
          <a href="/leaderboard" className="text-sm text-gray-400 hover:text-white transition-colors">
            Leaderboard
          </a>
          <a href="/portfolio" className="text-sm text-gray-400 hover:text-white transition-colors">
            Portfolio
          </a>
        </div>

        <ConnectWalletButton />
      </div>
    </nav>
  );
}
```

### Step 2: Build the landing page at `src/app/page.tsx`

```typescript
// src/app/page.tsx

import { Navbar } from "@/components/layout/Navbar";
import { HeroSection } from "@/components/landing/HeroSection";
import { FeaturedAgentCard } from "@/components/landing/FeaturedAgentCard";
import { HowItWorks } from "@/components/landing/HowItWorks";
import { ReferralSection } from "@/components/landing/ReferralSection";
import { Footer } from "@/components/landing/Footer";

// MVP: Single featured agent ID — the OBEY Predictor
const FEATURED_AGENT_ID = process.env.NEXT_PUBLIC_FEATURED_AGENT_ID ?? "obey-predictor";

export default function LandingPage() {
  return (
    <>
      <Navbar />
      <main className="min-h-screen bg-gray-950 text-gray-100 pt-16">
        <HeroSection />
        <FeaturedAgentCard agentId={FEATURED_AGENT_ID} />
        <HowItWorks />
        <ReferralSection />
        <Footer />
      </main>
    </>
  );
}
```

### Step 3: Build `HeroSection` at `src/components/landing/HeroSection.tsx`

```typescript
// src/components/landing/HeroSection.tsx

export function HeroSection() {
  return (
    <section className="px-4 py-20 text-center">
      <div className="mx-auto max-w-3xl">
        <h1 className="text-5xl font-bold leading-tight tracking-tight text-white sm:text-6xl">
          OBEY AGENT ECONOMY
        </h1>
        <p className="mt-4 text-xl text-gray-400 sm:text-2xl">
          Fund AI agents that trade prediction markets.
        </p>
        <p className="mt-2 text-sm text-gray-500">
          Live on Solana Mainnet. Powered by Drift BET.
        </p>
        <div className="mt-8 flex items-center justify-center gap-4">
          <a
            href="#featured-agent"
            className="rounded-lg bg-green-600 px-8 py-3 font-semibold text-white transition-colors hover:bg-green-500"
          >
            Start Earning
          </a>
          <a
            href="#how-it-works"
            className="rounded-lg border border-gray-700 px-8 py-3 font-semibold text-gray-300 transition-colors hover:border-gray-500"
          >
            How It Works
          </a>
        </div>
      </div>
    </section>
  );
}
```

### Step 4: Build `FeaturedAgentCard` at `src/components/landing/FeaturedAgentCard.tsx`

This is a client component that fetches live data.

```typescript
// src/components/landing/FeaturedAgentCard.tsx
"use client";

import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { useAgentProfile } from "@/hooks/useAgentProfile";
import { useAgentNAV } from "@/hooks/useAgentNAV";
import { useAgentMetrics } from "@/hooks/useAgentMetrics";
import { formatUSD, formatPercent, formatSharpe } from "@/lib/utils/formatNumber";

interface Props {
  agentId: string;
}

interface RecentTrade {
  id: string;
  timestamp: string;
  market: string;
  side: string;
  price: number;
  outcome: string;
}

export function FeaturedAgentCard({ agentId }: Props) {
  const { profile, loading: profileLoading } = useAgentProfile(agentId);
  const { nav, loading: navLoading } = useAgentNAV(agentId, "30d");
  const { metrics, loading: metricsLoading } = useAgentMetrics(agentId);

  if (profileLoading || navLoading || metricsLoading) {
    return (
      <section id="featured-agent" className="px-4 pb-16">
        <div className="mx-auto max-w-4xl">
          <div className="h-96 animate-pulse rounded-xl border border-gray-800 bg-gray-900" />
        </div>
      </section>
    );
  }

  if (!profile || !nav || !metrics) {
    return null;
  }

  const chartData = nav.history.map((pt) => ({
    date: new Date(pt.timestamp).toLocaleDateString("en-US", {
      month: "short",
      day: "numeric",
    }),
    nav: pt.nav,
  }));

  const statItems = [
    { label: "NAV", value: formatUSD(metrics.nav) },
    { label: "Return", value: formatPercent(metrics.totalReturn), color: metrics.totalReturn >= 0 ? "text-green-400" : "text-red-400" },
    { label: "Win Rate", value: `${metrics.winRate.toFixed(0)}%` },
    { label: "Sharpe", value: formatSharpe(metrics.sharpeRatio) },
    { label: "Max DD", value: formatPercent(-Math.abs(metrics.maxDrawdownPct), false), color: "text-red-400" },
    { label: "Trades", value: metrics.totalTrades.toString() },
  ];

  return (
    <section id="featured-agent" className="px-4 pb-16">
      <div className="mx-auto max-w-4xl">
        <div className="rounded-xl border border-gray-800 bg-gray-900 p-6 sm:p-8">
          {/* Header */}
          <div className="mb-6 flex items-start justify-between">
            <div>
              <h2 className="text-2xl font-bold text-white">{profile.name}</h2>
              <p className="mt-1 text-sm text-gray-400">
                Live on Solana Mainnet
              </p>
            </div>
            <span className="flex items-center gap-1.5 rounded-full bg-green-500/20 px-3 py-1 text-xs font-medium text-green-400">
              <span className="h-1.5 w-1.5 rounded-full bg-green-400" />
              Trading
            </span>
          </div>

          {/* Stats Grid */}
          <div className="mb-6 grid grid-cols-3 gap-4 sm:grid-cols-6">
            {statItems.map((item) => (
              <div key={item.label}>
                <p className="text-xs text-gray-500">{item.label}</p>
                <p className={`text-lg font-bold ${item.color ?? "text-white"}`}>
                  {item.value}
                </p>
              </div>
            ))}
          </div>

          {/* NAV Chart */}
          <div className="mb-6">
            <ResponsiveContainer width="100%" height={200}>
              <AreaChart data={chartData}>
                <defs>
                  <linearGradient id="landingNavGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#22c55e" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#22c55e" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <XAxis
                  dataKey="date"
                  tick={{ fill: "#6b7280", fontSize: 10 }}
                  axisLine={false}
                  tickLine={false}
                />
                <YAxis hide />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "#111827",
                    border: "1px solid #374151",
                    borderRadius: "8px",
                    fontSize: "12px",
                  }}
                  labelStyle={{ color: "#9ca3af" }}
                  itemStyle={{ color: "#22c55e" }}
                  formatter={(value: number) => [`$${value.toLocaleString()}`, "NAV"]}
                />
                <Area
                  type="monotone"
                  dataKey="nav"
                  stroke="#22c55e"
                  strokeWidth={2}
                  fill="url(#landingNavGradient)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>

          {/* Strategy Description */}
          <p className="mb-6 text-sm leading-relaxed text-gray-400">
            {profile.description}
          </p>

          {/* CTAs */}
          <div className="flex gap-3">
            <a
              href={`/agents/${agentId}/deposit`}
              className="flex-1 rounded-lg bg-green-600 py-3 text-center font-semibold text-white transition-colors hover:bg-green-500"
            >
              Deposit USDC
            </a>
            <a
              href={`/agents/${agentId}`}
              className="flex-1 rounded-lg border border-gray-700 py-3 text-center font-semibold text-gray-300 transition-colors hover:border-gray-500"
            >
              View All Trades
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}
```

### Step 5: Build `HowItWorks` at `src/components/landing/HowItWorks.tsx`

```typescript
// src/components/landing/HowItWorks.tsx

const STEPS = [
  {
    number: "1",
    title: "Deposit USDC",
    description: "Connect your Solana wallet and deposit USDC. You receive OBEY-PRED share tokens representing your stake.",
  },
  {
    number: "2",
    title: "AI Agent Trades",
    description: "The AI agent analyzes prediction markets on Drift BET 24/7, identifying mispriced markets and executing trades on your behalf.",
  },
  {
    number: "3",
    title: "Burn Shares Anytime",
    description: "Burn your share tokens at any time to withdraw your USDC plus any profits. You receive proportional underlying assets.",
  },
  {
    number: "4",
    title: "Refer and Earn",
    description: "Share your referral link and earn 10% of platform fees from every user you refer. Passive income forever.",
  },
];

export function HowItWorks() {
  return (
    <section id="how-it-works" className="px-4 py-16">
      <div className="mx-auto max-w-4xl">
        <h2 className="mb-12 text-center text-3xl font-bold text-white">
          How It Works
        </h2>
        <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          {STEPS.map((step) => (
            <div
              key={step.number}
              className="rounded-lg border border-gray-800 bg-gray-900 p-6"
            >
              <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-full bg-green-600/20 text-lg font-bold text-green-400">
                {step.number}
              </div>
              <h3 className="mb-2 text-lg font-semibold text-white">
                {step.title}
              </h3>
              <p className="text-sm leading-relaxed text-gray-400">
                {step.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
```

### Step 6: Build `ReferralSection` at `src/components/landing/ReferralSection.tsx`

```typescript
// src/components/landing/ReferralSection.tsx
"use client";

import { useState, useCallback } from "react";
import { useWallet } from "@solana/wallet-adapter-react";

const BASE_URL = process.env.NEXT_PUBLIC_BASE_URL ?? "https://obeyplatform.xyz";

export function ReferralSection() {
  const { publicKey, connected } = useWallet();
  const [copied, setCopied] = useState(false);

  // Generate a simple referral code from the wallet address
  const referralCode = connected && publicKey
    ? publicKey.toBase58().slice(0, 8).toUpperCase()
    : "CONNECT_WALLET";

  const referralLink = `${BASE_URL}?ref=${referralCode}`;

  const handleCopy = useCallback(() => {
    navigator.clipboard.writeText(referralLink);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }, [referralLink]);

  return (
    <section className="px-4 py-16">
      <div className="mx-auto max-w-2xl rounded-xl border border-gray-800 bg-gray-900 p-8 text-center">
        <h2 className="text-2xl font-bold text-white">Refer and Earn</h2>
        <p className="mt-2 text-gray-400">
          Earn 10% of platform fees from everyone you refer. Forever.
        </p>

        <div className="mt-6 flex items-center gap-2">
          <input
            type="text"
            readOnly
            value={referralLink}
            className="flex-1 rounded-lg border border-gray-700 bg-gray-800 px-4 py-3 font-mono text-sm text-gray-300"
          />
          <button
            onClick={handleCopy}
            className="rounded-lg bg-blue-600 px-5 py-3 text-sm font-semibold text-white transition-colors hover:bg-blue-500"
          >
            {copied ? "Copied!" : "Copy"}
          </button>
        </div>

        {!connected && (
          <p className="mt-3 text-xs text-gray-500">
            Connect your wallet to generate a personalized referral link.
          </p>
        )}
      </div>
    </section>
  );
}
```

### Step 7: Build `Footer` at `src/components/landing/Footer.tsx`

```typescript
// src/components/landing/Footer.tsx

export function Footer() {
  return (
    <footer className="border-t border-gray-800 px-4 py-8">
      <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-4 sm:flex-row">
        <p className="text-sm text-gray-500">
          OBEY Agent Economy. Built on Solana.
        </p>
        <div className="flex gap-6">
          <a href="https://twitter.com/obeyplatform" target="_blank" rel="noopener noreferrer" className="text-sm text-gray-500 hover:text-gray-300">
            Twitter
          </a>
          <a href="https://github.com/obeyplatform" target="_blank" rel="noopener noreferrer" className="text-sm text-gray-500 hover:text-gray-300">
            GitHub
          </a>
          <a href="https://discord.gg/obeyplatform" target="_blank" rel="noopener noreferrer" className="text-sm text-gray-500 hover:text-gray-300">
            Discord
          </a>
        </div>
      </div>
    </footer>
  );
}
```

### Step 8: Add environment variables

Add to `.env.local`:

```
NEXT_PUBLIC_FEATURED_AGENT_ID=obey-predictor
NEXT_PUBLIC_BASE_URL=https://obeyplatform.xyz
```

## Done When

- [ ] All requirements met
- [ ] Landing page renders with Navbar, Hero, Featured Agent Card, How It Works, Referral, and Footer sections
- [ ] Hero section displays "OBEY AGENT ECONOMY" heading, tagline, and two CTA buttons
- [ ] Featured Agent Card shows live stats (NAV, Return, Win Rate, Sharpe, Max DD, Trades) from the API
- [ ] NAV chart renders with green gradient fill and date axis labels
- [ ] Strategy description is displayed below the chart
- [ ] "Deposit USDC" and "View All Trades" buttons link to correct routes
- [ ] How It Works section shows 4 numbered steps in a grid layout
- [ ] Referral section shows a copyable link, with "Copied!" feedback on click
- [ ] Referral link includes the connected wallet's address-based code (or "CONNECT_WALLET" placeholder)
- [ ] Navbar is fixed to top with logo, nav links, and wallet connect button
- [ ] Footer shows social links
