---
fest_type: task
fest_id: 03_run_research_ritual
fest_parent: 02_protocol_labs_artifacts
fest_order: 3
fest_status: pending
fest_autonomy: high
fest_tracking: true
---

# Task: Execute Market Research Ritual

## Objective

Run the `agent-market-research-RI-AM0001` ritual 3+ times against live market data to generate the structured decision artifacts that feed into `agent_log.json`.

## Requirements

- [ ] Ritual copied to active via `fest ritual run`
- [ ] Execute 3+ ritual runs producing a mix of GO and NO_GO decisions
- [ ] Each run generates `decision.json` and `agent_log_entry.json`
- [ ] All runs use real market data (no mocks)

## Implementation

1. Copy the ritual to active for execution:
   ```bash
   fest ritual run agent-market-research-RI-AM0001
   ```
   This creates a run copy in `festivals/active/` with an auto-incremented hex counter (e.g., `-0001`)

2. Navigate to the active run and execute it:
   ```bash
   fest next
   ```
   Follow the `fest next` loop — it will walk through each phase:
   - **001_INGEST:** Query Uniswap V3 pool state, collect price history, get volume/volatility, query vault state
   - **002_RESEARCH:** Compute moving average, calculate deviation, run CRE 8-gate evaluation, score opportunity
   - **003_DECIDE:** Aggregate findings, produce GO/NO_GO decision, generate log entry, validate, review rationale, iterate if needed

3. After the run completes, the ritual produces:
   - `003_DECIDE/01_synthesize_decision/results/decision.json`
   - `003_DECIDE/01_synthesize_decision/results/agent_log_entry.json`

4. Repeat 2 more times:
   ```bash
   fest ritual run agent-market-research-RI-AM0001
   fest next
   # ... execute through all phases
   ```
   Each run gets a new hex counter (-0002, -0003, etc.)

5. Collect all `agent_log_entry.json` files from completed runs for the next task (04_generate_agent_log)

6. Completed ritual runs move to `festivals/dungeon/completed/` automatically

## Why 3+ Runs

- Protocol Labs judges want to see the full autonomous loop executed multiple times
- A mix of GO and NO_GO decisions shows the agent exercises judgment, not just blind execution
- Multiple runs with different market conditions demonstrate the research ritual handles real variability
- Each run's artifacts become entries in the final `agent_log.json`

## Done When

- [ ] 3+ ritual runs completed
- [ ] At least 1 GO decision and at least 1 NO_GO decision produced
- [ ] All `decision.json` and `agent_log_entry.json` files collected
- [ ] All runs used real market data (verify timestamps in output)
