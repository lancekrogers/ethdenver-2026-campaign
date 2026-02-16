# obeyd (Daemon) — Current State

> Source: `projects/obey-platform-monorepo/obey/` — Go, v0.1.0
> 20 internal packages, gRPC + SQLite + WebSocket

## What the Daemon Actually Is

The obey daemon (`obeyd`) is an **event broker, file watcher, sandboxed command executor, and hub sync client**. It runs as a background process, watches campaign/festival files for changes, receives events from fest and camp CLIs, persists state in SQLite, and syncs events to the obey.app hub via WebSocket.

**It does NOT manage agents today.** The design docs (`01-architecture.md`, `03-obey-layer.md`) describe the daemon as an agent orchestrator that spawns processes and routes LLM requests. That capability does not exist yet. The `StreamAgentActivity` infrastructure exists for recording agent session data, but agents are not first-class daemon entities.

---

## 5 Core Components (Running in Parallel via errgroup)

### 1. gRPC Server

**Socket**: `$XDG_RUNTIME_DIR/obey/daemon.sock` (Unix domain socket)
**Service**: `LocalDaemonService` (proto: `local/v1/local.proto`)

| RPC Method | Direction | Purpose |
|------------|-----------|---------|
| `ReportCampaignEvent` | Unary | Receive campaign lifecycle events from camp CLI |
| `ReportFestivalEvent` | Unary | Receive festival lifecycle events from fest CLI |
| `StreamAgentActivity` | Client streaming | Stream agent session activity (thinking, tool calls, results) |
| `Ping` | Unary | Health check — returns version, hostname, hub status, campaign count |
| `GetState` | Unary | Query campaigns, festivals, task progress |
| `Execute` | Server streaming | Sandboxed command execution with streaming stdout/stderr |
| `Shutdown` | Unary | Graceful daemon stop |

**Error handling**: All internal errors use `oberror` codes (format `OBEY-NNNN`), mapped to gRPC status codes via `ErrorInterceptor`.

### 2. File Watcher (fsnotify)

**Config defaults**: 100ms debounce, watches `fest.yaml` and `progress.yaml` files
**Ignored**: `.git`, `node_modules`, `.DS_Store`, `__pycache__`

Watches campaign directories recursively. On file change:
1. Debounces rapid changes per file path
2. Emits `FileChangePayload` (path, operation, isDir) to the event router
3. Operations: `create`, `write`, `remove`, `rename`

### 3. Event Router (Central Hub)

**Config defaults**: 500ms dedup window, 100-event buffer

Receives events from both gRPC server and file watcher. Processing:
1. **Deduplication** — SHA256 hash of (event type + truncated timestamp + payload IDs), keyed by entity (`campaign:ID` or `festival:ID`). gRPC events take priority over file watcher events.
2. **State update** — updates local SQLite via StateHandler
3. **Hub forwarding** — sends to hub WebSocket client if connected

#### Event Types (internal)

**Campaign events:**
- `CAMPAIGN_CREATED`, `CAMPAIGN_UPDATED`, `CAMPAIGN_DELETED`
- `PROJECT_ADDED`, `PROJECT_REMOVED`

**Festival events:**
- `FESTIVAL_CREATED`, `FESTIVAL_STATUS_CHANGED`
- `PHASE_CHANGED`, `SEQUENCE_STARTED`, `SEQUENCE_COMPLETED`
- `TASK_STARTED`, `TASK_COMPLETED`, `TASK_FAILED`, `TASK_BLOCKED`

**Agent activity events** (infrastructure exists, no agents to emit them yet):
- `AGENT_THINKING`, `AGENT_TOOL_CALL`, `AGENT_TOOL_RESULT`, `AGENT_COMPLETION`

**Event sources**: `SourceGRPC`, `SourceFileWatcher`

### 4. Hub WebSocket Client

**URL**: `wss://api.obey.app/v1/daemon` (configurable)
**Protocol**: Protobuf-encoded messages in WebSocket frames
**Reconnection**: Exponential backoff (1s min → 60s max)
**Keepalive**: 30s ping interval, 10s pong timeout

