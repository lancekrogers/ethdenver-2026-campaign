---
fest_type: sequence
fest_id: 01_data_layer
fest_name: data_layer
fest_parent: 001_IMPLEMENT
fest_order: 1
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 01_data_layer

**Sequence:** 01_data_layer | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Build the complete data layer for the dashboard, providing typed connectors for all three data sources: daemon hub WebSocket (production), direct daemon gRPC (dev mode), and Hedera mirror node REST API. Expose each connector through a React hook so panels can subscribe to live data with a single function call.

**Contribution to Phase Goal:** This sequence delivers the data foundation that every panel depends on. Without working data connectors and React hooks, no panel can render live data. The data layer must be complete and tested before panel development begins. It also provides the connection state management (auto-reconnect, error handling) that determines whether the dashboard meets the 2-second render requirement.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **TypeScript Types**: All data source types defined in `src/lib/data/types.ts` covering daemon events, HCS messages, agent status, DeFi trades, and inference metrics
- [ ] **WebSocket Connector**: Working daemon hub WebSocket connector in `src/lib/data/websocket.ts` with auto-reconnect and event parsing
- [ ] **gRPC Connector**: Working daemon gRPC connector (or REST fallback) in `src/lib/data/grpc.ts` with dev mode toggling
- [ ] **Mirror Node Client**: Working Hedera mirror node REST API client in `src/lib/data/mirror-node.ts` with configurable polling
- [ ] **React Hooks**: `useWebSocket()`, `useGRPC()`, and `useMirrorNode()` hooks in `src/hooks/` for panel consumption
- [ ] **Festival Linked**: Dashboard project linked via `fest link` so `fgo` navigation works

### Quality Standards

- [ ] **TypeScript Strict Mode**: No type errors when running `npx tsc --noEmit`
- [ ] **Auto-Reconnect**: WebSocket connector reconnects automatically on disconnect without user intervention
- [ ] **Read-Only**: No connector ever writes data to any external system
- [ ] **Error Handling**: All connectors surface connection errors through their hooks
- [ ] **Environment Toggle**: gRPC vs WebSocket selection controlled by environment variable

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed
- [ ] Hooks can be imported and used by panel components

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_link_project.md | Link festival to dashboard project | Enables `fgo` navigation for all subsequent tasks |
| 02_design_data_layer.md | Design types, interfaces, and hook APIs | Establishes the contract all connectors must satisfy |
| 03_implement_websocket.md | Implement daemon hub WebSocket connector | Delivers the production data path for real-time events |
| 04_implement_grpc.md | Implement daemon gRPC connector for dev mode | Delivers the dev mode data path with env-var toggling |
| 05_implement_mirror_node.md | Implement Hedera mirror node REST client | Delivers HCS/HTS historical data access |
| 06_testing_and_verify.md | Test all data connectors | Quality gate: verifies all implementations work correctly |
| 07_code_review.md | Review code quality and standards | Quality gate: ensures code meets project standards |
| 08_review_results_iterate.md | Address findings and iterate | Quality gate: resolves issues and confirms readiness |

## Dependencies

### Prerequisites (from other sequences)

- None. This is the first sequence and has no dependencies on other sequences.

### Provides (to other sequences)

- **Data Hooks**: Used by all five panel sequences (02 through 06) to subscribe to live data streams
- **TypeScript Types**: Used by all panel components for type-safe data rendering
- **Connection State**: Used by 07_demo_polish for connection status indicators

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Daemon hub WebSocket protocol not finalized | Medium | High | Design connector with configurable message format, use mock data for initial development |
| gRPC-web browser compatibility issues | Medium | Medium | Implement REST fallback alongside gRPC-web, toggle via config |
| Mirror node rate limiting in testnet | Low | Medium | Implement polling with configurable interval and exponential backoff |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Project linked and all TypeScript types/interfaces defined
- [ ] **Milestone 2**: All three connectors implemented with React hooks
- [ ] **Milestone 3**: All quality gates passed, hooks ready for panel consumption

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass with `npm test`
- [ ] TypeScript compiles with `npx tsc --noEmit` and zero errors
- [ ] WebSocket auto-reconnect verified manually
- [ ] Mirror node polling verified with testnet endpoint

### Code Review

- [ ] Code review conducted against project standards
- [ ] Review feedback addressed
- [ ] ESLint passes with no warnings: `npx eslint src/lib/data/ src/hooks/`

### Iteration Decision

- [ ] Need another iteration? To be determined after code review
- [ ] If yes, new tasks created with specific findings to address
