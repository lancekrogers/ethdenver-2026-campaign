---
fest_type: task
fest_id: 01_guardian_controls.md
fest_name: 03_guardian_controls
fest_parent: 01_vault_contract
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:22:36.008538-06:00
fest_tracking: true
---

# Task: Guardian Controls

## Objective

Implement guardian-only functions for managing agent assignment, token whitelist, swap limits, and pause/unpause, with full Foundry test coverage.

## Dependencies

- **Task 06_vault_core** must be complete (provides the ObeyVault.sol skeleton with storage, constructor, modifiers, events, and errors).

## Prerequisites

- `projects/contracts/src/ObeyVault.sol` exists and compiles (from Task 06).
- OpenZeppelin contracts installed. Determine the mock path:
  ```bash
  cd projects/contracts
  cat lib/openzeppelin-contracts/package.json | grep version
  ```
  - **v5.x**: Use `@openzeppelin/contracts/mocks/token/ERC20Mock.sol`
  - **v4.x**: Use `@openzeppelin/contracts/mocks/ERC20Mock.sol`

The instructions below assume **OpenZeppelin v5.x**. If you have v4.x, adjust the import path for ERC20Mock accordingly.

## Step-by-Step Instructions

### Step 1: Write tests first (TDD)

Create the file `projects/contracts/test/ObeyVault.t.sol` with the following exact content:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {ObeyVault} from "../src/ObeyVault.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ObeyVaultTest is Test {
    ObeyVault public vault;
    ERC20Mock public usdc;

    address guardian = address(this);  // test contract is deployer = guardian
    address agentAddr = address(0xA1);
    address user = address(0xB1);
    address randomToken = address(0xC1);

    // Dummy Uniswap addresses (not called in these tests)
    address swapRouter = address(0xD1);
    address uniFactory = address(0xE1);

    function setUp() public {
        usdc = new ERC20Mock();
        vault = new ObeyVault(
            IERC20(address(usdc)),
            agentAddr,
            swapRouter,
            uniFactory,
            1000e6,   // maxSwapSize: 1000 USDC
            10000e6,  // maxDailyVolume: 10,000 USDC
            100        // maxSlippageBps: 1%
        );
    }

    // --- Guardian Tests ---

    function test_guardianCanSetAgent() public {
        address newAgent = address(0xA2);
        vault.setAgent(newAgent);
        assertEq(vault.agent(), newAgent);
    }

    function test_nonGuardianCannotSetAgent() public {
        vm.prank(user);
        vm.expectRevert(ObeyVault.OnlyGuardian.selector);
        vault.setAgent(address(0xA2));
    }

    function test_guardianCanApproveToken() public {
        vault.setApprovedToken(randomToken, true);
        assertTrue(vault.approvedTokens(randomToken));

        vault.setApprovedToken(randomToken, false);
        assertFalse(vault.approvedTokens(randomToken));
    }

    function test_guardianCanPause() public {
        vault.pause();
        assertTrue(vault.paused());

        vault.unpause();
        assertFalse(vault.paused());
    }

    function test_guardianCanSetMaxSwapSize() public {
        vault.setMaxSwapSize(5000e6);
        assertEq(vault.maxSwapSize(), 5000e6);
    }

    function test_guardianCanSetMaxDailyVolume() public {
        vault.setMaxDailyVolume(50000e6);
        assertEq(vault.maxDailyVolume(), 50000e6);
    }
}
```

### Step 2: Run tests — expect FAILURE

```bash
cd projects/contracts && forge test --match-contract ObeyVaultTest -v
```

**Expected output:** Compilation fails because `setAgent`, `setApprovedToken`, `setMaxSwapSize`, `setMaxDailyVolume`, `pause`, and `unpause` do not yet exist on ObeyVault. This confirms the tests are wired correctly and will validate the implementation.

### Step 3: Add guardian functions to ObeyVault.sol

Open `projects/contracts/src/ObeyVault.sol` and add the following functions **inside the contract body, after the constructor's closing brace**:

```solidity
    // --- Guardian Functions ---

    function setAgent(address newAgent) external onlyGuardian {
        emit AgentUpdated(agent, newAgent);
        agent = newAgent;
    }

    function setApprovedToken(address token, bool approved) external onlyGuardian {
        approvedTokens[token] = approved;
        emit TokenApprovalUpdated(token, approved);
    }

    function setMaxSwapSize(uint256 newMax) external onlyGuardian {
        maxSwapSize = newMax;
        emit MaxSwapSizeUpdated(newMax);
    }

    function setMaxDailyVolume(uint256 newMax) external onlyGuardian {
        maxDailyVolume = newMax;
        emit MaxDailyVolumeUpdated(newMax);
    }

    function pause() external onlyGuardian {
        _pause();
    }

    function unpause() external onlyGuardian {
        _unpause();
    }
```

### Step 4: Run tests — expect ALL PASS

```bash
cd projects/contracts && forge test --match-contract ObeyVaultTest -v
```

**Expected output:** All 6 tests pass:

```
[PASS] test_guardianCanSetAgent()
[PASS] test_nonGuardianCannotSetAgent()
[PASS] test_guardianCanApproveToken()
[PASS] test_guardianCanPause()
[PASS] test_guardianCanSetMaxSwapSize()
[PASS] test_guardianCanSetMaxDailyVolume()

Test result: ok. 6 passed; 0 failed;
```

## Done When

- [ ] `projects/contracts/test/ObeyVault.t.sol` exists with all 6 tests above
- [ ] Guardian functions added to `projects/contracts/src/ObeyVault.sol`
- [ ] `cd projects/contracts && forge test --match-contract ObeyVaultTest -v` passes all 6 tests
