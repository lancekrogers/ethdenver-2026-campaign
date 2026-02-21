---
fest_type: task
fest_id: 02_implement_panel.md
fest_name: implement_panel
fest_parent: 04_agent_activity
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Agent Activity Panel

**Task Number:** 02 | **Sequence:** 04_agent_activity | **Autonomy:** medium

## Objective

Build the Agent Activity panel component at `src/components/panels/AgentActivity.tsx`. This component renders three agent status cards (coordinator, inference, defi) showing real-time agent status, heartbeat timing, current task, uptime, and error information. It follows the design from the previous task.

## Requirements

- [ ] Create `src/components/panels/AgentActivity.tsx` as the main component
- [ ] Implement AgentCard sub-component for individual agent status
- [ ] Implement HeartbeatIndicator sub-component with pulse animation
- [ ] Show status, heartbeat, current task, uptime, and error count for each agent
- [ ] Handle loading, empty, and error states
- [ ] Style with Tailwind CSS dark theme

## Implementation

### Step 1: Create a utility for formatting relative time

Create `src/lib/utils/formatTime.ts` (or add to existing utils):

```typescript
/**
 * Format seconds into human-readable uptime string.
 * Examples: "45s", "12m 30s", "1h 23m", "2d 3h"
 */
export function formatUptime(seconds: number): string {
  if (seconds < 60) return `${Math.floor(seconds)}s`;
  if (seconds < 3600) {
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${m}m ${s}s`;
  }
  if (seconds < 86400) {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    return `${h}h ${m}m`;
  }
  const d = Math.floor(seconds / 86400);
  const h = Math.floor((seconds % 86400) / 3600);
  return `${d}d ${h}h`;
}

/**
 * Format a timestamp into relative time from now.
 * Examples: "2s ago", "1m ago", "5m ago"
 */
