---
fest_type: task
fest_id: 01_defi_guard.md
fest_name: defi guard
fest_parent: 02_agent_signals
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:46:02.422918-07:00
fest_updated: 2026-03-02T01:24:55.533911-07:00
fest_tracking: true
---


# Task: defi guard

## Objective

Add a CRE constraint enforcement guard in `agent-defi` that respects the `constrained_position_usd` from the CRE Risk Router decision, preventing the agent from exceeding the approved position size (Req P1.4).

## Requirements

- [ ] `agent-defi` reads and enforces `constrained_position_usd` from the CRE RiskDecision (Req P1.4)
- [ ] If the assigned task includes a constrained position, the agent uses it instead of the original requested amount
- [ ] If the agent attempts to exceed the constrained position, the trade is blocked with a clear error
- [ ] Guard is applied before any trade execution logic
- [ ] Guard logs the constraint for audit trail

## Implementation

1. **Locate the trade execution entry point** in `agent-defi`:
   - Look for the function that receives a task from the coordinator and initiates trade execution
   - This is where the DeFi guard needs to be inserted (before the actual DEX/exchange interaction)

2. **Add constraint fields to the task input**:
   ```go
   type TradeTask struct {
       // ... existing fields
       ConstrainedPositionUSD float64 `json:"constrained_position_usd,omitempty"`
       CREApproved           bool    `json:"cre_approved"`
   }
   ```

3. **Create the DeFi guard** in `internal/guard/cre_guard.go`:
   ```go
   package guard

   import (
       "context"
       "fmt"
       "log/slog"
   )

   // CREGuard enforces position constraints from CRE Risk Router decisions.
   type CREGuard struct {
       logger *slog.Logger
   }

   func NewCREGuard(logger *slog.Logger) *CREGuard {
       return &CREGuard{logger: logger}
   }

   // EnforceConstraint checks that the proposed trade does not exceed the CRE-approved position.
   func (g *CREGuard) EnforceConstraint(ctx context.Context, task TradeTask) error {
       if err := ctx.Err(); err != nil {
           return fmt.Errorf("context cancelled before CRE guard: %w", err)
       }

       // If no CRE constraint was applied, allow the trade
       if task.ConstrainedPositionUSD <= 0 {
           g.logger.Info("no CRE constraint applied, proceeding",
               "task_id", task.ID,
               "requested_usd", task.RequestedPositionUSD,
           )
           return nil
       }

       // Enforce the constraint
       if task.RequestedPositionUSD > task.ConstrainedPositionUSD {
           g.logger.Warn("CRE constraint exceeded, using constrained value",
               "task_id", task.ID,
               "requested_usd", task.RequestedPositionUSD,
               "constrained_usd", task.ConstrainedPositionUSD,
           )
           task.RequestedPositionUSD = task.ConstrainedPositionUSD
       }

       g.logger.Info("CRE constraint enforced",
           "task_id", task.ID,
           "position_usd", task.RequestedPositionUSD,
           "constrained_usd", task.ConstrainedPositionUSD,
       )

       return nil
   }
   ```

4. **Wire the guard into trade execution**:
   ```go
   func (a *Agent) executeTrade(ctx context.Context, task TradeTask) error {
       // CRE guard -- enforce position constraint BEFORE any trade logic
       guard := guard.NewCREGuard(a.logger)
       if err := guard.EnforceConstraint(ctx, task); err != nil {
           return fmt.Errorf("CRE guard failed: %w", err)
       }

       // Proceed with trade at the (possibly constrained) position
       return a.doTrade(ctx, task)
   }
   ```

5. **Write tests**:
   - Test trade with no constraint proceeds normally
   - Test trade with constraint uses constrained value
   - Test trade exceeding constraint is clamped down
   - Test context cancellation is respected
   - Test logging output contains constraint information

## Done When

- [ ] All requirements met
- [ ] DeFi guard enforces CRE position constraints before trade execution
- [ ] Agent cannot exceed the constrained position size
- [ ] All constraint enforcement is logged for audit
- [ ] Tests pass with `go test ./internal/guard/...`