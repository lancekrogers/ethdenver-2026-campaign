---
fest_type: task
fest_id: 01_fix_all_stale_readmes.md
fest_name: fix all stale readmes
fest_parent: 06_doc_accuracy
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.828345-07:00
fest_updated: 2026-02-23T13:58:44.210074-07:00
fest_tracking: true
---


# Task: Fix All Stale READMEs

## Objective

Fix known inaccuracies in project READMEs so documentation matches the actual codebase state.

## Requirements

- [ ] `projects/contracts/README.md` no longer says "Scaffolded but not yet implemented" — it should reflect that both contracts are implemented with passing Forge tests
- [ ] `projects/agent-coordinator/README.md` has a dedicated "Schedule Service" subsection under "Native Hedera Services Used" (currently only HCS, HTS, and Account Management are enumerated as sections)
- [ ] `projects/hiero-plugin/README.md` templates table lists all 5 templates (this may already be done in seq 04 task 01 — verify and skip if so)

## Implementation

### Step 1: Fix contracts README

In `projects/contracts/README.md`, find the status line that says "Scaffolded but not yet implemented" or similar. Replace it with:

```markdown
**Status:** Implemented. Both contracts compile and pass Forge tests.
```

Also ensure the README describes both contracts accurately:

- AgentSettlement.sol: settle, batchSettle, ownership, events
- ReputationDecay.sol: time-decay reputation, updateReputation, getReputation

### Step 2: Fix coordinator README

In `projects/agent-coordinator/README.md`, find the "Native Hedera Services Used" section. Add a subsection for Schedule Service:

```markdown
### Schedule Service

- **Scheduled Transactions**: Wraps any Hedera transaction in a `ScheduleCreateTransaction` for deferred execution
- **Heartbeat**: Sends periodic scheduled zero-value HBAR transfers as agent liveness proofs (configurable interval, default 30s)
```

### Step 3: Verify hiero-plugin README

Check if seq 04 task 01 already added the 0G templates. If not, add them.

## Done When

- [ ] All requirements met
- [ ] No README contains claims that contradict the actual codebase (no "not yet implemented" for implemented features, no missing service documentation)