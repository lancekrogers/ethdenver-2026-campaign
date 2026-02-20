---
fest_type: task
fest_id: 01_design_component.md
fest_name: design_component
fest_parent: 03_hcs_feed
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design HCS Feed Component

**Task Number:** 01 | **Sequence:** 03_hcs_feed | **Autonomy:** medium

## Objective

Design the HCS Feed panel that shows live agent-to-agent messages from the Hedera Consensus Service. This task produces the component wireframe, props interface, interaction model for auto-scrolling and filtering, and the message row layout.

## Requirements

- [ ] Define the component props interface
- [ ] Design the visual wireframe for the message feed
- [ ] Design the message row layout with all fields
- [ ] Define the auto-scroll behavior with scroll-lock
- [ ] Define the message type filter UI
- [ ] Design empty, loading, and error states

## Implementation

### Step 1: Define the component props interface

```typescript
import { HCSMessage, HCSFeedFilter, ConnectionState } from '@/lib/data/types';

interface HCSFeedProps {
  /** Array of HCS messages to display, ordered by consensus timestamp */
  messages: HCSMessage[];
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

```
+-----------------------------------------------+
| HCS Message Feed        [Filter v] [Connected] |
+-----------------------------------------------+
| 14:32:01 | coordinator | task_assignment       |
| Assigned task 03_implement_websocket to         |
| inference agent                                 |
|---------------------------------------------- -|
| 14:32:03 | inference   | status_update          |
| Starting task execution...                      |
|-------------------------------------------------|
| 14:32:15 | inference   | heartbeat              |
| GPU: 78% | Memory: 45% | Active jobs: 3         |
|-------------------------------------------------|
| 14:32:30 | defi        | payment_settled        |
| Payment 0.5 HBAR settled for task completion    |
|-------------------------------------------------|
| 14:32:45 | coordinator | quality_gate           |
| Quality gate PASSED for 01_data_layer           |
|-------------------------------------------------|
|                     v auto-scrolling            |
+-----------------------------------------------+
```

Key wireframe elements:

- **Panel header**: Title "HCS Message Feed" with filter dropdown and connection indicator
- **Connection indicator**: Green dot for connected, yellow for connecting, red for disconnected/error
- **Filter dropdown**: Multi-select for message types (task_assignment, status_update, heartbeat, etc.)
- **Message rows**: Each row shows timestamp, sender agent, message type badge, and payload preview
- **Auto-scroll indicator**: Small label at the bottom showing "auto-scrolling" or "scroll locked"

### Step 3: Design the message row layout

Each message row has two lines:

**Line 1 (header):** `[timestamp] | [sender_agent] | [message_type_badge]`

- Timestamp: `text-xs text-gray-500` formatted as `HH:MM:SS`
- Separator: `text-gray-700` pipe character
- Sender agent: `text-sm text-gray-300` with agent-specific color (coordinator=purple, inference=blue, defi=green)
- Message type badge: Small pill with type-specific color (same as StatusBadge approach)

**Line 2 (payload preview):** Truncated payload text

- `text-sm text-gray-400`
- Max 2 lines, truncated with ellipsis
- Parse the JSON payload and display a human-readable summary

**Message type badge colors:**

| Type | Color |
|------|-------|
| task_assignment | `bg-purple-900 text-purple-400` |
| status_update | `bg-blue-900 text-blue-400` |
| task_result | `bg-green-900 text-green-400` |
| heartbeat | `bg-gray-800 text-gray-400` |
| quality_gate | `bg-yellow-900 text-yellow-400` |
| payment_settled | `bg-emerald-900 text-emerald-400` |

**Agent name colors:**

| Agent | Color |
|-------|-------|
| coordinator | `text-purple-400` |
| inference | `text-blue-400` |
| defi | `text-green-400` |
| unknown/other | `text-gray-400` |

### Step 4: Design the auto-scroll behavior

The feed must auto-scroll to show the newest messages at the bottom, but allow the user to scroll up to read older messages without the feed jumping back down.

**Auto-scroll rules:**

1. When new messages arrive and the user is at the bottom (within 50px), auto-scroll to the new message
2. When the user scrolls up (more than 50px from bottom), disable auto-scroll ("scroll locked")
3. Show a "New messages below" button/indicator when scroll-locked and new messages arrive
4. Clicking the indicator scrolls to bottom and re-enables auto-scroll
5. Use `scrollIntoView({ behavior: 'smooth' })` for smooth scrolling

**Implementation approach:**

- Use a `useRef` on the scroll container
- Track `isAutoScrolling` state
- On scroll event, check if user is near bottom: `scrollHeight - scrollTop - clientHeight < 50`
- On new messages, if isAutoScrolling, scroll to bottom

### Step 5: Design the filter UI

**Filter dropdown:**

- Located in the panel header, right-aligned
- Toggle button showing "Filter" with a count of active filters
- Dropdown panel with checkboxes for each message type
- All types checked by default
- Unchecking a type hides those messages from the feed
- Filter state managed in component with `useState<Set<DaemonEventType>>`
- Filtered messages computed with `useMemo` from the full messages array

### Step 6: Design loading, empty, and error states

**Loading state**: Skeleton with 3-4 pulsing message row placeholders using `animate-pulse`

**Empty state**: "No HCS messages yet" with sub-text "Messages will appear here as agents communicate through Hedera Consensus Service topics."

**Error state**: Error message with red text, connection status indicator

## Done When

- [ ] Props interface defined
- [ ] Visual wireframe documented
- [ ] Message row layout defined with colors and typography
- [ ] Auto-scroll behavior documented with scroll-lock rules
- [ ] Filter UI designed with interaction model
- [ ] Loading, empty, and error states designed
- [ ] Agent name color mapping defined
- [ ] Message type badge color mapping defined
- [ ] Design ready for implementation
