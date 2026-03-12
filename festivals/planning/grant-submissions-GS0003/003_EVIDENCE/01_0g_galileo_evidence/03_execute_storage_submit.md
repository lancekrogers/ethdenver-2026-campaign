---
fest_type: task
fest_id: 01_execute_storage_submit.md
fest_name: execute-storage-submit
fest_parent: 01_0g_galileo_evidence
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-11T05:02:37.260088-06:00
fest_tracking: true
---

# Task: Execute Storage Submit on 0G Galileo

## Objective

Execute a `submit()` write transaction against the 0G Storage Flow contract on Galileo testnet to generate verifiable on-chain evidence of storage layer integration.

## Requirements

- [ ] Galileo wallet funded (05_fund_galileo_wallet completed)
- [ ] 0G Storage Flow contract address: `0x22E03a6A89B950F1c82ec5e74F8eCa321a105296`
- [ ] Transaction hash recorded and verified on chainscan.io

## Implementation

### Step 1: Verify the Flow contract is accessible

```bash
cast call 0x22E03a6A89B950F1c82ec5e74F8eCa321a105296 \
  --rpc-url https://evmrpc-testnet.0g.ai \
  "owner()(address)"
```

### Step 2: Prepare submission data

The `submit()` function on the Flow contract expects a data submission. Prepare the submission parameters according to the 0G Storage Flow ABI. Typical parameters include:

- `submission`: encoded submission struct containing the data root and other metadata

If using the agent-inference CLI or SDK:

```bash
# Use the 0g-storage-client or agent-inference tooling to submit data
# This will call the Flow contract's submit() function internally
```

If calling directly via cast:

```bash
cast send 0x22E03a6A89B950F1c82ec5e74F8eCa321a105296 \
  "submit((uint256,bytes32[],uint256,uint256,bytes32))" \
  "<ENCODED_SUBMISSION_TUPLE>" \
  --rpc-url https://evmrpc-testnet.0g.ai \
  --private-key $PRIVATE_KEY
```

### Step 3: Record transaction details

From the transaction output, capture:
- **Tx hash**: The transaction hash
- **Block number**: The block the transaction was included in
- **Gas used**: For cost reporting

### Step 4: Verify on block explorer

Open `https://chainscan.0g.ai/tx/<TX_HASH>` and confirm:
- Transaction status is "Success"
- The `to` address is the Flow contract
- The method called is `submit()`

## Done When

- [ ] All requirements met
- [ ] Storage `submit()` transaction confirmed on chainscan.io with status "Success" at Flow contract 0x22E03a6A89B950F1c82ec5e74F8eCa321a105296
