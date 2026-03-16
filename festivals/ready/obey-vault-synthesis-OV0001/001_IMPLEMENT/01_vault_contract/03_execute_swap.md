---
fest_type: task
fest_id: 01_execute_swap.md
fest_name: 05_execute_swap
fest_parent: 01_vault_contract
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:22:37.862129-06:00
fest_tracking: true
---

# Task: executeSwap with Boundary Enforcement

## Objective

Implement the executeSwap function that enforces all spending boundaries (token whitelist, max swap size, daily volume cap, slippage limit) before executing via Uniswap V3 SwapRouter02.

## Dependencies

- **Task 04_deposit_redeem** must be complete (provides deposit/redeem overrides and totalAssets).

## Prerequisites

- `projects/contracts/src/ObeyVault.sol` has guardian functions and ERC-4626 overrides.
- `projects/contracts/test/ObeyVault.t.sol` has 9 passing tests.
- All prior tasks compile and pass.

## Step-by-Step Instructions

### Step 1: Add 5 swap boundary tests to the test file

Open `projects/contracts/test/ObeyVault.t.sol` and add the following 5 test functions **inside the `ObeyVaultTest` contract, after the deposit/redeem tests**:

```solidity
    // --- Swap Boundary Tests ---

    function test_executeSwap_onlyAgent() public {
        vm.prank(user);
        vm.expectRevert(ObeyVault.OnlyAgent.selector);
        vault.executeSwap(
            address(usdc),
            randomToken,
            100e6,
            90e6,
            bytes("test")
        );
    }

    function test_executeSwap_unapprovedTokenReverts() public {
        vm.prank(agentAddr);
        vm.expectRevert(
            abi.encodeWithSelector(ObeyVault.TokenNotApproved.selector, randomToken)
        );
        vault.executeSwap(
            address(usdc),
            randomToken,
            100e6,
            90e6,
            bytes("test")
        );
    }

    function test_executeSwap_exceedsMaxSizeReverts() public {
        // Approve the token first
        vault.setApprovedToken(randomToken, true);

        vm.prank(agentAddr);
        vm.expectRevert(
            abi.encodeWithSelector(
                ObeyVault.SwapExceedsMaxSize.selector,
                2000e6,
                1000e6
            )
        );
        vault.executeSwap(
            address(usdc),
            randomToken,
            2000e6,  // exceeds maxSwapSize of 1000e6
            1800e6,
            bytes("too big")
        );
    }

    function test_executeSwap_dailyVolumeCapEnforced() public {
        vault.setApprovedToken(randomToken, true);

        // Use up most of daily volume with repeated swaps at max size
        // maxDailyVolume = 10000e6, maxSwapSize = 1000e6
        // After 10 swaps of 1000e6, volume is exhausted
        // We can't actually execute swaps (no router), but the volume check
        // happens before the router call, so we test the revert.
        // First, set maxSwapSize high enough, then do a swap that exceeds daily volume.
        vault.setMaxSwapSize(15000e6);

        vm.prank(agentAddr);
        vm.expectRevert(
            abi.encodeWithSelector(
                ObeyVault.DailyVolumeExceeded.selector,
                11000e6,
                10000e6
            )
        );
        vault.executeSwap(
            address(usdc),
            randomToken,
            11000e6,  // exceeds maxDailyVolume of 10000e6
            10000e6,
            bytes("over daily limit")
        );
    }

    function test_executeSwap_whenPausedReverts() public {
        vault.setApprovedToken(randomToken, true);
        vault.pause();

        vm.prank(agentAddr);
        vm.expectRevert();  // Pausable: EnforcedPause
        vault.executeSwap(
            address(usdc),
            randomToken,
            100e6,
            90e6,
            bytes("paused")
        );
    }
```

### Step 2: Implement executeSwap in ObeyVault.sol

Open `projects/contracts/src/ObeyVault.sol` and add the following function **inside the contract body** (after the ERC-4626 overrides):

```solidity
    // --- Swap Execution ---

    function executeSwap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMinimum,
        bytes calldata reason
    ) external onlyAgent whenNotPaused returns (uint256 amountOut) {
        // --- Boundary Checks ---
        if (tokenIn == tokenOut) revert SameToken();
        if (!approvedTokens[tokenOut]) revert TokenNotApproved(tokenOut);

        if (amountIn > maxSwapSize) {
            revert SwapExceedsMaxSize(amountIn, maxSwapSize);
        }

        // Reset daily volume if new day
        uint256 today = block.timestamp / 1 days;
        if (today != currentDay) {
            currentDay = today;
            dailyVolumeUsed = 0;
        }

        uint256 newVolume = dailyVolumeUsed + amountIn;
        if (newVolume > maxDailyVolume) {
            revert DailyVolumeExceeded(newVolume, maxDailyVolume);
        }
        dailyVolumeUsed = newVolume;

        // --- Slippage Check ---
        // amountOutMinimum must be within maxSlippageBps of amountIn
        // (simplified: for same-decimal tokens; production should use oracle price)
        uint256 minAcceptable = amountIn * (10000 - maxSlippageBps) / 10000;
        if (amountOutMinimum < minAcceptable) {
            revert SlippageTooHigh(amountOutMinimum, minAcceptable);
        }

        // --- Execute Swap ---
        IERC20(tokenIn).safeApprove(address(swapRouter), amountIn);

        amountOut = swapRouter.exactInputSingle(
            ISwapRouter02.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: 3000, // 0.3% fee tier
                recipient: address(this),
                amountIn: amountIn,
                amountOutMinimum: amountOutMinimum,
                sqrtPriceLimitX96: 0
            })
        );

        // --- Track Held Tokens ---
        if (tokenOut != asset()) {
            _heldTokens.add(tokenOut);
        }
        // If we swapped all of tokenIn and it's not the base asset, remove it
        if (tokenIn != asset() && IERC20(tokenIn).balanceOf(address(this)) == 0) {
            _heldTokens.remove(tokenIn);
        }

        emit SwapExecuted(tokenIn, tokenOut, amountIn, amountOut, reason);
    }
```

**Important notes:**
- The `reason` parameter is `bytes calldata`, not `string`.
- `safeApprove` is used for the router allowance. If your OpenZeppelin version does not have `safeApprove`, use `forceApprove` instead (v5.x uses `forceApprove`). Check your version and adjust:
  - **v5.x**: Replace `safeApprove` with `forceApprove`
  - **v4.x**: `safeApprove` works but requires allowance to be 0 first

### Step 3: Run tests

```bash
cd projects/contracts && forge test --match-contract ObeyVaultTest -v
```

**Expected output:** All 14 tests pass (6 guardian + 3 deposit/redeem + 5 swap boundary). The boundary revert tests pass because the reverts happen **before** the router call:

```
[PASS] test_executeSwap_onlyAgent()
[PASS] test_executeSwap_unapprovedTokenReverts()
[PASS] test_executeSwap_exceedsMaxSizeReverts()
[PASS] test_executeSwap_dailyVolumeCapEnforced()
[PASS] test_executeSwap_whenPausedReverts()

Test result: ok. 14 passed; 0 failed;
```

## Done When

- [ ] 5 swap boundary tests added to `projects/contracts/test/ObeyVault.t.sol`
- [ ] `executeSwap` function added to `projects/contracts/src/ObeyVault.sol`
- [ ] `cd projects/contracts && forge test --match-contract ObeyVaultTest -v` passes all 14 tests
