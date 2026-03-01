# Festival Overview: Submission and Polish

## Problem Statement

**Current State:** Festivals 1-4 have produced working components across six projects -- smart contracts, Hiero agent plugin, chain agents, dashboard, and supporting infrastructure. However, these pieces have not been verified as a complete end-to-end system, submission packages are incomplete, and no demo materials exist. Individual projects may work in isolation but the full economy cycle has not been validated.

**Desired State:** Every bounty track has a polished, tested, and documented submission package. The full system runs on testnet with verifiable profitability. A 2-minute demo video walks judges through the architecture and live behavior. All submission forms are filled and linked.

**Why This Matters:** This is the final festival before submission. Incomplete docs, untested integrations, or missing demo materials directly reduce judging scores. This festival is the difference between "it works" and "it wins."

## Scope

### In Scope

- End-to-end testing of the full economy cycle (opportunity detection, execution, profit realization)
- Failure recovery testing (agent restart, failed transactions, network failures)
- Profitability validation with documented P&L proof (Base track)
- Hedera Track 3 submission: README, demo video, architecture diagram
- Hedera Track 4 submission: plugin documentation, pull request to Hiero repo
- 0G Track 2 submission: inference pipeline demo
- 0G Track 3 submission: iNFT showcase and documentation
- Base track submission: P&L proof and profitability evidence
- Dashboard deployment and verification
- Testnet agent deployment and monitoring
- Demo script writing and rehearsal (2-minute target)
- Demo video recording

### Out of Scope

- New feature development -- this festival is verification and packaging only
- Smart contract deployment to mainnet
- New contract development (Track 2 contracts only if time permits, treated as stretch goal)
- Performance optimization beyond what is needed for demo stability
- UI redesign or new dashboard features

## Planned Phases

### 001_INGEST

Gather all artifacts, build outputs, deployment records, and documentation from festivals 1-4. Inventory what exists, what is missing, and what needs fixing. This creates the ground truth for the submission checklist.

### 002_PLAN

Define the submission strategy per bounty track. Create a concrete checklist of deliverables for each track, assign priority order, define the deployment plan, and outline the demo script structure.

### 003_EXECUTE

Run end-to-end tests and fix any issues found. Build each submission package (README, architecture docs, demo materials). Deploy agents to testnet and dashboard to hosting. Record the demo video. Verify profitability metrics.

### 004_SUBMIT

Final review of all submission packages. Fill out bounty submission forms. Confirm all links, deployments, and videos are live. Submit each bounty track. Post-submission sanity check that everything is accessible to judges.

## Notes

- This festival depends on all four prior festivals (chain-agents, dashboard, hedera-foundation, hiero-plugin) being complete or substantially complete.
- The demo video is a high-leverage deliverable -- judges may only watch the video and skim the README, so these must be excellent.
- Track 2 contract work is a stretch goal. Do not let it block other submissions.
- Prioritize tracks by bounty value and completeness -- submit the strongest tracks first in case time runs short.
