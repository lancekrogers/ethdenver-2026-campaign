---
fest_type: task
fest_id: 05_implement_mirror_node.md
fest_name: implement_mirror_node
fest_parent: 01_data_layer
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Mirror Node Client

**Task Number:** 05 | **Sequence:** 01_data_layer | **Autonomy:** medium

## Objective

Implement the Hedera mirror node REST API client that provides historical and near-real-time data from the Hedera network. The mirror node is the authoritative source for HCS message history, HTS token transactions, and account information. This client polls the mirror node REST API at a configurable interval and exposes the data through a `useMirrorNode()` React hook.

## Requirements

- [ ] Implement mirror node REST client in `src/lib/data/mirror-node.ts`
- [ ] Implement `useMirrorNode()` React hook in `src/hooks/useMirrorNode.ts`
- [ ] Support HCS message retrieval: `GET /api/v1/topics/{topicId}/messages`
- [ ] Support HTS transaction retrieval: `GET /api/v1/transactions`
- [ ] Support account info retrieval: `GET /api/v1/accounts/{accountId}`
- [ ] Configurable polling interval with manual refresh capability
- [ ] Parse Hedera-specific timestamps and response formats

## Implementation

### Step 1: Understand the Mirror Node REST API

The Hedera mirror node REST API is documented at `https://mainnet.mirrornode.hedera.com/api/v1/docs`. For testnet, use `https://testnet.mirrornode.hedera.com`. Key endpoints:

**HCS Messages:**
- `GET /api/v1/topics/{topicId}/messages` -- returns messages for a topic
- Query params: `limit`, `order` (asc/desc), `sequencenumber` (gt, gte, lt, lte), `timestamp` (gt, gte, lt, lte)
- Response: `{ messages: [{ consensus_timestamp, message, payer_account_id, running_hash, sequence_number, topic_id }] }`
- The `message` field is base64 encoded

**Transactions:**
- `GET /api/v1/transactions` -- returns transactions
- Query params: `account.id`, `type`, `timestamp`, `limit`, `order`
- Filter by type: `CRYPTOTRANSFER` for HTS token transfers

**Accounts:**
- `GET /api/v1/accounts/{accountId}` -- returns account info
- Response includes balance, key, tokens, etc.

### Step 2: Create the mirror node client

Create `src/lib/data/mirror-node.ts`. This client wraps the REST API:

```typescript
import {
  MirrorNodeConfig,
  HCSMessage,
  DaemonEventType,
} from './types';

const DEFAULT_CONFIG: MirrorNodeConfig = {
  baseUrl: process.env.NEXT_PUBLIC_HEDERA_MIRROR_NODE_URL || 'https://testnet.mirrornode.hedera.com',
  pollingIntervalMs: 5000,
  topicIds: (process.env.NEXT_PUBLIC_HEDERA_TOPIC_IDS || '').split(',').filter(Boolean),
};
```

The client class should implement:

**Constructor:**
- Accept partial `MirrorNodeConfig` merged with defaults
- Initialize empty message cache
- Initialize polling state as stopped

**fetchTopicMessages(topicId: string, afterTimestamp?: string) method:**
- Build URL: `${baseUrl}/api/v1/topics/${topicId}/messages`
- Add query params: `limit=100`, `order=asc`
- If `afterTimestamp` is provided, add `timestamp=gt:${afterTimestamp}` to only fetch new messages
- Call `fetch()` with the URL
- Parse response JSON
- For each message in the response:
  - Decode the `message` field from base64: `atob(msg.message)` or `Buffer.from(msg.message, 'base64').toString()`
  - Parse the decoded message as JSON to extract the daemon event envelope
  - Map to an `HCSMessage` object with: consensusTimestamp, topicId, sequenceNumber, message (decoded), messageType (from envelope), senderAgent (from envelope), rawMessage (original base64)
- Return the array of `HCSMessage` objects
- Store the latest `consensus_timestamp` for subsequent polling

**fetchTransactions(accountId: string, type?: string) method:**
- Build URL: `${baseUrl}/api/v1/transactions`
- Add query params: `account.id=${accountId}`, `limit=50`, `order=desc`
- If `type` is provided, add `type=${type}`
- Call `fetch()`, parse response, return typed transaction array

