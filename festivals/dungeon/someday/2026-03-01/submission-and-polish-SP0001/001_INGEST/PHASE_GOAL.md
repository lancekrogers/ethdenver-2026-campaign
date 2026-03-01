---
fest_type: phase
fest_id: 001_INGEST
fest_name: INGEST
fest_parent: submission-and-polish-SP0001
fest_order: 1
fest_status: pending
fest_created: 2026-02-18T13:41:01.439862-07:00
fest_phase_type: ingest
fest_tracking: true
---

# Phase Goal: 001_INGEST

**Phase:** 001_INGEST | **Status:** Pending | **Type:** Ingest

## Phase Objective

**Primary Goal:** Gather and inventory all artifacts, build outputs, deployment records, and documentation from festivals 1-4 to establish the ground truth for what exists and what is missing before submission.

**Context:** Festivals 1-4 (chain-agents, dashboard, hedera-foundation, hiero-plugin) each produced code, documentation, and deployment artifacts. This ingest phase collects everything into a single view so the planning phase can define precise submission checklists per bounty track without guessing at completeness.

## Input Sources

Place all raw input materials in `input_specs/`:

- [ ] Festival 1 (chain-agents-CA0001) outputs: agent code, tests, deployment scripts
- [ ] Festival 2 (dashboard-DA0001) outputs: dashboard code, deployment config, UI state
- [ ] Festival 3 (hedera-foundation-HF0001) outputs: smart contracts, HCS integration, testnet records
- [ ] Festival 4 (hiero-plugin-HP0001) outputs: plugin code, PR draft, plugin documentation
- [ ] Existing READMEs and documentation across all six projects
- [ ] Testnet deployment records and wallet/account state
- [ ] Bounty track requirements from ETHDenver submission portal
- [ ] Any existing demo scripts, architecture diagrams, or video drafts

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

- [ ] All input sources reviewed and understood
- [ ] Output specs created following standard structure
- [ ] User has approved the structured output
- [ ] No unresolved questions or ambiguities

## Workflow

This phase uses step-based workflow guidance. See `WORKFLOW.md` for the step-by-step process.

Use `fest next` to see the current step.
Use `fest workflow advance` to move to the next step.

## Notes

- If any festival (1-4) is not yet complete, document its current state and flag remaining work as a blocker for the planning phase.
- Bounty track requirements should be pulled directly from the ETHDenver submission portal to ensure nothing is missed.
- Pay special attention to artifacts that are project-internal (e.g., test results) vs. submission-facing (e.g., READMEs, architecture docs) -- both matter but for different reasons.

---

*Ingest phases transform unstructured input into structured specifications ready for planning.*
