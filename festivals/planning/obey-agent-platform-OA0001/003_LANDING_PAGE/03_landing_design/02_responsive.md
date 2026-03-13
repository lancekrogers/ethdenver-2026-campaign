---
fest_type: task
fest_id: 02_responsive.md
fest_name: responsive
fest_parent: 03_landing_design
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.454185-06:00
fest_tracking: true
---

# Task: Responsive Design and Mobile Optimization

## Objective

Ensure all landing page, agent profile, deposit flow, and withdrawal flow pages are fully responsive across mobile (320px-640px), tablet (640px-1024px), and desktop (1024px+) viewports, including a mobile navigation drawer, touch-friendly inputs, and optimized layouts for small screens.

## Requirements

- [ ] Build a mobile navigation drawer (hamburger menu) that replaces the desktop nav links on screens below `sm` (640px)
- [ ] Make the Featured Agent Card stack vertically on mobile with full-width stats
- [ ] Ensure the NAV chart renders correctly at all viewport widths with proper touch interactions
- [ ] Make deposit and withdrawal form inputs large enough for mobile touch targets (min 44px height)
- [ ] Ensure the sticky "Fund This Agent" CTA bar on the profile page is properly positioned on mobile browsers (accounting for browser chrome)
- [ ] Make all data tables horizontally scrollable on mobile without breaking the layout
- [ ] Test and fix the How It Works grid to stack to single column on mobile, 2 columns on tablet, 4 on desktop
- [ ] Verify all text remains readable (min 14px body text on mobile)

## Implementation

### Step 1: Build `MobileNavDrawer` at `src/components/layout/MobileNavDrawer.tsx`

```typescript
// src/components/layout/MobileNavDrawer.tsx
"use client";

import { useState, useEffect } from "react";
import { ConnectWalletButton } from "@/components/wallet/ConnectWalletButton";

const NAV_LINKS = [
  { href: "/", label: "Home" },
  { href: "/agents", label: "Agents" },
  { href: "/leaderboard", label: "Leaderboard" },
  { href: "/portfolio", label: "Portfolio" },
];

export function MobileNavDrawer() {
  const [open, setOpen] = useState(false);

  // Prevent body scroll when drawer is open
  useEffect(() => {
    if (open) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
    return () => { document.body.style.overflow = ""; };
  }, [open]);

  return (
    <>
      {/* Hamburger button — visible only on mobile */}
      <button
        onClick={() => setOpen(true)}
        className="sm:hidden flex h-10 w-10 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white"
        aria-label="Open menu"
      >
        <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>

      {/* Overlay */}
      {open && (
        <div
          className="fixed inset-0 z-50 bg-black/60 sm:hidden"
          onClick={() => setOpen(false)}
        />
      )}

      {/* Drawer */}
      <div
        className={`fixed top-0 right-0 z-50 h-full w-72 transform border-l border-gray-800 bg-gray-950 p-6 transition-transform duration-300 sm:hidden ${
          open ? "translate-x-0" : "translate-x-full"
        }`}
      >
        {/* Close button */}
        <div className="mb-8 flex justify-end">
          <button
            onClick={() => setOpen(false)}
            className="flex h-10 w-10 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white"
            aria-label="Close menu"
          >
            <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Links */}
        <nav className="space-y-4">
          {NAV_LINKS.map((link) => (
            <a
              key={link.href}
              href={link.href}
              onClick={() => setOpen(false)}
              className="block rounded-lg px-4 py-3 text-lg font-medium text-gray-300 transition-colors hover:bg-gray-800 hover:text-white"
            >
              {link.label}
            </a>
          ))}
        </nav>

        {/* Wallet button at bottom of drawer */}
        <div className="mt-8">
          <ConnectWalletButton />
        </div>
      </div>
    </>
  );
}
```

### Step 2: Update `Navbar` to include the mobile drawer

Update `src/components/layout/Navbar.tsx`:

```typescript
// src/components/layout/Navbar.tsx
"use client";

import { ConnectWalletButton } from "@/components/wallet/ConnectWalletButton";
import { MobileNavDrawer } from "@/components/layout/MobileNavDrawer";

export function Navbar() {
  return (
    <nav className="fixed top-0 left-0 right-0 z-40 border-b border-gray-800 bg-gray-950/95 backdrop-blur-sm">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4">
        <a href="/" className="flex items-center gap-2">
          <span className="text-xl font-bold tracking-tight text-white">
            OBEY
          </span>
          <span className="hidden text-sm text-gray-500 sm:inline">Agent Economy</span>
        </a>

        {/* Desktop nav links — hidden on mobile */}
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

        <div className="flex items-center gap-3">
          {/* Desktop wallet — hidden on mobile */}
          <div className="hidden sm:block">
            <ConnectWalletButton />
          </div>
          {/* Mobile hamburger + drawer */}
          <MobileNavDrawer />
        </div>
      </div>
    </nav>
  );
}
```

### Step 3: Add responsive Tailwind utilities to key components

These are the specific responsive adjustments needed across the existing components. Apply these as modifications to the components built in previous tasks.

**Hero Section (`src/components/landing/HeroSection.tsx`):**

The hero already uses responsive classes (`text-5xl sm:text-6xl`, `text-xl sm:text-2xl`). Verify the CTA buttons stack on mobile:

