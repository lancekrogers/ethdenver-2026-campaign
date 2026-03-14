---
fest_type: task
fest_id: 01_execute_swap.md
fest_name: 05_execute_swap
fest_parent: 01_vault_contract
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T19:22:37.862129-06:00
fest_tracking: true
---

# Task: executeSwap with Boundary Enforcement

## Objective

Implement the executeSwap function that enforces all spending boundaries (token whitelist, max swap size, daily volume cap, slippage limit) before executing via Uniswap V3 SwapRouter02.

## Requirements

- [ ] Implement executeSwap(tokenIn, tokenOut, amountIn, amountOutMinimum, reason) with onlyAgent and whenNotPaused
- [ ] Enforce: same-token rejection, token whitelist, max swap size, daily volume tracking with day reset, slippage check
- [ ] Execute swap via ISwapRouter02.exactInputSingle with 0.3% fee tier
- [ ] Update _heldTokens tracking after swap
- [ ] Emit SwapExecuted event
- [ ] Add tests: onlyAgent, unapproved token reverts, exceeds max size reverts, daily volume cap, paused reverts

## Implementation

See implementation plan Task 5 (`workflow/design/synthesis/01-implementation-plan.md`).

**Key files to modify:**
- `projects/contracts/src/ObeyVault.sol` (add executeSwap)
- `projects/contracts/test/ObeyVault.t.sol` (add swap boundary tests)

## Done When

- [ ] All requirements met
- [ ] `cd projects/contracts && forge test --match-contract ObeyVaultTest -v` passes all boundary enforcement tests
