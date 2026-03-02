---
fest_type: task
fest_id: 01_receipt_contract.md
fest_name: receipt contract
fest_parent: 02_contract
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:43:36.928389-07:00
fest_updated: 2026-03-02T00:49:19.387254-07:00
fest_tracking: true
---


# Task: receipt contract

## Objective

Write `RiskDecisionReceipt.sol` implementing the on-chain receipt contract per spec Section 7 with `recordDecision()`, `isDecisionValid()`, `getRunCount()`, events, storage, and duplicate prevention.

## Requirements

- [ ] Contract implements `recordDecision()` with 7 parameters: runId, decisionHash, approved, maxPositionUsd, maxSlippageBps, ttlSeconds, chainlinkPrice (Req P0.2)
- [ ] Contract implements `isDecisionValid(bytes32 runId)` returning bool (false after TTL)
- [ ] Contract implements `getRunCount()` returning uint256
- [ ] `DecisionRecorded` event with indexed runId, decisionHash, recorder
- [ ] Duplicate prevention via `recorded` mapping
- [ ] Counters: totalDecisions, totalApproved, totalDenied

## Implementation

1. **Create** `contracts/evm/src/RiskDecisionReceipt.sol` with the Decision struct, storage mappings (`decisions`, `recorded`, `runIds`), counter variables, the `DecisionRecorded` event, and all three functions per spec Section 7.

2. **Key implementation details**:
   - `maxPositionUsd` uses 6-decimal precision
   - `chainlinkPrice` uses 8-decimal precision (matches Chainlink native format)
   - `recordDecision()` stores `block.timestamp` and `msg.sender`
   - `isDecisionValid()` checks `block.timestamp <= decision.timestamp + decision.ttlSeconds`
   - Duplicate check: `require(!recorded[runId], "Decision already recorded")`

3. **Compile**: `forge build`

4. **Copy ABI** to `contracts/evm/src/abi/RiskDecisionReceipt.json`

## Done When

- [ ] All requirements met
- [ ] `forge build` compiles without errors
- [ ] Contract has all 3 functions, event, storage, and duplicate prevention