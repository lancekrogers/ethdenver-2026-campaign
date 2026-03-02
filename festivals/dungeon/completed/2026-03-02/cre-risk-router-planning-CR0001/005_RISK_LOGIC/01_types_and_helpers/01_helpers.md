---
fest_type: task
fest_id: 01_helpers.md
fest_name: helpers
fest_parent: 01_types_and_helpers
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:43:52.814598-07:00
fest_updated: 2026-03-02T00:58:27.688902-07:00
fest_tracking: true
---


# Task: helpers

## Objective

Implement utility functions in `helpers.go`: `generateRunID()`, `hashDecision()`, `calculateSlippage()`, `toFeedDecimals()`, and `clamp()`.

## Requirements

- [ ] `generateRunID(taskID, agentID string, runtime cre.Runtime) [32]byte` -- keccak256 of task_id + agent_id + runtime.Now().UnixNano() + runtime.Rand() (Req P0.11)
- [ ] `hashDecision(decision RiskDecision) [32]byte` -- keccak256 of all decision fields
- [ ] `calculateSlippage(volatility float64) uint64` -- slippage in BPS based on volatility
- [ ] `toFeedDecimals(price float64, decimals int) uint64` -- converts float price to integer with specified decimal precision (default 8)
- [ ] `clamp(value, min, max float64) float64` -- bounds value to [min, max] range

## Implementation

1. **Create `helpers.go`** in `projects/cre-risk-router/`.

2. **`generateRunID`**: Concatenate taskID, agentID, runtime.Now().UnixNano() as string, and runtime.Rand() bytes, then keccak256 hash the concatenation. Uses CRE's deterministic randomness to avoid collisions under retries.

3. **`hashDecision`**: Serialize all RiskDecision fields (RunID, Approved, MaxPositionUSD, MaxSlippageBps, TTLSeconds, Reason, ChainlinkPrice, Timestamp) into a byte buffer and keccak256 hash.

4. **`toFeedDecimals`**: `return uint64(math.Round(price * math.Pow(10, float64(decimals))))`. At 8 decimals, uint64 supports prices up to ~184 billion.

5. **`clamp`**: Standard clamp: if value < min return min, if value > max return max, else return value.

6. **`calculateSlippage`**: Base slippage BPS adjusted by volatility. Exact formula to be determined during implementation.

7. **Verify compilation**: `go build ./...`

## Done When

- [ ] All requirements met
- [ ] All 5 helper functions implemented and compiling
- [ ] `toFeedDecimals` correctly handles 8-decimal precision conversion
- [ ] `clamp` correctly bounds values to specified range