---
fest_type: task
fest_id: 01_deploy_testnet.md
fest_name: deploy testnet
fest_parent: 02_contract
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:43:36.965639-07:00
fest_tracking: true
---

# Task: deploy testnet

## Objective

Deploy `RiskDecisionReceipt.sol` to the CRE-supported EVM testnet (determined in Phase 001), capture the contract address, and update `config.json`.

## Requirements

- [ ] Contract deployed to CRE-supported EVM testnet (Req P0.3)
- [ ] Contract address captured and documented
- [ ] `config.json` updated with `receipt_contract_address` and `target_network`
- [ ] Deployment verified on block explorer

## Implementation

1. **Deploy via Foundry** (use testnet from Phase 001 findings):

   ```bash
   forge create contracts/evm/src/RiskDecisionReceipt.sol:RiskDecisionReceipt \
     --rpc-url $TESTNET_RPC --private-key $DEPLOYER_PRIVATE_KEY
   ```

2. **Capture** the contract address from `Deployed to: 0x...` output.

3. **Update `config.json`** with `receipt_contract_address` and `target_network`.

4. **Verify on block explorer** and optionally verify source with `forge verify-contract`.

## Done When

- [ ] All requirements met
- [ ] Contract deployed and verified on block explorer
- [ ] `config.json` updated with contract address
