---
fest_type: task
fest_id: 01_http_trigger.md
fest_name: http trigger
fest_parent: 01_handlers
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:44:40.117016-07:00
fest_tracking: true
---

# Task: http trigger

## Objective

Implement the `onRiskEvaluation()` HTTP trigger handler that parses a `RiskRequest`, fetches market data, reads the Chainlink feed, evaluates risk, writes the receipt on-chain, and returns the `RiskDecision`.

## Requirements

- [ ] Parse `RiskRequest` from HTTP POST body (Req P0.13)
- [ ] Fetch market data from CoinGecko via CRE HTTP capability
- [ ] Read Chainlink price feed via CRE EVM read capability (`latestRoundData()`)
- [ ] Call `evaluateRisk()` with all collected data
- [ ] Write receipt on-chain via CRE EVM write capability (`recordDecision()`)
- [ ] Return `RiskDecision` as HTTP response

## Implementation

1. **In `workflow.go`**, implement `onRiskEvaluation`:
   - Parse `RiskRequest` from trigger event body
   - Use `runtime.HTTP().Fetch()` (or equivalent CRE API) to GET market data from `config.MarketDataURL`
   - Use `runtime.EVM().Read()` (or equivalent) to call `latestRoundData()` on `config.PriceFeedAddress`
   - Call `evaluateRisk(req, marketData, oracleData, config, runtime)`
   - Use `runtime.EVM().Write()` to call `recordDecision()` on `config.ReceiptContract`
   - Log gate results and final decision
   - Return `RiskDecision` as JSON response

2. **Register in `InitWorkflow()`**:
   ```go
   cre.NewHandler(httpTrigger("/evaluate-risk", "POST"), onRiskEvaluation)
   ```

3. **Handle external data failures gracefully** using fallback logic from Phase 003.

## Done When

- [ ] All requirements met
- [ ] Handler exercises 5 CRE capabilities: HTTP trigger, HTTP fetch, EVM read, EVM write, runtime
- [ ] Receipt is written on-chain for both approved and denied decisions