export function formatTimeAgo(isoTimestamp: string): string {
  const diff = Math.floor((Date.now() - new Date(isoTimestamp).getTime()) / 1000);
  if (diff < 0) return 'just now';
  if (diff < 60) return `${diff}s ago`;
  if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
  return `${Math.floor(diff / 3600)}h ago`;
}
```

### Step 2: Implement HeartbeatIndicator sub-component

This can live in the AgentActivity file or as a separate component.

**Props:**

- `lastHeartbeat: string` -- ISO timestamp of last heartbeat
- `className?: string`

**Implementation:**

1. Use `useState` and `useEffect` with a 1-second `setInterval` to update the "time ago" text and staleness color every second.

2. **Staleness calculation:**

   ```typescript
   const secondsAgo = Math.floor((Date.now() - new Date(lastHeartbeat).getTime()) / 1000);
   const color = secondsAgo < 10 ? 'bg-green-500' : secondsAgo < 30 ? 'bg-yellow-500' : 'bg-red-500';
   ```

3. **Pulse animation:** Use a key prop that changes on each heartbeat timestamp change to re-trigger the animation:

   ```typescript
   <span
     key={lastHeartbeat} // Re-triggers animation when heartbeat changes
     className={`inline-block w-2 h-2 rounded-full ${color} animate-ping`}
   />
   ```

   Place a static dot behind it for the persistent indicator:

   ```typescript
   <span className="relative flex h-2 w-2">
     <span key={lastHeartbeat} className={`animate-ping absolute inline-flex h-full w-full rounded-full ${color} opacity-75`} />
     <span className={`relative inline-flex rounded-full h-2 w-2 ${color}`} />
   </span>
   ```

4. **Display:** `{formatTimeAgo(lastHeartbeat)}` next to the indicator

5. **Cleanup:** Clear the interval in the useEffect cleanup function

### Step 3: Implement AgentCard sub-component

**Props:**

- `agent: AgentInfo`

**Implementation:**

1. **Card container:**
   - `bg-gray-800 rounded-lg p-4 border-t-2` with agent-specific top border color
   - Map agent name to border color: coordinator=`border-purple-500`, inference=`border-blue-500`, defi=`border-green-500`, default=`border-gray-500`
   - If agent status is `'error'`, override border to `border-red-500`

2. **Card header:**
   - Agent name in uppercase: `text-sm font-bold uppercase tracking-wider`
   - Use agent-specific text color matching the border

3. **Status row:**
   - Label: `text-xs text-gray-500 uppercase tracking-wider mt-3`
   - Status indicator: colored dot + status text
   - running: green dot + "Running" in `text-green-400`
   - idle: yellow dot + "Idle" in `text-yellow-400`
   - error: red dot + "Error" in `text-red-400`
   - stopped: gray dot + "Stopped" in `text-gray-500`

4. **Heartbeat row:**
   - Label: `text-xs text-gray-500 uppercase tracking-wider mt-3`
   - HeartbeatIndicator component with `lastHeartbeat` prop

5. **Current task row:**
   - Label: `text-xs text-gray-500 uppercase tracking-wider mt-3`
   - If `agent.currentTask`: display in `text-sm text-gray-300 truncate`
   - If null: display "No active task" in `text-sm text-gray-600 italic`

6. **Uptime row:**
   - Label: `text-xs text-gray-500 uppercase tracking-wider mt-3`
   - Display `formatUptime(agent.uptimeSeconds)` in `text-sm text-gray-300`

7. **Error count row:**
   - Label: `text-xs text-gray-500 uppercase tracking-wider mt-3`
   - If errorCount > 0: display count in `text-sm text-red-400 font-medium`
   - If errorCount === 0: display "0" in `text-sm text-green-400`
   - If `agent.lastError` exists: show error message below in `text-xs text-red-400 mt-1 truncate`

### Step 4: Implement the main AgentActivity component

**Panel container:** `bg-gray-900 rounded-lg border border-gray-800 p-4`

**Layout:**

1. **Panel header:** "Agent Activity" title with connection indicator (same pattern as HCSFeed)
2. **Cards grid:** `grid grid-cols-3 gap-4 mt-4` for the three agent cards
   - On smaller widths, fall back to `grid-cols-1` if needed (but dashboard is primarily large-screen)

**Agent ordering:** Always display agents in this order:

1. Coordinator
2. Inference
3. DeFi

If the `agents` array does not contain all three, render a placeholder card for missing agents with "Waiting for agent..." text.

**Sorting logic:**

```typescript
const agentOrder = ['coordinator', 'inference', 'defi'];
const sortedAgents = agentOrder.map(name =>
  agents.find(a => a.name.toLowerCase() === name) || null
);
```

**Loading state:** Three skeleton cards with `animate-pulse` in the grid

**Empty state:** "Waiting for agents..." with sub-text

**Error state:** Panel header with error message, cards still render if partial data available

### Step 5: Verify compilation

```bash
npx tsc --noEmit
```

Must pass with zero errors.

## Critical Constraints

- **READ-ONLY**: This component only displays agent status. It never sends commands, restarts agents, or modifies agent state.
- **Memory**: The heartbeat timer (setInterval) must be cleaned up on unmount to prevent memory leaks.
- **File Size**: Keep under 500 lines. If the file gets too large, extract AgentCard to a separate file.

## Done When

- [ ] `src/components/panels/AgentActivity.tsx` exists and exports the AgentActivity component
- [ ] `src/lib/utils/formatTime.ts` exists with formatUptime and formatTimeAgo utilities
- [ ] Three agent cards render with correct accent colors
- [ ] Status row shows correct state with colored indicators
- [ ] Heartbeat indicator pulses and updates relative time every second
- [ ] Heartbeat staleness colors (green/yellow/red) work correctly
- [ ] Current task displays or shows "No active task"
- [ ] Uptime formats correctly
- [ ] Error count and last error display correctly
- [ ] Missing agents show placeholder cards
- [ ] Loading, empty, and error states render correctly
- [ ] `npx tsc --noEmit` passes with zero errors
- [ ] No file exceeds 500 lines
