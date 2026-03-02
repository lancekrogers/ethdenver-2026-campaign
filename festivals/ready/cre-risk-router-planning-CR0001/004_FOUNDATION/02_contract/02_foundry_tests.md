---
fest_type: task
fest_id: 01_foundry_tests.md
fest_name: foundry tests
fest_parent: 02_contract
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:43:36.946965-07:00
fest_tracking: true
---

# Task: foundry tests

## Objective

Write 4 Foundry tests covering: approved decision recording, denied decision recording, duplicate runId rejection, and TTL-based decision expiry.

## Requirements

- [ ] Test 1: Record approved decision -- verify storage, events, counters (Req P0.2)
- [ ] Test 2: Record denied decision -- verify denial counters increment
- [ ] Test 3: Reject duplicate runId -- reverts with "Decision already recorded"
- [ ] Test 4: Decision expiry -- `isDecisionValid` returns false after TTL via `vm.warp`

## Implementation

1. **Create** `test/RiskDecisionReceipt.t.sol` importing forge-std/Test.sol and the contract.

2. **setUp()**: Deploy a fresh `RiskDecisionReceipt` instance.

3. **test_RecordApprovedDecision**: Call `recordDecision` with approved=true, assert totalApproved==1, totalDenied==0, recorded[runId]==true, isDecisionValid==true.

4. **test_RecordDeniedDecision**: Call with approved=false, assert totalApproved==0, totalDenied==1.

5. **test_RejectDuplicateRunId**: Record once, then `vm.expectRevert("Decision already recorded")` on second call with same runId.

6. **test_DecisionExpiry**: Record with ttl=300, assert isDecisionValid==true, then `vm.warp(block.timestamp + 301)`, assert isDecisionValid==false.

7. **Run**: `forge test -vvv`

## Done When

- [ ] All requirements met
- [ ] All 4 Foundry tests pass
- [ ] Tests verify storage, events, counters, and time-based expiry
