---
fest_type: task
fest_id: 02_implement_panel.md
fest_name: implement_panel
fest_parent: 02_festival_view
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Festival View Panel

**Task Number:** 02 | **Sequence:** 02_festival_view | **Autonomy:** medium

## Objective

Build the Festival View panel component at `src/components/panels/FestivalView.tsx`. This component renders the hierarchical festival progress tree with phases, sequences, and tasks, each with progress bars and status badges. It follows the design established in the previous task.

## Requirements

- [ ] Create `src/components/panels/FestivalView.tsx` as the main component
- [ ] Implement PhaseRow, SequenceRow, and TaskRow sub-components
- [ ] Implement reusable ProgressBar and StatusBadge utility components
- [ ] Render phase > sequence > task hierarchy with expand/collapse
- [ ] Show completion percentages and progress bars at phase and sequence levels
- [ ] Show status badges on tasks
- [ ] Handle loading, empty, and error states
- [ ] Style with Tailwind CSS using dark theme for demo visibility

## Implementation

### Step 1: Create the component directory

```bash
mkdir -p src/components/panels src/components/ui
```

### Step 2: Implement ProgressBar utility component

Create `src/components/ui/ProgressBar.tsx`:

This component renders a horizontal progress bar.

**Props:**

- `percentage: number` -- value from 0 to 100
- `size?: 'sm' | 'md'` -- height variant, defaults to `'sm'`
- `className?: string` -- additional CSS classes

**Implementation details:**

- Outer container: `bg-gray-700 rounded-full overflow-hidden` with height based on size (`h-1.5` for sm, `h-2.5` for md)
- Inner fill: `rounded-full transition-all duration-500` with width set to `${percentage}%`
- Color logic: `bg-green-500` if percentage > 80, `bg-blue-500` if > 50, `bg-gray-500` if <= 50
- Clamp percentage to 0-100 range

### Step 3: Implement StatusBadge utility component

Create `src/components/ui/StatusBadge.tsx`:

This component renders a small status pill.

**Props:**

- `status: FestivalEntityStatus`
- `className?: string`

**Implementation details:**

- Use a `<span>` with rounded-full padding
- Color mapping from the design task:
  - `pending`: `bg-gray-800 text-gray-400`
  - `active`: `bg-blue-900 text-blue-400`
  - `completed`: `bg-green-900 text-green-400`
  - `blocked`: `bg-yellow-900 text-yellow-400`
  - `failed`: `bg-red-900 text-red-400`
- Display the status text in lowercase
- Font size: `text-xs`

### Step 4: Implement TaskRow sub-component

This can be defined within the FestivalView file or as a separate component. Recommend keeping it in the same file if the file stays under 500 lines.

**Props:**

- `task: FestivalTask`

**Implementation details:**

- Render a flex row with:
  - A checkbox-style indicator: `[x]` for completed, `[ ]` for other statuses (use a small icon or text)
  - Task name (truncate long names with `truncate` class)
  - StatusBadge aligned to the right
- Padding: `pl-10` for indentation under sequences
- Font size: `text-sm`
- Text color: `text-gray-300`

### Step 5: Implement SequenceRow sub-component

**Props:**

- `sequence: FestivalSequence`
- `isExpanded: boolean`
- `onToggle: () => void`

**Implementation details:**

- Render a clickable flex row with:
  - Expand/collapse arrow: `>` when collapsed, `v` when expanded (use `ChevronRight` / `ChevronDown` or simple text, rotated with CSS transform)
  - Sequence name
  - Completion percentage text (e.g., `75%`)
  - ProgressBar (size sm) showing completion
- On click, call `onToggle`
- When expanded, render TaskRow for each task in `sequence.tasks`
- Padding: `pl-6` for indentation under phases
- Cursor: `cursor-pointer`
- Hover: `hover:bg-gray-800/50` for interactive feedback

### Step 6: Implement PhaseRow sub-component

