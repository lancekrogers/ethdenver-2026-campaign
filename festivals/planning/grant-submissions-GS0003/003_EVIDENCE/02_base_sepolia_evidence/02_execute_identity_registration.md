---
fest_type: task
fest_id: 01_execute_identity_registration.md
fest_name: execute-identity-registration
fest_parent: 02_base_sepolia_evidence
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-11T05:02:40.987886-06:00
fest_tracking: true
---

# Task: Execute ERC-8004 Identity Registration on Base Sepolia

## Objective

Execute an ERC-8004 identity registration write transaction on Base Sepolia (chain ID 84532) via agent-defi to generate verifiable on-chain evidence of identity protocol integration.

## Requirements

- [ ] Base Sepolia wallet funded with ETH for gas (03_fund_base_wallet completed)
- [ ] agent-defi built and configured for Base Sepolia
- [ ] Transaction hash recorded and verified on sepolia.basescan.org

## Implementation

### Step 1: Verify agent-defi is built

```bash
cd projects/agent-defi  # or wherever agent-defi lives
go build ./...
```

### Step 2: Verify Base Sepolia configuration

Ensure agent-defi has Base Sepolia chain config (chain ID 84532, RPC https://sepolia.base.org) and the ERC-8004 registry contract address is configured.

### Step 3: Execute identity registration

Using agent-defi CLI:

```bash
# Register identity on Base Sepolia via agent-defi
# The exact command depends on agent-defi's CLI interface
agent-defi identity register \
  --chain base-sepolia \
  --rpc-url https://sepolia.base.org \
  --private-key $PRIVATE_KEY
```

If calling directly via cast (fallback):

```bash
cast send <ERC_8004_REGISTRY_ADDRESS> \
  "register(address,bytes)" \
  $(cast wallet address --private-key $PRIVATE_KEY) \
  "0x" \
  --rpc-url https://sepolia.base.org \
  --private-key $PRIVATE_KEY
```

### Step 4: Record transaction details

From the transaction output, capture:
- **Tx hash**: The transaction hash
- **Block number**: The block the transaction was included in
- **Identity ID**: The registered identity identifier (if emitted in events)

### Step 5: Verify on block explorer

Open `https://sepolia.basescan.org/tx/<TX_HASH>` and confirm:
- Transaction status is "Success"
- The contract interaction matches the ERC-8004 registry
- Identity registration event is emitted

## Done When

- [ ] All requirements met
- [ ] ERC-8004 identity registration transaction confirmed on sepolia.basescan.org with status "Success"
