---
fest_type: task
fest_id: 01_uniswap_interfaces.md
fest_name: 01_uniswap_interfaces
fest_parent: 01_vault_contract
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:22:34.295908-06:00
fest_tracking: true
---

# Task: Create Uniswap V3 Interfaces

## Objective

Create ISwapRouter02.sol and IOracleLibrary.sol interfaces that the ObeyVault contract will use for swap execution and TWAP price reads.

## Requirements

- [ ] Create `projects/contracts/src/interfaces/ISwapRouter02.sol` with ExactInputSingleParams struct and exactInputSingle function
- [ ] Create `projects/contracts/src/interfaces/IOracleLibrary.sol` with IUniswapV3Factory (getPool) and IUniswapV3Pool (observe, token0, token1)
- [ ] Verify compilation with `forge build`

## Implementation

See implementation plan Task 1 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to create:**
- `projects/contracts/src/interfaces/ISwapRouter02.sol`
- `projects/contracts/src/interfaces/IOracleLibrary.sol`

## Done When

- [ ] All requirements met
- [ ] `cd projects/contracts && forge build` compiles with no errors
