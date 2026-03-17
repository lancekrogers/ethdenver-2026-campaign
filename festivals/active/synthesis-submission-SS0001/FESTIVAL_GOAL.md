---
fest_type: festival
fest_id: SS0001
fest_name: synthesis-submission
fest_status: active
fest_created: 2026-03-16T21:31:02.379128-06:00
fest_updated: 2026-03-16T22:16:29.878942-06:00
fest_tracking: true
---



# synthesis-submission

**Status:** Planned | **Created:** 2026-03-16T21:31:02-06:00

## Festival Objective

**Primary Goal:** Prepare and submit the OBEY project to the Synthesis hackathon, targeting Protocol Labs, Uniswap, Status Network, Markee, and the Open Track bounties.

**Vision:** Package existing OBEY infrastructure (ObeyVault, festival methodology, ERC-8004 identity, agent-defi) into hackathon submissions that maximize bounty payout probability. Deploy to Base mainnet, generate Protocol Labs required artifacts, and submit to all qualifying tracks before the deadline.

## Success Criteria

### Functional Success

- [ ] `agent.json` manifest generated in DevSpot format
- [ ] `agent_log.json` generated from festival ritual execution data
- [ ] ObeyVault deployed to Base mainnet with funded USDC
- [ ] 2-3 live Uniswap trades executed on Base mainnet via vault
- [ ] Uniswap API integration verified (Developer Platform API, not just SwapRouter02)
- [ ] Contract deployed to Status Network Sepolia + 1 gasless tx
- [ ] Markee integration live on festival repo
- [ ] Repo public with secrets cleaned
- [ ] Video demo recorded (6 checkpoints, ~3 min)
- [ ] Submissions sent to all target tracks via Synthesis API

### Quality Success

- [ ] Protocol Labs narrative differentiated: "Cook" = autonomy story, "Receipts" = identity/trust story
- [ ] All on-chain evidence has real TxIDs (no mocks)
- [ ] ConversationLog captures genuine human-agent collaboration
- [ ] Submission metadata accurately reflects tools and skills used

## Progress Tracking

### Phase Completion

- [ ] 001_IMPLEMENT: All submission artifacts, deployments, and integrations

## Complete When

- [ ] All phases completed
- [ ] Submissions confirmed via Synthesis API for all target tracks
- [ ] All on-chain deployments verified on block explorers