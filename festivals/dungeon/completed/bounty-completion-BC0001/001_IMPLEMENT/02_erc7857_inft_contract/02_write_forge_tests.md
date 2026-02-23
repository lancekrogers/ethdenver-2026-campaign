---
fest_type: task
fest_id: 02_write_forge_tests.md
fest_name: write forge tests
fest_parent: 02_erc7857_inft_contract
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.760607-07:00
fest_updated: 2026-02-23T13:42:27.027736-07:00
fest_tracking: true
---


# Task: Write Forge Tests for AgentINFT

## Objective

Write comprehensive Forge tests for the ERC-7857 AgentINFT contract covering mint, metadata update, ownership, and access control.

## Requirements

- [ ] Test file at `projects/contracts/test/AgentINFT.t.sol` with at least 8 test functions
- [ ] Tests cover: successful mint, mint emits Transfer event, metadata update by owner, metadata update rejected for non-owner, getTokenData returns correct data, sequential token IDs, ownership transfer, and update after transfer

## Implementation

### Step 1: Create the test file

Create `projects/contracts/test/AgentINFT.t.sol` following the same patterns as the existing `AgentSettlement.t.sol` and `ReputationDecay.t.sol` tests.

### Step 2: Write these specific tests

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {AgentINFT} from "../src/AgentINFT.sol";

contract AgentINFTTest is Test {
    AgentINFT public nft;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    bytes public sampleEncrypted = hex"deadbeef";
    bytes32 public sampleHash = keccak256(sampleEncrypted);

    function setUp() public { nft = new AgentINFT(); }

    function test_mint() public { ... }
    function test_mint_emitsTransfer() public { ... }
    function test_mint_sequentialIds() public { ... }
    function test_updateMetadata_byOwner() public { ... }
    function test_updateMetadata_revertsNonOwner() public { ... }
    function test_getTokenData() public { ... }
    function test_updateMetadata_afterTransfer() public { ... }
    function test_getTokenData_revertsNonexistent() public { ... }
}
```

Key patterns to follow:

- Use `vm.prank(alice)` to simulate calls from specific addresses
- Use `vm.expectEmit(true, true, false, false)` for Transfer event verification
- Use `vm.expectRevert()` for access control tests

### Step 3: Run tests

```bash
cd projects/contracts && forge test --match-contract AgentINFT -vvv
```

## Done When

- [ ] All requirements met
- [ ] `forge test` passes with all AgentINFT tests green and no regressions in existing Settlement/Reputation tests