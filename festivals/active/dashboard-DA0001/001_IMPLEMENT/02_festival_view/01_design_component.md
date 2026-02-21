---
fest_type: task
fest_id: 01_design_component.md
fest_name: design_component
fest_parent: 02_festival_view
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design Festival View Component

**Task Number:** 01 | **Sequence:** 02_festival_view | **Autonomy:** medium

## Objective

Design the Festival View panel component that shows structured phase/sequence/task progress from festival data. This task produces the component wireframe, props interface, internal component structure, and styling approach. The design must support a hierarchical tree view with progress tracking.

## Requirements

- [ ] Define the component props interface
- [ ] Design the visual wireframe for the tree view
- [ ] Define internal sub-component structure
- [ ] Choose styling approach (Tailwind CSS utility classes)
- [ ] Design the expand/collapse interaction model
- [ ] Define status badge color mapping

## Implementation

### Step 1: Define the component props interface

Create or plan the props interface for the FestivalView component. The component receives festival progress data from the data layer:

```typescript
import { FestivalProgress, FestivalPhase, FestivalSequence, FestivalTask, FestivalEntityStatus } from '@/lib/data/types';

interface FestivalViewProps {
  /** Festival progress data from the data layer */
  data: FestivalProgress | null;
  /** Whether the data source is currently loading */
  isLoading: boolean;
  /** Error from the data source, if any */
  error: Error | null;
  /** Optional CSS class for the container */
  className?: string;
}
```

### Step 2: Design the visual wireframe

The Festival View panel has this visual structure:

```
+-----------------------------------------------+
| Festival Progress            [87% complete]    |
+-----------------------------------------------+
| Overall: ████████████████░░░░  87%             |
|                                                |
| v 001_IMPLEMENT                    [75%]       |
|   |  ████████████░░░░░░░░  75%                 |
|   |                                            |
|   v 01_data_layer                  [100%]      |
|   |   [x] 01_link_project        completed     |
|   |   [x] 02_design_data_layer   completed     |
|   |   [x] 03_implement_websocket completed     |
|   |   [x] 04_implement_grpc      completed     |
|   |   [x] 05_implement_mirror... completed     |
|   |   [x] 06_testing_and_verify  completed     |
|   |   [x] 07_code_review         completed     |
|   |   [x] 08_review_results_i... completed     |
|   |                                            |
|   > 02_festival_view               [50%]       |
|   > 03_hcs_feed                    [pending]   |
|   > 04_agent_activity              [pending]   |
|   > 05_defi_pnl                    [pending]   |
|   > 06_inference_metrics           [pending]   |
|   > 07_demo_polish                 [pending]   |
+-----------------------------------------------+
```

Key wireframe elements:

- **Panel header**: Title "Festival Progress" with overall completion percentage
- **Overall progress bar**: Full-width bar showing total completion
- **Phase rows**: Collapsible, showing phase name and completion percentage with progress bar
- **Sequence rows**: Nested under phases, collapsible, showing sequence name and completion
- **Task rows**: Nested under sequences, showing task name and status badge
- **Status badges**: Color-coded indicators for each status
- **Expand/collapse arrows**: `v` for expanded, `>` for collapsed

### Step 3: Define status badge color mapping

Map each `FestivalEntityStatus` to a Tailwind color:

| Status | Badge Color | Text Color | Background |
|--------|-------------|------------|------------|
| pending | gray | `text-gray-400` | `bg-gray-800` |
| active | blue | `text-blue-400` | `bg-blue-900` |
| completed | green | `text-green-400` | `bg-green-900` |
| blocked | yellow | `text-yellow-400` | `bg-yellow-900` |
| failed | red | `text-red-400` | `bg-red-900` |

### Step 4: Define internal sub-component structure

Break the FestivalView into focused sub-components:

1. **FestivalView** (main container)
   - Renders panel header with title and overall progress
   - Maps over phases and renders PhaseRow for each

2. **PhaseRow** (phase level)
   - Renders phase name, progress bar, completion percentage
   - Expand/collapse toggle for sequences
   - Maps over sequences and renders SequenceRow for each when expanded

3. **SequenceRow** (sequence level)
   - Renders sequence name, progress bar, completion percentage
   - Expand/collapse toggle for tasks
   - Maps over tasks and renders TaskRow for each when expanded

4. **TaskRow** (task level)
   - Renders task name with status badge
   - Shows task autonomy level as a subtle indicator

5. **ProgressBar** (reusable utility)
   - Accepts `percentage: number` (0-100) and optional `size: 'sm' | 'md'`
   - Renders a horizontal bar with filled portion
   - Color: green for > 80%, blue for > 50%, gray for <= 50%

6. **StatusBadge** (reusable utility)
   - Accepts `status: FestivalEntityStatus`
   - Renders a small pill/badge with the appropriate color and text

### Step 5: Design expand/collapse interaction

- Phases start expanded (show sequences)
- Sequences start collapsed (hide tasks) to conserve vertical space
- Clicking a phase row toggles its sequence visibility
- Clicking a sequence row toggles its task visibility
- Use React `useState` with a `Set<string>` to track expanded node IDs
- Animate expand/collapse with CSS transitions (optional for MVP)

### Step 6: Design empty and loading states

**Loading state**: Show a subtle skeleton/shimmer effect in the panel area. Use Tailwind's `animate-pulse` on placeholder bars.

**Empty state**: Show "No festival data available" with a description: "Festival progress will appear here once connected to a data source."

**Error state**: Show the panel header with an error message below: "Failed to load festival data: {error.message}"

## Done When

- [ ] Props interface defined for FestivalView
- [ ] Visual wireframe documented (as above)
- [ ] Status badge color mapping defined
- [ ] Sub-component breakdown documented (FestivalView, PhaseRow, SequenceRow, TaskRow, ProgressBar, StatusBadge)
- [ ] Expand/collapse interaction model defined
- [ ] Loading, empty, and error states designed
- [ ] All design decisions use Tailwind CSS for styling
- [ ] Design is ready for implementation in the next task
