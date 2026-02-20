---
fest_type: festival
fest_id: HF0001
fest_name: hedera-foundation
fest_status: dungeon/completed
fest_created: 2026-02-18T13:40:53.486552-07:00
fest_updated: 2026-02-20T13:49:02.086974-07:00
fest_tracking: true
---



# Hedera Foundation

**Status:** Planned | **Created:** 2026-02-18T13:40:53-07:00

## Festival Objective

**Primary Goal:** Stand up the entire Hedera layer (HCS, HTS, Schedule Service) and coordinator agent logic for the agent-coordinator project.

**Vision:** Agents can publish plans, assign tasks, monitor progress, and settle payments using native Hedera services with zero Solidity. The coordinator orchestrates a full cycle from festival plan through HCS task assignment, result collection, and HTS payment settlement -- all built in Go as a consumer of the obey daemon API.

## Success Criteria

### Functional Success

- [ ] HCS topic creation, message publish, and subscribe working end-to-end
- [ ] HTS token creation and transfer between agent accounts operational
- [ ] Schedule Service heartbeat firing on a configurable interval
- [ ] Coordinator logic handles task assignment, progress monitoring, quality gates, and payment flow
- [ ] Shared daemon client package consumes daemon API correctly (consumer only, no daemon internals)
- [ ] Full cycle demonstrated: festival plan -> HCS task assignment -> result collection -> HTS payment

<!-- Add more functional outcomes as needed -->

### Quality Success

- [ ] All Hedera service wrappers have table-driven tests with context cancellation coverage
- [ ] Coordinator logic has integration tests covering the full task-to-payment cycle
- [ ] Zero Solidity in the entire codebase -- pure Hedera native services only
- [ ] Code passes go vet, staticcheck, and project linting with no warnings

<!-- Add more quality criteria as needed -->

## Progress Tracking

### Phase Completion

- [ ] 001_IMPLEMENT: Build HCS/HTS/Schedule Service wrappers, coordinator logic, and daemon client package

<!-- Add phases as they're created -->

## Complete When

- [ ] All phases completed
- [ ] A live demo runs the full cycle: plan -> assign -> collect -> pay using Hedera testnet
- [ ] Submission-ready for Hedera Track 3 bounty ($5k, 3 winners)

<!-- Add more completion criteria as needed -->