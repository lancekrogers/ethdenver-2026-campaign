# OpenClaw Extension — Track 1 Recovery

## Why This Is Phase 2, Not Phase 1

Building with obey agents first is the priority because:

1. **Permanent value**: Getting the daemon working as an agent orchestrator is real product development, not hackathon throwaway code
2. **Architecture validation**: If the daemon can orchestrate its own agents across 3 chains, it works
3. **No forfeited progress**: OpenClaw support is additive — nothing built in Phase 1 gets thrown away

Once obey agents work, adding OpenClaw is an integration task, not a rewrite.

## What OpenClaw Support Unlocks

| Without OpenClaw | With OpenClaw |
|-----------------|---------------|
| Tracks 2, 3, 4 ($15k) | **All 4 tracks ($25k)** |
| "Our agents on Hedera" | "Our orchestrator runs ANY agent on Hedera" |
| obey-only demo | **Provider-agnostic demo** |

Track 1 requires: "Build on OpenClaw runtime" + "society of OpenClaw agents" + UCP commerce.

## Architecture: Pluggable Agent Runtime

The obey daemon is already provider-agnostic for LLMs. The same principle extends to agent runtimes:

```
OBEY DAEMON (Orchestrator)
│
├── Agent Runtime: obey-native
│   └── Go process managed by daemon
│   └── Direct LLM provider connection
│
└── Agent Runtime: openclaw
    └── OpenClaw Node.js process managed by daemon
    └── OpenClaw handles LLM + 50 integrations
    └── Daemon manages lifecycle, routing, hierarchy
```

The daemon doesn't need to reimplement OpenClaw. It wraps OpenClaw instances as managed agents:

```
daemon.spawn({
  name: "research-agent",
  runtime: "openclaw",          // ← runtime selector
  config: {
    openclaw_skills: ["hedera", "web-search"],
    hedera_account: "0.0.xxx",
  }
})
```

vs the existing obey-native path:

```
daemon.spawn({
  name: "coordinator",
  runtime: "obey",              // ← runtime selector
  config: {
    provider: "claude",
    model: "opus",
    hedera_account: "0.0.yyy",
  }
})
```

The daemon manages both identically: spawn, configure, monitor, route messages, enforce hierarchy, kill.

## What Changes for Track 1

### Additional Requirements

| Track 1 Requirement | Implementation |
|---------------------|---------------|
| Build on OpenClaw runtime | Some agents run as OpenClaw instances via daemon |
| Agents as primary users | Agent-to-agent commerce, humans only observe |
| Multi-agent environment | Daemon orchestrates mixed obey + OpenClaw agents |
| Use Hedera (HTS/HCS) | Already built in Phase 1 |
| UI shows agent flow | Dashboard already built in Phase 1 |
| Agent flow steps and states | Festival progress visualization already built |

### Additional Components

1. **OpenClaw adapter for daemon** — Spawn/manage OpenClaw processes
2. **Hedera Agent Kit integration** — OpenClaw agents use `hedera-agent-kit` for chain ops
3. **UCP commerce layer** — Agent-to-agent service discovery and payment negotiation
4. **Mixed-runtime demo** — Dashboard shows obey and OpenClaw agents cooperating

### UCP (Universal Commerce Protocol)

Track 1 bonus points for UCP. This is Google's open standard for agentic commerce:

- REST/JSON-RPC based
- A2A (Agent-to-Agent) and MCP support
- Standardizes how agents discover, negotiate, and pay each other
- Fits naturally: coordinator uses UCP to post tasks, specialists use UCP to bid

## Integration Approach

### Step 1: OpenClaw Process Wrapper

The daemon spawns OpenClaw as a child process:

```go
type OpenClawAgent struct {
    process   *exec.Cmd
    stdin     io.Writer
    stdout    io.Reader
    hcsClient *hedera.HCSClient
}

func (a *OpenClawAgent) Start(config AgentConfig) error {
    // Start OpenClaw with Hedera skills enabled
    a.process = exec.Command("npx", "openclaw", "start",
        "--skills", "hedera,web-search",
        "--config", config.Path,
    )
    // Wire stdin/stdout for message passing
    // Register with daemon's agent registry
}
```

### Step 2: Message Bridge

OpenClaw agents communicate via their native protocol. The daemon bridges this to HCS:

```
OpenClaw agent ←→ daemon message router ←→ HCS topic
```

Messages from OpenClaw agents get published to HCS (audit trail).
Messages from HCS get forwarded to the appropriate OpenClaw agent.

### Step 3: Mixed Orchestration

The coordinator (obey-native) can delegate to both runtime types:

```
Coordinator (obey-native)
├── Inference Agent (obey-native) — runs on 0G
├── DeFi Agent (obey-native) — trades on Base
├── Research Agent (openclaw) — uses OpenClaw web skills
└── Writer Agent (openclaw) — uses OpenClaw integrations
```

The festival plan doesn't care about runtime. Tasks are assigned to agents by capability, not by runtime type.

## Demo Day Impact

If OpenClaw is ready, the demo evolves:

**Original close**: "Three agents. Three chains. One orchestrator."

**Extended close**: "Three agents. Three chains. Two runtimes. One orchestrator. Our daemon runs our own agents AND OpenClaw agents. It doesn't matter what the agent is built with — Obedience Corp orchestrates it."

This is a stronger pitch because it demonstrates the daemon's provider-agnostic value proposition with a concrete, well-known framework (60k GitHub stars).

## Build Sequence

This entire extension is a single sequence added after Phase 2:

### Sequence 2.4: OpenClaw Integration (P1 — after obey agents work)

1. Install OpenClaw runtime and Hedera skills
2. Implement OpenClaw process wrapper in daemon
3. Implement message bridge (OpenClaw ↔ daemon ↔ HCS)
4. Create 1-2 OpenClaw agents with Hedera Agent Kit
5. Add UCP commerce layer for agent service discovery
6. Verify: Coordinator (obey) assigns task to OpenClaw agent, receives result via HCS
7. Update dashboard to show mixed-runtime agent status
8. Update demo script for Track 1 narrative

### Dependency

```
Phase 1 (Foundation) → Phase 2 (obey agents working) → Sequence 2.4 (add OpenClaw)
                                                              │
                                                              ▼
                                                    Track 1 submission
```

No existing work changes. OpenClaw is purely additive.

## Risk

- **Low risk**: If OpenClaw integration doesn't work in time, we still have Tracks 2-4
- **Medium effort**: OpenClaw is Node.js, well-documented, has Hedera Agent Kit ready
- **High reward**: Unlocks $10k Track 1 + strongest "provider-agnostic" narrative
