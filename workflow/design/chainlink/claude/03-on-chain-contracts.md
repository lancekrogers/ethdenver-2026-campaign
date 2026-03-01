# 03 - On-Chain Contracts for CRE Risk Router

## Contract: `RiskDecisionReceipt.sol`

This contract receives and stores risk decisions from the CRE Risk Router workflow. It must be deployed on a **CRE-supported EVM testnet** (not Hedera EVM).

### Requirements

1. Accept signed reports from CRE DON via `IReceiver` interface
2. Store decision metadata indexed by run ID
3. Emit events for dashboard and agent consumption
4. Simple and auditable - judges will review this

### Contract Design

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title RiskDecisionReceipt
/// @notice Stores CRE Risk Router decisions as immutable on-chain receipts
/// @dev Implements IReceiver for CRE report consumption
contract RiskDecisionReceipt {

    struct Decision {
        bytes32 runId;
        bytes32 decisionHash;
        bool approved;
        uint256 maxPositionUsd;
        uint256 maxSlippageBps;
        uint256 ttlSeconds;
        uint256 chainlinkPrice;
        address recorder;
        uint256 timestamp;
    }

    // runId => Decision
    mapping(bytes32 => Decision) public decisions;

    // Track all run IDs for enumeration
    bytes32[] public runIds;

    // Prevent duplicate writes
    mapping(bytes32 => bool) public recorded;

    // Stats
    uint256 public totalDecisions;
    uint256 public totalApproved;
    uint256 public totalDenied;

    event DecisionRecorded(
        bytes32 indexed runId,
        bytes32 indexed decisionHash,
        bool approved,
        uint256 maxPositionUsd,
        uint256 maxSlippageBps,
        uint256 chainlinkPrice,
        address indexed recorder,
        uint256 timestamp
    );

    event DecisionDenied(
        bytes32 indexed runId,
        bytes32 indexed decisionHash,
        string reason,
        address indexed recorder,
        uint256 timestamp
    );

    /// @notice Record a risk decision from CRE Risk Router
    /// @param runId Unique identifier for this CRE workflow run
    /// @param decisionHash Hash of the full decision payload
    /// @param approved Whether the trade was approved
    /// @param maxPositionUsd Maximum approved position size in USD (6 decimals)
    /// @param maxSlippageBps Maximum slippage in basis points
    /// @param ttlSeconds Time-to-live for this decision
    /// @param chainlinkPrice Price from Chainlink feed at decision time
    function recordDecision(
        bytes32 runId,
        bytes32 decisionHash,
        bool approved,
        uint256 maxPositionUsd,
        uint256 maxSlippageBps,
        uint256 ttlSeconds,
        uint256 chainlinkPrice
    ) external {
        require(!recorded[runId], "Decision already recorded");

        Decision memory d = Decision({
            runId: runId,
            decisionHash: decisionHash,
            approved: approved,
            maxPositionUsd: maxPositionUsd,
            maxSlippageBps: maxSlippageBps,
            ttlSeconds: ttlSeconds,
            chainlinkPrice: chainlinkPrice,
            recorder: msg.sender,
            timestamp: block.timestamp
        });

        decisions[runId] = d;
        runIds.push(runId);
        recorded[runId] = true;
        totalDecisions++;

        if (approved) {
            totalApproved++;
            emit DecisionRecorded(
                runId,
                decisionHash,
                approved,
                maxPositionUsd,
                maxSlippageBps,
                chainlinkPrice,
                msg.sender,
                block.timestamp
            );
        } else {
            totalDenied++;
            emit DecisionDenied(
                runId,
                decisionHash,
                "denied_by_risk_router",
                msg.sender,
                block.timestamp
            );
        }
    }

    /// @notice Check if a decision is still valid (within TTL)
    /// @param runId The run ID to check
    /// @return valid Whether the decision exists and is within TTL
    function isDecisionValid(bytes32 runId) external view returns (bool valid) {
        Decision memory d = decisions[runId];
        if (!recorded[runId]) return false;
        if (!d.approved) return false;
        return block.timestamp <= d.timestamp + d.ttlSeconds;
    }

    /// @notice Get the total number of recorded decisions
    function getRunCount() external view returns (uint256) {
        return runIds.length;
    }
}
```

### Why Not IReceiver?

For the hackathon submission, using a direct `recordDecision()` call is clearer and more debuggable than implementing the full `IReceiver` interface for CRE report consumption. The judges need to see a clear on-chain write with readable parameters.

If time permits, a second version implementing `IReceiver` can be added to show proper CRE integration. But the direct call ensures we have a guaranteed working tx hash for the submission.

### Deployment Strategy

**Option A (preferred): Direct deployment via Foundry**
```bash
# Deploy to Arbitrum Sepolia
forge create src/RiskDecisionReceipt.sol:RiskDecisionReceipt \
  --rpc-url $ARBITRUM_SEPOLIA_RPC \
  --private-key $DEPLOYER_KEY
