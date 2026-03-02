---
fest_type: task
fest_id: 01_hcs_messages.md
fest_name: hcs messages
fest_parent: 02_agent_signals
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:46:02.442482-07:00
fest_tracking: true
---

# Task: hcs messages

## Objective

Define 3 new HCS (Hedera Consensus Service) message types for CRE risk events so that risk decisions, denials, and constraint enforcement are visible on the agent economy's shared message bus (Req P1.4).

## Requirements

- [ ] HCS message type `RiskCheckRequested` defined and emitted when coordinator sends a RiskRequest to CRE (Req P1.4)
- [ ] HCS message type `RiskCheckApproved` defined and emitted when CRE approves a trade (with constrained position if applicable)
- [ ] HCS message type `RiskCheckDenied` defined and emitted when CRE denies a trade (with deny reason)
- [ ] All 3 message types follow the existing HCS message schema conventions in the agent economy
- [ ] Messages include relevant fields: agent_id, task_id, run_id, timestamp, and type-specific data

## Implementation

1. **Locate the HCS message definitions** in the agent economy codebase:
   - Check `agent-coordinator` or a shared `pkg/hcs/` package for existing message types
   - Follow the same struct conventions and topic ID patterns

2. **Define the 3 new message types**:

   ```go
   package hcs

   // RiskCheckRequested is emitted when the coordinator sends a risk evaluation request to CRE.
   type RiskCheckRequested struct {
       Type               string  `json:"type"`                // "risk_check_requested"
       AgentID            string  `json:"agent_id"`
       TaskID             string  `json:"task_id"`
       Signal             string  `json:"signal"`
       SignalConfidence   float64 `json:"signal_confidence"`
       RiskScore          int     `json:"risk_score"`
       MarketPair         string  `json:"market_pair"`
       RequestedPositionUSD float64 `json:"requested_position_usd"`
       Timestamp          int64   `json:"timestamp"`
   }

   // RiskCheckApproved is emitted when CRE approves a trade for execution.
   type RiskCheckApproved struct {
       Type                   string  `json:"type"`              // "risk_check_approved"
       AgentID                string  `json:"agent_id"`
       TaskID                 string  `json:"task_id"`
       RunID                  string  `json:"run_id"`
       ConstrainedPositionUSD float64 `json:"constrained_position_usd"`
       TxHash                 string  `json:"tx_hash,omitempty"`
       Timestamp              int64   `json:"timestamp"`
   }

   // RiskCheckDenied is emitted when CRE denies a trade.
   type RiskCheckDenied struct {
       Type       string `json:"type"`         // "risk_check_denied"
       AgentID    string `json:"agent_id"`
       TaskID     string `json:"task_id"`
       RunID      string `json:"run_id"`
       DenyReason string `json:"deny_reason"`
       Gate       string `json:"gate"`          // Which gate triggered the denial
       Timestamp  int64  `json:"timestamp"`
   }
   ```

3. **Create constructor functions** for each message type:
   ```go
   func NewRiskCheckRequested(agentID, taskID, signal string, confidence float64, riskScore int, pair string, posUSD float64) RiskCheckRequested {
       return RiskCheckRequested{
           Type:               "risk_check_requested",
           AgentID:            agentID,
           TaskID:             taskID,
           Signal:             signal,
           SignalConfidence:   confidence,
           RiskScore:          riskScore,
           MarketPair:         pair,
           RequestedPositionUSD: posUSD,
           Timestamp:          time.Now().Unix(),
       }
   }

   func NewRiskCheckApproved(agentID, taskID, runID string, constrainedUSD float64, txHash string) RiskCheckApproved {
       return RiskCheckApproved{
           Type:                   "risk_check_approved",
           AgentID:                agentID,
           TaskID:                 taskID,
           RunID:                  runID,
           ConstrainedPositionUSD: constrainedUSD,
           TxHash:                 txHash,
           Timestamp:              time.Now().Unix(),
       }
   }

   func NewRiskCheckDenied(agentID, taskID, runID, denyReason, gate string) RiskCheckDenied {
       return RiskCheckDenied{
           Type:       "risk_check_denied",
           AgentID:    agentID,
           TaskID:     taskID,
           RunID:      runID,
           DenyReason: denyReason,
           Gate:       gate,
           Timestamp:  time.Now().Unix(),
       }
   }
   ```

4. **Emit messages from the coordinator** at the appropriate points:
   - `RiskCheckRequested`: Emit just before calling `creclient.EvaluateRisk()`
   - `RiskCheckApproved`: Emit when `decision.Approved == true`
   - `RiskCheckDenied`: Emit when `decision.Approved == false`
   ```go
   // In assign.go, within the CRE check block:
   hcs.Publish(ctx, hcs.NewRiskCheckRequested(agent.ID, task.ID, task.Signal, ...))

   decision, err := c.creClient.EvaluateRisk(ctx, req)
   // ... error handling ...

   if decision.Approved {
       hcs.Publish(ctx, hcs.NewRiskCheckApproved(agent.ID, task.ID, decision.RunID, decision.ConstrainedPositionUSD, decision.TxHash))
   } else {
       hcs.Publish(ctx, hcs.NewRiskCheckDenied(agent.ID, task.ID, decision.RunID, decision.DenyReason, ""))
   }
   ```

5. **Write tests**:
   - Test each constructor produces correctly typed and populated messages
   - Test JSON serialization matches expected HCS format
   - Test that all required fields are present
   - Test timestamp is set to a reasonable value

## Done When

- [ ] All requirements met
- [ ] 3 HCS message types defined with constructors
- [ ] Messages follow existing HCS schema conventions
- [ ] Emission points wired into coordinator's CRE check flow
- [ ] Tests verify message structure and serialization
