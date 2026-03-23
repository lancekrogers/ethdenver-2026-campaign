---
fest_type: task
fest_id: 01_wire_agent_defi_events_to_coordinator.md
fest_name: wire agent defi events to coordinator
fest_parent: 04_agent_event_routing
fest_order: 4
fest_status: completed
fest_autonomy: medium
fest_created: 0001-01-01T00:00:00Z
fest_updated: 2026-03-22T16:27:26.941024-06:00
fest_tracking: true
---


# Task: Wire Agent DeFi Events to Coordinator

## Objective

Make agent-defi publish heartbeats, trade results, and PnL reports to the coordinator's WebSocket hub so the DeFi P&L and Agent Activity panels show real data.

## Requirements

- [ ] Agent-defi connects to the coordinator hub (via gRPC, HTTP, or direct Go interface if running in same process)
- [ ] Heartbeats published every 30s with agent status
- [ ] Trade results published after each swap with pair, side, amount, price, pnl, gasCost, txHash
- [ ] PnL summary published periodically with revenue, costs, netProfit, winRate

## Implementation

1. Agent-defi currently publishes to HCS — add a parallel path that publishes DaemonEvents
2. Option A (in-process): If agents run as goroutines in the coordinator, pass the Hub directly
3. Option B (inter-process): Agent-defi makes HTTP POST calls to coordinator's event ingestion endpoint
4. Option C (HCS-mediated): Coordinator subscribes to HCS and re-broadcasts to WebSocket — this works with existing code but adds latency
5. Choose the option that matches the docker-compose architecture (agents as separate containers)

## Done When

- [ ] All requirements met
- [ ] DeFi P&L panel shows real trades from agent-defi in demo mode
- [ ] Agent Activity panel shows agent-defi heartbeat status