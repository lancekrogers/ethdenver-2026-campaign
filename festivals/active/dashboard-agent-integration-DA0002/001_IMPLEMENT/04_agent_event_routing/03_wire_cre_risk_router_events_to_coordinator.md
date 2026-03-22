---
fest_type: task
fest_id: 01_wire_cre_risk_router_events_to_coordinator.md
fest_name: wire cre risk router events to coordinator
fest_parent: 04_agent_event_routing
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_tracking: true
---

# Task: Wire CRE Risk Router Events to Coordinator

## Objective

Make the CRE risk router publish risk_check_requested, risk_check_approved, and risk_check_denied events to the coordinator hub so the CRE Decisions panel shows real risk evaluations.

## Requirements

- [ ] Risk check requests published when the CRE bridge receives an evaluation request
- [ ] Risk check approved/denied published with the decision result, reason, and constraints
- [ ] Events include task_id, max_position_usd, max_slippage_bps matching what CREDecisions.tsx expects

## Implementation

1. The CRE bridge (`projects/cre-risk-router/cmd/bridge`) handles HTTP POST /evaluate-risk
2. After evaluation, publish a DaemonEvent to the coordinator (same transport as agent-defi)
3. Include the full evaluation result in the event payload

## Done When

- [ ] All requirements met
- [ ] CRE Decisions panel shows real risk evaluations from the CRE bridge
- [ ] Both approved and denied decisions appear with correct styling
