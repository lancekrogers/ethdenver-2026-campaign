---
fest_type: task
fest_id: 02_design_data_layer.md
fest_name: design_data_layer
fest_parent: 01_data_layer
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design Data Layer

**Task Number:** 02 | **Sequence:** 01_data_layer | **Autonomy:** medium

## Objective

Design the complete data layer architecture for the dashboard. This task produces the TypeScript types file that defines all data structures for every data source (daemon hub, gRPC, mirror node) and every panel. It also defines the connector interfaces and React hook signatures that all subsequent implementation tasks must satisfy.

## Requirements

- [ ] Create the data layer package directory at `src/lib/data/`
- [ ] Create the hooks directory at `src/hooks/`
- [ ] Define TypeScript interfaces for all data source responses
- [ ] Define types for all five panel data shapes
- [ ] Define connector interfaces: WebSocketConnector, GRPCConnector, MirrorNodeClient
- [ ] Define React hook return types for each data stream
- [ ] Write all types to `src/lib/data/types.ts`

## Implementation

### Step 1: Create the directory structure

From the dashboard project root (navigate with `fgo`), create the data layer directories:

```
src/
  lib/
    data/
      types.ts
  hooks/
```

Create these directories if they do not exist:

```bash
mkdir -p src/lib/data src/hooks
```

### Step 2: Write types.ts -- Connection Types

Create `src/lib/data/types.ts`. Start with connection state types that all connectors share:

```typescript
// ============================================================
// Connection State Types
// ============================================================

/** Connection states for all real-time data connectors */
export type ConnectionState = 'connecting' | 'connected' | 'disconnected' | 'error';

/** Base interface for all connector configurations */
export interface ConnectorConfig {
  /** URL endpoint for the data source */
  url: string;
  /** Whether to automatically reconnect on disconnect */
  autoReconnect: boolean;
  /** Delay in milliseconds between reconnect attempts */
  reconnectDelayMs: number;
  /** Maximum number of reconnect attempts (0 = unlimited) */
  maxReconnectAttempts: number;
}

/** Base return type for all data hooks */
export interface DataHookResult<T> {
  /** Current data from the stream */
  data: T | null;
  /** Current connection state */
  connectionState: ConnectionState;
  /** Error if any occurred */
  error: Error | null;
  /** Whether data is currently being loaded */
  isLoading: boolean;
}
```

### Step 3: Write types.ts -- Daemon Event Types

Continue in `src/lib/data/types.ts` with daemon event types. These are the events that flow through the daemon hub WebSocket and direct gRPC connections:

```typescript
// ============================================================
// Daemon Event Types (WebSocket + gRPC)
// ============================================================

/** All possible daemon event types */
export type DaemonEventType =
  | 'task_assignment'
  | 'status_update'
  | 'task_result'
  | 'heartbeat'
  | 'quality_gate'
  | 'payment_settled'
  | 'agent_started'
  | 'agent_stopped'
  | 'agent_error';

/** A single daemon event from the hub */
export interface DaemonEvent {
  /** Event type identifier */
  type: DaemonEventType;
  /** ID of the agent that produced this event */
  agentId: string;
  /** Human-readable agent name */
  agentName: string;
  /** Event timestamp from the daemon */
  timestamp: string;
  /** Event-specific payload (varies by type) */
  payload: Record<string, unknown>;
}

/** Agent status as reported by daemon heartbeats */
export type AgentStatus = 'running' | 'idle' | 'error' | 'stopped';

/** Real-time status of a single agent */
export interface AgentInfo {
  /** Unique agent identifier */
  id: string;
  /** Human-readable agent name (coordinator, inference, defi) */
  name: string;
  /** Current agent status */
  status: AgentStatus;
  /** ISO timestamp of last heartbeat received */
  lastHeartbeat: string;
  /** Description of current task being executed, if any */
  currentTask: string | null;
  /** Agent uptime in seconds */
  uptimeSeconds: number;
  /** Number of errors since last restart */
  errorCount: number;
  /** Most recent error message, if status is 'error' */
  lastError: string | null;
}
```

### Step 4: Write types.ts -- HCS Message Types

Continue with Hedera Consensus Service message types:

