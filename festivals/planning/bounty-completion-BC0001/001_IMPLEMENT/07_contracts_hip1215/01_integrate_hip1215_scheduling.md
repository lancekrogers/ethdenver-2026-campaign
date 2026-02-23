---
fest_type: task
fest_id: 01_integrate_hip1215_scheduling.md
fest_name: integrate hip1215 scheduling
fest_parent: 07_contracts_hip1215
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.845307-07:00
fest_tracking: true
---

# Task: Integrate HIP-1215 Schedule Service System Contract

## Objective

Add Hedera Schedule Service system contract calls (`0x167`) to AgentSettlement.sol and ReputationDecay.sol so they qualify for Hedera Track 2 (On-Chain Automation) by demonstrating scheduling from within Solidity.

## Requirements

- [ ] AgentSettlement.sol calls `IHederaScheduleService` at address `0x167` to schedule batch settlements, and checks `hasScheduleCapacity()` before scheduling
- [ ] ReputationDecay.sol calls `IHederaScheduleService` to schedule periodic decay execution
- [ ] Both contracts compile with `forge build` targeting Hedera testnet EVM

## Implementation

### Step 1: Create the IHederaScheduleService interface

Create `projects/contracts/src/interfaces/IHederaScheduleService.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IHederaScheduleService {
    function scheduleNative(
        address to,
        uint256 value,
        bytes calldata data,
        uint256 expirationTime
    ) external returns (address scheduleAddress);

    function hasScheduleCapacity() external view returns (bool);

    function signSchedule(address schedule) external;
}
```

The system contract lives at `address(0x167)` on Hedera EVM.

### Step 2: Update AgentSettlement.sol

Add a `scheduleBatchSettle` function:

```solidity
IHederaScheduleService constant SCHEDULE = IHederaScheduleService(address(0x167));

function scheduleBatchSettle(
    address[] calldata agents,
    uint256[] calldata amounts,
    uint256 executeAt
) external onlyOwner {
    require(SCHEDULE.hasScheduleCapacity(), "no schedule capacity");
    bytes memory data = abi.encodeWithSelector(
        this.batchSettle.selector, agents, amounts
    );
    SCHEDULE.scheduleNative(address(this), msg.value, data, executeAt);
}
```

### Step 3: Update ReputationDecay.sol

Add a `scheduleDecay` function that schedules a future call to a `processDecay` function:

```solidity
IHederaScheduleService constant SCHEDULE = IHederaScheduleService(address(0x167));

function scheduleDecay(address[] calldata agents, uint256 executeAt) external onlyOwner {
    require(SCHEDULE.hasScheduleCapacity(), "no schedule capacity");
    bytes memory data = abi.encodeWithSelector(this.processDecay.selector, agents);
    SCHEDULE.scheduleNative(address(this), 0, data, executeAt);
}

function processDecay(address[] calldata agents) external {
    for (uint256 i = 0; i < agents.length; i++) {
        // Force a reputation read which triggers lazy decay
        getReputation(agents[i]);
    }
}
```

### Step 4: Compile

```bash
cd projects/contracts && forge build
```

**NOTE:** This is OPTIONAL (Hedera Track 2 is P2). The system contract at `0x167` only exists on Hedera EVM — `forge test` on a standard EVM will need mocking.

## Done When

- [ ] All requirements met
- [ ] `forge build` succeeds with the HIP-1215 calls compiled in
