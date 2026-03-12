---
fest_type: phase
fest_id: 001_INGEST
fest_name: INGEST
fest_parent: grant-submissions-GS0003
fest_order: 1
fest_status: pending
fest_created: 2026-03-11T04:59:40.7461-06:00
fest_phase_type: ingest
fest_tracking: true
---

# Phase Goal: 001_INGEST

**Phase:** 001_INGEST | **Status:** Pending | **Type:** Ingest

## Phase Objective

**Primary Goal:** Ingest and structure input materials into actionable specifications

**Context:** Research and content has already been created in workflow/explore/grant-research/2026-03-11/. This phase links that work into the festival structure and validates completeness.

## Input Sources

Place all raw input materials in `input_specs/`:

- [x] Grant opportunities research (workflow/explore/grant-research/2026-03-11/grant-opportunities.md)
- [x] Odds assessment (workflow/explore/grant-research/2026-03-11/odds-assessment.md)
- [x] 0G evidence gaps audit (workflow/explore/grant-research/2026-03-11/0g/evidence-gaps.md)
- [x] 0G hall post content (workflow/explore/grant-research/2026-03-11/0g/hall-post.md)
- [x] 0G step-by-step guide (workflow/explore/grant-research/2026-03-11/0g/step-by-step-submission.md)
- [x] Base evidence gaps audit (workflow/explore/grant-research/2026-03-11/base/evidence-gaps.md)
- [x] Base self-nomination content (workflow/explore/grant-research/2026-03-11/base/self-nomination.md)
- [x] Base social post content (workflow/explore/grant-research/2026-03-11/base/social-post.md)
- [x] Base step-by-step guide (workflow/explore/grant-research/2026-03-11/base/step-by-step-submission.md)
- [x] Compute metrics report (projects/agent-inference/docs/compute-metrics.md)
- [x] CRE submission evidence (projects/cre-risk-router/submission/moltbook-draft.md)

## Expected Outputs

The following structured documents will be created in `output_specs/`:

| Output | Purpose |
|--------|---------|
| `purpose.md` | Festival purpose: secure 0G and Base grant funding |
| `requirements.md` | What each grant requires for submission (evidence, repos, posts) |
| `constraints.md` | Blockers: no 0G tx evidence, private repos, no social presence |
| `context.md` | Competitive landscape: 1,045 0G applicants, 14.5% acceptance rate |

## Success Criteria

This ingest phase is complete when:

- [x] All input sources reviewed and understood
- [x] Evidence gaps identified for both chains
- [ ] Output specs created following standard structure
- [ ] No unresolved questions or ambiguities

## Notes

Most ingest work was done during the research phase. This phase primarily validates and structures what already exists.
