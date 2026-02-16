# Festival Roadmap — ETHDenver Agent Economy Build

## Dependency Graph

```
Festival 0: Daemon Agent Management     ← BLOCKS Festivals 2, 7
  │  (adds agent spawn/monitor/stop to daemon)
  │
  │  Festival 1: Hedera Core            ← no daemon dependency, START IMMEDIATELY
  │  │  (HCS, HTS, Schedule Service, festival protocol on-chain)
  │  │
  │  Festival 5: Hiero CLI Plugin       ← no dependency, START IMMEDIATELY
  │     (Node.js wrapper around camp for hiero-cli PR)
  │
  ├─── Festival 2: Agent Coordinator    ← depends on Festival 0 + 1
  │    │  (coordinator logic using daemon's new agent management)
  │    │
  │    ├── Festival 3: 0G Inference Agent  ← depends on 1 + 2
  │    │   (0G Compute/Storage/iNFT, receives tasks via HCS)
  │    │
  │    ├── Festival 4: Base DeFi Agent     ← depends on 1 + 2
  │    │   (AgentKit, ERC-8004, x402, ERC-8021, trading)
  │    │
  │    └── Festival 6: Dashboard           ← depends on 2 + 3 + 4
  │        (observer UI, festival progress, HCS feed, P&L)
  │
  └─── Festival 7: OpenClaw Extension     ← depends on 2 working
       (pluggable runtime, Track 1 recovery)
```

---

## Parallel Tracks

| Track | Festivals | Dependencies | Can Start |
|-------|-----------|-------------|-----------|
| **A** | 1 (Hedera Core) + 5 (Hiero Plugin) | None | Immediately |
| **B** | 0 (Daemon Agent Management) | None | Immediately |
| **C** | 2 → 3/4 → 6 | Tracks A + B must converge | After A+B |
| **D** | 7 (OpenClaw Extension) | Track C proves coordinator works | After C |

**Key insight**: Festivals 1 and 5 have **zero daemon dependency** and represent two P0 bounty submissions (Hedera Track 3, Hedera Track 4). We can start building immediately while the daemon gets agent management.

---

## Festival Definitions

### Festival 0: Daemon Agent Management

**Goal**: Add agent spawn/monitor/stop capability to the obey daemon as real product work.

**Bounty tracks**: None directly — this is infrastructure that enables all other festivals.

**Dependencies**: None (greenfield addition to existing daemon)

**Phase outline**:
1. **Agent Registry** — data model, gRPC API for register/list/get agents
2. **Process Management** — spawn agent as child process, monitor heartbeat, restart on failure, graceful stop
3. **Agent Configuration** — per-agent settings (blockchain accounts, working dir, env vars)
4. **Agent State API** — gRPC endpoints to query running agents, health, current task
5. **Event Enrichment** — tag existing event pipeline with agent_id for dashboard filtering
6. **Integration Testing** — spawn mock agents, verify lifecycle management end-to-end

**Estimated tasks**: ~25–30

---

### Festival 1: Hedera Core

**Goal**: Build the Hedera integration layer — HCS messaging, HTS tokens, Schedule Service, on-chain festival protocol.

**Bounty tracks**: Hedera Track 3 (Best use of native Hedera services — $10K)

**Dependencies**: None

**Phase outline**:
1. **HCS Integration** — topic creation, message publish, mirror node subscription
2. **HTS Integration** — token creation (fungible payment + NFT reputation), transfers, association
3. **Schedule Service** — scheduled heartbeat transactions, multi-agent approval
4. **Festival Protocol** — on-chain festival plan format, task assignment messages, completion messages, quality gate checks
5. **Account Management** — agent account creation, key management

**Estimated tasks**: ~30–35

**Track 3 requirement**: Minimum 2 native Hedera services. We use **4**: HCS + HTS + Schedule Service + Account Management.

---

### Festival 2: Agent Coordinator

**Goal**: Build the coordinator agent that reads festival plans, assigns tasks, monitors progress, and enforces quality gates.

**Bounty tracks**: Supports all tracks (the coordinator is the nervous system)

**Dependencies**: Festival 0 (daemon can spawn/manage agents) + Festival 1 (Hedera SDK ready)

**Phase outline**:
1. **Agent Definition** — coordinator agent config, LLM provider setup, daemon registration
2. **Festival Plan Reading** — parse fest structures into agent-executable plans
3. **Task Assignment** — assign tasks to specialist agents via HCS messages
4. **Progress Monitoring** — subscribe to HCS for agent progress updates
5. **Quality Gate Enforcement** — evaluate gates at sequence boundaries
6. **Payment Management** — HTS transfers on task completion
7. **Integration** — end-to-end flow: plan → assign → execute → verify → pay

**Estimated tasks**: ~35–40

---

### Festival 3: 0G Inference Agent

**Goal**: Build the inference agent that runs on 0G's decentralized compute/storage infrastructure.

**Bounty tracks**: 0G (Best application leveraging 0G infrastructure)

