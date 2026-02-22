---
fest_type: task
fest_id: 05_deploy_script.md
fest_name: deploy script
fest_parent: 03_contracts_implementation
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:46.814724-07:00
fest_tracking: true
---

# Task: Write Deploy Script for Hedera Testnet EVM

## Objective

Write `script/Deploy.s.sol` — a Forge deploy script that deploys both `AgentSettlement` and `ReputationDecay` to the Hedera testnet EVM and prints the deployed addresses.

## Requirements

- [ ] `script/Deploy.s.sol` extends `Script` from forge-std
- [ ] Deploys `AgentSettlement` with `msg.sender` as initial owner
- [ ] Deploys `ReputationDecay` with a configurable decay rate (default: 1 point per second)
- [ ] Prints both deployed addresses via `console.log`
- [ ] Script compiles with `forge build`
- [ ] Instructions for running against Hedera testnet EVM documented in this task

## Implementation

Create the file at `projects/contracts/script/Deploy.s.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/AgentSettlement.sol";
import "../src/ReputationDecay.sol";

/// @title Deploy
/// @notice Deploys AgentSettlement and ReputationDecay to the target network.
contract Deploy is Script {
    /// @dev Default decay rate: 1 reputation point per second.
    uint256 constant DEFAULT_DECAY_RATE = 1;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        AgentSettlement settlement = new AgentSettlement(deployer);
        ReputationDecay reputation = new ReputationDecay(DEFAULT_DECAY_RATE);

        vm.stopBroadcast();

        console.log("=== Deployed Contracts ===");
        console.log("AgentSettlement:", address(settlement));
        console.log("ReputationDecay:", address(reputation));
        console.log("Deployer:       ", deployer);
    }
}
```

After writing the file, verify it compiles:

```bash
cd projects/contracts
forge build
```

**To run against Hedera testnet EVM:**

1. Export your deployer private key:
   ```bash
   export PRIVATE_KEY=0x<your-testnet-private-key>
   ```

2. Run the deploy script against Hedera testnet JSON-RPC:
   ```bash
   forge script script/Deploy.s.sol:Deploy \
     --rpc-url https://testnet.hashio.io/api \
     --broadcast \
     --legacy \
     -vvvv
   ```

   Note: Use `--legacy` because Hedera EVM does not support EIP-1559 transactions.

3. Record the output addresses — they are needed for the 002_REVIEW phase bounty checklist.

**To do a dry run without broadcasting:**

```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url https://testnet.hashio.io/api \
  --legacy \
  -vvvv
```

## Done When

- [ ] All requirements met
- [ ] `script/Deploy.s.sol` exists and compiles with `forge build`
- [ ] Dry run completes without errors against Hedera testnet EVM RPC
- [ ] Deployed contract addresses recorded for use in 002_REVIEW
