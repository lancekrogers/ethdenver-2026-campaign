---
fest_type: phase
fest_id: 001_INGEST
fest_name: INGEST
fest_parent: cre-risk-router-planning-CR0001
fest_order: 1
fest_status: complete
fest_created: 2026-03-01T15:45:41.937013-07:00
fest_phase_type: ingest
fest_tracking: true
---

# Phase Goal: 001_INGEST

**Phase:** 001_INGEST | **Status:** Complete | **Type:** Ingest

## Phase Objective

**Primary Goal:** Ingest CRE Risk Router spec and produce structured planning outputs

**Context:** The full product spec was authored at `workflow/design/cre-risk-router/spec.md` after multiple rounds of review between Claude and Codex agents. The structured outputs feed directly into the 002_PLAN phase to decompose requirements into an implementation festival.

## Input Sources

Place all raw input materials in `input_specs/`:

- [x] `workflow/design/cre-risk-router/spec.md` — Full CRE Risk Router product spec (source of truth)
- [x] `workflow/design/chainlink/claude/` — 7 Chainlink CRE design documents (reference material)
- [x] `workflow/design/cre-risk-router/agent-thread.md` — Spec review thread with Codex findings and fixes

## Expected Outputs

The following structured documents will be created in `output_specs/`:

| Output | Purpose |
|--------|---------|
| `purpose.md` | Festival purpose, success criteria, motivation |
| `requirements.md` | Prioritized requirements (P0/P1/P2) with traceability |
| `constraints.md` | Technical and process constraints |
| `context.md` | Prior art, related systems, key references |

## Success Criteria

This ingest phase is complete when:

- [x] All input sources reviewed and understood
- [x] Output specs created following standard structure
- [x] User has approved the structured output
- [x] No unresolved questions or ambiguities

## Workflow

This phase uses step-based workflow guidance. See `WORKFLOW.md` for the step-by-step process.

Use `fest next` to see the current step.
Use `fest workflow advance` to move to the next step.

## Notes

- Spec went through 3 rounds of inter-agent review (claude/codex) before ingest
- All blockers from Codex review resolved: 8-decimal precision standardized, MaxPositionBps wired into Gate 6
- Full spec copied to `output_specs/spec.md` for downstream reference

---

*Ingest phases transform unstructured input into structured specifications ready for planning.*