**fetchAccountInfo(accountId: string) method:**
- Build URL: `${baseUrl}/api/v1/accounts/${accountId}`
- Call `fetch()`, parse response, return account info

**startPolling() method:**
- Begin a `setInterval` at `pollingIntervalMs`
- On each interval:
  - For each topic ID in config, call `fetchTopicMessages()` with the last known timestamp
  - Merge new messages into the message cache (deduplicate by consensus_timestamp)
  - Notify all registered listeners with new messages
- Track polling state

**stopPolling() method:**
- Clear the interval
- Update polling state

**Error handling:**
- Wrap all `fetch()` calls in try/catch
- On network error, log the error and continue polling (do not crash)
- On HTTP error (4xx/5xx), log the status and response body
- Expose errors through listener pattern

**Listener pattern:**
- `onMessages(callback: (messages: HCSMessage[]) => void): () => void` -- called with new messages on each poll
- `onError(callback: (error: Error) => void): () => void` -- called on fetch errors

### Step 3: Create the useMirrorNode React hook

Create `src/hooks/useMirrorNode.ts`. This hook wraps the mirror node client:

The hook should:

1. **Create the client once** using `useRef`

2. **Manage React state** for:
   - `messages: HCSMessage[]` -- all HCS messages received, ordered by consensus timestamp
   - `festivalProgress: FestivalProgress | null` -- festival data parsed from messages (if applicable)
   - `connectionState: ConnectionState` -- `'connected'` while polling, `'error'` on fetch failure
   - `error: Error | null` -- last error
   - `isLoading: boolean` -- true during initial fetch

3. **Start polling on mount** using `useEffect`:
   - Call `client.startPolling()` on mount
   - Register message and error listeners
   - Return cleanup that calls `client.stopPolling()` and removes listeners

4. **Process incoming messages**:
   - Append new messages to the messages array
   - Keep messages bounded to last 5000 entries (mirror node messages arrive less frequently than WebSocket)
   - Parse festival progress data from messages if they contain festival status updates

5. **Expose refresh function** using `useCallback`:
   - Triggers an immediate poll of all topics without waiting for the interval
   - Useful for UI refresh buttons

6. **Return `UseMirrorNodeResult`** matching the interface from types.ts

### Step 4: Environment variables

Add to `.env.local` and `.env.example`:

```
NEXT_PUBLIC_HEDERA_MIRROR_NODE_URL=https://testnet.mirrornode.hedera.com
NEXT_PUBLIC_HEDERA_TOPIC_IDS=0.0.12345,0.0.12346
```

### Step 5: Export from index files

Update `src/lib/data/index.ts`:

```typescript
export { WebSocketConnector } from './websocket';
export { GRPCConnector } from './grpc';
export { MirrorNodeClient } from './mirror-node';
```

Update `src/hooks/index.ts`:

```typescript
export { useWebSocket } from './useWebSocket';
export { useGRPC } from './useGRPC';
export { useMirrorNode } from './useMirrorNode';
```

### Step 6: Verify compilation

```bash
npx tsc --noEmit
```

Must pass with zero TypeScript errors.

## Critical Constraints

- **READ-ONLY**: The mirror node client only performs GET requests. It must NEVER submit transactions or modify state on Hedera. The dashboard is strictly an observer.
- **Rate Limiting**: The testnet mirror node may rate-limit requests. Use a minimum polling interval of 3 seconds. Implement basic retry with backoff if a 429 response is received.
- **Base64 Decoding**: HCS messages from the mirror node are base64 encoded. Always decode before parsing as JSON.
- **Memory Safety**: Bound the message cache to prevent memory issues during long polling sessions.

## Done When

- [ ] `src/lib/data/mirror-node.ts` exists with MirrorNodeClient class
- [ ] `src/hooks/useMirrorNode.ts` exists with useMirrorNode hook
- [ ] HCS message fetching works with base64 decoding
- [ ] Transaction fetching works with account/type filtering
- [ ] Account info fetching works
- [ ] Polling starts/stops correctly with configurable interval
- [ ] Manual refresh function triggers immediate poll
- [ ] Messages are bounded to prevent memory leaks
- [ ] Error handling does not crash the polling loop
- [ ] No write operations exist (GET requests only, read-only)
- [ ] `npx tsc --noEmit` passes with zero errors
- [ ] Environment variables documented in .env.example
