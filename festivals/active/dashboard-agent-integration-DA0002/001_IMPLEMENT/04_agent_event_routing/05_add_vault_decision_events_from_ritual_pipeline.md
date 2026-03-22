---
fest_type: task
fest_id: 01_add_vault_decision_events_from_ritual_pipeline.md
fest_name: add vault decision events from ritual pipeline
fest_parent: 04_agent_event_routing
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_tracking: true
---

# Task: Add Vault Decision Events from Ritual Pipeline

## Objective

Make the vault-agent's ritual pipeline (festruntime → decision.json → trading loop) publish vault_decision events to the coordinator hub so the Vault Decisions panel shows real GO/NO_GO decisions.

## Requirements

- [ ] After each ritual cycle completes, a vault_decision event is published with the full decision data
- [ ] Event includes: decision (GO/NO_GO), confidence, deviation_pct, gates_passed, signal, ritual_id, tools_used
- [ ] For execute phase: includes tx_hash, chain, token_in/out, amounts, verification result
- [ ] Events match the VaultDecision type defined in the dashboard

## Implementation

1. In agent-defi's trading loop (internal/loop/runner.go), after the festruntime returns a decision:
   - Create a DaemonEvent with type "vault_decision"
   - Populate payload from the ritual Decision struct
   - Publish to coordinator hub
2. After vault swap execution, publish a second vault_decision event with execution details
3. Use the same transport as other agent events

## Done When

- [ ] All requirements met
- [ ] Vault Decisions panel shows real GO/NO_GO decisions from ritual cycles
- [ ] Execute-phase entries show on-chain tx hashes and verification results
