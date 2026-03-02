---
fest_type: task
fest_id: 01_evm_bindings.md
fest_name: evm bindings
fest_parent: 02_contract
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:43:36.983976-07:00
fest_updated: 2026-03-02T00:51:53.79821-07:00
fest_tracking: true
---


# Task: evm bindings

## Objective

Generate Go EVM bindings from the `RiskDecisionReceipt.sol` contract ABI using `cre generate-bindings evm` and verify the generated Go code compiles.

## Requirements

- [ ] EVM bindings generated from contract ABI (Req P0.4)
- [ ] Generated Go code compiles without errors
- [ ] Bindings expose `RecordDecision()`, `IsDecisionValid()`, `GetRunCount()` methods

## Implementation

1. **Ensure ABI file** exists at `contracts/evm/src/abi/RiskDecisionReceipt.json`.

2. **Generate bindings**: `cre generate-bindings evm`

3. **If CRE CLI fails**, fall back to `abigen` from go-ethereum tools.

4. **Verify compilation**: `go build ./...`

5. **Verify** generated methods match contract interface.

## Done When

- [ ] All requirements met
- [ ] EVM bindings generated and Go code compiles
- [ ] Binding methods match the contract interface