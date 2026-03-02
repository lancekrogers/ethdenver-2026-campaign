---
fest_type: task
fest_id: 01_broadcast_simulation.md
fest_name: broadcast simulation
fest_parent: 02_evm_validation
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:43:09.732685-07:00
fest_tracking: true
---

# Task: broadcast simulation

## Objective

Run `cre workflow simulate . --broadcast` on the EVM-write-enabled hello-world workflow and verify it produces a real transaction hash.

## Requirements

- [ ] `cre workflow simulate . --broadcast` executes without errors (Req 0.6)
- [ ] Simulation output includes a transaction hash
- [ ] Transaction is verifiable on the testnet block explorer

## Implementation

1. **Navigate to the hello-world workflow directory**:

   ```bash
   cd /tmp/cre-hello-world
   ```

2. **Run broadcast simulation**:

   ```bash
   cre workflow simulate . --broadcast
   ```

3. **Analyze the output**:
   - Look for a transaction hash in the output (format: `0x...`, 66 characters)
   - Note whether the EVM write was executed (setValue called on trivial contract)
   - Check for any warnings about gas, nonce, or signing

4. **Verify on block explorer**:
   - Copy the tx hash from the output
   - Navigate to the testnet block explorer
   - Confirm the transaction exists and was successful
   - Verify the contract interaction (setValue called)

5. **If broadcast fails, debug**:
   - Check if the deployer wallet has sufficient funds
   - Verify the contract address in config is correct
   - Check if `--broadcast` requires additional flags or env vars
   - Try with explicit gas limit or gas price if needed
   - Check if CRE requires a specific signing key setup

6. **GATE DECISION**: If this task fails after thorough debugging, **stop the entire festival and reassess the approach** before continuing. This is a hard gate per the implementation plan.

7. **Document findings**:
   - Exact broadcast command and flags
   - How tx hash appears in the output
   - Whether a funded wallet is required (and which wallet CRE uses)
   - Any differences between dry-run and broadcast behavior

## Done When

- [ ] All requirements met
- [ ] Broadcast simulation produces a tx hash
- [ ] Transaction verified on block explorer
- [ ] Broadcast requirements and patterns documented
