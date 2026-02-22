---
fest_type: task
fest_id: 03_implement_reputation.md
fest_name: implement reputation
fest_parent: 03_contracts_implementation
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:46.814167-07:00
fest_tracking: true
---

# Task: Implement ReputationDecay.sol

## Objective

Write `ReputationDecay.sol` in `projects/contracts/src/` — a contract that tracks per-agent reputation scores with configurable linear time-decay, so that an agent's effective reputation decreases over time unless refreshed.

## Requirements

- [ ] `updateReputation(address agent, uint256 score)` — set the agent's raw reputation score and record the update timestamp
- [ ] `getReputation(address agent) returns (uint256)` — return the current effective score after linear time-decay is applied
- [ ] Configurable `decayRate` (points per second) set at construction
- [ ] Scores never decay below zero (clamp at 0)
- [ ] `ReputationUpdated(address indexed agent, uint256 newScore)` event on every update
- [ ] `forge build` exits 0 after writing the file

## Implementation

Create the file at `projects/contracts/src/ReputationDecay.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ReputationDecay
/// @notice Tracks agent reputation scores with configurable linear time-decay.
///         Effective score = max(0, rawScore - decayRate * secondsElapsed)
contract ReputationDecay {
    // -------------------------------------------------------------------------
    // State
    // -------------------------------------------------------------------------

    /// @notice Decay rate in reputation points per second.
    uint256 public immutable decayRate;

    struct Record {
        uint256 score;
        uint256 updatedAt;
    }

    mapping(address => Record) private _records;

    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    /// @notice Emitted when an agent's reputation score is updated.
    event ReputationUpdated(address indexed agent, uint256 newScore);

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    error ZeroAddress();

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------

    /// @param _decayRate Reputation points lost per second of inactivity.
    constructor(uint256 _decayRate) {
        decayRate = _decayRate;
    }

    // -------------------------------------------------------------------------
    // External functions
    // -------------------------------------------------------------------------

    /// @notice Set an agent's raw reputation score and reset the decay timer.
    /// @param agent Address of the agent.
    /// @param score New raw reputation score.
    function updateReputation(address agent, uint256 score) external {
        if (agent == address(0)) revert ZeroAddress();

        _records[agent] = Record({
            score: score,
            updatedAt: block.timestamp
        });

        emit ReputationUpdated(agent, score);
    }

    /// @notice Get an agent's current effective reputation after decay.
    /// @param agent Address of the agent.
    /// @return effectiveScore Current score with linear decay applied (clamped at 0).
    function getReputation(address agent) external view returns (uint256 effectiveScore) {
        Record storage rec = _records[agent];
        if (rec.updatedAt == 0) {
            return 0;
        }

        uint256 elapsed = block.timestamp - rec.updatedAt;
        uint256 decayed = decayRate * elapsed;

        if (decayed >= rec.score) {
            return 0;
        }

        return rec.score - decayed;
    }
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
- [ ] `projects/contracts/src/ReputationDecay.sol` exists and compiles
- [ ] `forge build` exits 0 after adding this file
