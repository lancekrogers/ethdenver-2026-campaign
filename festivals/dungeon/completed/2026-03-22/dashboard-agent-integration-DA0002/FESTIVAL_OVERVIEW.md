# Festival Overview: dashboard-agent-integration

## Problem Statement

**Current State:** The dashboard's demo mode generates fake data entirely client-side using React synthetic event generators. No Go agent runs, no coordinator dispatches tasks, no HCS messages flow, no CRE evaluations execute. The dashboard proves nothing about the real infrastructure — it's a static mockup pretending to be live. In live mode, only the Mirror Node path works (HCS polling for Festival View); the WebSocket path (`ws://coordinator:8080/ws`) points to a server that doesn't exist.

**Desired State:** Demo mode runs the actual Go agent binaries with mocked *external* dependencies (Hedera, Uniswap V3 RPC, Base RPC, 0G compute, obey daemon). The coordinator serves a real WebSocket on :8080 that forwards agent events to the dashboard. Events flow through our real event pipeline: agents → coordinator → WebSocket → dashboard. In live mode, external mocks are replaced with real services (real HCS topics, real Base Sepolia RPC, real obey daemon sessions).

**Why This Matters:** The Synthesis hackathon submission claims a multi-agent economy with 5 agents across 6 chains. If the dashboard only shows fabricated client-side data, the submission is dishonest. The integration must prove that our coordinator, agents, risk router, and event pipeline actually work together — with only external third-party services mocked.

## Scope

### In Scope

- Add WebSocket server to agent-coordinator (serve on :8080/ws, push DaemonEvent JSON to connected clients)
- Mock external dependencies in demo mode: Hedera HCS/HTS, Base RPC, Uniswap V3, 0G Compute, obey daemon
- Route real agent events through the coordinator WebSocket to dashboard
- Ensure `just demo up` starts agents with mocked externals and real internal event routing
- Ensure `just live up` starts agents with real externals (HCS, Base Sepolia, obey daemon)
- Validate all 7 dashboard panels receive data from real agent binaries in demo mode
- Update docker-compose.yml if needed for agent startup with mock vs live config

### Out of Scope

- Building the obey daemon WebSocket bridge (daemon stays gRPC-only as designed)
- Adding new dashboard panels or changing panel layouts
- Mainnet deployment
- Changing the obey daemon protocol or session management
- Rebuilding agent trading strategies or risk evaluation logic

## Planned Phases

### 001_IMPLEMENT

Six sequences:
1. **coordinator_websocket** — Add HTTP/WebSocket server to agent-coordinator that accepts dashboard connections and pushes DaemonEvent JSON
2. **external_mocks** — Create mock implementations for Hedera HCS/HTS, Base RPC, Uniswap V3, 0G in agent binaries (toggled by env var)
3. **daemon_mock** — Create a lightweight mock obey daemon for demo mode that responds to gRPC health checks and session creation without creating real sessions
4. **agent_event_routing** — Wire agent-defi, agent-inference, and cre-risk-router to publish events to coordinator WebSocket (heartbeats, task results, PnL, risk decisions, vault decisions)
5. **docker_integration** — Update docker-compose.yml and justfiles so `just demo up` starts the full stack with mocked externals and `just demo run` is no longer needed as a separate step
6. **end_to_end_verification** — Verify all 7 dashboard panels show data from real agent binaries in demo mode, verify live mode connects to real services

## Notes

- The coordinator already has HCS publishing code — the WebSocket server reuses the same event types
- Agent-defi already emits structured data (trades, PnL, heartbeats) to HCS — we're adding a parallel WebSocket path
- The dashboard's `useWebSocket` hook already expects DaemonEvent JSON on `ws://coordinator:8080/ws` — no dashboard changes needed for the connection
- Mock vs live is toggled by env vars (DEFI_MOCK_MODE, etc.) already present in docker-compose.yml
- The obey daemon mock only needs to respond to `ping` and `session create` — it doesn't need to run real agent sessions
- Primary design reference: the existing synthetic-events.ts generators show exactly what event shapes the dashboard expects
