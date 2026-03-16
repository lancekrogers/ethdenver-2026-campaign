---
fest_type: task
fest_id: 06_nav_twap.md
fest_name: 06_nav_twap
fest_parent: 01_vault_contract
fest_order: 6
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-13T19:22:38.69806-06:00
fest_updated: 2026-03-15T19:33:28.278547-06:00
fest_tracking: true
---


# Task: NAV Calculation via Uniswap V3 TWAP

## Objective

Upgrade totalAssets() to mark-to-market all held tokens using Uniswap V3 TWAP oracle prices with a 30-minute window.

## Dependencies

- **Task 03_execute_swap** must be complete (provides executeSwap and held token tracking via `_heldTokens`).

## Prerequisites

- `projects/contracts/src/ObeyVault.sol` has executeSwap with `_heldTokens` tracking.
- Uniswap V3 core library installed at `projects/contracts/lib/v3-core/` (from Task 06).
- Remappings include `@uniswap/v3-core/=lib/v3-core/`.

## Step-by-Step Instructions

### Step 1: Add TickMath and FullMath imports to ObeyVault.sol

Open `projects/contracts/src/ObeyVault.sol` and add these two imports **after the existing import statements** (e.g., after the `IOracleLibrary.sol` import):

```solidity
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v3-core/contracts/libraries/FullMath.sol";
```

### Step 2: Add the TWAP constant

Add this constant **inside the contract body**, near the top with the other state variables (e.g., after the `address public immutable uniswapFactory;` line):

```solidity
    // --- TWAP ---
    uint32 public constant TWAP_PERIOD = 1800; // 30 minutes
```

### Step 3: Add heldTokenCount() and heldTokenAt() view functions

Add these **inside the contract body** (after the guardian functions or ERC-4626 overrides):

```solidity
    // --- Token View Helpers ---

    function heldTokenCount() external view returns (uint256) {
        return _heldTokens.length();
    }

    function heldTokenAt(uint256 index) external view returns (address) {
        return _heldTokens.at(index);
    }
```

### Step 4: Replace the totalAssets() function

Find the existing `totalAssets()` function in `projects/contracts/src/ObeyVault.sol` and **replace it entirely** with:

```solidity
    function totalAssets() public view override returns (uint256) {
        uint256 total = IERC20(asset()).balanceOf(address(this));

        uint256 len = _heldTokens.length();
        for (uint256 i = 0; i < len; i++) {
            address token = _heldTokens.at(i);
            uint256 balance = IERC20(token).balanceOf(address(this));
            if (balance == 0) continue;

            uint256 price = _getTWAPPrice(token);
            if (price > 0) {
                total += FullMath.mulDiv(balance, price, 1e18);
            }
        }

        return total;
    }
```

### Step 5: Add the _getTWAPPrice() internal function

Add this **inside the contract body** (after the executeSwap function or after the totalAssets override):

```solidity
    // --- TWAP Oracle ---

    function _getTWAPPrice(address token) internal view returns (uint256 price) {
        address pool = IUniswapV3Factory(uniswapFactory).getPool(
            token, asset(), 3000
        );
        if (pool == address(0)) return 0;

        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = TWAP_PERIOD;
        secondsAgos[1] = 0;

        try IUniswapV3Pool(pool).observe(secondsAgos) returns (
            int56[] memory tickCumulatives,
            uint160[] memory
        ) {
            int56 tickDelta = tickCumulatives[1] - tickCumulatives[0];
            int24 averageTick = int24(tickDelta / int56(int32(TWAP_PERIOD)));

            uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(averageTick);

            // price = (sqrtPriceX96)^2 * 1e18 / 2^192
            // Use FullMath to avoid overflow
            price = FullMath.mulDiv(
                uint256(sqrtPriceX96) * uint256(sqrtPriceX96),
                1e18,
                1 << 192
            );

            // If token is token1 in the pool, price is inverted
            if (IUniswapV3Pool(pool).token0() == asset()) {
                if (price > 0) {
                    price = FullMath.mulDiv(1e18, 1e18, price);
                }
            }
        } catch {
            return 0;
        }
    }
```

### Step 6: Add test for held tokens tracking

Open `projects/contracts/test/ObeyVault.t.sol` and add this test **inside the `ObeyVaultTest` contract**:

```solidity
    // --- TWAP / Held Token Tests ---

    function test_heldTokensTracking() public {
        // Initially no held tokens
        assertEq(vault.heldTokenCount(), 0);

        // totalAssets should return just USDC balance (no held tokens)
        uint256 depositAmount = 1000e6;
        usdc.mint(user, depositAmount);

        vm.startPrank(user);
        usdc.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, user);
        vm.stopPrank();

        assertEq(vault.totalAssets(), depositAmount);
        assertEq(vault.heldTokenCount(), 0);
    }
```

### Step 7: Run tests

```bash
cd projects/contracts && forge test --match-contract ObeyVaultTest -v
```

**Expected output:** All 15 tests pass (6 guardian + 3 deposit/redeem + 5 swap boundary + 1 held tokens). The TWAP functions are present but return 0 for mock/nonexistent pools, so `totalAssets()` gracefully falls back to just the USDC balance:

```
[PASS] test_heldTokensTracking()

Test result: ok. 15 passed; 0 failed;
```

## Done When

- [ ] TickMath and FullMath imports added to `projects/contracts/src/ObeyVault.sol`
- [ ] `TWAP_PERIOD` constant added
- [ ] `heldTokenCount()` and `heldTokenAt()` view functions added
- [ ] `totalAssets()` updated to include TWAP-priced held tokens
- [ ] `_getTWAPPrice()` internal function added
- [ ] `test_heldTokensTracking` test added to `projects/contracts/test/ObeyVault.t.sol`
- [ ] `cd projects/contracts && forge test --match-contract ObeyVaultTest -v` passes all 15 tests