---
fest_type: gate
fest_id: 06_testing.md
fest_name: Testing and Verification
fest_parent: 01_data_layer
fest_order: 6
fest_status: pending
fest_gate_type: testing
fest_created: 2026-02-18T14:21:00.575132-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 06 | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Verify all data layer functionality implemented in this sequence works correctly through comprehensive testing. This includes the WebSocket connector, gRPC connector, mirror node client, and all three React hooks.

## Requirements

- [ ] All unit tests pass
- [ ] Integration tests verify main workflows
- [ ] Manual testing confirms data connectors work as expected
- [ ] Error cases are handled correctly
- [ ] Edge cases are addressed

## Test Categories

### Unit Tests

```bash
cd $(fgo) && npm test
```

**Verify:**

- [ ] All new/modified code has test coverage
- [ ] Tests are meaningful (not just coverage padding)
- [ ] Test names describe what they verify

**Specific unit tests to write or verify:**

1. **WebSocket connector tests** (`src/lib/data/__tests__/websocket.test.ts`):
   - Connection state transitions: disconnected -> connecting -> connected
   - Event parsing: valid JSON -> DaemonEvent
   - Event parsing: invalid JSON -> error handled gracefully
   - Auto-reconnect: triggers after disconnect
   - Agent status tracking: heartbeat updates agent map
   - Disconnect: cleanly closes connection
   - Memory bounds: events array stays under 1000

2. **gRPC connector tests** (`src/lib/data/__tests__/grpc.test.ts`):
   - SSE connection: opens EventSource and parses events
   - Polling fallback: starts interval and fetches events
   - Environment toggle: respects NEXT_PUBLIC_USE_GRPC
   - Disconnect: cleans up EventSource or interval

3. **Mirror node client tests** (`src/lib/data/__tests__/mirror-node.test.ts`):
   - HCS message fetch: correct URL construction and base64 decoding
   - Pagination: afterTimestamp parameter applied correctly
   - Polling: interval starts and stops correctly
   - Error handling: network errors do not crash the polling loop
   - Rate limiting: 429 response triggers backoff

4. **React hook tests** (`src/hooks/__tests__/`):
   - useWebSocket: returns correct initial state, updates on events
   - useGRPC: delegates to WebSocket when NEXT_PUBLIC_USE_GRPC is false
   - useMirrorNode: starts polling on mount, stops on unmount

### Integration Tests

```bash
cd $(fgo) && npm run test:integration 2>/dev/null || echo "No integration test script; run manual integration checks"
```

**Verify:**

- [ ] WebSocket connector can connect to a local WebSocket server (if daemon hub is running)
- [ ] Mirror node client can fetch messages from the Hedera testnet mirror node
- [ ] All three hooks can be rendered in a test component without errors

### Manual Verification

1. [ ] **WebSocket auto-reconnect**: Start the dashboard, connect to a local WebSocket server, kill the server, verify the connector attempts to reconnect (check console logs), restart the server, verify connection is re-established
2. [ ] **gRPC toggle**: Set `NEXT_PUBLIC_USE_GRPC=true`, restart dev server, verify the gRPC connector is used. Set to `false`, verify WebSocket connector is used.
3. [ ] **Mirror node polling**: Start the dashboard, verify HCS messages appear from the testnet mirror node. Check that new messages are fetched on each poll interval.
4. [ ] **TypeScript strict mode**: Run `npx tsc --noEmit` and verify zero errors
5. [ ] **Read-only verification**: Inspect all connector code and confirm no write operations (no POST/PUT/DELETE requests, no WebSocket send calls)

## Coverage Requirements

- Minimum coverage: 70% for new code (data connectors and hooks)

```bash
cd $(fgo) && npm test -- --coverage
```

## Error Handling Verification

- [ ] Invalid WebSocket URL produces a clear error state, not a crash
- [ ] Invalid mirror node URL produces a clear error state
- [ ] Malformed JSON from WebSocket is handled gracefully (logged, not thrown)
- [ ] Network timeout on mirror node fetch retries without crashing
- [ ] All errors are surfaced through hook state (error property), not just console.log

## Definition of Done

- [ ] All automated tests pass
- [ ] Manual verification complete for all 5 items above
- [ ] Coverage meets 70% requirement for new code
- [ ] Error handling verified for all connectors
- [ ] No regressions introduced

## Notes

Document any test gaps, flaky tests, or areas needing future attention here.

---

**Test Results Summary:**

- Unit tests: [ ] Pass / [ ] Fail
- Integration tests: [ ] Pass / [ ] Fail / [ ] N/A
- Manual tests: [ ] Pass / [ ] Fail
- Coverage: ____%
