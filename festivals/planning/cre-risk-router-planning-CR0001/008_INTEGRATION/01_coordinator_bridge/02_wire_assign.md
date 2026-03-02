---
fest_type: task
fest_id: 01_wire_assign.md
fest_name: wire assign
fest_parent: 01_coordinator_bridge
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:45:49.028969-07:00
fest_tracking: true
---

# Task: wire assign

## Objective

Wire the CRE Risk Router client into `agent-coordinator`'s task assignment flow so that DeFi-related tasks are evaluated for risk before being assigned to agents (Req P1.2).

## Requirements

- [ ] `assign.go` (or equivalent task assignment handler) calls `creclient.EvaluateRisk()` before assigning DeFi tasks (Req P1.2)
- [ ] If the CRE Risk Router denies the request, the task is blocked with the deny reason logged
- [ ] If the CRE Risk Router approves with a constrained position, the constrained value is passed to the agent
- [ ] Non-DeFi tasks bypass the CRE check entirely
- [ ] CRE client failure (network error, timeout) does not crash the coordinator -- falls back to blocking the task with a logged warning

## Implementation

1. **Identify the task assignment entry point** in `agent-coordinator`:
   - Look for the function that assigns tasks to agents (likely in `internal/coordinator/assign.go` or similar)
   - This is where the CRE check needs to be inserted

2. **Add the CRE client to the coordinator**:
   ```go
   // In the coordinator struct or initialization
   type Coordinator struct {
       // ... existing fields
       creClient *creclient.Client  // CRE Risk Router client
   }

   // During initialization
   creEndpoint := os.Getenv("CRE_RISK_ROUTER_URL")
   if creEndpoint == "" {
       creEndpoint = "http://localhost:8080/evaluate-risk"
   }
   coord.creClient = creclient.New(creEndpoint, 10*time.Second)
   ```

3. **Add a DeFi task detection function**:
   ```go
   func isDeFiTask(task Task) bool {
       // Check task type, category, or agent type
       // DeFi tasks involve trade execution, position management, etc.
       return task.Category == "defi" || task.AgentType == "agent-defi"
   }
   ```

4. **Wire the CRE check into assignment**:
   ```go
   func (c *Coordinator) assignTask(ctx context.Context, task Task, agent Agent) error {
       // Only check DeFi tasks
       if isDeFiTask(task) && c.creClient != nil {
           decision, err := c.creClient.EvaluateRisk(ctx, creclient.RiskRequest{
               AgentID:              agent.ID,
               TaskID:               task.ID,
               Signal:               task.Signal,
               SignalConfidence:      task.SignalConfidence,
               RiskScore:            task.RiskScore,
               MarketPair:           task.MarketPair,
               RequestedPositionUSD: task.RequestedPositionUSD,
               Timestamp:            time.Now().Unix(),
           })
           if err != nil {
               // CRE failure should not crash coordinator -- block task with warning
               log.Warn("CRE risk check failed, blocking task", "task_id", task.ID, "error", err)
               return c.blockTask(ctx, task, "cre_check_failed: "+err.Error())
           }

           if !decision.Approved {
               log.Info("CRE denied task", "task_id", task.ID, "reason", decision.DenyReason)
               return c.blockTask(ctx, task, decision.DenyReason)
           }

           // Use constrained position if CRE adjusted it
           if decision.ConstrainedPositionUSD > 0 && decision.ConstrainedPositionUSD < task.RequestedPositionUSD {
               task.RequestedPositionUSD = decision.ConstrainedPositionUSD
               log.Info("CRE constrained position", "task_id", task.ID, "constrained_usd", decision.ConstrainedPositionUSD)
           }
       }

       // Proceed with normal assignment
       return c.doAssign(ctx, task, agent)
   }
   ```

5. **Add the blockTask helper**:
   ```go
   func (c *Coordinator) blockTask(ctx context.Context, task Task, reason string) error {
       task.Status = "blocked"
       task.BlockReason = reason
       return c.updateTask(ctx, task)
   }
   ```

6. **Write tests**:
   - Test DeFi task gets CRE check and is approved
   - Test DeFi task gets CRE check and is denied (task blocked)
   - Test DeFi task with constrained position
   - Test non-DeFi task bypasses CRE check
   - Test CRE client failure results in task blocked (not crash)

## Done When

- [ ] All requirements met
- [ ] DeFi tasks are evaluated by CRE before assignment
- [ ] Denied tasks are blocked with the deny reason from CRE
- [ ] Approved tasks proceed with any constrained position applied
- [ ] Non-DeFi tasks are unaffected
- [ ] CRE failures are handled gracefully without coordinator crash
