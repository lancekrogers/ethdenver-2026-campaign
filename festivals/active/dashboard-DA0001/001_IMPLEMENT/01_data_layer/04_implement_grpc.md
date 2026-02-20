---
fest_type: task
fest_id: 04_implement_grpc.md
fest_name: implement_grpc
fest_parent: 01_data_layer
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement gRPC Connector

**Task Number:** 04 | **Sequence:** 01_data_layer | **Autonomy:** medium

## Objective

Implement the direct daemon gRPC connector for dev mode. In development, instead of going through the daemon hub WebSocket, the dashboard connects directly to individual daemon gRPC endpoints for faster iteration and debugging. This connector uses gRPC-web (or a REST fallback for environments where gRPC-web is not available) and is toggled on/off via an environment variable. When gRPC mode is disabled, the dashboard falls back to the WebSocket connector transparently.

## Requirements

- [ ] Implement gRPC connector in `src/lib/data/grpc.ts`
- [ ] Implement `useGRPC()` React hook in `src/hooks/useGRPC.ts`
- [ ] Support gRPC-web protocol for browser-to-daemon communication
- [ ] Provide REST fallback when gRPC-web is unavailable
- [ ] Toggle between gRPC (dev) and WebSocket (production) via `NEXT_PUBLIC_USE_GRPC` env var
- [ ] Parse responses into the same `DaemonEvent` type used by the WebSocket connector
- [ ] Track connection state and expose agent status

## Implementation

### Step 1: Install gRPC-web dependency

If gRPC-web is needed, add it as a dependency. However, for the hackathon, a REST fallback is more pragmatic since it avoids proto compilation. The recommended approach:

- Use a REST endpoint that the daemon exposes alongside gRPC (e.g., `GET /api/events/stream` for SSE or `GET /api/events` for polling)
- If the daemon only exposes gRPC, use `grpc-web` package with an Envoy proxy

For simplicity and reliability, implement the REST fallback first:

```bash
# No additional dependencies needed for REST fallback
# If gRPC-web is needed later:
# npm install grpc-web google-protobuf
```

### Step 2: Create the gRPC/REST connector

Create `src/lib/data/grpc.ts`. This connector provides dev-mode access to daemon events:

```typescript
import {
  ConnectionState,
  GRPCConfig,
  DaemonEvent,
  AgentInfo,
} from './types';

const DEFAULT_CONFIG: GRPCConfig = {
  url: process.env.NEXT_PUBLIC_DAEMON_GRPC_URL || 'http://localhost:9090',
  autoReconnect: true,
  reconnectDelayMs: 3000,
  maxReconnectAttempts: 0,
  useRestFallback: true,
};
```

The connector class should implement the following:

**Constructor:**

- Accept partial `GRPCConfig` merged with defaults
- Initialize connection state as `'disconnected'`
- Initialize empty agent map
- Determine whether to use gRPC-web or REST based on `useRestFallback` config

**REST Fallback Mode (Primary Implementation):**

The REST fallback uses Server-Sent Events (SSE) for streaming, falling back to polling if SSE is not available:

**connect() method (SSE mode):**

- Set state to `'connecting'`
- Create an `EventSource` instance pointing to `${url}/api/events/stream`
- Register `onopen`, `onerror`, and `onmessage` handlers
- On `onopen`: set state to `'connected'`, reset reconnect counter
- On `onerror`: if EventSource is closed, set state to `'disconnected'` and trigger reconnect; otherwise set state to `'error'`
- On `onmessage`: parse `event.data` as JSON into `DaemonEvent`, update agent map, notify listeners
- EventSource has built-in reconnection, but add manual reconnect logic as backup

**connect() method (Polling fallback):**

- If SSE fails or is not supported, fall back to polling
- Set state to `'connecting'`
- Start a `setInterval` that calls `${url}/api/events?since=${lastTimestamp}` every `reconnectDelayMs`
- Parse response body as `DaemonEvent[]`
- Update agent map and notify listeners for each event

**disconnect() method:**

- Close EventSource or clear polling interval
- Set state to `'disconnected'`

**Auto-reconnect logic:**

- Same exponential backoff pattern as the WebSocket connector
- On SSE error, attempt to reconnect after delay
- Cap backoff at 30 seconds

**Agent status tracking:**

- Identical to WebSocket connector: maintain `Map<string, AgentInfo>`, update on heartbeat/lifecycle events

**Listener pattern:**

- Same as WebSocket connector: `onEvent()`, `onStateChange()` with unsubscribe functions

### Step 3: Create the useGRPC React hook

Create `src/hooks/useGRPC.ts`. This hook wraps the gRPC connector:

The hook should:

1. **Check the environment variable** `NEXT_PUBLIC_USE_GRPC`:
   - If `'true'`, use the gRPC connector
   - If not set or `'false'`, delegate to `useWebSocket()` hook instead
   - Expose `isGRPC: boolean` indicating which mode is active

2. **When gRPC is enabled**, behave identically to `useWebSocket` but using the gRPC connector:
   - Create connector instance with `useRef`
   - Manage state for events, agents, connectionState, error, isLoading
   - Connect on mount, disconnect on unmount
   - Bound events array to 1000 entries

3. **When gRPC is disabled**, import and call `useWebSocket()` directly, wrapping its result to match `UseGRPCResult` interface with `isGRPC: false`

4. **Return `UseGRPCResult`** matching the interface from types.ts

### Step 4: Environment variables

Add to `.env.local` and `.env.example`:

```
NEXT_PUBLIC_USE_GRPC=false
NEXT_PUBLIC_DAEMON_GRPC_URL=http://localhost:9090
```

### Step 5: Export from index files

Update `src/lib/data/index.ts`:

```typescript
export { WebSocketConnector } from './websocket';
export { GRPCConnector } from './grpc';
```

Update `src/hooks/index.ts`:

```typescript
export { useWebSocket } from './useWebSocket';
export { useGRPC } from './useGRPC';
```

### Step 6: Verify compilation

```bash
npx tsc --noEmit
```

Must pass with zero TypeScript errors.

## Critical Constraints

- **READ-ONLY**: The gRPC connector must NEVER send commands to daemons. It only reads event streams. The dashboard is strictly an observer.
- **Transparent Fallback**: Components that use `useGRPC()` should not need to know whether they are using gRPC or WebSocket. The hook API is identical.
- **Dev Mode Only**: gRPC mode is intended for local development only. Production always uses the daemon hub WebSocket.

## Done When

- [ ] `src/lib/data/grpc.ts` exists with GRPCConnector class
- [ ] `src/hooks/useGRPC.ts` exists with useGRPC hook
- [ ] REST/SSE fallback works when gRPC-web is unavailable
- [ ] Environment variable `NEXT_PUBLIC_USE_GRPC` toggles between gRPC and WebSocket
- [ ] Events are parsed into the same `DaemonEvent` type as WebSocket
- [ ] Agent status tracking works identically to WebSocket connector
- [ ] Connection state management with auto-reconnect
- [ ] No write operations exist in the connector (read-only)
- [ ] `npx tsc --noEmit` passes with zero errors
- [ ] Environment variables documented in .env.example
