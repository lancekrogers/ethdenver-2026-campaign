---
fest_type: task
fest_id: 03_update_forge_tests.md
fest_name: update forge tests
fest_parent: 07_contracts_hip1215
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.845935-07:00
fest_tracking: true
---

# Task: Update Forge Tests for HIP-1215 Scheduling

## Objective

Add Forge tests for the new `scheduleBatchSettle` and `scheduleDecay` functions, mocking the HIP-1215 system contract since it only exists on Hedera EVM.

## Requirements

- [ ] Tests mock the `IHederaScheduleService` contract at address `0x167` using `vm.etch` and `vm.mockCall`
- [ ] Tests verify `scheduleBatchSettle` reverts when `hasScheduleCapacity()` returns false and succeeds when it returns true

## Implementation

### Step 1: Mock the system contract

In Forge tests, mock the system contract using `vm.mockCall`:

```solidity
address SCHEDULE_ADDR = address(0x167);

// Mock hasScheduleCapacity to return true
vm.mockCall(
    SCHEDULE_ADDR,
    abi.encodeWithSelector(IHederaScheduleService.hasScheduleCapacity.selector),
    abi.encode(true)
);

// Mock scheduleNative to return a fake schedule address
vm.mockCall(
    SCHEDULE_ADDR,
    abi.encodeWithSelector(IHederaScheduleService.scheduleNative.selector),
    abi.encode(address(0xBEEF))
);
```

You may also need `vm.etch(SCHEDULE_ADDR, hex"00")` to place code at the system contract address so the call doesn't revert as an EOA call.

### Step 2: Test scheduleBatchSettle

```solidity
function test_scheduleBatchSettle() public {
    // Setup mocks
    // Call scheduleBatchSettle with valid args
    // Verify it doesn't revert
}

function test_scheduleBatchSettle_revertsNoCapacity() public {
    // Mock hasScheduleCapacity to return false
    vm.mockCall(SCHEDULE_ADDR, ..., abi.encode(false));
    vm.expectRevert("no schedule capacity");
    settlement.scheduleBatchSettle(agents, amounts, block.timestamp + 1 hours);
}
```

### Step 3: Test scheduleDecay

Similar pattern — mock the system contract, verify `scheduleDecay` calls through.

### Step 4: Run tests

```bash
cd projects/contracts && forge test -vvv
```

Ensure no regressions in existing AgentSettlement and ReputationDecay tests.

## Done When

- [ ] All requirements met
- [ ] `forge test` passes with all existing tests plus new scheduling tests