```typescript
// ============================================================
// HCS Message Types (Mirror Node + WebSocket)
// ============================================================

/** A single HCS message as displayed in the feed */
export interface HCSMessage {
  /** Consensus timestamp (unique message ID on Hedera) */
  consensusTimestamp: string;
  /** Topic ID the message was published to */
  topicId: string;
  /** Sequence number within the topic */
  sequenceNumber: number;
  /** Decoded message content */
  message: string;
  /** Parsed message type from the envelope */
  messageType: DaemonEventType;
  /** Sender agent identifier from the envelope */
  senderAgent: string;
  /** Raw message bytes (base64 encoded) */
  rawMessage: string;
}

/** Filter options for the HCS feed */
export interface HCSFeedFilter {
  /** Filter by message type(s) */
  messageTypes?: DaemonEventType[];
  /** Filter by sender agent ID */
  senderAgent?: string;
  /** Filter by topic ID */
  topicId?: string;
}
```

### Step 5: Write types.ts -- DeFi and Inference Types

Continue with DeFi P&L and inference metrics types:

```typescript
// ============================================================
// DeFi P&L Types (Base Chain)
// ============================================================

/** A single trade executed by the DeFi agent */
export interface Trade {
  /** Unique trade identifier */
  id: string;
  /** Trade pair (e.g., "ETH/USDC") */
  pair: string;
  /** Trade direction */
  side: 'buy' | 'sell';
  /** Trade amount in base currency */
  amount: number;
  /** Execution price */
  price: number;
  /** Trade timestamp */
  timestamp: string;
  /** Profit or loss from this trade in USD */
  pnl: number;
  /** Gas cost in USD */
  gasCost: number;
  /** Transaction hash on Base */
  txHash: string;
}

/** Aggregated P&L summary */
export interface PnLSummary {
  /** Total revenue from profitable trades in USD */
  totalRevenue: number;
  /** Total costs (losses + gas) in USD */
  totalCosts: number;
  /** Net profit/loss in USD */
  netProfit: number;
  /** Total number of trades executed */
  tradeCount: number;
  /** Number of profitable trades */
  winCount: number;
  /** Number of losing trades */
  lossCount: number;
  /** Win rate as percentage (0-100) */
  winRate: number;
}

/** Time-series data point for P&L chart */
export interface PnLDataPoint {
  /** Timestamp for this data point */
  timestamp: string;
  /** Cumulative revenue at this point */
  cumulativeRevenue: number;
  /** Cumulative costs at this point */
  cumulativeCosts: number;
  /** Cumulative net profit at this point */
  cumulativeProfit: number;
}

// ============================================================
// Inference & 0G Metrics Types
// ============================================================

/** Current compute utilization metrics from 0G */
export interface ComputeMetrics {
  /** Current GPU utilization percentage (0-100) */
  gpuUtilization: number;
  /** Current memory utilization percentage (0-100) */
  memoryUtilization: number;
  /** Number of active inference jobs */
  activeJobs: number;
  /** Average inference latency in milliseconds */
  avgLatencyMs: number;
  /** Total inferences completed */
  totalInferences: number;
}

/** Storage metrics from 0G */
export interface StorageMetrics {
  /** Total storage allocated in GB */
  totalStorageGb: number;
  /** Storage currently used in GB */
  usedStorageGb: number;
  /** Number of stored objects */
  objectCount: number;
}

/** iNFT status information */
export interface INFTStatus {
  /** iNFT token ID */
  tokenId: string;
  /** Current iNFT status */
  status: 'active' | 'minting' | 'inactive';
  /** Model name associated with the iNFT */
  modelName: string;
  /** Number of inferences served by this iNFT */
  inferenceCount: number;
  /** Last activity timestamp */
  lastActive: string;
}

/** A single inference job record */
export interface InferenceJob {
  /** Job identifier */
  id: string;
  /** Model used for inference */
  model: string;
  /** Job status */
  status: 'pending' | 'running' | 'completed' | 'failed';
  /** Input token count */
  inputTokens: number;
  /** Output token count */
  outputTokens: number;
  /** Inference latency in milliseconds */
  latencyMs: number;
  /** Job timestamp */
  timestamp: string;
}
```

### Step 6: Write types.ts -- Festival View Types

