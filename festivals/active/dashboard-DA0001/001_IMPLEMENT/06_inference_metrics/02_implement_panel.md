---
fest_type: task
fest_id: 02_implement_panel.md
fest_name: implement_panel
fest_parent: 06_inference_metrics
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Inference Metrics Panel

**Task Number:** 02 | **Sequence:** 06_inference_metrics | **Autonomy:** medium

## Objective

Build the Inference Metrics panel component at `src/components/panels/InferenceMetrics.tsx`. This component renders a compute utilization gauge, storage usage bar, iNFT status card, and inference job history table. It follows the design from the previous task.

## Requirements

- [ ] Create `src/components/panels/InferenceMetrics.tsx` as the main component
- [ ] Implement ComputeGauge sub-component with SVG circular progress
- [ ] Implement StorageUsage sub-component reusing ProgressBar
- [ ] Implement INFTCard sub-component
- [ ] Implement JobTable sub-component
- [ ] Handle loading, empty, and error states
- [ ] Style with Tailwind CSS dark theme

## Implementation

### Step 1: Implement ComputeGauge sub-component

**Props:**

- `compute: ComputeMetrics | null`

**Implementation:**

1. **SVG Circular Progress Ring:**
   Create a simple SVG gauge for GPU utilization:

   ```tsx
   const percentage = compute?.gpuUtilization ?? 0;
   const color = percentage < 50 ? '#22c55e' : percentage < 80 ? '#eab308' : '#ef4444';
   const circumference = 2 * Math.PI * 15.9; // radius = 15.9
   const dashArray = `${(percentage / 100) * circumference} ${circumference}`;

   <div className="relative w-32 h-32 mx-auto">
     <svg viewBox="0 0 36 36" className="w-full h-full">
       {/* Background circle */}
       <circle
         cx="18" cy="18" r="15.9"
         fill="none"
         stroke="#374151"
         strokeWidth="3"
       />
       {/* Progress arc */}
       <circle
         cx="18" cy="18" r="15.9"
         fill="none"
         stroke={color}
         strokeWidth="3"
         strokeLinecap="round"
         strokeDasharray={dashArray}
         transform="rotate(-90 18 18)"
         className="transition-all duration-500"
       />
     </svg>
     {/* Center text */}
     <div className="absolute inset-0 flex items-center justify-center">
       <span className="text-2xl font-bold" style={{ color }}>
         {percentage}%
       </span>
     </div>
   </div>
   ```

2. **Label**: "GPU Utilization" centered above the gauge in `text-xs text-gray-500 uppercase tracking-wider`

3. **Stat rows below the gauge** in a 2x2 grid:
   - "Memory" : `{compute.memoryUtilization}%` with same color logic
   - "Active Jobs" : `{compute.activeJobs}`
   - "Avg Latency" : `{compute.avgLatencyMs}ms`
   - "Total" : `{compute.totalInferences.toLocaleString()}`

   Each stat: label in `text-xs text-gray-500` and value in `text-sm text-gray-300`

4. **Null handling**: When compute is null, show skeleton with `animate-pulse`

### Step 2: Implement StorageUsage sub-component

**Props:**

- `storage: StorageMetrics | null`

**Implementation:**

1. **Card container**: `bg-gray-800 rounded-lg p-4`

2. **Header**: "Storage Usage" in `text-xs text-gray-500 uppercase tracking-wider`

3. **Usage text**:
   - "Used: {usedStorageGb.toFixed(1)} GB" in `text-sm text-white`
   - "Total: {totalStorageGb.toFixed(1)} GB" in `text-sm text-gray-500`

4. **Progress bar**: Reuse the `ProgressBar` component from `src/components/ui/ProgressBar.tsx`:

   ```tsx
   const percentage = storage ? (storage.usedStorageGb / storage.totalStorageGb) * 100 : 0;
   <ProgressBar percentage={percentage} size="md" />
   ```

5. **Percentage and object count**:
   - `{percentage.toFixed(1)}%` in `text-sm`
   - "Objects: {storage.objectCount.toLocaleString()}" in `text-xs text-gray-500`

6. **Null handling**: Skeleton with `animate-pulse`

### Step 3: Implement INFTCard sub-component

**Props:**

- `inft: INFTStatus | null`

**Implementation:**

1. **Card container**: `bg-gray-800 rounded-lg p-4` spanning full width

