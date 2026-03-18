---
fest_type: task
fest_id: 05_integrate_api_into_executor
fest_parent: 01_verify_uniswap_api
fest_order: 5
fest_status: completed
fest_autonomy: high
fest_created: 0001-01-01T00:00:00Z
fest_updated: 2026-03-16T22:37:16.302201-06:00
fest_tracking: true
---


# Task: Integrate API Client into Trade Executor

## Objective

Replace the direct `exactInputSingle` ABI encoding in the trade executor with Uniswap Trading API-routed quotes and swap transactions.

## Requirements

- [ ] `executor.Execute()` uses API quote + swap instead of hand-encoded calldata
- [ ] `executor.GetMarketState()` unchanged — keep direct on-chain pool queries for strategy signals
- [ ] `loop/runner.go` cycle includes API quote step between strategy evaluation and vault execution
- [ ] ERC-8021 builder attribution still applied to final calldata
- [ ] Existing tests updated to reflect new flow

## Implementation

1. Modify `internal/base/trading/executor.go`:
   - Add `UniswapAPIClient` as a field on the `executor` struct
   - In `NewExecutor()`, initialize the API client from config (API key from env)
   - In `Execute()`:
     - Call `apiClient.GetQuote()` with trade parameters
     - Call `apiClient.GetSwap()` with the quote response
     - Use the API-returned transaction data (`to`, `data`, `value`) instead of hand-encoded calldata
     - Still apply ERC-8021 attribution to the calldata before signing
     - Sign and submit via go-ethereum (existing `ethutil.SignAndSend`)

2. Keep `GetMarketState()` as-is — it queries on-chain pool state for:
   - Price from `slot0()` sqrtPriceX96
   - Liquidity from `liquidity()`
   - Moving average calculation
   These feed the strategy, not the swap execution.

3. Modify `internal/loop/runner.go`:
   - No changes needed if the executor interface stays the same
   - The API integration is internal to `executor.Execute()`

4. Update `ExecutorConfig` to include API config:
   ```go
   type ExecutorConfig struct {
       // ... existing fields ...
       UniswapAPIKey  string
       UniswapAPIBase string
   }
   ```

5. Update `cmd/vault-agent/main.go` to pass API config from env vars

6. Update tests in `executor_test.go` to cover the new API flow

## What Changes vs What Stays

| Component | Change? | Detail |
|-----------|---------|--------|
| `Execute()` | YES | API quote+swap replaces hand-encoded calldata |
| `GetMarketState()` | NO | Still uses direct on-chain pool queries |
| `GetBalance()` | NO | Still uses direct eth_call |
| Trading loop | NO | Executor interface unchanged |
| ERC-8021 attribution | YES | Applied to API-returned calldata |
| Transaction signing | NO | Same go-ethereum signing |
| Vault boundary enforcement | NO | Contract-level, unchanged |

## Done When

- [ ] All requirements met
- [ ] `Execute()` routes through Uniswap Trading API
- [ ] API key loaded from env, not hardcoded
- [ ] ERC-8021 attribution still applied
- [ ] `go build ./...` succeeds
- [ ] Updated tests pass