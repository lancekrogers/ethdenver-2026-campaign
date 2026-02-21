# Obey Agent Economy

**Three AI agents. Three blockchains. One orchestrator.**

## Overview

The Obey Agent Economy is a multi-chain autonomous AI agent system built for ETHDenver 2026. Three specialized agents — Coordinator, Inference, and DeFi — operate across Hedera, 0G, and Base to form a self-sustaining economic cycle.

The **Coordinator** agent orchestrates the system via Hedera Consensus Service (HCS), dispatching tasks and managing payments through Hedera Token Service (HTS). The **Inference** agent routes AI compute jobs to 0G's decentralized infrastructure and maintains ERC-7857 iNFTs as on-chain proof of work. The **DeFi** agent executes yield strategies on Base using ERC-8004, x402, and ERC-8021 payment protocols.

All three agents are managed by the `obey` daemon and planned using the Festival Methodology — a structured task orchestration system designed for human-AI collaboration.

## Architecture

```
obey daemon
  └── agent-coordinator (Hedera)
        ├── agent-inference (0G)
        └── agent-defi (Base)

dashboard (observer UI)
contracts (on-chain settlement)
```

The coordinator acts as the central hub, receiving tasks from the obey daemon and delegating work to the inference and defi agents. The dashboard provides real-time monitoring. Smart contracts handle cross-chain settlement and reputation tracking.

## Projects

| Project | Description | Repo |
|---------|-------------|------|
| agent-coordinator | Orchestrates agents via HCS, manages HTS payments | [GitHub](https://github.com/lancekrogers/agent-coordinator-ethden-2026) |
| agent-inference | Routes inference to 0G Compute, maintains ERC-7857 iNFT | [GitHub](https://github.com/lancekrogers/agent-inference-ethden-2026) |
| agent-defi | Executes DeFi strategies on Base, ERC-8004/x402/ERC-8021 | [GitHub](https://github.com/lancekrogers/agent-defi-ethden-2026) |
| dashboard | Next.js observer UI for real-time agent monitoring | [GitHub](https://github.com/lancekrogers/dashboard-ethden-2026) |
| contracts | Solidity contracts for settlement and reputation | [GitHub](https://github.com/lancekrogers/contracts-ethden-2026) |
| hiero-plugin | Hiero CLI plugin for camp workspace management | [GitHub](https://github.com/lancekrogers/hiero-plugin-ethden-2026) |

## Tech Stack

Go, TypeScript, Next.js, Hedera (HCS/HTS), 0G (Compute/Storage/DA/Chain), Base, Solidity, Foundry

## Directory Structure

| Directory | Purpose |
|-----------|---------|
| `projects/` | Git submodules for all project repos |
| `workflow/` | Code reviews, pipelines, design docs, intents |
| `festivals/` | Festival methodology planning |
| `ai_docs/` | AI-generated documentation |
| `docs/` | Human-authored documentation |
| `dungeon/` | Final state or paused work |
