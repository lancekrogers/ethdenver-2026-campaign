# Festival TODO - Hedera Foundation

**Goal**: Stand up the entire Hedera layer (HCS, HTS, Schedule Service) and coordinator agent logic for the agent-coordinator project.
**Status**: Planning

---

## Festival Progress Overview

### Phase Completion Status

- [ ] 001_IMPLEMENT: Build HCS/HTS/Schedule wrappers, coordinator logic, and daemon client package

<!-- Add phases as they're created -->

### Current Work Status

```
Active Phase: 001_IMPLEMENT
Active Sequences: N/A for planning phases
Blockers: Obey daemon must be available as an external dependency before implementation begins
```

---

## Phase Progress

### 001_IMPLEMENT

**Status**: Not Started

#### Sequences

- [ ] HCS service layer (topic creation, message publish, subscribe)
- [ ] HTS service layer (token creation, transfer between agent accounts)
- [ ] Schedule Service heartbeat (configurable interval)
- [ ] Coordinator logic (task assignment, progress monitoring, quality gates, payment flow)
- [ ] Daemon client package (shared, consumer-only)
- [ ] Integration test: full cycle (plan -> assign -> collect -> pay)

<!-- Add sequences as they're created -->

---

## Blockers

<!-- Add blockers as they arise -->

- Obey daemon must be available as an external dependency. Agents consume its API but do not build it.

---

## Decision Log

<!-- Add decisions as they're made -->

- Zero Solidity approach: all Hedera interaction uses native services (HCS, HTS, Schedule Service) only.
- Daemon is an external dependency -- agent-coordinator is a consumer, not a contributor.

---

*Detailed progress available via `fest status`*