**Props:**

- `phase: FestivalPhase`
- `isExpanded: boolean`
- `onToggle: () => void`
- `expandedSequences: Set<string>`
- `onToggleSequence: (sequenceId: string) => void`

**Implementation details:**

- Render a clickable flex row with:
  - Expand/collapse arrow
  - Phase name (bold, slightly larger text)
  - Completion percentage
  - ProgressBar (size md) showing completion
- On click, call `onToggle`
- When expanded, render SequenceRow for each sequence in `phase.sequences`
- Pass expand state for each sequence
- Padding: `pl-2`
- Background: subtle border-bottom for visual separation

### Step 7: Implement the main FestivalView component

Create `src/components/panels/FestivalView.tsx`:

**Props (from design):**

- `data: FestivalProgress | null`
- `isLoading: boolean`
- `error: Error | null`
- `className?: string`

**State:**

- `expandedPhases: Set<string>` -- tracks which phases are expanded (default: all expanded)
- `expandedSequences: Set<string>` -- tracks which sequences are expanded (default: none)

**Implementation details:**

1. **Panel container**: `bg-gray-900 rounded-lg border border-gray-800 p-4 overflow-auto` with optional className merged

2. **Panel header**:
   - Title: "Festival Progress" in `text-lg font-semibold text-white`
   - Overall completion: `{data.overallCompletionPercent}% complete` in `text-sm text-gray-400`
   - Overall ProgressBar (size md) spanning full width below header

3. **Loading state**: When `isLoading && !data`:
   - Render panel header skeleton with `animate-pulse bg-gray-800 rounded h-4 w-48`
   - Render 3-4 skeleton rows with varying widths

4. **Error state**: When `error`:
   - Render panel header
   - Below: red text with error icon and message
   - Suggest: "Check your data source connection"

5. **Empty state**: When `!data && !isLoading && !error`:
   - Render panel header
   - Below: gray text "No festival data available"
   - Sub-text: "Festival progress will appear here once connected to a data source."

6. **Data state**: When `data`:
   - Render panel header with actual data
   - Map over `data.phases` and render PhaseRow for each
   - Pass expand/collapse state and toggle handlers

7. **Toggle handlers**:
   - `togglePhase(phaseId)`: add/remove from expandedPhases Set (create new Set for immutability)
   - `toggleSequence(sequenceId)`: add/remove from expandedSequences Set
   - Initialize expandedPhases with all phase IDs (phases start expanded)

### Step 8: Verify compilation and rendering

```bash
npx tsc --noEmit
```

Must pass with zero errors.

Temporarily render the component on the main page to verify it works:

```typescript
// In src/app/page.tsx (temporary, will be replaced in 07_demo_polish)
import { FestivalView } from '@/components/panels/FestivalView';

// Use mock data or null to verify loading/empty states render
```

## Critical Constraints

- **READ-ONLY**: This component only displays data. It never modifies festival state, writes to disk, or calls any mutation APIs.
- **File Size**: Keep the main component file under 500 lines. Extract sub-components to separate files if needed.
- **Dark Theme**: All colors must work on dark backgrounds (bg-gray-900). Do not use light theme colors.

## Done When

- [ ] `src/components/panels/FestivalView.tsx` exists and exports the FestivalView component
- [ ] `src/components/ui/ProgressBar.tsx` exists and exports the ProgressBar component
- [ ] `src/components/ui/StatusBadge.tsx` exists and exports the StatusBadge component
- [ ] Phase > sequence > task hierarchy renders correctly
- [ ] Expand/collapse works on phases and sequences
- [ ] Progress bars show correct completion percentages
- [ ] Status badges show correct colors for each status
- [ ] Loading, empty, and error states render correctly
- [ ] All styling uses Tailwind CSS with dark theme
- [ ] `npx tsc --noEmit` passes with zero errors
- [ ] No file exceeds 500 lines
