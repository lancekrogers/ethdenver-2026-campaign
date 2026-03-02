---
fest_type: task
fest_id: 01_cron_trigger.md
fest_name: cron trigger
fest_parent: 01_handlers
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:44:40.137396-07:00
fest_updated: 2026-03-02T01:11:49.880364-07:00
fest_tracking: true
---


# Task: cron trigger

## Objective

Implement the `onScheduledSweep()` cron trigger handler that generates a synthetic `RiskRequest` with hardcoded realistic parameters and a fresh `runtime.Now()` timestamp, then runs the same pipeline as the HTTP handler.

## Requirements

- [ ] Generate synthetic `RiskRequest` with realistic parameters (Req P0.14)
- [ ] Use `runtime.Now()` for timestamp so Gate 3 (staleness) always passes in simulation
- [ ] Run same pipeline: fetch market data, read Chainlink feed, evaluate risk, write receipt
- [ ] Registered with cron trigger `*/5 * * * *`

## Implementation

1. **In `workflow.go`**, implement `onScheduledSweep`:
   - Construct synthetic `RiskRequest`:
     - AgentID: "agent-inference-001"
     - TaskID: "task-sweep-" + runtime timestamp
     - Signal: "buy"
     - SignalConfidence: 0.85
     - RiskScore: 10
     - MarketPair: "ETH/USD"
     - RequestedPosition: 1000.0
     - Timestamp: `runtime.Now().Unix()` (fresh, so Gate 3 always passes)
   - Run same data fetching and evaluation pipeline as HTTP handler
   - Write receipt on-chain
   - Log results

2. **Register in `InitWorkflow()`**:
   ```go
   cre.NewHandler(cronTrigger("*/5 * * * *"), onScheduledSweep)
   ```

3. **This handler exists so `cre workflow simulate` works** without an external HTTP client.

## Done When

- [ ] All requirements met
- [ ] Cron handler generates realistic synthetic request
- [ ] `runtime.Now()` used for timestamp (not system clock)
- [ ] Same pipeline as HTTP handler executed