---
fest_type: task
fest_id: 01_dry_run_simulation.md
fest_name: dry run simulation
fest_parent: 01_cli_setup
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:42:44.259669-07:00
fest_tracking: true
---

# Task: dry run simulation

## Objective

Run `cre workflow simulate .` on the hello-world workflow and verify it passes without errors, validating the core CRE simulation pipeline.

## Requirements

- [ ] `cre workflow simulate .` executes without errors on the hello-world workflow (Req 0.4)
- [ ] Simulation output shows the logged string from the handler
- [ ] Any simulation requirements (network access, auth state) are documented

## Implementation

1. **Navigate to the hello-world workflow directory**:

   ```bash
   cd /tmp/cre-hello-world
   ```

2. **Run dry-run simulation**:

   ```bash
   cre workflow simulate .
   ```

3. **Analyze the output**:
   - Look for the "Hello from CRE Risk Router validation!" log line
   - Check for any errors or warnings
   - Note the simulation execution flow (trigger firing, handler invocation, completion)

4. **If simulation fails, debug**:
   - Check error messages for missing config, auth issues, or SDK version mismatches
   - Verify `config.json` has all required fields
   - Check if `cre workflow simulate` requires additional flags or environment
   - Try `cre workflow simulate --help` for available options
   - Consult CRE docs and hackathon skills repo for troubleshooting

5. **Document findings**:
   - Exact command and flags that work
   - What the simulation output looks like
   - Any prerequisites (auth state, network access, Go version)
   - Whether the cron trigger fires automatically in simulation or needs a flag

6. **GATE DECISION**: If this task fails after thorough debugging, **stop the entire festival and reassess the approach** before continuing. This is a hard gate per the implementation plan.

## Done When

- [ ] All requirements met
- [ ] `cre workflow simulate .` completes without errors
- [ ] Handler log output is visible in simulation results
- [ ] Simulation requirements documented
