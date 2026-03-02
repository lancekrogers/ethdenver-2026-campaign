---
fest_type: task
fest_id: 01_capture_logs.md
fest_name: capture logs
fest_parent: 02_evidence
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:45:22.141727-07:00
fest_tracking: true
---

# Task: capture logs

## Objective

Run simulation scenarios and capture execution logs with the tx hash clearly visible for inclusion in the Moltbook submission.

## Requirements

- [ ] Simulation logs captured from running scenarios (Req P0.20)
- [ ] Tx hash is clearly visible and labeled in the output
- [ ] Logs show gate evaluation results and final decision

## Implementation

1. **Run broadcast simulation** and capture output:
   ```bash
   cd projects/cre-risk-router
   just broadcast 2>&1 | tee evidence/simulation-output.log
   ```

2. **Verify the log** contains:
   - Gate evaluation results for each active gate
   - Final decision (approved/denied) with reason
   - Tx hash clearly labeled (e.g., "Transaction hash: 0x...")

3. **If tx hash is buried in output**, add a summary line at the end of the handler that explicitly prints:
   ```
   === SIMULATION RESULT ===
   Decision: approved/denied
   Reason: <reason>
   Tx Hash: 0x<hash>
   ```

4. **Save the log file** for inclusion in the Moltbook post evidence section.

## Done When

- [ ] All requirements met
- [ ] Logs captured with clearly visible tx hash
- [ ] Gate results and decision visible in output
