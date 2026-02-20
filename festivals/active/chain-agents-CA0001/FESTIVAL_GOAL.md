---
fest_type: festival
fest_id: CA0001
fest_name: chain-agents
fest_status: ready
fest_created: 2026-02-18T13:40:55.706133-07:00
fest_updated: 2026-02-20T11:07:10.73094-07:00
fest_tracking: true
---



# Chain Agents

**Status:** Planned | **Created:** 2026-02-18T13:40:55-07:00

## Festival Objective

**Primary Goal:** Build the 0G inference agent and Base DeFi agent so that all three agents (coordinator, inference, DeFi) form a working autonomous economy.

**Vision:** The coordinator assigns tasks via HCS, the inference agent executes AI workloads on decentralized GPU compute through 0G, and the DeFi agent trades autonomously on Base with revenue exceeding costs. Both specialized agents report results back to the coordinator via HCS, completing the full autonomous economic loop. Each agent targets separate bounty tracks while contributing to the unified system.

## Success Criteria

### Functional Success

- [ ] Inference agent connects to 0G Compute broker and executes GPU inference jobs
- [ ] Inference agent stores memory and results on 0G Storage
- [ ] Inference agent mints ERC-7857 iNFT with encrypted metadata on 0G Chain
- [ ] Inference agent publishes audit trail via 0G DA
- [ ] Inference agent receives task assignments from coordinator via HCS and reports results back
- [ ] DeFi agent registers identity via ERC-8004 on Base
- [ ] DeFi agent implements x402 payment protocol for machine-to-machine payments
- [ ] DeFi agent includes ERC-8021 builder attribution codes
- [ ] DeFi agent executes autonomous trading strategies on Base
- [ ] DeFi agent reports P&L back to coordinator via HCS
- [ ] DeFi agent revenue exceeds operational costs (self-sustaining)
- [ ] All three agents (coordinator, inference, DeFi) operate as a connected autonomous economy

<!-- Add more functional outcomes as needed -->

### Quality Success

- [ ] Both agent codebases have table-driven tests with context cancellation coverage
- [ ] All HCS message handling has integration tests covering publish, subscribe, and error paths
- [ ] Code passes go vet, staticcheck, and project linting with no warnings
- [ ] 0G integration has tests covering broker connection, storage writes, and iNFT minting
- [ ] Base integration has tests covering trade execution, P&L calculation, and payment flows

<!-- Add more quality criteria as needed -->

## Progress Tracking

### Phase Completion

- [ ] 001_IMPLEMENT: Build inference agent (0G integration) and DeFi agent (Base integration) in parallel, then verify cross-agent communication

<!-- Add phases as they're created -->

## Complete When

- [ ] All phases completed
- [ ] Live demo runs the full three-agent cycle: coordinator assigns task via HCS -> inference agent executes on 0G and reports back -> DeFi agent trades on Base and reports P&L
- [ ] Submission-ready for 0G Track 2 bounty ($7k, decentralized GPU inference)
- [ ] Submission-ready for 0G Track 3 bounty ($7k, ERC-7857 iNFT)
- [ ] Submission-ready for Base bounty ($3k+, self-sustaining agent)

<!-- Add more completion criteria as needed -->