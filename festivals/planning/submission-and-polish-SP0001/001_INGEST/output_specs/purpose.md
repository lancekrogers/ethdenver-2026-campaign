# Festival Purpose: Get It Working, Record the Demo

## End Goal

The three-agent autonomous economy runs end-to-end — coordinator assigns tasks via HCS, inference agent processes them, defi agent trades, payments settle via HTS — and a demo video captures it all.

## Why This Festival Exists

The submission deadline has passed. Bounty packaging, Devfolio forms, and per-track submission materials are no longer relevant. What matters now is having a working system and a video that proves it.

Festivals 1-4 produced working components, and a single live testnet run on 2026-02-21 confirmed HCS transport and HTS payments work. But:

- The full economy cycle has not been demonstrated end-to-end in a single recorded session
- 0G inference pipeline is blocked by a missing serving contract
- Base DeFi trades are stubbed (zero-address DEX router)
- Dashboard does not compile (stub components with broken imports)
- No demo video exists

## Success Criteria

### Must Have

- All three agents start, communicate via HCS, and complete tasks
- Coordinator triggers HTS payment on task completion
- The full cycle is captured in a demo video
- Dashboard or equivalent visualization shows agent activity in real-time

### Should Have

- 0G inference pipeline executes against real compute (requires contract deployment)
- DeFi agent executes real trades on Base Sepolia (requires DEX router address)
- Demo video follows the narrative from `04-demo-and-deliverables.md`

### Nice to Have

- Polished project READMEs
- Architecture diagrams

## What Done Looks Like

- A demo video exists showing three agents operating across chains
- The video shows real HCS messages, real HTS payments, and agent activity
- Someone watching the video understands: three AI agents, three blockchains, one orchestrator
