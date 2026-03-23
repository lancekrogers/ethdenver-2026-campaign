---
fest_type: task
fest_id: 01_create_0g_compute_mock.md
fest_name: create 0g compute mock
fest_parent: 02_external_mocks
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-22T15:58:29.12355-06:00
fest_updated: 2026-03-22T16:21:13.93977-06:00
fest_tracking: true
---


# Task: Create 0G Compute Mock

## Objective

Create a mock 0G Compute client so agent-inference can run its inference loop and report metrics in demo mode.

## Requirements

- [ ] Mock inference job submission returns simulated results (model, input/output tokens, latency)
- [ ] Mock storage client returns fake content IDs and storage metrics
- [ ] Mock DA client returns fake submission IDs
- [ ] Toggled by env var (e.g., ZG_MOCK_MODE=true or absence of ZG_CHAIN_RPC)

## Implementation

1. Read `projects/agent-inference/internal/` to understand the 0G client interfaces
2. Create mock implementations that return realistic inference results
3. Vary latency (80-180ms), token counts, GPU utilization for realistic dashboard display
4. Mock should produce heartbeat data matching what the dashboard InferenceMetrics panel expects

## Done When

- [ ] All requirements met
- [ ] Agent-inference runs with mock 0G and publishes heartbeats with compute metrics
- [ ] No network calls to 0G testnet in mock mode