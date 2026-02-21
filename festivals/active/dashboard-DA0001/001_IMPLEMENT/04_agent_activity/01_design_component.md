---
fest_type: task
fest_id: 01_design_component.md
fest_name: design_component
fest_parent: 04_agent_activity
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design Agent Activity Component

**Task Number:** 01 | **Sequence:** 04_agent_activity | **Autonomy:** medium

## Objective

Design the Agent Activity panel that shows real-time status of the three autonomous agents: coordinator, inference, and defi. This task produces the component wireframe, props interface, agent card layout, heartbeat indicator design, and status state machine.

## Requirements

- [ ] Define the component props interface
- [ ] Design the visual wireframe for the three agent cards
- [ ] Design the agent card layout with all fields
- [ ] Define the heartbeat indicator behavior
- [ ] Design status transitions and color mapping
- [ ] Design empty, loading, and error states

## Implementation

### Step 1: Define the component props interface

```typescript
import { AgentInfo, ConnectionState } from '@/lib/data/types';

interface AgentActivityProps {
  /** Array of agent status objects (one per agent) */
  agents: AgentInfo[];
  /** Current connection state of the data source */
  connectionState: ConnectionState;
  /** Whether the data source is loading */
  isLoading: boolean;
  /** Error from the data source, if any */
  error: Error | null;
  /** Optional CSS class for the container */
  className?: string;
}
```

### Step 2: Design the visual wireframe

The panel displays three agent cards in a row (or stacked on narrow viewports):

```
+-----------------------------------------------+
| Agent Activity                    [Connected]  |
+-----------------------------------------------+
| +-------------+ +-------------+ +-------------+|
| | COORDINATOR | | INFERENCE   | | DEFI        ||
| |             | |             | |             ||
| | Status:     | | Status:     | | Status:     ||
| | * Running   | | * Running   | | * Idle      ||
| |             | |             | |             ||
| | Heartbeat:  | | Heartbeat:  | | Heartbeat:  ||
| | 2s ago  *   | | 5s ago  *   | | 12s ago *   ||
| |             | |             | |             ||
| | Task:       | | Task:       | | Task:       ||
| | Assigning   | | Running     | | Waiting for ||
| | 03_hcs_feed | | inference   | | trade sig.  ||
| |             | |             | |             ||
| | Uptime:     | | Uptime:     | | Uptime:     ||
| | 1h 23m      | | 1h 22m      | | 1h 20m      ||
| |             | |             | |             ||
| | Errors: 0   | | Errors: 1   | | Errors: 0   ||
| +-------------+ +-------------+ +-------------+|
+-----------------------------------------------+
```

### Step 3: Design the agent card layout

Each agent card contains:

1. **Card header**: Agent name in uppercase, bold, with agent-specific accent color
   - Coordinator: purple accent (`border-purple-500`)
   - Inference: blue accent (`border-blue-500`)
   - DeFi: green accent (`border-green-500`)
   - Top border using the accent color (2px)

2. **Status row**: Label "Status:" with status badge
   - `running`: green pulsing dot + "Running" in green text
   - `idle`: yellow dot + "Idle" in yellow text
   - `error`: red pulsing dot + "Error" in red text
   - `stopped`: gray dot + "Stopped" in gray text

3. **Heartbeat row**: Label "Heartbeat:" with time since last heartbeat
   - Display as relative time: "2s ago", "1m ago", etc.
   - Pulsing circle animation that triggers on each heartbeat
   - Color based on staleness: green if < 10s, yellow if < 30s, red if > 30s
   - Update every second using a `setInterval`

4. **Current task row**: Label "Task:" with task description
   - If `currentTask` is not null: display the task name/description
   - If `currentTask` is null: display "No active task" in gray italic
   - Truncate long task names with `truncate` class

5. **Uptime row**: Label "Uptime:" with formatted uptime
   - Format `uptimeSeconds` as human-readable: "1h 23m", "45m 12s", "2d 3h"

6. **Error count row**: Label "Errors:" with count
   - If errorCount > 0, display in red with the count
   - If errorCount === 0, display "0" in green
   - If lastError is not null, show a tooltip or expandable section with the error message

### Step 4: Design the heartbeat indicator

The heartbeat is a small circle that visually "pulses" when a heartbeat is received:

**Behavior:**

- Display a small circle (8px) next to the heartbeat time
- On each new heartbeat event, trigger a CSS animation: scale up briefly then return
- Use CSS keyframes: `@keyframes pulse { 0% { transform: scale(1); } 50% { transform: scale(1.5); } 100% { transform: scale(1); } }`
- Re-trigger the animation by toggling a CSS class or using a key prop

**Staleness coloring:**

- Compute seconds since last heartbeat: `(Date.now() - new Date(lastHeartbeat).getTime()) / 1000`
- < 10 seconds: `bg-green-500` (healthy)
- 10-30 seconds: `bg-yellow-500` (stale)
- > 30 seconds: `bg-red-500` (possibly dead)

### Step 5: Design loading and error states

**Loading state**: Three card skeletons with `animate-pulse`, matching card dimensions

**Empty state (no agents)**: "Waiting for agents..." with sub-text "Agent status cards will appear here when agents connect to the daemon hub."

**Error state**: Panel header with error message. Agent cards may still render if partial data is available.

**Agent-level error**: When an individual agent has status `'error'`:

- Card border changes to red
- Status shows red "Error" badge
- Last error message displays below the status
- Other cards remain in their normal state

## Done When

- [ ] Props interface defined
- [ ] Visual wireframe documented with three-card layout
- [ ] Agent card layout defined with all six rows
- [ ] Agent-specific accent colors mapped
- [ ] Heartbeat indicator behavior defined with staleness thresholds
- [ ] Status badge colors defined for all four states
- [ ] Loading, empty, error, and agent-error states designed
- [ ] Design ready for implementation
