---
fest_type: task
fest_id: 02_mock_data.md
fest_name: mock_data
fest_parent: 07_demo_polish
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Mock Data Providers

**Task Number:** 02 | **Sequence:** 07_demo_polish | **Autonomy:** medium

## Objective

Create mock data providers for development and demo without live agents running. The mock data should generate realistic-looking data for all five panels and be toggled on/off via an environment variable. When judges see the dashboard in mock mode, it should look indistinguishable from live data at a glance.

## Requirements

- [ ] Create `src/lib/data/mock.ts` with mock data generators for all five panels
- [ ] Create `useMockData()` hook that provides mock data matching all panel prop interfaces
- [ ] Toggle mock vs live data via `NEXT_PUBLIC_USE_MOCK` environment variable
- [ ] Mock data should include realistic agent names, task names, HCS messages, trades, and metrics
- [ ] Mock data should animate/update to simulate live activity

## Implementation

### Step 1: Create the mock data module

Create `src/lib/data/mock.ts`. This module exports functions that generate realistic mock data for each panel type.

**Mock Festival Progress:**

```typescript
export function generateMockFestivalProgress(): FestivalProgress {
  return {
    festivalId: 'DA0001',
    festivalName: 'dashboard',
    overallCompletionPercent: 72,
    phases: [
      {
        id: '001_IMPLEMENT',
        name: 'IMPLEMENT',
        status: 'active',
        completionPercent: 72,
        sequences: [
          {
            id: '01_data_layer',
            name: 'data_layer',
            status: 'completed',
            completionPercent: 100,
            tasks: [
              { id: '01', name: 'link_project', status: 'completed', autonomy: 'medium' },
              { id: '02', name: 'design_data_layer', status: 'completed', autonomy: 'medium' },
              { id: '03', name: 'implement_websocket', status: 'completed', autonomy: 'medium' },
              { id: '04', name: 'implement_grpc', status: 'completed', autonomy: 'medium' },
              { id: '05', name: 'implement_mirror_node', status: 'completed', autonomy: 'medium' },
              { id: '06', name: 'testing_and_verify', status: 'completed', autonomy: 'medium' },
              { id: '07', name: 'code_review', status: 'completed', autonomy: 'low' },
              { id: '08', name: 'review_results_iterate', status: 'completed', autonomy: 'medium' },
            ],
          },
          // Add 02_festival_view through 07_demo_polish with varying completion
          // Some completed, some active, some pending
        ],
      },
    ],
  };
}
```

Fill in all 7 sequences with realistic completion states:

- 01_data_layer: completed (100%)
- 02_festival_view: completed (100%)
- 03_hcs_feed: completed (100%)
- 04_agent_activity: completed (100%)
- 05_defi_pnl: active (60%)
- 06_inference_metrics: pending (0%)
- 07_demo_polish: pending (0%)

**Mock HCS Messages:**

```typescript
export function generateMockHCSMessages(count: number): HCSMessage[] {
  const messageTypes: DaemonEventType[] = [
    'task_assignment', 'status_update', 'task_result',
    'heartbeat', 'quality_gate', 'payment_settled',
  ];
  const agents = ['coordinator', 'inference', 'defi'];

  return Array.from({ length: count }, (_, i) => ({
    consensusTimestamp: `${Math.floor(Date.now() / 1000) - (count - i)}.${String(Math.floor(Math.random() * 999999999)).padStart(9, '0')}`,
    topicId: '0.0.12345',
    sequenceNumber: i + 1,
    message: generateMockPayload(messageTypes[i % messageTypes.length]),
    messageType: messageTypes[i % messageTypes.length],
    senderAgent: agents[i % agents.length],
    rawMessage: btoa(JSON.stringify({ type: messageTypes[i % messageTypes.length] })),
  }));
}
```

Create a `generateMockPayload()` function that returns realistic message content for each type:

- task_assignment: "Assigned task 03_implement_websocket to inference agent"
- status_update: "Task 03_implement_websocket: 45% complete, writing tests"
- task_result: "Task 03_implement_websocket completed successfully"
- heartbeat: "GPU: 78% | Memory: 45% | Active jobs: 3"
- quality_gate: "Quality gate PASSED for 01_data_layer"
- payment_settled: "Payment 0.5 HBAR settled for task completion"

**Mock Agent Status:**

