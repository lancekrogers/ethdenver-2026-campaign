# Daemon Requirements — ETHDenver Agent Economy

This is the key document. It separates what works today, what must be built, and what Lance is planning beyond the hackathon.

---

## A. What Works Today (Leverage for Hackathon)

These capabilities exist in obeyd v0.1.0 and can be used immediately:

### Event Routing Infrastructure
- Full event pipeline: source → router → dedup → state update → hub forward
- Campaign and festival event types cover all lifecycle states
- Agent activity event types exist (THINKING, TOOL_CALL, TOOL_RESULT, COMPLETION)
- Events flow to hub via WebSocket for dashboard consumption
- **Hackathon use**: Agent events can flow through this existing pipeline with zero changes to the router

### Command Execution Sandbox
- `Execute` RPC with streaming stdout/stderr
- Allowlist-based: fest, camp, just, git
- Path validation bound to campaign root (symlink-aware)
- Timeout support, exit code reporting
- **Hackathon use**: Agents can run fest/camp/just commands within sandbox — no need to shell out unsafely

### State Tracking (SQLite)
- `agent_sessions` table: session ID, campaign, festival, task, agent name, provider, model, tokens, working dir
- `agent_activities` table: activity type, content, tool name/ID, success flag
- `festivals` table: status, current phase, current task, completed count
- 7-day event retention, 30-day activity retention
- **Hackathon use**: Agent session data has a home — sessions can be created and queried today

### Hub Sync
- Real-time WebSocket connection to obey.app
- Protobuf-encoded events with exponential backoff reconnection
- Bidirectional: outbound events + inbound commands
- **Hackathon use**: Dashboard could consume agent events via hub without direct daemon connection

### gRPC API
- `Ping` — health check with version, hostname, hub status, campaign count
- `GetState` — query campaigns, festivals, task progress
- `StreamAgentActivity` — client-streaming for activity events
- **Hackathon use**: Dashboard or coordinator can query daemon state over gRPC

---

## B. What Needs to Be Built (Agent Management)

These are the new daemon capabilities required for the hackathon. This is **real product work** — agent management is being added to the daemon as a permanent feature, not a hackathon hack.

### 1. Agent Registry

**Purpose**: Register agent definitions so the daemon knows what agents exist and how to run them.

**Data model** (new table: `agents`):
```
id TEXT PK
name TEXT UNIQUE          -- e.g., "coordinator", "inference-agent", "defi-agent"
type TEXT                 -- e.g., "coordinator", "inference", "defi"
command TEXT[]            -- how to spawn: ["go", "run", "./cmd/agent"]
working_dir TEXT          -- agent's working directory
config JSONB              -- per-agent config (blockchain accounts, etc.)
status TEXT               -- "registered", "running", "stopped", "failed"
created_at TIMESTAMP
updated_at TIMESTAMP
```

**gRPC additions**:
- `RegisterAgent(AgentDefinition) → AgentRegistration`
- `ListAgents() → AgentList`
- `GetAgent(agent_id) → AgentState`
- `UnregisterAgent(agent_id) → Ack`

### 2. Agent Process Management

**Purpose**: Spawn agents as child processes, monitor health, restart on failure, stop gracefully.

**Process lifecycle**:
```
RegisterAgent → StartAgent → [running: heartbeat monitoring] → StopAgent
                                     ↓ (failure)
                              RestartAgent (with backoff)
```

**Key requirements**:
- Spawn agent as OS child process with daemon as parent
- Capture agent stdout/stderr and route to event pipeline
- Heartbeat monitoring: agent must ping daemon within configurable interval
- Restart policy: configurable max restarts, backoff interval
- Graceful stop: SIGTERM → wait → SIGKILL
- Process group isolation: agent crash doesn't take down daemon

**gRPC additions**:
- `StartAgent(agent_id) → AgentStartResponse`
- `StopAgent(agent_id, graceful) → Ack`
- `RestartAgent(agent_id) → AgentStartResponse`

### 3. Agent Configuration

**Purpose**: Per-agent settings that the daemon injects into the agent's environment.

**Config categories**:
- **Blockchain accounts**: Hedera account ID, Base wallet address (injected as env vars)
- **Working directory**: where the agent operates within the campaign
- **Environment variables**: arbitrary key-value pairs for agent-specific config
- **Restart policy**: max restarts, backoff base, backoff max

**What the daemon does NOT configure**:
- LLM provider/model — agents handle their own LLM connections
- Agent logic or prompts — agents are autonomous programs
- Blockchain private keys — agents read from their own `.env` files

### 4. Agent State API

**Purpose**: gRPC endpoints to query what agents are running, their health, and current work.

**State information per agent**:
- Process status: `registered`, `running`, `stopped`, `failed`, `restarting`
- Health: last heartbeat timestamp, heartbeat interval, healthy/unhealthy
- Current work: active session ID, festival ID, task ID
- Resource usage: PID, uptime, restart count
- Token counts: input/output tokens from activity stream

**gRPC additions**:
- `GetAgentStatus(agent_id) → AgentStatus` (detailed single-agent state)
- `ListAgentStatuses() → AgentStatusList` (all agents summary)
- `WatchAgentStatus(agent_id) → stream AgentStatus` (server-streaming status updates)

### 5. Agent Event Enrichment

**Purpose**: Tag existing event pipeline events with `agent_id` so the dashboard can filter by agent.

**Changes**:
- Add `agent_id` field to internal `Event` struct
- Add `agent_id` column to `events` table
- Add `agent_id` to `StreamAgentActivity` message (currently only has `session_id`)
- Router includes `agent_id` when forwarding to hub
- Dashboard can filter events by agent

**This is the smallest change but the most impactful for the demo** — it connects agent identity to the existing event stream.

---

## C. Daemon Roadmap (Beyond Hackathon)

> **This section is for Lance to fill in.** It ensures the hackathon additions align with the product direction.

Questions for Lance:

1. **What's planned for the daemon by Feb 21 (hackathon deadline)?**
   - Which of the above items will you build vs. delegate to an agent?
   - Are there any daemon changes already in progress that overlap?

2. **Agent management long-term vision**:
   - Will agents always be child processes, or will the daemon support remote agents?
   - Is there a planned agent discovery/registration protocol beyond local gRPC?
   - Will agents have declarative configs (YAML) or only programmatic registration?

3. **Hub integration**:
   - Should agent status be synced to hub in real-time?
   - Will the hub dashboard need agent management controls (start/stop)?

4. **Security model for agents**:
   - Should each agent get its own sandbox boundary?
   - Should agents have separate command allowlists?
   - How are agent-to-agent communications secured locally?

5. **Priority order for implementation**:
   - What's the minimum viable agent management for the demo?
   - Can we start with just spawn/stop and add health monitoring later?

---

## Implementation Order (Suggested)

If building Festival 0 (Daemon Agent Management):

```
Phase 1: Agent Registry          ← Foundation, must come first
Phase 2: Process Management      ← Core capability
Phase 3: Event Enrichment        ← Small change, big demo impact
Phase 4: Agent State API         ← Dashboard dependency
Phase 5: Agent Configuration     ← Can be iterative
Phase 6: Integration Testing     ← End-to-end verification
```

**Minimum viable for demo**: Phases 1 + 2 + 3 — daemon can register agents, spawn them, and tag events with agent_id so the dashboard can show which agent did what.
