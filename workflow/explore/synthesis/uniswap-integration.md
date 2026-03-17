# Uniswap Developer Platform Integration

## Status

**Current:** Agent uses direct on-chain calls (Uniswap V3 Factory `getPool()` → pool `slot0()` → ABI-encode `exactInputSingle` → sign and submit). No Trading API usage.

**Required:** Integrate Trading API for quoting/routing to qualify for the $5K Uniswap bounty. Direct SwapRouter02 calls do not satisfy the "real Developer Platform API key" hard requirement.

**API Key:** Verified working. Stored in `.env` at campaign root as `UNISWAP_API_KEY`.

## Target Integration Flow

```
Agent Trading Loop
  │
  ├── 1. Strategy signal: BUY/SELL with confidence + size
  │
  ├── 2. POST /check_approval → verify token approved for Permit2
  │      Endpoint: https://trade-api.gateway.uniswap.org/v1/check_approval
  │      Headers: x-api-key, x-universal-router-version: 2.0
  │
  ├── 3. POST /quote → get optimized route + price
  │      Endpoint: https://trade-api.gateway.uniswap.org/v1/quote
  │      Body: { type, tokenIn, tokenOut, tokenInChainId, tokenOutChainId, amount, swapper }
  │      Response: routing type, calldata, gas estimate, quote amount
  │
  ├── 4. POST /swap → get unsigned transaction
  │      Endpoint: https://trade-api.gateway.uniswap.org/v1/swap
  │      Body: { quote, permitData (if needed) }
  │      Response: unsigned transaction (to, data, value, gasLimit)
  │
  ├── 5. Sign transaction with go-ethereum (existing infrastructure)
  │
  └── 6. Submit via vault.executeSwap() with API-provided calldata
         ObeyVault enforces: whitelist, maxSwap, dailyVolume, slippage
```

## Code Changes Required

### New: `internal/base/trading/uniswap_api.go`

Go HTTP client wrapping the Trading API:
- `CheckApproval(ctx, tokenIn, chainID)` → approval status
- `GetQuote(ctx, params QuoteParams)` → quote response with routing
- `GetSwap(ctx, quote)` → unsigned transaction

### Modified: `internal/base/trading/executor.go`

- `GetMarketState()` — keep existing on-chain pool queries for price/liquidity (used by strategy)
- `Execute()` — replace hand-encoded `exactInputSingle` calldata with API-provided transaction data

### Modified: `internal/loop/runner.go`

- `cycle()` — insert API quote step between strategy evaluation and vault execution

## Key Configuration

```
UNISWAP_API_KEY=<key>           # .env at campaign root
UNISWAP_API_BASE=https://trade-api.gateway.uniswap.org/v1
```

## What Stays the Same

- Uniswap V3 TWAP oracle for vault NAV pricing (on-chain, not API)
- Pool state queries for strategy signals (on-chain)
- Vault boundary enforcement (contract-level)
- ERC-8021 builder attribution on calldata
- Transaction signing via go-ethereum

## Bounty Evidence

For submission, judges need to see:
1. API key in env configuration (not hardcoded)
2. HTTP calls to `trade-api.gateway.uniswap.org` in Go code
3. Real TxIDs from API-routed swaps on Base mainnet
4. Public repo with README explaining the integration
