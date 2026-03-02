---
fest_type: task
fest_id: 01_types.md
fest_name: types
fest_parent: 01_types_and_helpers
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:43:52.796994-07:00
fest_updated: 2026-03-02T00:58:27.706104-07:00
fest_tracking: true
---


# Task: types

## Objective

Define all data types (`RiskRequest`, `RiskDecision`, `MarketData`, `Config`) in `types.go` per spec Section 5, with correct field types, JSON tags, and 8-decimal precision on `ChainlinkPrice`.

## Requirements

- [ ] `RiskRequest` struct with all 8 fields and JSON tags matching spec (Req P0.5-P0.10)
- [ ] `RiskDecision` struct with all 9 fields, `ChainlinkPrice` as uint64 with 8-decimal precision
- [ ] `MarketData` struct with 4 fields matching CoinGecko API response format
- [ ] `Config` struct with all 15 fields and correct default annotations

## Implementation

1. **Create `types.go`** in `projects/cre-risk-router/`:

   - `RiskRequest`: AgentID (string), TaskID (string), Signal (string, buy|sell|hold), SignalConfidence (float64, 0.0-1.0), RiskScore (int, 0-100), MarketPair (string), RequestedPosition (float64), Timestamp (int64, Unix seconds)
   - `RiskDecision`: RunID ([32]byte), DecisionHash ([32]byte), Approved (bool), MaxPositionUSD (uint64), MaxSlippageBps (uint64), TTLSeconds (uint64), Reason (string), ChainlinkPrice (uint64, 8 decimals), Timestamp (int64)
   - `MarketData`: Price (float64, json:"current_price"), Volume24h (float64, json:"total_volume"), Volatility24h (float64, json:"price_change_percentage_24h"), MarketCap (float64, json:"market_cap")
   - `Config`: All 15 fields from spec Section 5 with json tags

2. **Ensure JSON tags** match the exact field names from the spec.

3. **Verify compilation**: `go build ./...`

## Done When

- [ ] All requirements met
- [ ] All 4 structs defined with correct fields, types, and JSON tags
- [ ] `go build` succeeds without errors