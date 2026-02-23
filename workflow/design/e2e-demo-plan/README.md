# E2E Demo Plan - Remaining Work

## Current State

All 6 projects compile, pass tests, and have real chain integrations. The dashboard runs in mock mode with all 5 panels. Each agent has a daemon gRPC client that falls back to noop when no daemon is available.

**The single blocker for a live e2e demo is the obey daemon (`obeyd`).** It does not exist yet.

## The Gap

```
Agents (gRPC clients) --> [MISSING: obeyd] --> Dashboard (WebSocket client)
       :50051                                      :8080/ws
```

- Agents call Register, Heartbeat, Execute on `localhost:50051` - gracefully fall back to noop today
- Dashboard connects to `ws://localhost:8080/ws` - shows "connecting" forever today
- The daemon bridges these two: accepts gRPC from agents, broadcasts DaemonEvent JSON to dashboard

## Work Items

### 1. Build the Obey Daemon (BLOCKER)

**What it needs to do:**

gRPC server on `:50051`:

- `Register(AgentName, AgentType, Capabilities, HederaAccountID)` -> `(AgentID, SessionID)`
- `Heartbeat(AgentID, SessionID, Timestamp)` -> ack
- `Execute(TaskID, TaskType, Payload, Timeout)` -> `(TaskID, Status, Result, Duration)`

WebSocket server on `:8080/ws`:

- Accept dashboard connections (read-only, no auth for demo)
- Broadcast `DaemonEvent` JSON matching `projects/dashboard/src/lib/data/types.ts`
- Event types: `agent_started`, `agent_stopped`, `heartbeat`, `task_assignment`, `task_result`, `quality_gate`, `payment_settled`, `agent_error`

Festival progress broadcasting:

- Periodically run `fest show --json` (every 10s)
- Broadcast the result as a `festival_progress` event over the same WebSocket channel
- This feeds the Festival View panel with real festival data (phases, sequences, tasks, completion %)

Session tracking:

- Map of active agents (agentID -> session info)
- 90s heartbeat timeout marks agent as stopped
- Broadcast `agent_started` on Register, `agent_stopped` on timeout

**Proto is already defined:** `projects/agent-coordinator/proto/daemon.proto`
**Payload contracts are documented:** `docs/obey/daemon-requirements.md`

**Estimated scope:** ~500 lines of Go. Single binary. No persistence needed for demo.

### 2. Deploy Contracts to Testnet

**Status:** All 3 compile and pass Foundry tests. Deploy script exists. Not deployed.

- Deploy AgentSettlement.sol and ReputationDecay.sol to Hedera testnet
- Deploy AgentINFT.sol to 0G Galileo testnet
- Record deployed addresses in a config file
- Update agent configs to reference deployed addresses

**Scope:** Run `forge script` with the right RPC URLs and keys. 30 minutes if keys are ready.

### 3. Wire Mirror Node in Dashboard Live Mode

**Status:** Fetcher code exists in `src/lib/data/mirror-node.ts`. Partially integrated into `useLiveData`.

- Complete the Mirror Node -> Festival Progress data mapping
- Wire HCS message fetching for the HCS Feed panel in live mode
- This gives 2 of 5 panels (Festival View + HCS Feed) working without the daemon

**Scope:** Small. The fetcher is written, just needs the data transformation layer.

## Demo Sequence (Once Daemon Exists)

```
1. Start obeyd                           # gRPC :50051, WebSocket :8080
2. Start dashboard (just live)           # Connects to :8080/ws
3. Start agent-coordinator               # Registers with daemon, subscribes to HCS
4. Start agent-inference                 # Registers, waits for tasks
5. Start agent-defi                      # Registers, starts trading loop

Dashboard shows:
- Festival View: real festival data from `fest show --json` via daemon
- HCS Feed: real messages from all 3 agents
- Agent Activity: 3 green cards with heartbeats
- DeFi P&L: live trades from Base Sepolia
- Inference Metrics: GPU stats from 0G Compute
```

## Priority Order

| #   | Item               | Impact                       | Effort   |
| --- | ------------------ | ---------------------------- | -------- |
| 1   | Build obeyd        | Unlocks entire live demo     | ~500 LOC |
| 2   | Deploy contracts   | Proves on-chain settlement   | 30 min   |
| 3   | Mirror Node wiring | 2 panels work without daemon | Small    |

## Files Reference

| File                                            | What it defines                        |
| ----------------------------------------------- | -------------------------------------- |
| `projects/agent-coordinator/proto/daemon.proto` | gRPC service contract                  |
| `projects/dashboard/src/lib/data/types.ts`      | DaemonEvent + all payload types        |
| `projects/dashboard/src/hooks/useLiveData.ts`   | How dashboard consumes events          |
| `projects/dashboard/src/lib/data/websocket.ts`  | WebSocket connector (client side)      |
| `docs/obey/daemon-requirements.md`              | Full daemon spec with payload examples |
| `fest show --json`                              | Structured festival data (phases, sequences, tasks, completion %) |
