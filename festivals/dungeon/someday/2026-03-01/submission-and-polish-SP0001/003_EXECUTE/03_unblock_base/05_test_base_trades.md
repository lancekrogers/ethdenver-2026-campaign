---
fest_type: task
fest_id: 05_test_base_trades.md
fest_name: test_base_trades
fest_parent: 03_unblock_base
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Test Base Trades

## Objective

Run the DeFi agent end-to-end on Base Sepolia and verify that identity registration, a real Uniswap V3 swap, PnL recording, and ERC-8021 attribution all succeed. Document the results with transaction hashes.

## Context

This is the integration verification task. All prior tasks in this sequence (contract config, executor fix, identity fix, wallet funding) must be complete before starting this task. The agent should now be capable of executing a full trade cycle on Base Sepolia.

## Verification Steps

### 1. Start the DeFi agent

```bash
cd projects/agent-defi && just run
```

Watch the startup logs for errors. The agent should:
- Load contract addresses from `.env`
- Derive or load the wallet address
- Log non-zero ETH and USDC balances

### 2. Verify ERC-8004 identity registration

The agent should attempt to register its identity with the ERC-8004 IdentityRegistry on startup or on first trade. Verify:
- The registration transaction is sent
- The transaction is mined without reverting (check BaseScan: https://sepolia.basescan.org)
- Record the registration transaction hash

If registration fails, check the error log against the fixes in task 03.

### 3. Verify a real Uniswap V3 swap executes

Allow the agent to run until it attempts a swap (this may require the coordinator to send a trade signal, or a manual trigger depending on agent architecture). Verify:
- The approve transaction is sent and mined
- The `exactInputSingle` swap transaction is sent and mined
- Both transactions appear on BaseScan with successful status
- Record both transaction hashes

### 4. Verify PnL tracker records the trade

After the swap is mined, check that the agent's PnL tracker has recorded the trade:
- Input token, output token, amounts
- Entry price vs. exit price (if applicable)
- Timestamp and transaction hash

### 5. Verify ERC-8021 attribution bytes

Inspect the swap transaction calldata on BaseScan. The ERC-8021 attribution bytes should be appended after the standard `exactInputSingle` params. Confirm the agent wallet address (or builder code) appears in the trailing calldata.

### 6. Document results

Record the following in a comment or log file for use in 08_base_package:

```
ERC-8004 Registration:  <tx hash>
ERC-20 Approve:         <tx hash>
Uniswap V3 Swap:        <tx hash>
Agent Wallet:           <address>
USDC In:                <amount>
Token Out:              <token> <amount>
PnL Recorded:           yes/no
ERC-8021 Attribution:   confirmed/not found
```

## Done When

- ERC-8004 identity registration transaction is mined on Base Sepolia (no revert)
- At least one Uniswap V3 swap transaction is mined on Base Sepolia (no revert)
- PnL tracker shows the trade recorded
- ERC-8021 attribution bytes are present in the swap calldata
- All transaction hashes are documented