**Dependencies**: Festival 1 (HCS for coordination) + Festival 2 (coordinator can assign tasks)

**Phase outline**:
1. **0G Compute Integration** — broker connection, inference request submission, payment flow
2. **0G Storage Integration** — upload/download agent memory and results
3. **iNFT (ERC-7857)** — deploy contract, mint agent iNFT, update metadata on learning
4. **Agent Logic** — receive tasks from coordinator, process inference, return results
5. **0G DA Integration** — data availability for inference audit trail

**Estimated tasks**: ~25–30

**0G requirement**: Maximize utilization across all 4 layers (Chain, Storage, Compute, DA).

---

### Festival 4: Base DeFi Agent

**Goal**: Build the DeFi agent that executes trading strategies on Base and demonstrates self-sustaining economics.

**Bounty tracks**: Base/Coinbase (AgentKit, ERC-8004, x402, ERC-8021)

**Dependencies**: Festival 1 (HCS for coordination) + Festival 2 (coordinator can assign tasks)

**Phase outline**:
1. **AgentKit Setup** — Coinbase AgentKit wallet, Smart Account (AA), gasless transactions
2. **ERC-8004 Identity** — register agent in Trustless Agents Identity Registry
3. **x402 Payments** — HTTP 402 payment protocol for compute/API access
4. **ERC-8021 Attribution** — builder codes appended to all transaction calldata
5. **Trading Strategy** — basic swap/LP strategy, P&L tracking
6. **Agent Logic** — receive strategy recommendations, execute, report results via HCS

**Estimated tasks**: ~30–35

---

### Festival 5: Hiero CLI Plugin

**Goal**: Build a Hiero CLI plugin that wraps camp's workspace management for Hedera developers.

**Bounty tracks**: Hedera Track 4 (Hiero tooling contribution — $10K)

**Dependencies**: None (wraps existing camp binary)

**Phase outline**:
1. **Plugin Architecture** — follow PLUGIN_ARCHITECTURE_GUIDE.md, Node.js wrapper
2. **Command Mapping** — map camp commands to `hiero camp` namespace
3. **Hedera Templates** — bundled project templates for common Hedera patterns
4. **Documentation** — README, usage examples, contribution guide
5. **PR Preparation** — format for Hiero CLI repository submission

**Estimated tasks**: ~15–20

---

### Festival 6: Dashboard

**Goal**: Build the observer UI showing festival progress, agent activity, HCS feed, and P&L.

**Bounty tracks**: Supports all tracks (demo vehicle)

**Dependencies**: Festival 2 (coordinator running) + Festival 3 (inference agent data) + Festival 4 (DeFi agent P&L)

**Phase outline**:
1. **Layout and Navigation** — Next.js app, main views
2. **Festival Progress View** — visualize fest progress tree, phase/sequence/task states
3. **HCS Feed** — real-time HCS message stream display
4. **Agent Activity** — daemon events visualized (health, status, current task)
5. **DeFi P&L** — Base agent performance metrics
6. **0G Metrics** — inference compute stats
7. **Polish** — responsive design, loading states, error handling

**Estimated tasks**: ~25–30

---

### Festival 7: OpenClaw Extension

**Goal**: Package the daemon's agent management as an OpenClaw-compatible pluggable runtime for Track 1 recovery.

**Bounty tracks**: Hedera Track 1 (OpenClaw extension — $10K)

**Dependencies**: Festival 2 (coordinator proves the pattern works)

**Phase outline**:
1. **Extension Interface** — implement OpenClaw runtime plugin contract
2. **Runtime Adapter** — bridge daemon agent management to OpenClaw expectations
3. **Template Pack** — festival-structured agent templates
4. **Documentation** — extension README and integration guide
5. **Testing** — verify extension loads and runs within OpenClaw

**Estimated tasks**: ~15–20

---

## Total Scope

| Festival | Est. Tasks | Parallel Track |
|----------|-----------|----------------|
| 0: Daemon Agent Management | 25–30 | B |
| 1: Hedera Core | 30–35 | A |
| 2: Agent Coordinator | 35–40 | C |
| 3: 0G Inference Agent | 25–30 | C |
| 4: Base DeFi Agent | 30–35 | C |
| 5: Hiero CLI Plugin | 15–20 | A |
| 6: Dashboard | 25–30 | C |
| 7: OpenClaw Extension | 15–20 | D |
| **Total** | **200–240** | |

---

## Critical Path

The longest dependency chain determines the minimum time-to-demo:

```
Festival 0 (daemon) + Festival 1 (hedera) → Festival 2 (coordinator) → Festival 3/4 (agents) → Festival 6 (dashboard)
```

Tracks A and B run in parallel from day one. The convergence point is Festival 2, which needs both daemon agent management and Hedera SDK integration. After Festival 2 proves the coordinator pattern, Festivals 3 and 4 can run in parallel, and the dashboard builds on top of whatever is ready.

Festival 7 (OpenClaw) is the lowest priority — it's a bonus bounty track that only makes sense if the coordinator is working well.
