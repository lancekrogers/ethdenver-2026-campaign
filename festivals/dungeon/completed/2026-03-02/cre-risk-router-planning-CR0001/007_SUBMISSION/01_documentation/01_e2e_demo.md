---
fest_type: task
fest_id: 01_e2e_demo.md
fest_name: e2e demo
fest_parent: 01_documentation
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:45:12.214666-07:00
fest_updated: 2026-03-02T01:16:51.206666-07:00
fest_tracking: true
---


# Task: e2e demo

## Objective

Create `demo/e2e.sh` that curls the HTTP trigger with a coordinator-format payload (matching agent IDs, task ID format) and captures the on-chain receipt.

## Requirements

- [ ] Script sends a `RiskRequest` matching the exact format `agent-coordinator` would produce (Req P0.18)
- [ ] Uses real agent IDs and task ID format from the agent economy
- [ ] Captures the `RiskDecision` response
- [ ] Documents the on-chain receipt (tx hash)

## Implementation

1. **Create `demo/e2e.sh`**:

   ```bash
   #!/bin/bash
   # CRE Risk Router - End-to-End Integration Demo
   # Demonstrates the integration path between agent-coordinator and CRE Risk Router

   ENDPOINT="http://localhost:8080/evaluate-risk"  # CRE HTTP trigger endpoint

   echo "=== CRE Risk Router E2E Demo ==="
   echo "Sending risk evaluation request..."

   curl -s -X POST "$ENDPOINT" \
     -H "Content-Type: application/json" \
     -d '{
       "agent_id": "agent-inference-hedera-001",
       "task_id": "task-eval-20260301-001",
       "signal": "buy",
       "signal_confidence": 0.85,
       "risk_score": 10,
       "market_pair": "ETH/USD",
       "requested_position_usd": 1000,
       "timestamp": '"$(date +%s)"'
     }' | jq .

   echo ""
   echo "=== Check block explorer for on-chain receipt ==="
   ```

2. **Make executable**: `chmod +x demo/e2e.sh`

3. **Note**: The exact endpoint URL depends on how CRE exposes HTTP triggers in simulation. Adjust after Phase 004 simulation testing.

## Done When

- [ ] All requirements met
- [ ] Script uses coordinator-format payload with real agent IDs
- [ ] Script is executable and self-documenting