```typescript
// Update the CTA container in HeroSection.tsx
<div className="mt-8 flex flex-col items-center gap-3 sm:flex-row sm:justify-center sm:gap-4">
  <a
    href="#featured-agent"
    className="w-full rounded-lg bg-green-600 px-8 py-3 text-center font-semibold text-white transition-colors hover:bg-green-500 sm:w-auto"
  >
    Start Earning
  </a>
  <a
    href="#how-it-works"
    className="w-full rounded-lg border border-gray-700 px-8 py-3 text-center font-semibold text-gray-300 transition-colors hover:border-gray-500 sm:w-auto"
  >
    How It Works
  </a>
</div>
```

**Featured Agent Card stats grid:**

Update the stats grid in `FeaturedAgentCard.tsx` to use 2 columns on mobile:

```typescript
// Update the stats grid div
<div className="mb-6 grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-6">
```

**Profile page sticky CTA:**

Update the sticky CTA in `src/app/agents/[id]/page.tsx` to account for mobile browser chrome using `pb-safe`:

```typescript
// Update the sticky CTA div
<div className="fixed bottom-0 left-0 right-0 z-30 border-t border-gray-800 bg-gray-950/95 p-4 pb-[calc(1rem+env(safe-area-inset-bottom))] backdrop-blur-sm">
  <div className="mx-auto flex max-w-4xl flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
    <div className="text-center sm:text-left">
      <p className="text-xs text-gray-400">Pool Size</p>
      <p className="text-lg font-bold">
        ${profile.depositorStats.poolSize.toLocaleString()}
      </p>
    </div>
    <a
      href={`/agents/${id}/deposit`}
      className="w-full rounded-lg bg-green-600 px-8 py-3 text-center font-semibold text-white transition-colors hover:bg-green-500 sm:w-auto"
    >
      Fund This Agent
    </a>
  </div>
</div>
```

**Deposit/Withdraw form inputs:**

Ensure all `<input>` elements use min-height for touch targets. Update the shared input classes used in deposit and withdraw components:

```typescript
// Standard input class string for deposit/withdraw inputs
const INPUT_CLASSES = "w-full rounded-lg border border-gray-700 bg-gray-800 px-4 py-3 text-lg font-mono text-white placeholder-gray-600 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 min-h-[44px]";
```

The existing `py-3` with `text-lg` already produces ~44px height, but adding `min-h-[44px]` ensures the touch target is never smaller.

**Recent Trades table:**

The `RecentTradesTable` already wraps in `overflow-x-auto`. Verify on mobile that horizontal scroll works. Add `min-width` to the table to prevent column collapse:

```typescript
// In RecentTradesTable.tsx, update the table element
<table className="w-full min-w-[500px] text-sm">
```

### Step 4: Add viewport meta and safe-area support in `src/app/layout.tsx`

```typescript
// Update the <html> tag in layout.tsx
<html lang="en">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
  </head>
  <body className="bg-gray-950 text-gray-100 antialiased">
    <SolanaWalletProvider>
      {children}
    </SolanaWalletProvider>
  </body>
</html>
```

### Step 5: Add responsive chart height adjustments

Update `NAVChartSection.tsx` to use a smaller chart height on mobile:

```typescript
// Replace the fixed height ResponsiveContainer
<ResponsiveContainer width="100%" height={window.innerWidth < 640 ? 180 : 256}>
```

Since `window` is not available during SSR, use a state-based approach:

```typescript
// Add to NAVChartSection.tsx
const [chartHeight, setChartHeight] = useState(256);

useEffect(() => {
  function updateHeight() {
    setChartHeight(window.innerWidth < 640 ? 180 : 256);
  }
  updateHeight();
  window.addEventListener("resize", updateHeight);
  return () => window.removeEventListener("resize", updateHeight);
}, []);

// Then use:
<ResponsiveContainer width="100%" height={chartHeight}>
```

### Step 6: Tailwind safelist for dynamic responsive classes

If using Tailwind 4, ensure the CSS utility classes used dynamically are available. Since we use standard Tailwind classes (not dynamically constructed strings), this should work out of the box with Tailwind's content scanning.

No additional configuration needed beyond what exists in the dashboard's `postcss.config.mjs` and `tailwindcss` setup.

## Done When

- [ ] All requirements met
- [ ] Mobile (320px-640px): Hamburger menu opens a slide-out drawer with nav links and wallet connect button
- [ ] Mobile: Hero CTA buttons stack vertically at full width
- [ ] Mobile: Featured Agent Card stats display in a 2-column grid
- [ ] Mobile: NAV chart renders at reduced height (180px) without overflow
- [ ] Mobile: Deposit and withdraw inputs have minimum 44px touch target height
- [ ] Mobile: Recent Trades table scrolls horizontally without layout breaking
- [ ] Mobile: Sticky "Fund This Agent" CTA accounts for safe-area-inset-bottom on iOS
- [ ] Mobile: How It Works grid displays as single column
- [ ] Tablet (640px-1024px): Nav links visible in header, stats in 3-column grid, How It Works in 2 columns
- [ ] Desktop (1024px+): Full layout with 6-column stats, 4-column How It Works grid, inline nav
- [ ] All pages tested at 320px, 375px, 414px, 768px, 1024px, 1440px viewport widths
- [ ] No horizontal overflow or content clipping at any viewport size
- [ ] Body text is minimum 14px on mobile (Tailwind `text-sm` = 14px, which satisfies this)
