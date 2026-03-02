---
fest_type: task
fest_id: 01_deploy_trivial_contract.md
fest_name: deploy trivial contract
fest_parent: 02_evm_validation
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:43:09.698131-07:00
fest_tracking: true
---

# Task: deploy trivial contract

## Objective

Deploy a minimal 1-function Solidity contract to a CRE-supported EVM testnet via Foundry to validate the deployment pipeline.

## Requirements

- [ ] A trivial Solidity contract with a single write function is written (Req 0.5)
- [ ] Contract compiles with `forge build`
- [ ] Contract is deployed to a CRE-supported EVM testnet
- [ ] Deployment is verified on a block explorer
- [ ] Contract address is captured

## Implementation

1. **Create a temporary Foundry project**:

   ```bash
   mkdir -p /tmp/cre-trivial-contract && cd /tmp/cre-trivial-contract
   forge init --no-git
   ```

2. **Write a trivial contract** at `src/Trivial.sol`:

   ```solidity
   // SPDX-License-Identifier: MIT
   pragma solidity ^0.8.19;

   contract Trivial {
       uint256 public value;

       event ValueSet(uint256 newValue, address setter);

       function setValue(uint256 _value) external {
           value = _value;
           emit ValueSet(_value, msg.sender);
       }
   }
   ```

3. **Compile**:

   ```bash
   forge build
   ```

4. **Determine the CRE-supported testnet**:
   - Check CRE documentation for supported EVM testnets
   - Common candidates: Sepolia, Arbitrum Sepolia, Base Sepolia, Avalanche Fuji
   - The testnet must support `cre workflow simulate . --broadcast`

5. **Fund a deployer wallet** on the chosen testnet:
   - Use the appropriate faucet for the testnet
   - Document the faucet URL and any requirements

6. **Deploy the contract**:

   ```bash
   forge create src/Trivial.sol:Trivial \
     --rpc-url $TESTNET_RPC \
     --private-key $DEPLOYER_KEY
   ```

7. **Capture the contract address** from deployment output.

8. **Verify on block explorer**:
   - Navigate to the testnet's block explorer
   - Confirm the contract exists at the deployed address
   - Document the block explorer URL and contract address

## Done When

- [ ] All requirements met
- [ ] Contract is deployed and verified on block explorer
- [ ] Contract address is documented
- [ ] Testnet name and RPC URL are documented
