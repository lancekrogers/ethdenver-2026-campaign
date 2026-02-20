---
fest_type: phase
fest_id: 001_IMPLEMENT
fest_name: IMPLEMENT
fest_parent: dashboard-DA0001
fest_order: 1
fest_status: pending
fest_created: 2026-02-18T13:40:59.816243-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 001_IMPLEMENT

**Phase:** 001_IMPLEMENT | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Deliver a complete, demo-ready observer dashboard with five visualization panels and a real-time data layer connecting to daemon hub WebSocket, direct daemon gRPC, and the Hedera mirror node REST API.

**Context:** This is the sole implementation phase for the dashboard festival. Component design decisions are made inline as each panel is built. The output of this phase is the final demo artifact presented to ETHDenver judges. All data sources must be wired and rendering live data by phase completion.

## Required Outcomes

Deliverables this phase must produce:

- [ ] Data layer with daemon hub WebSocket connector (production) and direct daemon gRPC connector (dev mode)
- [ ] Hedera mirror node REST API integration for HCS/HTS historical data
- [ ] Festival View panel rendering structured phase/sequence/task progress from fest
- [ ] HCS Feed panel streaming live agent-to-agent messages from Hedera Consensus Service
- [ ] Agent Activity panel displaying real-time status of coordinator, inference, and defi agents
- [ ] DeFi P&L panel showing Base trading performance with revenue vs costs breakdown
- [ ] Inference Metrics panel showing 0G compute utilization, storage usage, and iNFT status
- [ ] Demo-ready layout polished for projector/large-screen presentation

## Quality Standards

Quality criteria for all work in this phase:

- [ ] All panels render with live data within 2 seconds of page load
- [ ] WebSocket auto-reconnects on disconnect without user intervention
- [ ] Dashboard is strictly read-only — no write operations to any chain, daemon, or service
- [ ] TypeScript strict mode with no type errors
- [ ] Components are modular and independently testable

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_data_layer | Connect to all data sources (WebSocket, gRPC, mirror node) | Working data connectors with auto-reconnect |
| 02_festival_view | Render festival phase/sequence/task progress | Festival View panel component |
| 03_hcs_feed | Stream live HCS agent messages | HCS Feed panel component |
| 04_agent_activity | Display real-time agent lifecycle status | Agent Activity panel component |
| 05_defi_pnl | Visualize Base trading P&L | DeFi P&L panel component |
| 06_inference_metrics | Show 0G compute and storage metrics | Inference Metrics panel component |
| 07_demo_polish | Tune layout and presentation for demo | Final demo-ready dashboard |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_data_layer
- [ ] 02_festival_view
- [ ] 03_hcs_feed
- [ ] 04_agent_activity
- [ ] 05_defi_pnl
- [ ] 06_inference_metrics
- [ ] 07_demo_polish

## Notes

- Dashboard project is Next.js/TypeScript.
- Dependencies: chain-agents festival must be active for live agent data; hedera-foundation festival must be active for HCS/HTS data. Development can proceed with mock data.
- Data sources: daemon events via hub WebSocket (production path), direct daemon gRPC (dev mode), Hedera mirror node REST API for HCS/HTS history.
- The dashboard is not a direct bounty target but is required to demonstrate all track submissions effectively.
- Read-only constraint is absolute — the dashboard must never issue write operations to any external system.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
