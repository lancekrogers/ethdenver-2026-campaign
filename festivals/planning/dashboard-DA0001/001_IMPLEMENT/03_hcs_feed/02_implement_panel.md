---
fest_type: task
fest_id: 02_implement_panel.md
fest_name: implement_panel
fest_parent: 03_hcs_feed
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement HCS Feed Panel

**Task Number:** 02 | **Sequence:** 03_hcs_feed | **Autonomy:** medium

## Objective

Build the HCS Feed panel component at `src/components/panels/HCSFeed.tsx`. This component renders a real-time scrolling feed of HCS messages with auto-scroll, scroll-lock, message type filtering, and formatted message display. It follows the design established in the previous task.

## Requirements

- [ ] Create `src/components/panels/HCSFeed.tsx` as the main component
- [ ] Implement MessageRow sub-component for individual messages
- [ ] Implement MessageTypeBadge for color-coded message type indicators
- [ ] Implement auto-scroll with scroll-lock on user scroll-up
- [ ] Implement message type filter dropdown
- [ ] Implement connection status indicator
- [ ] Handle loading, empty, and error states
- [ ] Style with Tailwind CSS dark theme

## Implementation

### Step 1: Implement MessageTypeBadge component

Create a small utility (can be in the same file or in `src/components/ui/MessageTypeBadge.tsx`):

**Props:**
- `type: DaemonEventType`

**Implementation:**
- Map each message type to its badge colors (from design task)
- Render a `<span>` with `text-xs px-2 py-0.5 rounded-full` and the mapped colors
- Display the type text with underscores replaced by spaces

### Step 2: Implement MessageRow sub-component

**Props:**
- `message: HCSMessage`

**Implementation details:**

1. **Container**: `border-b border-gray-800 py-2 px-3`

2. **Header line**: Flex row with:
   - Timestamp: format `consensusTimestamp` to `HH:MM:SS` using `new Date(parseFloat(consensusTimestamp) * 1000).toLocaleTimeString()` (Hedera timestamps are seconds.nanoseconds format). Use `text-xs text-gray-500 font-mono`
   - Separator: `text-gray-700 mx-2` pipe `|`
   - Agent name: `text-sm font-medium` with agent-specific color. Map agent name to color: coordinator=`text-purple-400`, inference=`text-blue-400`, defi=`text-green-400`, default=`text-gray-400`
   - Separator pipe
   - MessageTypeBadge

3. **Payload preview line**: Below the header:
   - Parse `message.message` (the decoded string) and display a summary
   - `text-sm text-gray-400 mt-1`
   - Truncate to 2 lines using `line-clamp-2` Tailwind class
   - If the decoded message is valid JSON, format key fields. If it is plain text, display directly.

### Step 3: Implement the filter dropdown

**Implementation approach:**
- Use a button in the header that toggles a dropdown panel
- Filter button text: "Filter" with count of hidden types in parentheses, e.g. "Filter (2 hidden)"
- Dropdown: `absolute z-10 bg-gray-800 border border-gray-700 rounded-lg shadow-lg p-3`
- Each message type as a checkbox row:
  - `<input type="checkbox" checked={activeFilters.has(type)} onChange={...} />`
  - Type label with its badge color
- Close dropdown on click outside (use a click-away listener via `useEffect`)

**State:**
- `activeFilters: Set<DaemonEventType>` initialized with all types
- `showFilterDropdown: boolean`

**Filtering:**
- Use `useMemo` to compute filtered messages: `messages.filter(m => activeFilters.has(m.messageType))`

### Step 4: Implement auto-scroll with scroll-lock

**Implementation:**

1. Create a `scrollContainerRef = useRef<HTMLDivElement>(null)` for the scrollable message area
2. Create a `bottomRef = useRef<HTMLDivElement>(null)` as an anchor element at the bottom of the list
3. Track `isAutoScrolling = useState(true)`
4. Track `newMessageCount = useState(0)` for the "new messages" indicator

**Scroll event handler (on the scroll container):**
```typescript
const handleScroll = useCallback(() => {
  const container = scrollContainerRef.current;
  if (!container) return;
  const isNearBottom = container.scrollHeight - container.scrollTop - container.clientHeight < 50;
  setIsAutoScrolling(isNearBottom);
  if (isNearBottom) setNewMessageCount(0);
}, []);
```

**Auto-scroll on new messages:**
```typescript
useEffect(() => {
  if (isAutoScrolling && bottomRef.current) {
    bottomRef.current.scrollIntoView({ behavior: 'smooth' });
  } else if (!isAutoScrolling) {
    // Count new messages while scroll-locked
    setNewMessageCount(prev => prev + 1);
  }
}, [filteredMessages.length, isAutoScrolling]);
```

**"New messages" indicator:**
- Show a fixed-position button at the bottom of the scroll container when `newMessageCount > 0` and `!isAutoScrolling`
- Button text: `"${newMessageCount} new messages"` with a down arrow
- On click: scroll to bottom and set `isAutoScrolling(true)`

### Step 5: Implement connection status indicator

In the panel header, right side:
- Green pulsing dot + "Connected" text when `connectionState === 'connected'`
- Yellow pulsing dot + "Connecting..." when `connectionState === 'connecting'`
- Red dot + "Disconnected" when `connectionState === 'disconnected'`
- Red dot + "Error" when `connectionState === 'error'`

Use `animate-pulse` for the pulsing effect on the dot.

### Step 6: Implement the main HCSFeed component

**Panel container**: `bg-gray-900 rounded-lg border border-gray-800 flex flex-col` with a fixed height (or flex-grow in the grid)

**Layout structure:**
1. **Header** (fixed, not scrollable): Title, filter button, connection indicator
2. **Message area** (scrollable, flex-grow): `overflow-y-auto` with messages
3. **Auto-scroll indicator** (fixed at bottom of message area, overlaid)

**State management:**
- `activeFilters: Set<DaemonEventType>` -- which message types to show
- `showFilterDropdown: boolean` -- filter dropdown visibility
- `isAutoScrolling: boolean` -- whether to auto-scroll on new messages
- `newMessageCount: number` -- count of unseen messages while scroll-locked

**Loading state**: Skeleton message rows with `animate-pulse`

**Empty state**: Centered text "No HCS messages yet" with descriptive sub-text

**Error state**: Panel header with error message below

### Step 7: Verify compilation

```bash
npx tsc --noEmit
```

Must pass with zero errors.

## Critical Constraints

- **READ-ONLY**: This component only displays HCS messages. It never publishes messages to any HCS topic.
- **Performance**: The component must handle 1000+ messages. Use virtualized list (react-window) if performance becomes an issue, but start with a simple list since the feed is bounded.
- **Memory**: Messages array should already be bounded by the data layer hooks. The component does not need additional bounding.
- **Timestamp Parsing**: Hedera consensus timestamps are in `seconds.nanoseconds` format (e.g., `1708300000.123456789`). Parse carefully.

## Done When

- [ ] `src/components/panels/HCSFeed.tsx` exists and exports the HCSFeed component
- [ ] Message rows display timestamp, sender agent, type badge, and payload preview
- [ ] Auto-scroll works when user is at bottom
- [ ] Scroll-lock activates when user scrolls up
- [ ] "New messages" indicator appears when scroll-locked
- [ ] Filter dropdown allows toggling message types
- [ ] Connection status indicator shows current state
- [ ] Loading, empty, and error states render correctly
- [ ] Dark theme styling with Tailwind CSS
- [ ] `npx tsc --noEmit` passes with zero errors
- [ ] No file exceeds 500 lines
