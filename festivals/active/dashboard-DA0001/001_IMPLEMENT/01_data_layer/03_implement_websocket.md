---
fest_type: task
fest_id: 03_implement_websocket.md
fest_name: implement_websocket
fest_parent: 01_data_layer
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement WebSocket Connector

**Task Number:** 03 | **Sequence:** 01_data_layer | **Autonomy:** medium

## Objective

Implement the daemon hub WebSocket connector that provides the production data path for real-time daemon events. This connector handles connecting to the daemon hub WebSocket endpoint, parsing incoming events into typed `DaemonEvent` objects, managing connection state with automatic reconnection on disconnect, and exposing all functionality through a `useWebSocket()` React hook.

## Requirements

- [ ] Implement WebSocket connector class in `src/lib/data/websocket.ts`
- [ ] Implement `useWebSocket()` React hook in `src/hooks/useWebSocket.ts`
- [ ] Auto-reconnect on disconnect with configurable delay and max attempts
- [ ] Parse incoming WebSocket messages into typed `DaemonEvent` objects
- [ ] Track connection state (connecting, connected, disconnected, error)
- [ ] Derive agent status from heartbeat events
- [ ] Expose reconnect function for manual reconnection
- [ ] Dashboard must never write data through the WebSocket (read-only)

## Implementation

### Step 1: Create the WebSocket connector

Create `src/lib/data/websocket.ts`. This is the core connector class that manages the raw WebSocket connection:

```typescript
import {
  ConnectionState,
  WebSocketConfig,
  DaemonEvent,
  AgentInfo,
  AgentStatus,
} from './types';

const DEFAULT_CONFIG: WebSocketConfig = {
  url: process.env.NEXT_PUBLIC_DAEMON_HUB_WS_URL || 'ws://localhost:8080/ws',
  autoReconnect: true,
  reconnectDelayMs: 2000,
  maxReconnectAttempts: 0, // unlimited
};
```

The connector class should implement the following behavior:

**Constructor:**

- Accept a partial `WebSocketConfig` that merges with defaults
- Initialize connection state as `'disconnected'`
- Initialize an empty agent map for tracking agent status
- Do NOT connect in the constructor -- connection is started explicitly

**connect() method:**

- Set state to `'connecting'`
- Create a new `WebSocket` instance with the configured URL
- Register `onopen`, `onclose`, `onerror`, and `onmessage` handlers
- On `onopen`: set state to `'connected'`, reset reconnect attempt counter
- On `onclose`: set state to `'disconnected'`, trigger auto-reconnect if enabled
- On `onerror`: set state to `'error'`, store the error
- On `onmessage`: parse the message data as JSON into a `DaemonEvent`, notify listeners

**disconnect() method:**

- Set auto-reconnect to false (prevent reconnect loop)
- Close the WebSocket connection with code 1000 (normal closure)
- Set state to `'disconnected'`

**Auto-reconnect logic:**

- After `onclose`, if `autoReconnect` is true and max attempts not exceeded:
  - Wait `reconnectDelayMs` using `setTimeout`
  - Increment attempt counter
  - Call `connect()` again
- Use exponential backoff: multiply delay by 1.5 on each attempt, cap at 30 seconds
- Reset attempt counter and delay on successful connection

**Event parsing in onmessage:**

- Parse the raw `event.data` string as JSON
- Validate that the parsed object has a `type` field
- Cast to `DaemonEvent` type
- If `type === 'heartbeat'`, update the internal agent status map
- Notify all registered event listeners with the parsed event

**Agent status tracking:**

- Maintain a `Map<string, AgentInfo>` keyed by agent ID
- On `heartbeat` events: update or create the agent entry with latest timestamp, status, current task
- On `agent_started` events: set agent status to `'running'`
- On `agent_stopped` events: set agent status to `'stopped'`
- On `agent_error` events: set agent status to `'error'`, store error message
- Expose `getAgents()` method that returns the current agent map as an array

**Listener pattern:**

- Use a callback pattern: `onEvent(callback: (event: DaemonEvent) => void): () => void`
- The return value is an unsubscribe function
- Use a `Set<Function>` internally to manage listeners
- Also support `onStateChange(callback: (state: ConnectionState) => void): () => void`

### Step 2: Create the useWebSocket React hook

Create `src/hooks/useWebSocket.ts`. This hook wraps the WebSocket connector for use in React components:

```typescript
import { useState, useEffect, useCallback, useRef } from 'react';
import { UseWebSocketResult, DaemonEvent, AgentInfo, ConnectionState } from '@/lib/data/types';
```

The hook should:

1. **Create the connector once** using `useRef` to persist across renders. The connector instance should be created on first render and reused.

2. **Manage React state** for:
   - `events: DaemonEvent[]` -- array of received events (keep last 1000 to prevent memory leaks)
   - `agents: AgentInfo[]` -- current agent status derived from events
   - `connectionState: ConnectionState` -- current connection state
   - `error: Error | null` -- last error, if any
   - `isLoading: boolean` -- true while in `'connecting'` state

3. **Connect on mount** using `useEffect`:
   - Call `connector.connect()` on mount
   - Register event and state change listeners
   - Return cleanup function that calls `connector.disconnect()` and removes listeners

4. **Update state from events**:
   - On each event, append to events array (trim to last 1000)
   - Update agents array from connector's `getAgents()`
   - On state change, update connectionState and derive isLoading/error

5. **Expose reconnect function** using `useCallback`:
   - Calls `connector.disconnect()` then `connector.connect()`
   - Allows manual reconnection from UI

6. **Return the `UseWebSocketResult` object** matching the interface defined in types.ts

### Step 3: Export from index

Create or update `src/lib/data/index.ts` to re-export the WebSocket connector:

```typescript
export { WebSocketConnector } from './websocket';
```

Create or update `src/hooks/index.ts` to re-export the hook:

```typescript
export { useWebSocket } from './useWebSocket';
```

### Step 4: Environment variable

Add the WebSocket URL environment variable to `.env.local` (create if not exists):

```
NEXT_PUBLIC_DAEMON_HUB_WS_URL=ws://localhost:8080/ws
```

Also add it to `.env.example` for documentation:

```
NEXT_PUBLIC_DAEMON_HUB_WS_URL=ws://localhost:8080/ws
```

### Step 5: Verify compilation

```bash
npx tsc --noEmit
```

Must pass with zero TypeScript errors.

## Critical Constraints

- **READ-ONLY**: The WebSocket connector must NEVER send messages through the WebSocket. It only receives. The dashboard is strictly an observer.
- **No Global State**: The connector must be instantiable (not a singleton), enabling dependency injection and testability.
- **Memory Safety**: The events array in the hook must be bounded (1000 max) to prevent memory leaks during long sessions.

## Done When

- [ ] `src/lib/data/websocket.ts` exists with WebSocketConnector class
- [ ] `src/hooks/useWebSocket.ts` exists with useWebSocket hook
- [ ] Auto-reconnect works with exponential backoff
- [ ] Events are parsed into typed DaemonEvent objects
- [ ] Agent status is derived from heartbeat/lifecycle events
- [ ] Connection state is tracked and exposed
- [ ] Manual reconnect function is exposed
- [ ] Events array is bounded to prevent memory leaks
- [ ] No write operations exist in the connector (read-only)
- [ ] `npx tsc --noEmit` passes with zero errors
- [ ] Environment variable documented in .env.example
