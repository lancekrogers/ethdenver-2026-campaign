---
fest_type: task
fest_id: 01_nav_twap.md
fest_name: 06_nav_twap
fest_parent: 01_vault_contract
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:22:38.69806-06:00
fest_tracking: true
---

# Task: NAV Calculation via Uniswap V3 TWAP

## Objective

Upgrade totalAssets() to mark-to-market all held tokens using Uniswap V3 TWAP oracle prices with a 30-minute window.

## Requirements

- [ ] Add TWAP_PERIOD constant (1800 seconds)
- [ ] Add heldTokenCount() and heldTokenAt() public view functions
- [ ] Implement _getTWAPPrice(token) using IUniswapV3Factory.getPool and IUniswapV3Pool.observe
- [ ] Convert tick to price via TickMath.getSqrtRatioAtTick and FullMath.mulDiv
- [ ] Update totalAssets() to sum USDC balance + TWAP-priced held token balances
- [ ] Import TickMath and FullMath from @uniswap/v3-core
- [ ] Add heldTokens tracking test

## Implementation

See implementation plan Task 6 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to modify:**
- `projects/contracts/src/ObeyVault.sol` (add TWAP helper, update totalAssets)
- `projects/contracts/test/ObeyVault.t.sol` (add heldTokenCount test)

## Done When

- [ ] All requirements met
- [ ] `cd projects/contracts && forge test --match-contract ObeyVaultTest -v` passes (TWAP returns 0 for mock pools, totalAssets falls back to USDC balance)
