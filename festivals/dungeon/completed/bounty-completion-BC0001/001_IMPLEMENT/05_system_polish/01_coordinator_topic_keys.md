---
fest_type: task
fest_id: 01_coordinator_topic_keys.md
fest_name: coordinator topic keys
fest_parent: 05_system_polish
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.811192-07:00
fest_updated: 2026-02-23T13:56:27.343116-07:00
fest_tracking: true
---


# Task: Verify and Document HCS Topic Key Configuration

## Objective

Verify whether the coordinator's HCS topics require admin/submit keys on Hedera testnet, document the decision, and only add key configuration if tests or testnet behavior require it.

## Context

The architecture doc states: "HCS topic creation uses `TopicCreateTransaction` without a submit key restriction in the current testnet setup." If topics work without submit keys on testnet, adding them could break existing topic IDs. This task verifies the current behavior before making changes.

## Requirements

- [ ] Verify that existing HCS topic message submission works without submit keys on testnet (check coordinator logs or run a test)
- [ ] If submit keys ARE needed: add `HEDERA_TOPIC_SUBMIT_KEY` env loading and pass to HCS client
- [ ] If submit keys are NOT needed: document this decision in `projects/agent-coordinator/docs/architecture.md` with a note explaining the testnet security model
- [ ] Either way, `just test` passes in agent-coordinator

## Implementation

### Step 1: Check current behavior

Run the coordinator's HCS tests or check testnet logs to confirm whether message submission succeeds without submit keys. Look for `INVALID_SIGNATURE` errors in any test output or logs.

### Step 2: Decide based on evidence

- If messages submit successfully without keys → document this is intentional for testnet, skip key addition
- If messages fail with `INVALID_SIGNATURE` → add `HEDERA_TOPIC_SUBMIT_KEY` env var loading to `config/config.go` and pass the key to `TopicCreateTransaction.SetSubmitKey()`

### Step 3: Update docker-compose.yml if keys are added

If adding submit key support, add `HEDERA_TOPIC_SUBMIT_KEY` to the coordinator's environment section in docker-compose.yml.

## Done When

- [ ] All requirements met
- [ ] Decision documented (either "keys not needed on testnet" or "keys added and working")
- [ ] `just test` passes in agent-coordinator