---
fest_type: task
fest_id: 01_design_component.md
fest_name: design_component
fest_parent: 06_inference_metrics
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design Inference Metrics Component

**Task Number:** 01 | **Sequence:** 06_inference_metrics | **Autonomy:** medium

## Objective

Design the Inference Metrics panel that shows 0G compute utilization, storage usage, and iNFT status. This task produces the component wireframe, props interface, gauge/bar chart designs, iNFT card layout, and inference job table design.

## Requirements

- [ ] Define the component props interface
- [ ] Design the visual wireframe with compute gauge, storage bar, iNFT card, and job table
- [ ] Design the compute utilization gauge display
- [ ] Design the storage usage bar
- [ ] Design the iNFT status card
- [ ] Design the inference job history table
- [ ] Design empty, loading, and error states

## Implementation

### Step 1: Define the component props interface

```typescript
import { ComputeMetrics, StorageMetrics, INFTStatus, InferenceJob, ConnectionState } from '@/lib/data/types';

interface InferenceMetricsProps {
  /** Current compute utilization metrics */
  compute: ComputeMetrics | null;
  /** Current storage usage metrics */
  storage: StorageMetrics | null;
  /** Current iNFT status */
  inft: INFTStatus | null;
  /** Recent inference jobs */
  jobs: InferenceJob[];
  /** Connection state */
  connectionState: ConnectionState;
  /** Whether data is loading */
  isLoading: boolean;
  /** Error from data source */
  error: Error | null;
  /** Optional CSS class */
  className?: string;
}
```

### Step 2: Design the visual wireframe

```
+-----------------------------------------------+
| Inference & 0G Metrics            [Connected]  |
+-----------------------------------------------+
| +-------------------+ +---------------------+ |
| | GPU Utilization    | | Storage Usage       | |
| |                    | |                     | |
| |   ___              | | Used: 12.4 GB       | |
| |  /   \    78%      | | Total: 50.0 GB      | |
| | |     |            | |                     | |
| |  \___/             | | ████████████░░░░░░  | |
| |                    | | 24.8%               | |
| | Memory: 45%        | |                     | |
| | Active Jobs: 3     | | Objects: 1,234      | |
| | Avg Latency: 120ms | |                     | |
| | Total: 5,678       | |                     | |
| +-------------------+ +---------------------+ |
|                                               |
| +-------------------------------------------+ |
| | iNFT Status                                | |
| | Token: 0.0.12345  Model: llama-3-8b       | |
| | Status: Active     Inferences: 5,678      | |
| | Last Active: 2 minutes ago                 | |
| +-------------------------------------------+ |
|                                               |
| Recent Inference Jobs                         |
| Model   | Status  | In/Out  | Latency | Time |
| llama-3 | done    | 512/128 | 120ms   | 14:32|
| llama-3 | running | 256/... | ...     | 14:31|
| llama-3 | done    | 1024/256| 340ms   | 14:28|
+-----------------------------------------------+
```

### Step 3: Design the compute utilization display

Instead of a complex SVG gauge (which adds implementation complexity for the hackathon), use a simple and visually impactful approach:

**GPU Utilization:**
- Large percentage number: `text-4xl font-bold` in the center
- Color based on utilization: green (< 50%), yellow (50-80%), red (> 80%)
- Circular progress ring using SVG (a simple circle with `stroke-dasharray`):
  ```
  <svg viewBox="0 0 36 36">
    <circle cx="18" cy="18" r="15.9" fill="none" stroke="#374151" strokeWidth="3" />
    <circle cx="18" cy="18" r="15.9" fill="none" stroke={color} strokeWidth="3"
      strokeDasharray={`${percentage} ${100 - percentage}`}
      strokeDashoffset="25" transform="rotate(-90 18 18)" />
  </svg>
  ```
- Below the gauge: three stat rows in `text-sm`:
  - "Memory: {memoryUtilization}%"
  - "Active Jobs: {activeJobs}"
  - "Avg Latency: {avgLatencyMs}ms"
  - "Total Inferences: {totalInferences}"

### Step 4: Design the storage usage bar

**Layout:** Card with storage metrics
- "Used: {usedStorageGb} GB" in white text
- "Total: {totalStorageGb} GB" in gray text
- Full-width progress bar (reuse ProgressBar component from 02_festival_view):
  - Percentage: `(usedStorageGb / totalStorageGb) * 100`
  - Color: green if < 60%, yellow if 60-80%, red if > 80%
- Below the bar: percentage text
- "Objects: {objectCount.toLocaleString()}" in small gray text

### Step 5: Design the iNFT status card

**Layout:** Full-width card below the gauge and storage:
- Two-column layout:
  - Left: "Token: {tokenId}" and "Status: {status}" with status badge
  - Right: "Model: {modelName}" and "Inferences: {inferenceCount.toLocaleString()}"
- Below: "Last Active: {relative time from lastActive}"

**Status badges (reuse StatusBadge pattern):**
- active: green
- minting: yellow/amber
- inactive: gray

### Step 6: Design the inference job history table

**Columns:**

| Column | Alignment | Format |
|--------|-----------|--------|
| Model | left | model name, truncated |
| Status | center | badge (pending=gray, running=blue, completed=green, failed=red) |
| Tokens | center | "{inputTokens}/{outputTokens}" |
| Latency | right | "{latencyMs}ms" (or "..." if running) |
| Time | right | HH:MM format |

**Table styling:** Same patterns as DeFi trade table -- scrollable, dark theme, sticky header

### Step 7: Design loading, empty, and error states

**Loading**: Skeleton gauge, storage bar, and table rows

**Empty**: "No inference data available" with sub-text "Inference metrics will display once the inference agent connects to 0G compute."

**Error**: Panel header with error message

## Done When

- [ ] Props interface defined
- [ ] Visual wireframe documented
- [ ] Compute gauge design specified (SVG circular progress)
- [ ] Storage bar design specified (reusing ProgressBar)
- [ ] iNFT status card layout defined
- [ ] Job history table columns and styling defined
- [ ] Loading, empty, error states designed
- [ ] Design ready for implementation
