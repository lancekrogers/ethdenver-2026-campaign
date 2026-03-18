---
fest_type: task
fest_id: 04_build_api_client
fest_parent: 01_verify_uniswap_api
fest_order: 4
fest_status: completed
fest_autonomy: high
fest_created: 0001-01-01T00:00:00Z
fest_updated: 2026-03-16T22:35:36.455741-06:00
fest_tracking: true
---


# Task: Build Uniswap Trading API Client

## Objective

Create a Go HTTP client in agent-defi that wraps the Uniswap Developer Platform Trading API for quoting and swap transaction construction.

## Requirements

- [ ] New file `internal/base/trading/uniswap_api.go` with Trading API client
- [ ] `CheckApproval(ctx, tokenIn, chainID)` — check Permit2 approval status
- [ ] `GetQuote(ctx, params)` — get optimized routing quote from the API
- [ ] `GetSwap(ctx, quote)` — get unsigned transaction from the API
- [ ] API key loaded from `UNISWAP_API_KEY` env var (never hardcoded)
- [ ] All requests include required headers: `x-api-key`, `x-universal-router-version: 2.0`, `Content-Type: application/json`

## Implementation

1. Create `internal/base/trading/uniswap_api.go`:

```go
package trading

// UniswapAPIClient wraps the Uniswap Developer Platform Trading API.
type UniswapAPIClient struct {
    baseURL    string // https://trade-api.gateway.uniswap.org/v1
    apiKey     string
    httpClient *http.Client
}

// QuoteParams holds parameters for a quote request.
type QuoteParams struct {
    Type           string // "EXACT_INPUT"
    TokenIn        string // token address
    TokenOut       string // token address
    TokenInChainID int    // 8453 for Base
    TokenOutChainID int   // 8453 for Base
    Amount         string // amount in smallest unit (e.g., "10000000" for 10 USDC)
    Swapper        string // wallet address executing the swap
}
```

2. Implement `CheckApproval`:
   - `POST /check_approval`
   - Body: `{ token, amount, chainId, walletAddress }`
   - Returns whether token is approved for Permit2

3. Implement `GetQuote`:
   - `POST /quote`
   - Body: QuoteParams mapped to API fields
   - Returns: routing type, quote amount, gas estimate, permit data

4. Implement `GetSwap`:
   - `POST /swap`
   - Body: quote response + permit signature (if needed)
   - Returns: unsigned transaction (`to`, `data`, `value`, `gasLimit`)

5. Create `internal/base/trading/uniswap_api_test.go`:
   - Test request construction (correct headers, body format)
   - Test response parsing for each endpoint
   - Test error handling (401, 403, 500, timeout)

6. Load API key from environment:
   ```go
   apiKey := os.Getenv("UNISWAP_API_KEY")
   ```

Reference: Uniswap skill docs at `.agents/skills/swap-integration/SKILL.md` and integration doc at `workflow/explore/synthesis/uniswap-integration.md`

## Done When

- [ ] All requirements met
- [ ] `uniswap_api.go` compiles without errors
- [ ] Unit tests pass for request/response handling
- [ ] Test quote request against live API returns valid routing data