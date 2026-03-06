# Chain Integration Map

Which runtime components interact with which blockchain services. Left side: agents and services. Right side: chain-specific resources grouped by network.

```mermaid
graph LR
    subgraph Components["Runtime Components"]
        COORD["Coordinator"]
        INF["Inference Agent"]
        DEFI["DeFi Agent"]
        CRE["CRE Router"]
        DASH["Dashboard"]
    end

    subgraph Hedera["Hedera"]
        HCS["HCS Topics"]
        HTS["HTS (AGNT)"]
        SCHED["Schedule Service"]
        MIRROR["Mirror Node"]
    end

    subgraph ZeroG["0G Galileo"]
        ZG_COMPUTE["InferenceServing<br/><i>compute discovery</i>"]
        ZG_STORAGE["Storage + Flow<br/><i>data anchoring</i>"]
        ZG_DA["DA Entrance<br/><i>audit trail</i>"]
        ZG_INFT["ERC-7857<br/><i>iNFT provenance</i>"]
    end

    subgraph Base["Base Sepolia"]
        UNI["Uniswap V3"]
        ERC8004["ERC-8004 Identity"]
        X402["x402 Protocol"]
        ERC8021["ERC-8021 Attribution"]
    end

    subgraph Eth["Ethereum Sepolia"]
        RECEIPT["RiskDecisionReceipt.sol"]
        DON_NODE["Chainlink DON"]
    end

    %% Coordinator → Hedera
    COORD -->|"publish / subscribe"| HCS
    COORD -->|"TransferTransaction"| HTS
    COORD -->|"ScheduleCreateTransaction"| SCHED

    %% Inference → Hedera + 0G
    INF -->|"subscribe / publish"| HCS
    INF -->|"getAllServices()"| ZG_COMPUTE
    INF -->|"submit() + upload"| ZG_STORAGE
    INF -->|"submitOriginalData()"| ZG_DA
    INF -->|"mint()"| ZG_INFT

    %% DeFi → Hedera + Base
    DEFI -->|"subscribe / publish"| HCS
    DEFI -->|"exactInputSingle()"| UNI
    DEFI -->|"register()"| ERC8004
    DEFI -->|"HTTP 402 handshake"| X402
    DEFI -.->|"builder code in calldata"| ERC8021

    %% CRE → Ethereum
    CRE -->|"WASM → report"| DON_NODE
    DON_NODE -->|"recordDecision()"| RECEIPT

    %% Dashboard → Hedera
    DASH -->|"REST polling"| MIRROR

    %% Off-chain connections (dashed)
    COORD -.->|"HTTP POST"| CRE
    COORD -.->|"gRPC"| DAEMON["Obey Daemon"]
    INF -.->|"gRPC"| DAEMON
    DEFI -.->|"gRPC"| DAEMON
    DAEMON -.->|"WebSocket"| DASH

    %% Styles
    classDef hedera fill:#8259EF,color:#fff,stroke:#6b48cc
    classDef zerog fill:#00D4AA,color:#000,stroke:#00b894
    classDef base fill:#0052FF,color:#fff,stroke:#003ecc
    classDef ethereum fill:#3C3C3D,color:#fff,stroke:#2a2a2a
    classDef runtime fill:#2d3436,color:#fff,stroke:#636e72
    classDef dashboard fill:#00b4d8,color:#000,stroke:#0077b6

    class COORD,INF,DEFI,CRE runtime
    class DASH dashboard
    class DAEMON runtime
    class HCS,HTS,SCHED,MIRROR hedera
    class ZG_COMPUTE,ZG_STORAGE,ZG_DA,ZG_INFT zerog
    class UNI,ERC8004,X402,ERC8021 base
    class RECEIPT,DON_NODE ethereum
```

## Chain Summary

| Chain | ID | Services Used | Accessed By |
|-------|----|---------------|-------------|
| **Hedera Testnet** | — | HCS, HTS, Schedule Service, Mirror Node | All agents + Dashboard |
| **0G Galileo** | 16602 | InferenceServing, Flow, DA Entrance, ERC-7857 | Inference Agent |
| **Base Sepolia** | 84532 | Uniswap V3, ERC-8004, x402, ERC-8021 | DeFi Agent |
| **Ethereum Sepolia** | 11155111 | RiskDecisionReceipt.sol, Chainlink DON | CRE Router |

## Off-Chain Connections

| From | To | Protocol | Purpose |
|------|----|----------|---------|
| Coordinator | CRE Bridge | HTTP POST | Risk evaluation before DeFi task assignment |
| All Agents | Obey Daemon | gRPC (port 50051) | Registration, heartbeat, command execution |
| Daemon | Dashboard | WebSocket (port 8080) | Real-time event stream |

## See Also

- [System Overview](./01-system-overview.md) — full system topology
- [CRE Risk Pipeline](./04-cre-risk-pipeline.md) — Chainlink CRE details
- [Docker Compose](./06-docker-compose.md) — how services connect in containers
