---
fest_type: task
fest_id: 02_full_cycle_test.md
fest_name: full_cycle_test
fest_parent: 01_e2e_testing
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Full Cycle Test

**Task Number:** 02 | **Sequence:** 01_e2e_testing | **Autonomy:** medium

## Objective

Run the full economy cycle end-to-end on Hedera testnet. Start all three agents (coordinator, inference, defi), trigger a complete cycle from opportunity detection through profit realization, and document the entire flow with logs, screenshots, and timing.

## Requirements

- [ ] All three agents started and connected to HCS topics on testnet
- [ ] A complete economy cycle executed: opportunity detected, task assigned via HCS, inference executed, DeFi trade completed, HTS payment settled
- [ ] Full cycle documented with logs showing each stage
- [ ] Screenshots captured at key transition points
- [ ] Timing recorded for each stage of the cycle
- [ ] Results saved to `results/full_cycle_test_report.md` within this sequence directory

## Implementation

### Step 1: Start the coordinator agent

From the agent-coordinator project root:

```bash
cd $(fgo)
# Start the coordinator agent in the background or a separate terminal
# Use the project's standard run command (check justfile or Makefile)
just run-coordinator
# Or if no just recipe exists:
go run cmd/coordinator/main.go --config config/testnet.yaml
```

Verify the coordinator is running by checking for HCS heartbeat messages in the logs.

### Step 2: Start the inference agent

From the agent-inference project:

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-inference
# Start the inference agent
just run
# Or: go run cmd/agent/main.go --config config/testnet.yaml
```

Verify the inference agent registers with the coordinator via HCS.

### Step 3: Start the DeFi agent

From the agent-defi project:

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/agent-defi
# Start the defi agent
just run
# Or: go run cmd/agent/main.go --config config/testnet.yaml
```

Verify the DeFi agent registers with the coordinator via HCS.

### Step 4: Trigger a full economy cycle

With all three agents running, trigger or wait for an opportunity detection. The coordinator should:

1. Detect an opportunity (or receive one)
2. Assign a task to the inference agent via HCS
3. The inference agent executes the task (model inference via 0G Compute)
4. The inference agent reports results back via HCS
5. The coordinator routes the results to the DeFi agent
6. The DeFi agent executes a trade on Base
7. HTS payment settles between agents

Document each step as it happens.

### Step 5: Capture evidence

For each stage of the cycle, capture:

- **Log excerpt**: The relevant log lines showing the state transition
- **HCS message**: The HCS topic message that triggered or confirmed the transition
- **Timestamp**: The exact time the transition occurred
- **Screenshot**: If applicable (e.g., dashboard showing the agent state)

### Step 6: Write the test report

Create `results/full_cycle_test_report.md` in this sequence directory with:

```markdown
# Full Cycle Test Report

## Test Environment
- Date: [date]
- Network: Hedera Testnet
- Coordinator version: [commit hash]
- Inference agent version: [commit hash]
- DeFi agent version: [commit hash]

## Cycle Timeline

| Stage | Timestamp | Duration | HCS Message ID | Notes |
|-------|-----------|----------|----------------|-------|
| Opportunity detected | | | | |
| Task assigned | | | | |
| Inference started | | | | |
| Inference completed | | | | |
| Trade executed | | | | |
| Payment settled | | | | |

## Total Cycle Time: [X seconds]

## Log Excerpts
[Include relevant log excerpts for each stage]

## Screenshots
[Include or reference screenshots]

## Issues Encountered
[Document any issues, retries, or unexpected behavior]
```

## Done When

- [ ] All three agents started and communicating via HCS on testnet
- [ ] At least one complete economy cycle executed successfully
- [ ] Test report written with logs, timing, and evidence for every stage
- [ ] Report saved to `results/full_cycle_test_report.md`
- [ ] No unresolved critical issues blocking the cycle