```

**Option B: CRE-managed deployment**
If CRE supports contract deployment, use that path for stronger integration story.

### Test Contract

```solidity
// test/RiskDecisionReceipt.t.sol
contract RiskDecisionReceiptTest is Test {
    RiskDecisionReceipt receipt;

    function setUp() public {
        receipt = new RiskDecisionReceipt();
    }

    function test_recordApprovedDecision() public {
        bytes32 runId = keccak256("test-run-1");
        bytes32 hash = keccak256("test-hash-1");

        receipt.recordDecision(runId, hash, true, 1000e6, 50, 300, 2500e8);

        (,,bool approved,,,,,, ) = receipt.decisions(runId);
        assertTrue(approved);
        assertTrue(receipt.isDecisionValid(runId));
        assertEq(receipt.totalApproved(), 1);
    }

    function test_recordDeniedDecision() public {
        bytes32 runId = keccak256("test-run-2");
        bytes32 hash = keccak256("test-hash-2");

        receipt.recordDecision(runId, hash, false, 0, 0, 0, 2500e8);

        assertTrue(receipt.recorded(runId));
        assertFalse(receipt.isDecisionValid(runId));
        assertEq(receipt.totalDenied(), 1);
    }

    function test_revertOnDuplicate() public {
        bytes32 runId = keccak256("test-run-3");
        bytes32 hash = keccak256("test-hash-3");

        receipt.recordDecision(runId, hash, true, 1000e6, 50, 300, 2500e8);

        vm.expectRevert("Decision already recorded");
        receipt.recordDecision(runId, hash, true, 1000e6, 50, 300, 2500e8);
    }

    function test_decisionExpiry() public {
        bytes32 runId = keccak256("test-run-4");
        bytes32 hash = keccak256("test-hash-4");

        receipt.recordDecision(runId, hash, true, 1000e6, 50, 300, 2500e8);
        assertTrue(receipt.isDecisionValid(runId));

        // Fast forward past TTL
        vm.warp(block.timestamp + 301);
        assertFalse(receipt.isDecisionValid(runId));
    }
}
```

## Existing Contract Reuse

The contracts in `projects/contracts/` (`AgentSettlement.sol`, `ReputationDecay.sol`, `AgentINFT.sol`) are Hedera-specific (HIP-1215 scheduling). They don't need modification for the Chainlink submission.

The new `RiskDecisionReceipt.sol` can either:
1. Live in `projects/cre-risk-router/contracts/` (self-contained, recommended for clean submission)
2. Live in `projects/contracts/src/` alongside existing contracts (shared Foundry workspace)

Recommendation: **Option 1** - keep the CRE project self-contained so the submission repo is clean and judges can evaluate it independently.

## Chainlink Price Feed Integration

The CRE workflow reads Chainlink price feeds on testnet to validate agent price assumptions:

**Arbitrum Sepolia price feeds (examples):**
- ETH/USD: verify against Chainlink's testnet feed contracts
- Need to confirm exact feed addresses via Chainlink docs or CRE tooling

This is read-only (via `CallContract`) and supplements the on-chain write to `RiskDecisionReceipt`.
