---
fest_type: task
fest_id: 07_deploy_script.md
fest_name: 07_deploy_script
fest_parent: 01_vault_contract
fest_order: 7
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-13T19:22:39.606408-06:00
fest_updated: 2026-03-15T19:33:48.492845-06:00
fest_tracking: true
---


# Task: Foundry Deploy Script

## Objective

Create a Foundry deployment script that deploys ObeyVault to both Base Sepolia testnet and Base mainnet, with correct USDC, SwapRouter, and Factory addresses for each network.

## Dependencies

- **All prior vault tasks** (07, 06, 05, 04, 03, 02) must be complete. The full ObeyVault contract must compile successfully.

## Prerequisites

- `projects/contracts/src/ObeyVault.sol` is fully implemented and all 15 tests pass.
- `projects/contracts/script/` directory exists (create it if not).

## Step-by-Step Instructions

### Step 1: Create the script directory (if needed)

```bash
mkdir -p projects/contracts/script
```

### Step 2: Create `projects/contracts/script/DeployVault.s.sol`

Create the file at `projects/contracts/script/DeployVault.s.sol` with the following exact content:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {ObeyVault} from "../src/ObeyVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployVault is Script {
    // --- Base Sepolia Addresses ---
    address constant SEPOLIA_USDC = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;
    address constant SEPOLIA_SWAP_ROUTER = 0x2626664c2603336E57B271c5C0b26F421741e481;
    address constant SEPOLIA_FACTORY = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;

    // --- Base Mainnet Addresses ---
    address constant MAINNET_USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address constant MAINNET_SWAP_ROUTER = 0x2626664c2603336E57B271c5C0b26F421741e481;
    address constant MAINNET_FACTORY = 0x33128a8fC17869897dcE68Ed026d694621f6FDfD;

    // --- WETH on Base (same for both networks) ---
    address constant WETH = 0x4200000000000000000000000000000000000006;

    // --- Default Parameters ---
    uint256 constant MAX_SWAP_SIZE = 1000e6;      // 1,000 USDC
    uint256 constant MAX_DAILY_VOLUME = 10000e6;   // 10,000 USDC
    uint256 constant MAX_SLIPPAGE_BPS = 100;       // 1%

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address agentAddress = vm.envAddress("AGENT_ADDRESS");
        bool isMainnet = vm.envOr("MAINNET", false);

        address usdc;
        address swapRouter;
        address factory;

        if (isMainnet) {
            usdc = MAINNET_USDC;
            swapRouter = MAINNET_SWAP_ROUTER;
            factory = MAINNET_FACTORY;
            console2.log("Deploying to BASE MAINNET");
        } else {
            usdc = SEPOLIA_USDC;
            swapRouter = SEPOLIA_SWAP_ROUTER;
            factory = SEPOLIA_FACTORY;
            console2.log("Deploying to BASE SEPOLIA");
        }

        console2.log("Agent:", agentAddress);
        console2.log("USDC:", usdc);
        console2.log("SwapRouter:", swapRouter);
        console2.log("Factory:", factory);

        vm.startBroadcast(deployerPrivateKey);

        ObeyVault vault = new ObeyVault(
            IERC20(usdc),
            agentAddress,
            swapRouter,
            factory,
            MAX_SWAP_SIZE,
            MAX_DAILY_VOLUME,
            MAX_SLIPPAGE_BPS
        );

        // Auto-approve WETH
        vault.setApprovedToken(WETH, true);

        vm.stopBroadcast();

        console2.log("ObeyVault deployed at:", address(vault));
        console2.log("Guardian (deployer):", vault.guardian());
        console2.log("Agent:", vault.agent());
        console2.log("WETH approved:", vault.approvedTokens(WETH));
    }
}
```

### Step 3: Verify compilation

```bash
cd projects/contracts && forge build
```

**Expected output:** Compilation succeeds with no errors:

```
[⠊] Compiling...
Compiler run successful!
```

### Deployment Commands (for reference, do NOT run during this task)

**Base Sepolia (testnet):**
```bash
cd projects/contracts
DEPLOYER_PRIVATE_KEY=0x... AGENT_ADDRESS=0x... \
  forge script script/DeployVault.s.sol:DeployVault \
  --rpc-url https://sepolia.base.org \
  --broadcast --verify
```

**Base Mainnet:**
```bash
cd projects/contracts
DEPLOYER_PRIVATE_KEY=0x... AGENT_ADDRESS=0x... MAINNET=true \
  forge script script/DeployVault.s.sol:DeployVault \
  --rpc-url https://mainnet.base.org \
  --broadcast --verify
```

## Done When

- [ ] `projects/contracts/script/DeployVault.s.sol` exists with the exact code above
- [ ] All network addresses are correct (Base Sepolia and Base Mainnet)
- [ ] WETH auto-approval is included in the deploy script
- [ ] `cd projects/contracts && forge build` compiles with zero errors