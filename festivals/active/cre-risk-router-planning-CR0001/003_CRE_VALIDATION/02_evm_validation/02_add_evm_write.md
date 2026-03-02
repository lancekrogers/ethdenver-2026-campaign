---
fest_type: task
fest_id: 01_add_evm_write.md
fest_name: add evm write
fest_parent: 02_evm_validation
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:43:09.715483-07:00
fest_updated: 2026-03-02T00:32:26.517808-07:00
fest_tracking: true
---


# Task: add evm write

## Objective

Add an EVM write capability to the hello-world CRE workflow, calling the trivial contract deployed in the previous task.

## Requirements

- [ ] Hello-world workflow is updated with EVM write capability calling the trivial contract (Req 0.5)
- [ ] The workflow compiles with the EVM write addition
- [ ] CRE SDK EVM write patterns are documented

## Implementation

1. **Generate EVM bindings** for the trivial contract (if CRE supports this):

   ```bash
   # If cre generate-bindings exists:
   cre generate-bindings evm --abi /tmp/cre-trivial-contract/out/Trivial.sol/Trivial.json
   ```

   If `cre generate-bindings` is not available for standalone use, generate Go bindings manually using `abigen` or include the ABI directly.

2. **Update the hello-world workflow** to include EVM write:

   ```go
   // In the cron handler, after logging:
   // Use CRE EVM write capability to call setValue(42) on the trivial contract

   // The exact CRE API for EVM writes will be discovered from:
   // - CRE SDK source code
   // - Hackathon skills repo examples
   // - Phase 001 auth/setup findings
   ```

   The handler should:
   - Read the trivial contract address from config
   - Construct a `setValue(42)` transaction
   - Execute via CRE's EVM write capability
   - Log the result

3. **Update `config.json`** with:
   - `target_network`: The CRE-supported testnet identifier
   - `contract_address`: The trivial contract address
   - Any other CRE-required EVM config fields

4. **Verify compilation**:

   ```bash
   go mod tidy && go build -o /dev/null .
   ```

5. **Document the EVM write pattern**:
   - Exact CRE SDK functions used for EVM writes
   - How the target network is specified
   - How the contract ABI/bindings are provided to CRE
   - Any required config fields for EVM writes

## Done When

- [ ] All requirements met
- [ ] Workflow compiles with EVM write capability
- [ ] EVM write SDK patterns are documented with exact function signatures
- [ ] Config fields for EVM writes are documented