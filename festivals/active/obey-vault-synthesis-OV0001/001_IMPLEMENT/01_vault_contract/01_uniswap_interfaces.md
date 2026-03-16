---
fest_type: task
fest_id: 01_uniswap_interfaces.md
fest_name: 01_uniswap_interfaces
fest_parent: 01_vault_contract
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-13T19:22:34.295908-06:00
fest_updated: 2026-03-15T19:29:06.68687-06:00
fest_tracking: true
---


# Task: Create Uniswap V3 Interfaces

## Objective

Create ISwapRouter02.sol and IOracleLibrary.sol interfaces that the ObeyVault contract will use for swap execution and TWAP price reads.

## Dependencies

- **None** — this is the first task in the sequence.

## Prerequisites

- Foundry must be installed (`forge --version` should return a version string).
- The `projects/contracts/` directory must exist with a valid `foundry.toml`.
- OpenZeppelin contracts must already be installed in `projects/contracts/lib/openzeppelin-contracts/`.

## Step-by-Step Instructions

### Step 1: Create the interfaces directory

```bash
mkdir -p projects/contracts/src/interfaces
```

### Step 2: Create `projects/contracts/src/interfaces/ISwapRouter02.sol`

Create the file at the exact path `projects/contracts/src/interfaces/ISwapRouter02.sol` with the following content:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISwapRouter02 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);
}
```

### Step 3: Create `projects/contracts/src/interfaces/IOracleLibrary.sol`

Create the file at the exact path `projects/contracts/src/interfaces/IOracleLibrary.sol` with the following content:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUniswapV3Factory {
    function getPool(address tokenA, address tokenB, uint24 fee)
        external view returns (address pool);
}

interface IUniswapV3Pool {
    function observe(uint32[] calldata secondsAgos)
        external view returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    function token0() external view returns (address);
    function token1() external view returns (address);
}
```

### Step 4: Verify compilation

Run from the repository root:

```bash
cd projects/contracts && forge build
```

**Expected output:** Compilation succeeds with zero errors. You should see output like:

```
[⠊] Compiling...
[⠒] Compiling 2 files with ...
Compiler run successful!
```

If compilation fails, check:
1. The `pragma solidity ^0.8.20;` matches the version configured in `foundry.toml`.
2. The file paths are exactly as specified above.

## Done When

- [ ] File `projects/contracts/src/interfaces/ISwapRouter02.sol` exists with the exact code above
- [ ] File `projects/contracts/src/interfaces/IOracleLibrary.sol` exists with the exact code above
- [ ] `cd projects/contracts && forge build` compiles with zero errors