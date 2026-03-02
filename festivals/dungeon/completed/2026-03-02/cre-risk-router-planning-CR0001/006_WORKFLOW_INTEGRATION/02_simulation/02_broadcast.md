---
fest_type: task
fest_id: 01_broadcast.md
fest_name: broadcast
fest_parent: 02_simulation
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:44:53.485921-07:00
fest_updated: 2026-03-02T01:14:01.649997-07:00
fest_tracking: true
---


# Task: broadcast

## Objective

Run `cre workflow simulate . --broadcast` and verify it produces a real transaction hash with the `DecisionRecorded` event on the testnet block explorer.

## Requirements

- [ ] `cre workflow simulate . --broadcast` produces a tx hash (Req P0.16)
- [ ] Transaction is verifiable on block explorer
- [ ] `DecisionRecorded` event is visible in the transaction logs

## Implementation

1. **Run broadcast simulation**:
   ```bash
   cd projects/cre-risk-router && just broadcast
   ```

2. **Capture the tx hash** from the output.

3. **Verify on block explorer**:
   - Navigate to the testnet block explorer
   - Look up the tx hash
   - Confirm the `DecisionRecorded` event is present with correct parameters
   - Verify the receipt contract was called

4. **If broadcast fails**, check:
   - Deployer wallet has sufficient testnet funds
   - Contract address in config is correct
   - Testnet RPC is responsive
   - CRE signing key is properly configured

## Done When

- [ ] All requirements met
- [ ] Tx hash produced and verified on block explorer
- [ ] `DecisionRecorded` event visible in transaction logs