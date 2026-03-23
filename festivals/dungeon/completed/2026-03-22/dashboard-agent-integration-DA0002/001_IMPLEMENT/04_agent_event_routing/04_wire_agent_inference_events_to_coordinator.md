---
fest_type: task
fest_id: 01_wire_agent_inference_events_to_coordinator.md
fest_name: wire agent inference events to coordinator
fest_parent: 04_agent_event_routing
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 0001-01-01T00:00:00Z
fest_updated: 2026-03-22T16:27:27.030491-06:00
fest_tracking: true
---


# Task: Wire Agent Inference Events to Coordinator

## Objective

Make agent-inference publish heartbeats with compute metrics and inference job results to the coordinator hub so the Inference Metrics panel shows real data.

## Requirements

- [ ] Heartbeats include gpuUtilization, memoryUtilization, activeJobs, storage metrics, INFT status
- [ ] Inference job completions include jobId, model, inputTokens, outputTokens, latencyMs
- [ ] Events match the payload shapes expected by InferenceMetrics.tsx and useLiveData.ts

## Implementation

1. Agent-inference already has a heartbeat loop — add event publishing alongside HCS publishing
2. On inference job completion, publish a task_result event with inference-specific payload
3. Use the same transport mechanism as agent-defi (chosen in task 04)

## Done When

- [ ] All requirements met
- [ ] Inference Metrics panel shows GPU gauge, storage bar, and job table from real agent data
- [ ] Agent Activity panel shows inference agent heartbeat