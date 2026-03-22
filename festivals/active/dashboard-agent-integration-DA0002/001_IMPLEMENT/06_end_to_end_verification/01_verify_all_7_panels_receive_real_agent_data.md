---
fest_type: task
fest_id: 01_verify_all_7_panels_receive_real_agent_data.md
fest_name: verify all 7 panels receive real agent data
fest_parent: 06_end_to_end_verification
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_tracking: true
---

# Task: Verify All 7 Panels Receive Real Agent Data

## Objective

Run `just demo up` and verify each dashboard panel displays data from real agent binaries, not synthetic generators.

## Requirements

- [ ] Festival View: Shows real festival hierarchy from coordinator's fest CLI integration
- [ ] HCS Feed: Shows real HCS messages (or mock-HCS messages) from agent event stream
- [ ] CRE Decisions: Shows real risk evaluations from CRE bridge
- [ ] Vault Decisions: Shows real GO/NO_GO decisions from vault-agent ritual pipeline
- [ ] Agent Activity: Shows real heartbeats from all 3 agents
- [ ] DeFi P&L: Shows real trades from agent-defi mock trading loop
- [ ] Inference Metrics: Shows real compute metrics from agent-inference mock inference loop

## Implementation

1. Run `just demo up`
2. Open http://localhost:3000
3. Wait 60 seconds for all agents to publish initial events
4. Verify each panel has data — screenshot each one
5. Verify no "Source: synthetic (fallback)" labels appear
6. Check browser console for WebSocket connection established

## Done When

- [ ] All requirements met
- [ ] All 7 panels show data sourced from real agent binaries
- [ ] Browser console shows active WebSocket connection to coordinator
