# Festival Overview: Dashboard — Observer Dashboard

## Problem Statement

**Current State:** The agent economy spans three chains (Hedera, Base, 0G) with multiple autonomous agents, but there is no unified view of the system. Judges and developers must inspect each chain and agent independently, making it impossible to see the economy operating as a whole during a live demo.

**Desired State:** A single Next.js dashboard that streams real-time data from all layers — festival task progress, HCS message feeds, agent lifecycle status, DeFi trading P&L, and inference compute metrics — into five purpose-built panels. One URL shows the entire system.

**Why This Matters:** This dashboard is the primary demo surface for ETHDenver judges. Without it, the multi-chain agent economy is invisible. While not a direct bounty target, the dashboard is required to demonstrate every track submission effectively.

## Scope

### In Scope

- Festival View panel: structured phase/sequence/task progress visualization
- HCS Feed panel: live stream of agent-to-agent messages on Hedera Consensus Service
- Agent Activity panel: real-time status of coordinator, inference, and defi agents
- DeFi P&L panel: Base trading performance with revenue vs costs
- Inference Metrics panel: 0G compute utilization, storage usage, iNFT status
- Data layer: daemon hub WebSocket (production), direct daemon gRPC (dev mode), Hedera mirror node REST API
- Demo polish: layout and presentation tuned for projector/large-screen display

### Out of Scope

- Any write operations — the dashboard is strictly read-only and never acts
- Agent control or management interfaces
- Historical data analytics or time-range queries beyond what the mirror node provides
- Authentication or multi-user access control
- Mobile-optimized layout (demo is large-screen only)

## Planned Phases

### 001_IMPLEMENT

Build the complete dashboard: five visualization panels (Festival View, HCS Feed, Agent Activity, DeFi P&L, Inference Metrics), the data layer with WebSocket and gRPC connectors, Hedera mirror node integration, and demo-ready layout polish.

## Notes

- Dependencies: Requires live agent data from the chain-agents festival and HCS/HTS data from the hedera-foundation festival. Dashboard development can proceed with mock data but end-to-end testing requires those festivals to be active.
- Data sources: Daemon events via hub WebSocket (production path), direct daemon gRPC (dev mode), Hedera mirror node REST API for HCS/HTS history.
- The dashboard project is Next.js/TypeScript.
- Not a direct bounty target, but required for demonstrating all track submissions to judges.
