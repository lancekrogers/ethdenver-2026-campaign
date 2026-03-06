# Dashboard Data Flow

Three-tier data source architecture feeding six dashboard panels. The `useLiveData` hook selects between synthetic and live sources at build time via `NEXT_PUBLIC_USE_MOCK`.

```mermaid
graph TD
    subgraph BuildSwitch["Build-Time Switch"]
        ENV["NEXT_PUBLIC_USE_MOCK"]
        ENV -->|"true"| SYNTH_PATH["Synthetic Path"]
        ENV -->|"false"| LIVE_PATH["Live Path"]
    end

    subgraph Tier1["Tier 1: Synthetic / Mock"]
        SWS["useSyntheticWebSocket<br/><i>synthetic-events.ts generators</i>"]
        SMN["useSyntheticMirrorNode<br/><i>synthetic HCS messages + festival</i>"]
    end

    subgraph Tier2["Tier 2: Live WebSocket"]
        WS["useWebSocket<br/><i>ws://coordinator:8080/ws</i>"]
        WS_EVENTS["DaemonEvent stream:<br/>heartbeat, task_result,<br/>pnl_report, payment_settled"]
    end

    subgraph Tier3["Tier 3: Mirror Node REST"]
        MN["useMirrorNode<br/><i>NEXT_PUBLIC_HEDERA_MIRROR_NODE_URL</i>"]
        MN_DATA["HCS messages + festival progress"]
    end

    SYNTH_PATH --> SWS
    SYNTH_PATH --> SMN
    LIVE_PATH --> WS
    LIVE_PATH --> MN

    WS --> WS_EVENTS

    subgraph LiveData["useLiveData Hook"]
        MERGE["Event Processing<br/><i>processEvent()</i>"]
    end

    SWS --> MERGE
    SMN --> MERGE
    WS_EVENTS --> MERGE
    MN --> MN_DATA --> MERGE

    subgraph Panels["Dashboard Panels"]
        P1["Festival View<br/><i>phases, sequences, tasks</i>"]
        P2["HCS Feed<br/><i>message stream</i>"]
        P3["CRE Decisions<br/><i>risk lifecycle</i>"]
        P4["Agent Activity<br/><i>status, heartbeats</i>"]
        P5["DeFi P&L<br/><i>trades, charts</i>"]
        P6["Inference Metrics<br/><i>compute, storage, iNFT</i>"]
    end

    MERGE -->|"mirror.festivalProgress"| P1
    MERGE -->|"mirror.data (HCSMessage[])"| P2
    MERGE -->|"risk_check_* events"| P3
    MERGE -->|"ws.agents (AgentInfo[])"| P4
    MERGE -->|"pnlSummary, trades, pnlChart"| P5
    MERGE -->|"compute, storage, inft, jobs"| P6

    %% Styles
    classDef hedera fill:#8259EF,color:#fff,stroke:#6b48cc
    classDef runtime fill:#2d3436,color:#fff,stroke:#636e72
    classDef dashboard fill:#00b4d8,color:#000,stroke:#0077b6
    classDef synthetic fill:#f59e0b,color:#000,stroke:#d97706
    classDef panel fill:#1e3a5f,color:#fff,stroke:#2563eb

    class WS,WS_EVENTS runtime
    class MN,MN_DATA hedera
    class SWS,SMN synthetic
    class MERGE dashboard
    class P1,P2,P3,P4,P5,P6 panel
```

## Data Source Priority

| Source | Panels Fed | Requires |
|--------|-----------|----------|
| **Synthetic** (Tier 1) | All 6 panels | `NEXT_PUBLIC_USE_MOCK=true` only |
| **WebSocket** (Tier 2) | Agent Activity, DeFi P&L, Inference Metrics, CRE Decisions | Live coordinator + daemon |
| **Mirror Node** (Tier 3) | Festival View, HCS Feed | Hedera testnet access |

## Panel-Source Mapping

| Panel | Synthetic | WebSocket | Mirror Node |
|-------|:---------:|:---------:|:-----------:|
| Festival View | generateFestivalProgress() | — | festivalProgress |
| HCS Feed | eventToHCSMessage() | — | HCS polling |
| CRE Decisions | generateRiskCheck*() | risk_check_* events | — |
| Agent Activity | deriveAgents() | ws.agents | — |
| DeFi P&L | generateTradeResult() | task_result, pnl_report | — |
| Inference Metrics | generateInferenceResult() | heartbeat (compute/storage/inft) | — |

## Degradation

Without the live daemon/coordinator running, panels degrade as follows:

- **Festival View** and **HCS Feed** continue working via Mirror Node REST
- **Agent Activity**, **DeFi P&L**, **Inference Metrics**, and **CRE Decisions** require the WebSocket connection and show empty/stale state without it
- **Synthetic mode** provides full demo coverage for all panels without any external dependencies

## See Also

- [System Overview](./01-system-overview.md) — where the dashboard fits in the topology
- [Docker Compose](./06-docker-compose.md) — running the dashboard in containers
- [Message Flow](./02-message-flow.md) — event types the dashboard consumes
