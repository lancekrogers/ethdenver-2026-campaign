---
fest_type: task
fest_id: 02_implement_settlement.md
fest_name: implement settlement
fest_parent: 03_contracts_implementation
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:46.813896-07:00
fest_tracking: true
---

# Task: Implement AgentSettlement.sol

## Objective

Write `AgentSettlement.sol` in `projects/contracts/src/` — an Ownable contract that lets the owner settle payments to agents, supports batch settlement, and emits an `AgentPaid` event for every settlement.

## Requirements

- [ ] Contract inherits from OpenZeppelin `Ownable`
- [ ] `settle(address agent, uint256 amount, bytes32 taskId)` — pays one agent, emits `AgentPaid`
- [ ] `batchSettle(address[] agents, uint256[] amounts, bytes32[] taskIds)` — pays multiple agents in one tx, emits `AgentPaid` for each
- [ ] `AgentPaid(address indexed agent, uint256 amount, bytes32 indexed taskId)` event defined
- [ ] `onlyOwner` modifier on both settle functions
- [ ] Custom errors for invalid inputs (zero address, array length mismatch, zero amount)
- [ ] `forge build` exits 0 after writing the file

## Implementation

Create the file at `projects/contracts/src/AgentSettlement.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title AgentSettlement
/// @notice Settles payments from the contract owner to agents for completed tasks.
contract AgentSettlement is Ownable {
    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    /// @notice Emitted when an agent is paid for a completed task.
    event AgentPaid(address indexed agent, uint256 amount, bytes32 indexed taskId);

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    error ZeroAddress();
    error ZeroAmount();
    error ArrayLengthMismatch();
    error InsufficientBalance(uint256 required, uint256 available);

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------

    constructor(address initialOwner) Ownable(initialOwner) {}

    // -------------------------------------------------------------------------
    // External functions
    // -------------------------------------------------------------------------

    /// @notice Settle a payment to a single agent for a completed task.
    /// @param agent    Address of the agent to pay.
    /// @param amount   Amount of native currency (wei) to send.
    /// @param taskId   Identifier of the completed task.
    function settle(
        address agent,
        uint256 amount,
        bytes32 taskId
    ) external payable onlyOwner {
        if (agent == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        if (address(this).balance < amount) {
            revert InsufficientBalance(amount, address(this).balance);
        }

        (bool success, ) = agent.call{value: amount}("");
        require(success, "AgentSettlement: transfer failed");

        emit AgentPaid(agent, amount, taskId);
    }

    /// @notice Settle payments to multiple agents in a single transaction.
    /// @param agents   Array of agent addresses.
    /// @param amounts  Array of amounts (wei) corresponding to each agent.
    /// @param taskIds  Array of task identifiers corresponding to each agent.
    function batchSettle(
        address[] calldata agents,
        uint256[] calldata amounts,
        bytes32[] calldata taskIds
    ) external payable onlyOwner {
        uint256 len = agents.length;
        if (len != amounts.length || len != taskIds.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i = 0; i < len; ) {
            if (agents[i] == address(0)) revert ZeroAddress();
            if (amounts[i] == 0) revert ZeroAmount();
            if (address(this).balance < amounts[i]) {
                revert InsufficientBalance(amounts[i], address(this).balance);
            }

            (bool success, ) = agents[i].call{value: amounts[i]}("");
            require(success, "AgentSettlement: transfer failed");

            emit AgentPaid(agents[i], amounts[i], taskIds[i]);

            unchecked { ++i; }
        }
    }

    /// @notice Allow the contract to receive ETH for settlement funding.
    receive() external payable {}
}
```

After writing the file, run:

```bash
cd projects/contracts
forge build
```

Verify it exits 0 with no errors.

## Done When

- [ ] All requirements met
- [ ] `projects/contracts/src/AgentSettlement.sol` exists and compiles
- [ ] `forge build` exits 0 after adding this file
