---
fest_type: task
fest_id: 01_debug_iterate.md
fest_name: debug iterate
fest_parent: 02_simulation
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:44:53.503945-07:00
fest_tracking: true
---

# Task: debug iterate

## Objective

Fix any simulation failures from dry-run or broadcast tasks and iterate until both modes are stable and reliable.

## Requirements

- [ ] Both `just simulate` and `just broadcast` pass reliably (Req P0.15-P0.16)
- [ ] No flaky failures from transient issues
- [ ] Output is clean and informative

## Implementation

1. **Review any failures** from dry-run and broadcast tasks.

2. **Common issues to check**:
   - CoinGecko rate limiting -- verify fallback path activates
   - Testnet RPC timeouts -- try alternative endpoints
   - Gas estimation failures -- use fixed gas limit
   - Config field mismatches -- verify all fields populated
   - SDK API changes -- compare against latest CRE SDK source

3. **For each failure**:
   - Identify root cause from error output
   - Apply fix
   - Re-run simulation to verify
   - Document the fix

4. **Run multiple times** to confirm stability.

5. **Add explicit log lines** for:
   - Each gate result (pass/deny with reason)
   - Final decision summary
   - Tx hash (clearly labeled for easy finding)

## Done When

- [ ] All requirements met
- [ ] Both dry-run and broadcast pass on consecutive runs
- [ ] Output clearly shows gate results and tx hash
