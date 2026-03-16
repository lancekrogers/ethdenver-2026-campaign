---
fest_type: task
fest_id: 04_deposit_redeem.md
fest_name: 04_deposit_redeem
fest_parent: 01_vault_contract
fest_order: 4
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-13T19:22:36.954842-06:00
fest_updated: 2026-03-15T19:31:11.40713-06:00
fest_tracking: true
---


# Task: ERC-4626 Deposit and Redeem

## Objective

Override ERC-4626 deposit/redeem with pause guards and implement totalAssets (initially USDC balance only, TWAP pricing added in Task 6).

## Dependencies

- **Task 05_guardian_controls** must be complete (provides guardian functions and the test file `ObeyVault.t.sol`).

## Prerequisites

- `projects/contracts/src/ObeyVault.sol` exists with guardian functions implemented.
- `projects/contracts/test/ObeyVault.t.sol` exists with guardian tests passing.
- All prior tasks compile and pass tests.

## Step-by-Step Instructions

### Step 1: Add deposit/redeem tests to the test file

Open `projects/contracts/test/ObeyVault.t.sol` and add the following 3 test functions **inside the `ObeyVaultTest` contract, after the existing guardian tests**:

```solidity
    // --- Deposit / Redeem Tests ---

    function test_depositAndReceiveShares() public {
        uint256 depositAmount = 1000e6;
        usdc.mint(user, depositAmount);

        vm.startPrank(user);
        usdc.approve(address(vault), depositAmount);
        uint256 shares = vault.deposit(depositAmount, user);
        vm.stopPrank();

        assertGt(shares, 0, "Should receive shares");
        assertEq(vault.balanceOf(user), shares, "Share balance mismatch");
        assertEq(usdc.balanceOf(address(vault)), depositAmount, "Vault should hold USDC");
    }

    function test_redeemReturnsAssets() public {
        uint256 depositAmount = 1000e6;
        usdc.mint(user, depositAmount);

        vm.startPrank(user);
        usdc.approve(address(vault), depositAmount);
        uint256 shares = vault.deposit(depositAmount, user);

        uint256 assets = vault.redeem(shares, user, user);
        vm.stopPrank();

        assertEq(assets, depositAmount, "Should get back full deposit");
        assertEq(usdc.balanceOf(user), depositAmount, "User USDC balance restored");
        assertEq(vault.balanceOf(user), 0, "Shares should be burned");
    }

    function test_depositWhenPausedReverts() public {
        vault.pause();

        uint256 depositAmount = 1000e6;
        usdc.mint(user, depositAmount);

        vm.startPrank(user);
        usdc.approve(address(vault), depositAmount);
        vm.expectRevert();  // Pausable: EnforcedPause
        vault.deposit(depositAmount, user);
        vm.stopPrank();
    }
```

### Step 2: Add ERC-4626 overrides to ObeyVault.sol

Open `projects/contracts/src/ObeyVault.sol` and add the following functions **inside the contract body** (after the guardian functions):

```solidity
    // --- ERC-4626 Overrides ---

    function totalAssets() public view override returns (uint256) {
        return IERC20(asset()).balanceOf(address(this));
    }

    function deposit(uint256 assets, address receiver)
        public
        override
        whenNotPaused
        returns (uint256)
    {
        return super.deposit(assets, receiver);
    }

    function redeem(uint256 shares, address receiver, address owner)
        public
        override
        whenNotPaused
        returns (uint256)
    {
        return super.redeem(shares, receiver, owner);
    }
```

### Step 3: Run all tests

```bash
cd projects/contracts && forge test --match-contract ObeyVaultTest -v
```

**Expected output:** All 9 tests pass (6 guardian + 3 deposit/redeem):

```
[PASS] test_guardianCanSetAgent()
[PASS] test_nonGuardianCannotSetAgent()
[PASS] test_guardianCanApproveToken()
[PASS] test_guardianCanPause()
[PASS] test_guardianCanSetMaxSwapSize()
[PASS] test_guardianCanSetMaxDailyVolume()
[PASS] test_depositAndReceiveShares()
[PASS] test_redeemReturnsAssets()
[PASS] test_depositWhenPausedReverts()

Test result: ok. 9 passed; 0 failed;
```

## Done When

- [ ] 3 new test functions added to `projects/contracts/test/ObeyVault.t.sol`
- [ ] `totalAssets()`, `deposit()`, and `redeem()` overrides added to `projects/contracts/src/ObeyVault.sol`
- [ ] `cd projects/contracts && forge test --match-contract ObeyVaultTest -v` passes all 9 tests