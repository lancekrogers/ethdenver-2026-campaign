---
fest_type: task
fest_id: 01_dry_run.md
fest_name: dry run
fest_parent: 02_simulation
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:44:53.466741-07:00
fest_updated: 2026-03-02T01:13:04.493711-07:00
fest_tracking: true
---


# Task: dry run

## Objective

Run `cre workflow simulate .` on the complete CRE Risk Router workflow and verify the full pipeline executes without errors.

## Requirements

- [ ] `cre workflow simulate .` completes without errors (Req P0.15)
- [ ] Output shows: request parsed, market data fetched, Chainlink feed read, gates evaluated, decision produced
- [ ] No panics, crashes, or unhandled errors

## Implementation

1. **Run dry-run simulation**:
   ```bash
   cd projects/cre-risk-router && just simulate
   ```

2. **Verify output** shows the full pipeline:
   - Cron trigger fires
   - Market data fetched (or fallback activated)
   - Chainlink feed read (or denied path taken)
   - Gate evaluation results logged
   - Final decision (approved/denied) logged with reason

3. **If simulation fails**, debug:
   - Check for import errors, missing config fields, SDK API mismatches
   - Verify `config.json` has all required fields populated
   - Check network access for CoinGecko and testnet RPC
   - Review CRE simulation output for specific error messages

## Done When

- [ ] All requirements met
- [ ] `just simulate` completes without errors
- [ ] Full pipeline execution visible in output