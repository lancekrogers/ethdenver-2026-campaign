---
fest_type: task
fest_id: 01_execute_da_submit.md
fest_name: execute-da-submit
fest_parent: 01_0g_galileo_evidence
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-11T05:02:37.276521-06:00
fest_tracking: true
---

# Task: Execute DA Submit on 0G Galileo

## Objective

Execute a `submitOriginalData()` write transaction against the 0G DA Entrance contract on Galileo testnet to generate verifiable on-chain evidence of data availability layer integration.

## Requirements

- [ ] Galileo wallet funded (05_fund_galileo_wallet completed)
- [ ] 0G DA Entrance contract address: `0xE75A073dA5bb7b0eC622170Fd268f35E675a957B`
- [ ] Transaction hash recorded and verified on chainscan.io

## Implementation

### Step 1: Verify the DA Entrance contract is accessible

```bash
cast call 0xE75A073dA5bb7b0eC622170Fd268f35E675a957B \
  --rpc-url https://evmrpc-testnet.0g.ai \
  "owner()(address)"
```

### Step 2: Prepare DA submission data

The `submitOriginalData()` function on the DA Entrance contract accepts raw data for DA submission. Prepare a sample data payload:

If using the agent-inference CLI or SDK:

```bash
# Use the 0g-da-client or agent-inference tooling to submit data
# This will call the DA Entrance contract's submitOriginalData() function internally
```

If calling directly via cast:

```bash
cast send 0xE75A073dA5bb7b0eC622170Fd268f35E675a957B \
  "submitOriginalData(bytes)" \
  "0x$(echo -n 'obey-agent-economy-da-evidence' | xxd -p)" \
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
- The `to` address is the DA Entrance contract
- The method called is `submitOriginalData()`

## Done When

- [ ] All requirements met
- [ ] DA `submitOriginalData()` transaction confirmed on chainscan.io with status "Success" at DA Entrance 0xE75A073dA5bb7b0eC622170Fd268f35E675a957B
