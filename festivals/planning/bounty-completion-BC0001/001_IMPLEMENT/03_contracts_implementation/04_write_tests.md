---
fest_type: task
fest_id: 04_write_tests.md
fest_name: write tests
fest_parent: 03_contracts_implementation
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:46.814464-07:00
fest_tracking: true
---

# Task: Write Forge Tests for AgentSettlement and ReputationDecay

## Objective

Write comprehensive Forge tests for both contracts covering settle, batch settle, access control, decay math, and edge cases — all tests must pass with `forge test`.

## Requirements

- [ ] `test/AgentSettlement.t.sol` with tests for: single settle, batch settle, access control (non-owner reverts), zero-address revert, zero-amount revert, array-length-mismatch revert, `AgentPaid` event emission
- [ ] `test/ReputationDecay.t.sol` with tests for: update and immediate get (no decay), get after time warp (decay applied), get after full decay (returns 0), zero-address revert on update, initial score returns 0
- [ ] All tests pass with `forge test`
- [ ] Test error cases before happy paths (as per festival rules)

## Implementation

**Test file 1:** `projects/contracts/test/AgentSettlement.t.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/AgentSettlement.sol";

contract AgentSettlementTest is Test {
    AgentSettlement public settlement;
    address public owner;
    address public agent1;
    address public agent2;

    function setUp() public {
        owner = address(this);
        agent1 = makeAddr("agent1");
        agent2 = makeAddr("agent2");
        settlement = new AgentSettlement(owner);
        // Fund the contract for settlements
        vm.deal(address(settlement), 10 ether);
    }

    // --- Error cases ---

    function test_settle_revertsWhenNotOwner() public {
        address notOwner = makeAddr("notOwner");
        vm.prank(notOwner);
        vm.expectRevert();
        settlement.settle(agent1, 1 ether, bytes32("task1"));
    }

    function test_settle_revertsOnZeroAddress() public {
        vm.expectRevert(AgentSettlement.ZeroAddress.selector);
        settlement.settle(address(0), 1 ether, bytes32("task1"));
    }

    function test_settle_revertsOnZeroAmount() public {
        vm.expectRevert(AgentSettlement.ZeroAmount.selector);
        settlement.settle(agent1, 0, bytes32("task1"));
    }

    function test_batchSettle_revertsOnLengthMismatch() public {
        address[] memory agents = new address[](2);
        agents[0] = agent1;
        agents[1] = agent2;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1 ether;
        bytes32[] memory taskIds = new bytes32[](2);
        taskIds[0] = bytes32("task1");
        taskIds[1] = bytes32("task2");

        vm.expectRevert(AgentSettlement.ArrayLengthMismatch.selector);
        settlement.batchSettle(agents, amounts, taskIds);
    }

    // --- Happy paths ---

    function test_settle_sendsEthAndEmitsEvent() public {
        uint256 balanceBefore = agent1.balance;
        bytes32 taskId = bytes32("task-abc");

        vm.expectEmit(true, true, false, true);
        emit AgentSettlement.AgentPaid(agent1, 1 ether, taskId);

        settlement.settle(agent1, 1 ether, taskId);

        assertEq(agent1.balance - balanceBefore, 1 ether);
    }

    function test_batchSettle_paysAllAgentsAndEmitsEvents() public {
        address[] memory agents = new address[](2);
        agents[0] = agent1;
        agents[1] = agent2;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1 ether;
        amounts[1] = 0.5 ether;
        bytes32[] memory taskIds = new bytes32[](2);
        taskIds[0] = bytes32("task1");
        taskIds[1] = bytes32("task2");

        uint256 agent1Before = agent1.balance;
        uint256 agent2Before = agent2.balance;

        settlement.batchSettle(agents, amounts, taskIds);

        assertEq(agent1.balance - agent1Before, 1 ether);
        assertEq(agent2.balance - agent2Before, 0.5 ether);
    }
}
```

**Test file 2:** `projects/contracts/test/ReputationDecay.t.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/ReputationDecay.sol";

contract ReputationDecayTest is Test {
    ReputationDecay public reputation;
    address public agent;
    uint256 constant DECAY_RATE = 1; // 1 point per second

    function setUp() public {
        reputation = new ReputationDecay(DECAY_RATE);
        agent = makeAddr("agent");
    }

    // --- Error cases ---

    function test_updateReputation_revertsOnZeroAddress() public {
        vm.expectRevert(ReputationDecay.ZeroAddress.selector);
        reputation.updateReputation(address(0), 100);
    }

    function test_getReputation_returnsZeroForUnknownAgent() public view {
        address unknown = makeAddr("unknown");
        assertEq(reputation.getReputation(unknown), 0);
    }

    // --- Happy paths ---

    function test_getReputation_returnsFullScoreImmediately() public {
        reputation.updateReputation(agent, 100);
        assertEq(reputation.getReputation(agent), 100);
    }

    function test_getReputation_appliesDecayAfterTimeWarp() public {
        reputation.updateReputation(agent, 100);

        // Warp 30 seconds forward — score should decay by 30 * 1 = 30 points
        vm.warp(block.timestamp + 30);

        assertEq(reputation.getReputation(agent), 70);
    }

    function test_getReputation_clampsAtZero() public {
        reputation.updateReputation(agent, 50);

        // Warp far past full decay — should return 0, not underflow
        vm.warp(block.timestamp + 1000);

        assertEq(reputation.getReputation(agent), 0);
    }

    function test_updateReputation_resetsDecayTimer() public {
        reputation.updateReputation(agent, 100);
        vm.warp(block.timestamp + 50); // decayed to 50

        // Refresh score
        reputation.updateReputation(agent, 200);

        // Immediately after update — should be full 200
        assertEq(reputation.getReputation(agent), 200);

        // After 10 more seconds — should be 190
        vm.warp(block.timestamp + 10);
        assertEq(reputation.getReputation(agent), 190);
    }

    function test_updateReputation_emitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit ReputationDecay.ReputationUpdated(agent, 100);
        reputation.updateReputation(agent, 100);
    }
}
```

After writing both test files, run:

```bash
cd projects/contracts
forge test -vv
```

All tests should pass. If any fail, fix the contract or test logic before marking this task complete.

## Done When

- [ ] All requirements met
- [ ] `test/AgentSettlement.t.sol` and `test/ReputationDecay.t.sol` exist
- [ ] `forge test` exits 0 with all tests passing