```typescript
export function generateMockAgents(): AgentInfo[] {
  return [
    {
      id: 'coord-001',
      name: 'coordinator',
      status: 'running',
      lastHeartbeat: new Date(Date.now() - 3000).toISOString(),
      currentTask: 'Monitoring 05_defi_pnl sequence execution',
      uptimeSeconds: 4980,
      errorCount: 0,
      lastError: null,
    },
    {
      id: 'inf-001',
      name: 'inference',
      status: 'running',
      lastHeartbeat: new Date(Date.now() - 5000).toISOString(),
      currentTask: 'Running llama-3-8b inference job #5678',
      uptimeSeconds: 4920,
      errorCount: 1,
      lastError: 'Temporary 0G compute timeout at 14:12:03 (resolved)',
    },
    {
      id: 'defi-001',
      name: 'defi',
      status: 'idle',
      lastHeartbeat: new Date(Date.now() - 12000).toISOString(),
      currentTask: null,
      uptimeSeconds: 4800,
      errorCount: 0,
      lastError: null,
    },
  ];
}
```

**Mock DeFi P&L Data:**

```typescript
export function generateMockPnLSummary(): PnLSummary {
  return {
    totalRevenue: 1234.56,
    totalCosts: 456.78,
    netProfit: 777.78,
    tradeCount: 42,
    winCount: 30,
    lossCount: 12,
    winRate: 71.4,
  };
}

export function generateMockPnLChart(points: number): PnLDataPoint[] {
  // Generate cumulative revenue and costs over time
  // Revenue grows faster than costs for a positive P&L story
}

export function generateMockTrades(count: number): Trade[] {
  // Generate realistic ETH/USDC trades with varying P&L
}
```

**Mock Inference Metrics:**

```typescript
export function generateMockComputeMetrics(): ComputeMetrics {
  return {
    gpuUtilization: 78,
    memoryUtilization: 45,
    activeJobs: 3,
    avgLatencyMs: 120,
    totalInferences: 5678,
  };
}

export function generateMockStorageMetrics(): StorageMetrics {
  return {
    totalStorageGb: 50.0,
    usedStorageGb: 12.4,
    objectCount: 1234,
  };
}

export function generateMockINFTStatus(): INFTStatus {
  return {
    tokenId: '0.0.98765',
    status: 'active',
    modelName: 'llama-3-8b',
    inferenceCount: 5678,
    lastActive: new Date(Date.now() - 120000).toISOString(),
  };
}

export function generateMockInferenceJobs(count: number): InferenceJob[] {
  // Generate jobs with varying statuses
}
```

### Step 2: Create the useMockData hook

Create `src/hooks/useMockData.ts`:

This hook simulates live data by generating mock data and periodically updating it:

1. **Initial data**: Generate all mock data on first render

2. **Periodic updates** using `setInterval` (every 3-5 seconds):
   - Append a new HCS message to the messages array
   - Randomly update agent heartbeat timestamps
   - Occasionally change agent status or current task
   - Add a new trade to the trade history
   - Slightly adjust compute and storage metrics

3. **Return type**: A single object with all data needed by all panels:

   ```typescript
   interface MockDataResult {
     festivalProgress: FestivalProgress;
     hcsMessages: HCSMessage[];
     agents: AgentInfo[];
     pnlSummary: PnLSummary;
     pnlChart: PnLDataPoint[];
     trades: Trade[];
     compute: ComputeMetrics;
     storage: StorageMetrics;
     inft: INFTStatus;
     inferenceJobs: InferenceJob[];
     connectionState: ConnectionState;
     isLoading: boolean;
     error: null;
   }
   ```

4. **Cleanup**: Clear all intervals on unmount

### Step 3: Wire mock data into the main page

Update `src/app/page.tsx` to conditionally use mock or live data:

```typescript
const useMock = process.env.NEXT_PUBLIC_USE_MOCK === 'true';

// If mock mode, use useMockData hook
// If live mode, use useWebSocket/useGRPC + useMirrorNode hooks
```

The page component checks the env var at the top level and conditionally renders with mock or live data. Both paths provide the same data shape to the panels.

### Step 4: Environment variable

Add to `.env.local` and `.env.example`:

```
NEXT_PUBLIC_USE_MOCK=true
```

Set to `true` for development and demo without agents, `false` for live data.

### Step 5: Verify mock mode

```bash
cd $(fgo) && NEXT_PUBLIC_USE_MOCK=true npm run dev
```

Open the dashboard and verify:

- [ ] All 5 panels render with realistic-looking data
- [ ] Data updates periodically (new HCS messages appear, heartbeats update)
- [ ] No errors in console
- [ ] Dashboard looks convincing for a demo

## Done When

- [ ] `src/lib/data/mock.ts` exists with generators for all data types
- [ ] `src/hooks/useMockData.ts` exists with periodic mock data updates
- [ ] Mock data is realistic (real agent names, task names, message formats)
- [ ] `NEXT_PUBLIC_USE_MOCK=true` activates mock mode
- [ ] `NEXT_PUBLIC_USE_MOCK=false` (or unset) uses live data
- [ ] Mock data updates periodically to simulate live activity
- [ ] All panels render correctly with mock data
- [ ] `npx tsc --noEmit` passes with zero errors
