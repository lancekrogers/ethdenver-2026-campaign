---
fest_type: task
fest_id: 02_fix_executor.md
fest_name: fix_executor
fest_parent: 03_unblock_base
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Fix Executor

## Objective

Fix `projects/agent-defi/internal/base/trading/executor.go` to build correct Uniswap V3 `exactInputSingle` calldata, add an ERC-20 `approve` call before each swap, and replace the hardcoded market state stub with a real QuoterV2 `slot0` query.

## Context

The current executor has three defects that prevent any real trade from succeeding:

1. **Wrong function selector.** The stub uses `0xa9059cbb` which is the ERC-20 `transfer(address,uint256)` selector. Uniswap V3 SwapRouter02 `exactInputSingle` requires `0x414bf389`. Any transaction built with the wrong selector will either revert or call the wrong function entirely.

2. **No token approval.** Uniswap V3 pulls tokens from the caller via `transferFrom`. Before calling `exactInputSingle`, the agent must call `approve(routerAddress, amount)` on the input token's ERC-20 contract. Without this the swap reverts with "insufficient allowance".

3. **Hardcoded market state.** `GetMarketState` returns a constant, making the agent's price calculations meaningless. It must query real pool data from QuoterV2.

## Implementation Steps

### 1. Fix the exactInputSingle calldata

The Uniswap V3 SwapRouter02 `exactInputSingle` function signature:
```
exactInputSingle((address,address,uint24,address,uint256,uint256,uint160))
```

Function selector: `0x414bf389`

The struct parameter (ExactInputSingleParams) fields in ABI order:
- `tokenIn` — address (32 bytes, left-padded)
- `tokenOut` — address (32 bytes, left-padded)
- `fee` — uint24 (32 bytes; use 3000 for the standard 0.3% pool)
- `recipient` — address (32 bytes, left-padded)
- `amountIn` — uint256 (32 bytes)
- `amountOutMinimum` — uint256 (32 bytes; set to 0 for testing, use slippage calc in production)
- `sqrtPriceLimitX96` — uint160 (32 bytes; set to 0 to accept any price)

Use `go-ethereum`'s `abi.Pack` with a parsed ABI, or construct the calldata manually using `abi.Arguments.Pack`. Do not use raw byte string concatenation for ABI encoding.

Example approach using a parsed ABI:
```go
swapABI, err := abi.JSON(strings.NewReader(exactInputSingleABI))
// where exactInputSingleABI is the JSON ABI string for exactInputSingle
data, err := swapABI.Pack("exactInputSingle", params)
```

### 2. Add ERC-20 approve before swap

Before building the swap transaction, call `approve(address spender, uint256 amount)` on the input token contract:

- `spender` = SwapRouter02 address (from `DEFI_DEX_ROUTER` env var)
- `amount` = the swap `amountIn`

The ERC-20 `approve` selector is `0x095ea7b3`. ABI-encode the two parameters and send the transaction to the input token contract address. Wait for the approval transaction to be mined before submitting the swap.

### 3. Replace hardcoded GetMarketState with QuoterV2

Replace the stub `GetMarketState` implementation with a call to QuoterV2 (`DEFI_QUOTER_V2` env var, `0xC5290058841028F1614F3A6F0F5816cAd0df5E27`).

QuoterV2 `quoteExactInputSingle` can be called as a view (eth_call) to get the expected output amount and current sqrt price without sending a transaction. Use this to populate the market state struct with real price data.

### 4. Update tests

Update unit tests in `executor_test.go` (or equivalent) to:
- Verify the correct function selector appears in generated calldata
- Verify the approve call is present before the swap call
- Mock the QuoterV2 call and verify the market state is populated from the response

## Done When

- `executor.go` generates calldata with selector `0x414bf389` for all swaps
- An `approve` transaction is sent before each swap
- `GetMarketState` queries QuoterV2 instead of returning a constant
- All executor unit tests pass
- `go build ./...` in `projects/agent-defi` succeeds with no errors
