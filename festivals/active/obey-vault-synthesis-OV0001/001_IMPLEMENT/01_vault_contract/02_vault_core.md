---
fest_type: task
fest_id: 02_vault_core.md
fest_name: 02_vault_core
fest_parent: 01_vault_contract
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-13T19:22:35.125438-06:00
fest_updated: 2026-03-15T19:29:50.159747-06:00
fest_tracking: true
---


# Task: ObeyVault Core Storage and Constructor

## Objective

Create the ObeyVault.sol contract skeleton with storage layout, constructor, roles (guardian/agent), modifiers, events, and custom errors.

## Dependencies

- **Task 07_uniswap_interfaces** must be complete (provides `ISwapRouter02.sol` and `IOracleLibrary.sol` in `projects/contracts/src/interfaces/`).

## Prerequisites

- Foundry installed.
- OpenZeppelin contracts installed in `projects/contracts/lib/openzeppelin-contracts/`.
- Interface files from Task 07 exist at:
  - `projects/contracts/src/interfaces/ISwapRouter02.sol`
  - `projects/contracts/src/interfaces/IOracleLibrary.sol`

## Step-by-Step Instructions

### Step 1: Install Uniswap V3 Foundry dependencies

```bash
cd projects/contracts
forge install uniswap/v3-core --no-commit
forge install uniswap/v3-periphery --no-commit
```

### Step 2: Add Uniswap remappings

Open (or create) `projects/contracts/remappings.txt` and **append** these two lines (do not remove existing remappings):

```
@uniswap/v3-core/=lib/v3-core/
@uniswap/v3-periphery/=lib/v3-periphery/
```

Verify the file contains both lines:

```bash
cat projects/contracts/remappings.txt
```

### Step 3: Create `projects/contracts/src/ObeyVault.sol`

Create the file at `projects/contracts/src/ObeyVault.sol` with the following exact content:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {ISwapRouter02} from "./interfaces/ISwapRouter02.sol";
import {IUniswapV3Factory, IUniswapV3Pool} from "./interfaces/IOracleLibrary.sol";

contract ObeyVault is ERC4626, Pausable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    // --- Roles ---
    address public guardian;
    address public agent;

    // --- Spending Boundaries ---
    mapping(address => bool) public approvedTokens;
    uint256 public maxSwapSize;
    uint256 public maxDailyVolume;
    uint256 public maxSlippageBps;

    // --- Daily Volume Tracking ---
    uint256 public dailyVolumeUsed;
    uint256 public currentDay;

    // --- Token Tracking ---
    EnumerableSet.AddressSet private _heldTokens;

    // --- Uniswap ---
    ISwapRouter02 public immutable swapRouter;
    address public immutable uniswapFactory;

    // --- Events ---
    event SwapExecuted(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        bytes reason
    );
    event AgentUpdated(address indexed oldAgent, address indexed newAgent);
    event TokenApprovalUpdated(address indexed token, bool approved);
    event MaxSwapSizeUpdated(uint256 newMax);
    event MaxDailyVolumeUpdated(uint256 newMax);

    // --- Errors ---
    error OnlyGuardian();
    error OnlyAgent();
    error SameToken();
    error TokenNotApproved(address token);
    error SwapExceedsMaxSize(uint256 amount, uint256 max);
    error DailyVolumeExceeded(uint256 used, uint256 max);
    error SlippageTooHigh(uint256 requested, uint256 max);

    modifier onlyGuardian() {
        if (msg.sender != guardian) revert OnlyGuardian();
        _;
    }

    modifier onlyAgent() {
        if (msg.sender != agent) revert OnlyAgent();
        _;
    }

    constructor(
        IERC20 asset_,
        address agent_,
        address swapRouter_,
        address uniswapFactory_,
        uint256 maxSwapSize_,
        uint256 maxDailyVolume_,
        uint256 maxSlippageBps_
    )
        ERC4626(asset_)
        ERC20("OBEY Vault Share", "oVAULT")
    {
        guardian = msg.sender;
        agent = agent_;
        swapRouter = ISwapRouter02(swapRouter_);
        uniswapFactory = uniswapFactory_;
        maxSwapSize = maxSwapSize_;
        maxDailyVolume = maxDailyVolume_;
        maxSlippageBps = maxSlippageBps_;
        currentDay = block.timestamp / 1 days;

        // USDC (the base asset) is always approved
        approvedTokens[address(asset_)] = true;
    }
}
```

### Step 4: Verify compilation

```bash
cd projects/contracts && forge build
```

**Expected output:** Compilation succeeds with no errors. Output should include:

```
[⠊] Compiling...
Compiler run successful!
```

If compilation fails, check:
1. Remappings are correct in `remappings.txt`.
2. OpenZeppelin version is v5.x (check with `cat lib/openzeppelin-contracts/package.json | grep version`).
3. Interface files from Task 07 exist in `src/interfaces/`.

## Done When

- [ ] Uniswap V3 dependencies installed in `projects/contracts/lib/v3-core/` and `projects/contracts/lib/v3-periphery/`
- [ ] `projects/contracts/remappings.txt` contains the two Uniswap remapping lines
- [ ] `projects/contracts/src/ObeyVault.sol` exists with the exact code above
- [ ] `cd projects/contracts && forge build` compiles with zero errors