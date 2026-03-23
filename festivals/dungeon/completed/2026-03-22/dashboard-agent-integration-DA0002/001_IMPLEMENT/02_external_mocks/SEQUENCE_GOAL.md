---
fest_type: sequence
fest_id: 02_external_mocks
fest_name: external mocks
fest_parent: 001_IMPLEMENT
fest_order: 2
fest_status: completed
fest_created: 2026-03-22T15:58:02.57287-06:00
fest_updated: 2026-03-22T16:23:08.528554-06:00
fest_tracking: true
fest_working_dir: projects/agent-coordinator
---


# Sequence Goal: 02_external_mocks

**Sequence:** 02_external_mocks | **Phase:** 001_IMPLEMENT | **Status:** Pending

## Sequence Objective

**Primary Goal:** Create mock implementations for all external dependencies (Hedera HCS/HTS, Base RPC, Uniswap V3, 0G Compute) so agents can run in demo mode without connecting to real external services.

**Contribution to Phase Goal:** Agents can't run in demo mode without mocked externals — they'd fail on connection errors. These mocks let the real agent code execute its full event pipeline with deterministic, realistic data.

## Success Criteria

### Required Deliverables

- [ ] **Hedera HCS mock**: In-memory topic that accepts messages and returns them on subscribe — no real Hedera connection
- [ ] **Base RPC + Uniswap mock**: Returns realistic pool state, price quotes, and simulated swap results
- [ ] **0G Compute mock**: Returns simulated inference job results and storage acknowledgments
- [ ] **Mock toggle**: All mocks activated by existing env vars (DEFI_MOCK_MODE=true, etc.)

### Quality Standards

- [ ] **Interface parity**: Mocks implement the same Go interfaces as real clients
- [ ] **Realistic data**: Mock responses use plausible values (real token addresses, realistic prices)

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Agents compile and run with mocks enabled
- [ ] No real external network calls made in demo mode

## Dependencies

### Prerequisites

- 01_coordinator_websocket: Hub must exist so mocked agent events can be broadcast

### Provides

- Mock implementations: Used by 04_agent_event_routing to run agents end-to-end in demo mode