Bidirectional:
- **Outbound**: daemon events forwarded to hub for dashboard consumption
- **Inbound**: hub commands/requests routed to daemon request handler
- Sends `DaemonReady` event on successful connection

### 5. SQLite State Manager

**Location**: `~/.local/share/obey/daemon.db` (via SQLC-generated queries)

#### Schema

**`campaigns`** — registered campaigns
```
id TEXT PK, name TEXT, path TEXT UNIQUE, description TEXT,
festival_count INT, active_festival_count INT,
created_at TIMESTAMP, updated_at TIMESTAMP
```

**`festivals`** — festival state per campaign
```
(campaign_id, id) PK, name TEXT, goal TEXT, status TEXT,
phase TEXT, path TEXT, total_tasks INT, completed_tasks INT,
current_task TEXT, current_agent TEXT,
created_at TIMESTAMP, updated_at TIMESTAMP
FK → campaigns(id)
```

**`agent_sessions`** — agent execution sessions
```
id TEXT PK, campaign_id TEXT, festival_id TEXT, task_id TEXT,
agent_name TEXT, provider TEXT, model TEXT, status TEXT,
tokens_input INT, tokens_output INT, working_dir TEXT,
started_at TIMESTAMP, ended_at TIMESTAMP
FK → campaigns(id)
```

**`agent_activities`** — per-session activity log
```
id INT PK AUTO, session_id TEXT, activity_type TEXT,
content TEXT, tool_name TEXT, tool_call_id TEXT, success INT,
created_at TIMESTAMP
FK → agent_sessions(id)
```

**`events`** — event audit log (7-day retention)
```
id INT PK AUTO, campaign_id TEXT, festival_id TEXT,
event_type TEXT, payload TEXT, source TEXT,
created_at TIMESTAMP
FK → campaigns(id)
```

**`recent_events`** — deduplication cache
```
entity_key TEXT PK, event_hash TEXT, source TEXT,
created_at TIMESTAMP
```

Festival statuses: `planned`, `active`, `paused`, `completed`, `failed`, `cancelled`

---

## Command Sandbox

**Allowlist** (default):
| Command | Purpose |
|---------|---------|
| `fest` | Festival CLI |
| `camp` | Campaign CLI |
| `just` | Task runner |
| `git` | Version control |

**Execution flow**:
1. Validate request (command + campaign_id required)
2. Resolve campaign by ID (primary) or name (fallback)
3. Check command against per-campaign allowlist or defaults
4. Check subcommand restrictions via `__manifest`
5. Create sandbox bound to campaign directory
6. Validate all path-like arguments stay within campaign boundary
7. Execute with timeout, stream stdout/stderr via gRPC
8. Return exit code + duration on completion

**Boundary enforcement**:
- Campaign root is the sandbox boundary
- All paths resolved through symlinks before validation (prevents symlink escape)
- `cd` command changes working dir within sandbox only
- `OBEY_*` environment variables filtered (reserved namespace)
- Max 1MB per output line

---

## Daemon Lifecycle

1. **Acquire PID lock** — single-instance enforcement via PID file
2. **Setup signal handling** — SIGINT/SIGTERM → graceful shutdown
3. **Start components** in parallel (errgroup):
   - gRPC server (if enabled + configured)
   - File watcher (if enabled + paths configured)
   - Event router (if configured)
   - Hub client (if configured)
4. **Wait for shutdown** — signal, component error, or `Shutdown` RPC
5. **Graceful shutdown** — stop all components, close database
6. **Release lock** — remove PID file

---

## Agent Activity Infrastructure (Exists But Unused)

The `StreamAgentActivity` RPC and `agent_sessions`/`agent_activities` tables exist but have no producer. The data model supports:

- **Session tracking**: agent name, provider, model, token counts, working directory
- **Activity types**: `AGENT_THINKING`, `AGENT_TOOL_CALL`, `AGENT_TOOL_RESULT`, `AGENT_COMPLETION`
- **Tool call tracking**: tool name, call ID, arguments (bytes), output, success flag

This infrastructure was built anticipating agent management. The hackathon work (Festival 0) adds the missing piece: agent process lifecycle management.
