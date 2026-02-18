---
fest_type: task
fest_id: 01_layout_tuning.md
fest_name: layout_tuning
fest_parent: 07_demo_polish
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Layout Tuning

**Task Number:** 01 | **Sequence:** 07_demo_polish | **Autonomy:** medium

## Objective

Design and implement the final dashboard layout that arranges all five panels in an optimized grid for projector/large-screen presentation. This task creates the DashboardLayout component and updates the main page to render the complete dashboard with all panels wired to the data layer.

## Requirements

- [ ] Create `src/components/DashboardLayout.tsx` with 5-panel grid
- [ ] Update `src/app/page.tsx` to render the dashboard
- [ ] Wire all five panels to data layer hooks
- [ ] Implement dark theme with consistent styling
- [ ] Layout must be optimized for 1920x1080 and larger displays
- [ ] Dashboard title and connection status header

## Implementation

### Step 1: Design the grid layout

The dashboard uses a CSS grid optimized for wide-screen presentation. The layout divides the screen into a 3-column grid with panels distributed for visual balance:

```
+---------------------------------------------------+
| Dashboard Header: "Agent Economy Observer"  [Status]|
+---------------------------------------------------+
| Festival View  | HCS Message Feed | Agent Activity |
| (tall panel)   | (tall panel)     | (tall panel)   |
|                |                  |                |
|                |                  |                |
|                |                  |                |
+---------------------------------------------------+
| DeFi P&L (wide panel)     | Inference Metrics     |
|                            | (wide panel)          |
+---------------------------------------------------+
```

Grid specification:
- `grid grid-cols-3 grid-rows-[auto_1fr_1fr] gap-4 h-screen p-4`
- Row 1: Dashboard header (auto height)
- Row 2: Festival View (col 1), HCS Feed (col 2), Agent Activity (col 3)
- Row 3: DeFi P&L (col 1-2, spans 2 columns), Inference Metrics (col 3)

Alternative layout if panels need more vertical space:
- `grid grid-cols-3 grid-rows-[auto_2fr_1fr]` -- top panels get 2/3, bottom panels get 1/3

### Step 2: Create DashboardLayout component

Create `src/components/DashboardLayout.tsx`:

**Props:**
```typescript
interface DashboardLayoutProps {
  children?: React.ReactNode;
}
```

**Implementation:**

1. **Container**: Full viewport height with dark background:
   ```tsx
   <div className="min-h-screen bg-gray-950 text-white">
   ```

2. **Header bar**: Fixed at top:
   ```tsx
   <header className="flex items-center justify-between px-6 py-3 border-b border-gray-800 bg-gray-900">
     <div className="flex items-center gap-3">
       <h1 className="text-xl font-bold text-white">Agent Economy Observer</h1>
       <span className="text-xs text-gray-500 bg-gray-800 px-2 py-0.5 rounded">ETHDenver 2026</span>
     </div>
     <div className="flex items-center gap-4">
       {/* Connection status indicators will be passed as children or composed */}
       <ConnectionStatus />
     </div>
   </header>
   ```

3. **Panel grid**: Below header, fills remaining viewport:
   ```tsx
   <main className="grid grid-cols-3 grid-rows-[2fr_1fr] gap-4 p-4 h-[calc(100vh-60px)]">
     {/* Row 1: Three equal panels */}
     <div className="overflow-hidden">{/* Festival View */}</div>
     <div className="overflow-hidden">{/* HCS Feed */}</div>
     <div className="overflow-hidden">{/* Agent Activity */}</div>
     {/* Row 2: Two panels, DeFi spans 2 cols */}
     <div className="col-span-2 overflow-hidden">{/* DeFi P&L */}</div>
     <div className="overflow-hidden">{/* Inference Metrics */}</div>
   </main>
   ```

4. **ConnectionStatus sub-component**: Shows overall data connection status:
   - Green dot + "Live" when WebSocket is connected
   - Yellow dot + "Connecting..." when connecting
   - Red dot + "Disconnected" when disconnected
   - Display data mode: "WebSocket" or "gRPC" or "Mock"

### Step 3: Create a ConnectionStatus component

Small component that aggregates connection state from hooks:

```typescript
function ConnectionStatus() {
  // Determine which data mode is active
  const mode = process.env.NEXT_PUBLIC_USE_MOCK === 'true' ? 'Mock' :
               process.env.NEXT_PUBLIC_USE_GRPC === 'true' ? 'gRPC' : 'WebSocket';

  return (
    <div className="flex items-center gap-2 text-sm">
      <span className="text-gray-500">Mode:</span>
      <span className="text-gray-300">{mode}</span>
      {/* Connection dot - will be dynamic based on actual state */}
    </div>
  );
}
```

### Step 4: Update the main page

Update `src/app/page.tsx` to render the complete dashboard:

```typescript
'use client';

import { DashboardLayout } from '@/components/DashboardLayout';
import { FestivalView } from '@/components/panels/FestivalView';
import { HCSFeed } from '@/components/panels/HCSFeed';
import { AgentActivity } from '@/components/panels/AgentActivity';
import { DeFiPnL } from '@/components/panels/DeFiPnL';
import { InferenceMetrics } from '@/components/panels/InferenceMetrics';
import { useWebSocket } from '@/hooks/useWebSocket';
import { useMirrorNode } from '@/hooks/useMirrorNode';
// Import mock data provider if in mock mode
```

The page component:
1. Calls the data layer hooks to get live data
2. Distributes data to each panel via props
3. Handles the mock vs live data toggle

**Data wiring:**
- `useWebSocket()` or `useGRPC()` provides: daemon events, agent status
- `useMirrorNode()` provides: HCS messages, festival progress
- All panels receive their specific data slices

If `NEXT_PUBLIC_USE_MOCK=true`, import and use mock data instead of live hooks.

### Step 5: Configure global styles

Ensure `src/app/globals.css` has the dark theme base:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  @apply bg-gray-950 text-white;
}

/* Custom scrollbar for dark theme */
::-webkit-scrollbar {
  width: 6px;
}
::-webkit-scrollbar-track {
  background: #1f2937;
}
::-webkit-scrollbar-thumb {
  background: #4b5563;
  border-radius: 3px;
}
```

### Step 6: Verify the layout

```bash
cd $(fgo) && npm run dev
```

Open `http://localhost:3000` in a browser. Verify:
- [ ] All 5 panels render in the grid
- [ ] No horizontal scrolling at 1920x1080
- [ ] Header shows title and connection status
- [ ] Dark theme is consistent
- [ ] Panels fill their grid cells without overflow

```bash
npx tsc --noEmit
```

Must pass with zero errors.

## Critical Constraints

- **READ-ONLY**: The dashboard page only renders data. No mutations, no form submissions, no write operations.
- **Full Viewport**: The dashboard must fill the entire viewport without scrolling. Each panel internally scrolls if needed.
- **No Light Theme**: Everything is dark theme for projector visibility. No white backgrounds anywhere.

## Done When

- [ ] `src/components/DashboardLayout.tsx` exists with the grid layout
- [ ] `src/app/page.tsx` renders all 5 panels in the layout
- [ ] All panels are wired to data layer hooks
- [ ] Header shows "Agent Economy Observer" with connection status
- [ ] Grid fills viewport without scrolling (panels scroll internally)
- [ ] Dark theme is consistent across all panels
- [ ] Layout works at 1920x1080 and larger
- [ ] `npx tsc --noEmit` passes with zero errors
- [ ] `npm run dev` starts and renders the dashboard
