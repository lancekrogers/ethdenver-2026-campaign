# Festival Rules: agent-market-research

## Purpose

This is a **ritual festival** — a repeatable process designed to run on every trading cycle. Rules are lightweight compared to implementation festivals. The focus is on data validity, decision quality, and audit trail completeness.

## Ritual-Specific Rules

### Data Integrity

- All market data must come from real sources (no mocks, no synthetic data)
- Every data point must be timestamped
- If a data source fails, flag it in data_quality.md — do NOT substitute fake data
- Stale data (> 5 minutes old) must be flagged, not silently used

### Decision Quality

- Decisions must be binary: GO or NO_GO — never "maybe" or "uncertain"
- Rationale must reference specific numbers from research findings
- "Market looks good" is not acceptable rationale — cite the deviation %, confidence score, gate results
- A NO_GO decision is equally valuable as GO — it proves judgment

### Audit Trail

- Every ritual execution produces dated artifacts in `results/`
- Artifacts become immutable after `results/ritual_complete.md` is written for the run
- Output format is JSON for machine readability
- Each execution generates an `agent_log_entry.json` for Protocol Labs submission

### Execution Speed

- This ritual should complete in seconds, not minutes
- Ingest: query APIs and chain state (< 10 seconds)
- Research: compute over ingested data (< 5 seconds)
- Decide: synthesize and output (< 2 seconds)
- If execution is slow, the bottleneck is a bug, not complexity

## Quality Gates

Quality gates for rituals are lighter than implementation festivals:

- Quality gates focus on decision validity and rationale auditability
- **At most one bounded correction pass** — if validation or rationale review fails, the agent may fix the run once inside `results/` before finalization
- **Data validity gate** — all data sources responded, data is fresh, no nulls
- **Decision completeness gate** — all required fields present in decision.json
- If the run remains ambiguous after one correction pass, default to `NO_GO` with a machine-readable blocking factor instead of waiting for a human

## What This Ritual Does NOT Do

- Modify code (that's an implementation festival)
- Execute trades (that's the downstream planning/execution phase)
- Change strategy parameters (that requires human approval)
- Store state between runs (each execution is independent)
