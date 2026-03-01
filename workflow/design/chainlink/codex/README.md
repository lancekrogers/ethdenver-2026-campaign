# Chainlink Convergence Design Pack (Codex)

## Goal

Design the fastest path from the current Obey Agent Economy codebase to a strong Chainlink Convergence submission that satisfies:

1. CRE-based workflow build
2. Reproducible one-shot simulation with `cre simulate ...`
3. At least one on-chain write on a CRE-supported testnet
4. Valid Moltbook post format and evidence package

Reference requirements: `docs/2026_requirements/moltbook/chainlink/clink-converge-hackathon.md`.

## Proposed Submission Theme

**Project concept:** `CRE Risk Router for Autonomous Agent Economy`

**Primary use-case hashtag:** `#cre-ai`

**Optional secondary hashtag:** `#defi-tokenization` (only if tokenized strategy receipt is completed without risking timeline)

## Why This Fits Existing Work

You already have:

- Live multi-agent task orchestration on Hedera HCS (`projects/agent-coordinator`)
- AI inference outputs from 0G (`projects/agent-inference`)
- DeFi execution and P&L reporting on Base (`projects/agent-defi`)
- Real-time observability surface (`projects/dashboard`)
- Solidity deployment/test workflow (`projects/contracts`)

The missing differentiator for Chainlink is not a full rebuild. It is adding a **CRE decision/simulation layer** that:

- gates agent actions,
- proves behavior in simulation, and
- writes run receipts on-chain.

## Document Map

- `01-cre-ai-core-feature.md`: concrete feature/update design tied to current repos.
- `02-implementation-plan.md`: day-by-day execution plan to March 8, 2026.
- `03-submission-playbook.md`: post format, evidence checklist, and demo narrative.
