# Runtime Gap Analysis

This note compares the current ritual template to the runtime contract in `workflow/design/2026-03-18-synthesis-fest-ritual-runtime/README.md`.

## Verified Current State

- `fest validate festivals/ritual/agent-market-research-RI-AM0001` passes structural validation.
- `fest ritual run agent-market-research-RI-AM0001 --json` creates active runs under `festivals/active/agent-market-research-RI-AM0001-<hex>/`.
- The active run layout already includes `003_DECIDE/01_synthesize_decision/results/`, so the runtime can target a stable run-local results directory.

## Blocking Gaps For A Daemon-Backed `fest next` Loop

### 1. Ingest docs still describe a human approval workflow

Why this blocks runtime use:
The runtime contract requires unattended execution inside a live ritual run. The ingest template still says the agent will "present for your approval" and that all output documents require user approval before phase completion.

Files to update:
- `001_INGEST/input_specs/README.md`
- `001_INGEST/output_specs/README.md`

Required fix:
- Replace planner-template approval language with ritual-runtime instructions.
- Name the actual ingest artifacts the ritual must produce on every run.

### 2. Output paths are not explicit enough in the ingest phase

Why this blocks runtime use:
The runtime needs deterministic artifact locations. `market_snapshot.json`, `price_history.json`, and `data_quality.md` are mentioned, but not all steps name the exact run-local path.

Files to update:
- `001_INGEST/WORKFLOW.md`
- `002_RESEARCH/PHASE_GOAL.md`

Required fix:
- Use explicit relative paths under the run directory:
  - `001_INGEST/output_specs/market_snapshot.json`
  - `001_INGEST/output_specs/price_history.json`
  - `001_INGEST/output_specs/data_quality.md`

### 3. The decision contract is internally inconsistent for `NO_GO`

Why this blocks runtime use:
`003_DECIDE/PHASE_GOAL.md` defines the main `decision.json` schema, but the validation task requires a non-empty `blocking_factors` array for `NO_GO` outcomes and the schema does not currently define that field.

Files to update:
- `003_DECIDE/PHASE_GOAL.md`
- `003_DECIDE/01_synthesize_decision/02_produce_decision.md`
- `003_DECIDE/01_synthesize_decision/04_validate_decision.md`

Required fix:
- Extend the documented schema so both `GO` and `NO_GO` outputs are valid and deterministic.
- Make the `NO_GO` contract explicit instead of leaving validators and producers to infer it.

### 4. The final artifact destination is ambiguous

Why this blocks runtime use:
The runtime contract expects the ritual to finish with concrete files the Go runtime can resolve. Current instructions say to copy artifacts to the "ritual output directory" without naming it.

Files to update:
- `003_DECIDE/PHASE_GOAL.md`
- `003_DECIDE/01_synthesize_decision/03_generate_log_entry.md`
- `003_DECIDE/01_synthesize_decision/06_iterate_if_needed.md`
- `gates/implementation/QUALITY_GATE_ITERATE.md`

Required fix:
- State that the canonical outputs for each run are:
  - `003_DECIDE/01_synthesize_decision/results/decision.json`
  - `003_DECIDE/01_synthesize_decision/results/agent_log_entry.json`
  - `003_DECIDE/01_synthesize_decision/results/validation_result.md`
  - `003_DECIDE/01_synthesize_decision/results/rationale_review.md`
  - `003_DECIDE/01_synthesize_decision/results/ritual_complete.md`
- Remove any extra copy step unless a second explicit target path is truly required.

### 5. The log-entry task uses ambiguous write semantics

Why this blocks runtime use:
`03_generate_log_entry.md` says to "append to `results/agent_log_entry.json`". The runtime expects a single machine-readable file per ritual run, not an append-only stream with unclear shape.

Files to update:
- `003_DECIDE/01_synthesize_decision/03_generate_log_entry.md`

Required fix:
- Change the task to write exactly one JSON object to `results/agent_log_entry.json`.
- Keep the per-run history at the run-directory level, not inside one file.

### 6. The ritual's iterate guidance conflicts with its own rules

Why this blocks runtime use:
- `FESTIVAL_RULES.md` says rituals have no iterate step.
- `FESTIVAL_RULES.md` also says artifacts are immutable once written.
- `06_iterate_if_needed.md` and `QUALITY_GATE_ITERATE.md` allow rewriting `results/decision.json`.

Files to update:
- `FESTIVAL_RULES.md`
- `003_DECIDE/01_synthesize_decision/06_iterate_if_needed.md`
- `gates/implementation/QUALITY_GATE_ITERATE.md`

Required fix:
- Choose one contract and document it clearly.
- Preferred contract for runtime safety: allow at most one in-run correction pass before finalization, keep all edits inside `results/`, and define immutability as applying only after `ritual_complete.md` is written.

### 7. Fast-path `NO_GO` handling is underspecified

Why this blocks runtime use:
`002_RESEARCH/WORKFLOW.md` says several conditions skip directly to Step 5 with a `NO_GO` output, but Step 5 only packages research findings. The handoff from research fast paths to the final decision artifact is implied rather than explicit.

Files to update:
- `002_RESEARCH/WORKFLOW.md`
- `003_DECIDE/PHASE_GOAL.md`
- `003_DECIDE/01_synthesize_decision/01_aggregate_findings.md`
- `003_DECIDE/01_synthesize_decision/02_produce_decision.md`

Required fix:
- State that fast paths still produce full research outputs and then flow into the normal `003_DECIDE` artifact generation tasks.
- Preserve the same final `decision.json` and `agent_log_entry.json` contract for both `GO` and `NO_GO`.

## Non-Blocking But Important Gaps

### 8. The ritual does not document the exact tools list expected in the log entry

Why this matters:
The runtime contract and downstream `agent_log.json` aggregation benefit from stable tool naming.

Files to update:
- `003_DECIDE/01_synthesize_decision/03_generate_log_entry.md`

Required fix:
- Define canonical tool IDs for pool query, TWAP/oracle data, CRE gate evaluation, vault-state lookup, and any fallback source used.

### 9. The template does not name the active-run results path in top-level docs

Why this matters:
Top-level docs still talk about generic `results/` output, but the runtime resolves artifacts from an active ritual run.

Files to update:
- `FESTIVAL_GOAL.md`
- `FESTIVAL_OVERVIEW.md`
- `TODO.md`

Required fix:
- Reference `003_DECIDE/01_synthesize_decision/results/` directly when describing the ritual's final outputs.

## Recommended Order For Fixes

1. Fix ingest approval language and explicit ingest output paths.
2. Fix the `decision.json` and `agent_log_entry.json` contract, including `NO_GO` fields.
3. Fix the finalization and iterate rules so the run has one unambiguous terminal state.
4. Verify both `GO` and `NO_GO` paths by executing a real active run through `fest next`.
