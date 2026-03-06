# Architecture Diagrams

System-level Mermaid diagrams for the Obey Agent Economy — a multi-agent autonomous economy coordinating across Hedera, 0G, Base, and Ethereum.

## System Diagrams

| # | Diagram | Description |
|:-:|---------|-------------|
| 1 | [System Overview](./01-system-overview.md) | Hero diagram — full system topology with all agents, chains, and connections |
| 2 | [Message Flow](./02-message-flow.md) | HCS protocol sequence diagram + task state machine |
| 3 | [Chain Integration](./03-chain-integration.md) | Which components interact with which blockchain services |
| 4 | [CRE Risk Pipeline](./04-cre-risk-pipeline.md) | End-to-end: inference signal → 8 CRE gates → constrained DeFi execution |
| 5 | [Dashboard Data Flow](./05-dashboard-data-flow.md) | 3-tier data sources → 6 dashboard panels |
| 6 | [Docker Compose](./06-docker-compose.md) | 5 services, 3 profiles, ports, networks, host bridges |

## Component-Level Diagrams

Each submodule contains its own architecture diagram focused on internal details:

| Project | Diagram Location |
|---------|-----------------|
| [agent-coordinator](../../projects/agent-coordinator/README.md) | HCS topic flow, payment settlement |
| [agent-inference](../../projects/agent-inference/README.md) | 7-stage 0G pipeline (discover → infer → store → mint → audit) |
| [agent-defi](../../projects/agent-defi/README.md) | Base trading pipeline (identity → trade → attribute → report) |
| [cre-risk-router](../../projects/cre-risk-router/README.md) | 8 risk gates flowchart |

## Quick Reference

### Chains

| Chain | Color | Primary User |
|-------|-------|-------------|
| Hedera | ![#8259EF](https://placehold.co/12x12/8259EF/8259EF.png) Purple | All agents (HCS coordination + HTS payments) |
| 0G Galileo | ![#00D4AA](https://placehold.co/12x12/00D4AA/00D4AA.png) Teal | Inference Agent (compute, storage, DA, iNFT) |
| Base Sepolia | ![#0052FF](https://placehold.co/12x12/0052FF/0052FF.png) Blue | DeFi Agent (Uniswap, ERC-8004, x402, ERC-8021) |
| Ethereum Sepolia | ![#3C3C3D](https://placehold.co/12x12/3C3C3D/3C3C3D.png) Gray | CRE Router (RiskDecisionReceipt, Chainlink DON) |

### Services

| Service | Port | Profile |
|---------|------|---------|
| Dashboard | 3000 | (default) |
| CRE Bridge | 8080 | chainlink |
| Obey Daemon | 50051 | host (not containerized) |
