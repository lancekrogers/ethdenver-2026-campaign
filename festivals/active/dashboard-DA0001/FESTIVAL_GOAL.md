---
fest_type: festival
fest_id: DA0001
fest_name: dashboard
fest_status: ready
fest_created: 2026-02-18T13:40:59.812256-07:00
fest_updated: 2026-02-20T11:07:11.523695-07:00
fest_tracking: true
---



# Dashboard — Observer Dashboard

**Status:** Planned | **Created:** 2026-02-18T13:40:59-07:00

## Festival Objective

**Primary Goal:** Build a real-time observer dashboard that visualizes the entire agent economy across all three chains (Hedera, Base, 0G) as the primary demo surface for ETHDenver judges.

**Vision:** A single Next.js dashboard that streams live data from every layer of the system — festival progress, HCS agent-to-agent messages, agent lifecycle status, DeFi P&L from Base, and inference/storage metrics from 0G. Judges open one URL and immediately see the full economy operating autonomously. The dashboard is read-only; it observes and renders, never acts.

## Success Criteria

### Functional Success

- [ ] Festival View panel renders structured phase/sequence/task progress from fest
- [ ] HCS Feed panel streams live agent-to-agent messages from Hedera Consensus Service
- [ ] Agent Activity panel shows real-time status of all three agents (coordinator, inference, defi)
- [ ] DeFi P&L panel displays Base trading performance with revenue vs costs breakdown
- [ ] Inference Metrics panel shows 0G compute utilization, storage usage, and iNFT status
- [ ] Data layer connects to daemon hub WebSocket for production and gRPC for dev mode

### Quality Success

- [ ] All five panels render with live data within 2 seconds of page load
- [ ] WebSocket reconnects automatically on disconnect without user intervention
- [ ] Dashboard is fully read-only — no write operations to any chain or service
- [ ] Responsive layout suitable for projector/large-screen demo presentation

## Progress Tracking

### Phase Completion

- [ ] 001_IMPLEMENT: Build all five dashboard panels, data layer, and WebSocket/gRPC connectors

## Complete When

- [ ] All phases completed
- [ ] All five panels display live data from their respective sources
- [ ] Dashboard tested end-to-end with daemon hub running locally
- [ ] Demo-ready layout polished for ETHDenver judge presentation