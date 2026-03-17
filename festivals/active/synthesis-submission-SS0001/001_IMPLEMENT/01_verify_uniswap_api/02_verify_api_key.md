---
fest_type: task
fest_id: 02_verify_api_key.md
fest_name: verify api key
fest_parent: 01_verify_uniswap_api
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-16T21:39:45.052002-06:00
fest_tracking: true
---

# Task: Verify Uniswap API Key and Developer Platform Routing

## Objective

Confirm that the Uniswap Developer Platform API key is valid and that swap requests route through trade-api.gateway.uniswap.org.

## Requirements

- [ ] Locate the API key configuration (env var, config file, or hardcoded)
- [ ] Test the API key with a quote request to the Developer Platform endpoint
- [ ] Confirm the response contains valid routing data (not a 401/403)

## Implementation

1. Search agent-defi for the API key: check `.env`, config files, and code for `UNISWAP_API_KEY`, `X-API-KEY`, or `trade-api.gateway.uniswap.org`
2. Make a test quote request:
   - Endpoint: `https://trade-api.gateway.uniswap.org/v1/quote`
   - Header: `x-api-key: <key>`
   - Body: USDC -> WETH, 10 USDC, chainId 8453 (Base)
3. Inspect the response:
   - 200 with routing data = API key valid, Developer Platform confirmed
   - 401/403 = key invalid or expired (blocker)
   - Connection error = wrong endpoint (investigate)
4. If API key is invalid, document as a blocker and determine if a new key can be obtained before deadline

## Done When

- [ ] All requirements met
- [ ] API key location documented
- [ ] Test quote request executed with response documented
- [ ] Go/no-go for Uniswap bounty API requirement determined
