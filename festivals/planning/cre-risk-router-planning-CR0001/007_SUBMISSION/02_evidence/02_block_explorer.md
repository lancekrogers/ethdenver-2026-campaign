---
fest_type: task
fest_id: 01_block_explorer.md
fest_name: block explorer
fest_parent: 02_evidence
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:45:22.168651-07:00
fest_tracking: true
---

# Task: block explorer

## Objective

Verify the broadcast simulation transaction on the testnet block explorer and capture a screenshot or permanent link as evidence.

## Requirements

- [ ] Tx hash from broadcast simulation verified on block explorer (Req P0.20)
- [ ] `DecisionRecorded` event is visible in transaction logs
- [ ] Screenshot or permanent link captured for Moltbook submission

## Implementation

1. **Navigate to the testnet block explorer** (URL from Phase 001 findings).

2. **Look up the tx hash** from the captured simulation logs.

3. **Verify**:
   - Transaction status is "Success"
   - Contract address matches `config.receipt_contract_address`
   - `DecisionRecorded` event is present in the logs tab
   - Event parameters (runId, decisionHash, approved, chainlinkPrice) are readable

4. **Capture evidence**:
   - Copy the permanent link to the transaction
   - Take a screenshot showing the transaction details and event
   - Save both for inclusion in Moltbook post Section 8

## Done When

- [ ] All requirements met
- [ ] Transaction verified as successful on block explorer
- [ ] Evidence captured (link and/or screenshot) for Moltbook submission
