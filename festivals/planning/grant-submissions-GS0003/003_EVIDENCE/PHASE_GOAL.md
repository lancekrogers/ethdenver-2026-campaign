---
fest_type: phase
fest_id: 003_EVIDENCE
fest_name: EVIDENCE
fest_parent: grant-submissions-GS0003
fest_order: 3
fest_status: pending
fest_created: 2026-03-11T05:00:54.071526-06:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 003_EVIDENCE

**Phase:** 003_EVIDENCE | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Close all on-chain evidence gaps on 0G Galileo and Base Sepolia so both grant applications have verifiable transaction hashes.

**Context:** Code is production-quality with 350+ passing tests, but zero write transactions exist on 0G Galileo and Base Sepolia evidence is unverified. Grant reviewers need chainscan/basescan links as proof. This phase generates that proof.

## Required Outcomes

Deliverables this phase must produce:

- [ ] Funded Galileo wallet (via faucet.0g.ai)
- [ ] Funded Base Sepolia wallet (ETH + USDC)
- [ ] AgentINFT.sol deployed to 0G Galileo — contract address on chainscan
- [ ] Storage `submit()` transaction on 0G Galileo — tx hash on chainscan
- [ ] DA `submitOriginalData()` transaction on 0G Galileo — tx hash on chainscan
- [ ] iNFT `mint()` transaction on 0G Galileo — tx hash + token ID on chainscan
- [ ] ERC-8004 identity registration on Base Sepolia — tx hash on basescan
- [ ] Uniswap V3 swap on Base Sepolia — tx hash on basescan
- [ ] All tx hashes documented in evidence-manifest.md

## Quality Standards

Quality criteria for all work in this phase:

- [ ] Every transaction verified on block explorer (not just claimed from logs)
- [ ] Transaction hashes are for WRITE operations (not view calls)
- [ ] Evidence document includes direct links to block explorers

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_0g_galileo_evidence | Generate 4+ write transactions on 0G Galileo | chainscan tx links |
| 02_base_sepolia_evidence | Generate 2+ write transactions on Base Sepolia | basescan tx links |
| 03_evidence_manifest | Document all tx hashes in a single manifest | evidence-manifest.md |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Galileo faucet tested and working
- [ ] Base Sepolia faucet tested and working
- [ ] Private keys available for both chains
- [ ] agent-inference and agent-defi build successfully

## Phase Progress

### Sequence Completion

- [ ] 01_0g_galileo_evidence
- [ ] 02_base_sepolia_evidence
- [ ] 03_evidence_manifest

## Notes

- 0G Galileo chain ID: 16602, RPC: https://evmrpc-testnet.0g.ai
- Base Sepolia chain ID: 84532, RPC: https://sepolia.base.org
- If session auth with 0G compute providers works, also generate an inference tx (bonus, not required)
- Reference: workflow/explore/grant-research/2026-03-11/0g/evidence-gaps.md