Continue with festival progress types:

```typescript
// ============================================================
// Festival View Types
// ============================================================

/** Status of a festival entity (phase, sequence, or task) */
export type FestivalEntityStatus = 'pending' | 'active' | 'completed' | 'blocked' | 'failed';

/** A single task in the festival hierarchy */
export interface FestivalTask {
  /** Task identifier */
  id: string;
  /** Task display name */
  name: string;
  /** Current status */
  status: FestivalEntityStatus;
  /** Autonomy level */
  autonomy: 'low' | 'medium' | 'high';
}

/** A sequence containing tasks */
export interface FestivalSequence {
  /** Sequence identifier */
  id: string;
  /** Sequence display name */
  name: string;
  /** Current status */
  status: FestivalEntityStatus;
  /** Ordered list of tasks */
  tasks: FestivalTask[];
  /** Completion percentage (0-100) */
  completionPercent: number;
}

/** A phase containing sequences */
export interface FestivalPhase {
  /** Phase identifier */
  id: string;
  /** Phase display name */
  name: string;
  /** Current status */
  status: FestivalEntityStatus;
  /** Ordered list of sequences */
  sequences: FestivalSequence[];
  /** Completion percentage (0-100) */
  completionPercent: number;
}

/** Complete festival progress data */
export interface FestivalProgress {
  /** Festival identifier */
  festivalId: string;
  /** Festival display name */
  festivalName: string;
  /** Ordered list of phases */
  phases: FestivalPhase[];
  /** Overall completion percentage (0-100) */
  overallCompletionPercent: number;
}
```

### Step 7: Write types.ts -- Connector Interfaces

Finish `src/lib/data/types.ts` with the connector and hook interfaces:

```typescript
// ============================================================
// Connector Interfaces
// ============================================================

/** Configuration for the WebSocket connector */
export interface WebSocketConfig extends ConnectorConfig {
  /** Protocols to request during WebSocket handshake */
  protocols?: string[];
}

/** Configuration for the gRPC connector */
export interface GRPCConfig extends ConnectorConfig {
  /** Whether to use REST fallback instead of gRPC-web */
  useRestFallback: boolean;
}

/** Configuration for the mirror node client */
export interface MirrorNodeConfig {
  /** Base URL of the Hedera mirror node REST API */
  baseUrl: string;
  /** Polling interval in milliseconds */
  pollingIntervalMs: number;
  /** Topic IDs to subscribe to */
  topicIds: string[];
}

// ============================================================
// Hook Return Types
// ============================================================

/** Return type for useWebSocket hook */
export interface UseWebSocketResult extends DataHookResult<DaemonEvent[]> {
  /** All agents' current status derived from events */
  agents: AgentInfo[];
  /** Manually trigger reconnect */
  reconnect: () => void;
}

/** Return type for useGRPC hook */
export interface UseGRPCResult extends DataHookResult<DaemonEvent[]> {
  /** All agents' current status derived from events */
  agents: AgentInfo[];
  /** Whether currently using gRPC (true) or WebSocket fallback (false) */
  isGRPC: boolean;
}

/** Return type for useMirrorNode hook */
export interface UseMirrorNodeResult extends DataHookResult<HCSMessage[]> {
  /** Festival progress data parsed from HCS messages */
  festivalProgress: FestivalProgress | null;
  /** Manually trigger a poll */
  refresh: () => void;
}
```

### Step 8: Verify compilation

Run from the project root:

```bash
npx tsc --noEmit
```

This must pass with zero errors. If there are type errors, fix them before marking this task complete.

## Done When

- [ ] `src/lib/data/types.ts` exists with all type definitions listed above
- [ ] `src/lib/data/` directory exists
- [ ] `src/hooks/` directory exists
- [ ] All types cover: connection state, daemon events, agent info, HCS messages, DeFi P&L, inference metrics, festival progress
- [ ] Connector config interfaces defined: WebSocketConfig, GRPCConfig, MirrorNodeConfig
- [ ] Hook return type interfaces defined: UseWebSocketResult, UseGRPCResult, UseMirrorNodeResult
- [ ] `npx tsc --noEmit` passes with zero errors
- [ ] No file exceeds 500 lines