2. **Header**: "iNFT Status" in `text-xs text-gray-500 uppercase tracking-wider mb-2`

3. **Two-column layout** using `grid grid-cols-2 gap-4`:
   - Left column:
     - "Token: {inft.tokenId}" in `text-sm text-gray-300`
     - "Status: " with StatusBadge for inft.status (map 'active'='completed', 'minting'='active', 'inactive'='pending' to StatusBadge)
   - Right column:
     - "Model: {inft.modelName}" in `text-sm text-gray-300`
     - "Inferences: {inft.inferenceCount.toLocaleString()}" in `text-sm text-gray-300`

4. **Last active**: Below the grid:
   - "Last Active: {formatTimeAgo(inft.lastActive)}" in `text-xs text-gray-500 mt-2`
   - Reuse `formatTimeAgo` from `src/lib/utils/formatTime.ts`

5. **Null handling**: Skeleton layout

### Step 4: Implement JobTable sub-component

**Props:**

- `jobs: InferenceJob[]`

**Implementation:**

1. **Section header**: "Recent Inference Jobs" in `text-xs text-gray-500 uppercase tracking-wider mb-2`

2. **Table container**: `overflow-y-auto max-h-[180px]`

3. **Table header**: Sticky, with columns: Model, Status, Tokens, Latency, Time

4. **Table rows**: Map over jobs (sorted by timestamp descending, limited to 30):

   ```tsx
   {jobs.slice(0, 30).map(job => (
     <tr key={job.id} className="text-sm text-gray-300 border-b border-gray-800">
       <td className="py-1.5 truncate max-w-[100px]">{job.model}</td>
       <td className="py-1.5 text-center">
         <span className={`text-xs px-2 py-0.5 rounded-full ${statusColors[job.status]}`}>
           {job.status}
         </span>
       </td>
       <td className="py-1.5 text-center font-mono text-xs">
         {job.inputTokens}/{job.status === 'running' ? '...' : job.outputTokens}
       </td>
       <td className="py-1.5 text-right font-mono text-xs">
         {job.status === 'running' ? '...' : `${job.latencyMs}ms`}
       </td>
       <td className="py-1.5 text-right text-xs text-gray-500">
         {new Date(job.timestamp).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}
       </td>
     </tr>
   ))}
   ```

5. **Status color mapping:**
   - pending: `bg-gray-800 text-gray-400`
   - running: `bg-blue-900 text-blue-400`
   - completed: `bg-green-900 text-green-400`
   - failed: `bg-red-900 text-red-400`

6. **Empty state**: "No inference jobs recorded yet."

### Step 5: Implement the main InferenceMetrics component

**Panel container**: `bg-gray-900 rounded-lg border border-gray-800 p-4 flex flex-col`

**Layout:**

1. **Panel header**: "Inference & 0G Metrics" with connection indicator
2. **Top section**: `grid grid-cols-2 gap-4 mt-4`
   - Left: ComputeGauge
   - Right: StorageUsage
3. **Middle section**: INFTCard (full width, `mt-4`)
4. **Bottom section**: JobTable (`mt-4`)

**Loading state**: Skeleton for all sub-components

**Empty state**: "No inference data available" with sub-text

**Error state**: Panel header with error message

### Step 6: Verify compilation

```bash
npx tsc --noEmit
```

Must pass with zero errors.

## Critical Constraints

- **READ-ONLY**: This component only displays inference metrics. It never submits inference jobs, uploads to storage, or modifies iNFT state.
- **SVG Simplicity**: Use simple SVG for the gauge (no complex D3 or external gauge libraries). A single `<circle>` with `strokeDasharray` is sufficient.
- **File Size**: Keep under 500 lines. Extract sub-components to separate files if needed.

## Done When

- [ ] `src/components/panels/InferenceMetrics.tsx` exists and exports the InferenceMetrics component
- [ ] Compute gauge renders GPU utilization with circular progress ring
- [ ] Gauge color transitions: green < 50%, yellow 50-80%, red > 80%
- [ ] Storage bar shows used vs total with progress bar
- [ ] iNFT card shows token ID, status, model name, inference count
- [ ] Job table shows recent jobs with status badges
- [ ] Running jobs show "..." for pending output tokens and latency
- [ ] Loading, empty, and error states render correctly
- [ ] Dark theme styling throughout
- [ ] `npx tsc --noEmit` passes with zero errors
- [ ] No file exceeds 500 lines
