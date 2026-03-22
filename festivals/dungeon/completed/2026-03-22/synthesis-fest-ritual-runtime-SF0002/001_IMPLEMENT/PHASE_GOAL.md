---
fest_type: phase
fest_id: 001_IMPLEMENT
fest_name: IMPLEMENT
fest_parent: synthesis-fest-ritual-runtime-SF0002
fest_order: 1
fest_status: completed
fest_created: 2026-03-18T07:25:57.507827-06:00
fest_updated: 2026-03-19T03:31:39.441478-06:00
fest_phase_type: implementation
fest_tracking: true
---


# Phase Goal: 001_IMPLEMENT

**Phase:** 001_IMPLEMENT | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Deliver the runtime integration that makes the OBEY Vault Agent execute a real ritual through `fest` and a real daemon-backed `obey` session before any trade decision is allowed through.

**Context:** The design already exists in `workflow/design/2026-03-18-synthesis-fest-ritual-runtime/README.md`. This phase turns that design into executable code and campaign artifacts that can be shown to Synthesis judges immediately.

## Required Outcomes

Deliverables this phase must produce:

- [ ] A hardened ritual template that guarantees `decision.json` and `agent_log_entry.json` for both `GO` and `NO_GO` paths.
- [ ] A thin `fest` runtime bridge in `projects/agent-defi` that creates ritual runs and resolves artifacts without reimplementing fest logic.
- [ ] A daemon-backed `obey` integration that creates real sessions with dynamic festival IDs and `--workdir`.
- [ ] A ritual-backed decision loop and refreshed `agent_log.json` evidence pipeline.
- [ ] End-to-end validation proving at least three real runtime-driven cycles.

## Quality Standards

Quality criteria for all work in this phase:

- [ ] Runtime behavior must fail closed on missing binaries, invalid campaign root, or daemon/session failures.
- [ ] Code and ritual updates must preserve a single campaign-root source of truth for ritual templates and artifacts.
- [ ] Sequence outputs must be specific enough that an agent can execute them through `fest next` without guessing.

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_ritual_contract | Make the ritual template safe for unattended agent execution | Updated ritual workflow and explicit artifact contract |
| 02_fest_runtime_bridge | Create the thin runtime bridge around the real `fest` CLI | `internal/festruntime/` or equivalent bridge code |
| 03_obey_daemon_runtime | Extend runtime session management to real daemon-backed `obey` execution | Dynamic session creation with `--workdir`, provider/model logging, and fail-closed checks |
| 04_ritual_decision_loop | Gate vault decisions on ritual output | Runner flow that requires parsed ritual results before trade execution |
| 05_artifact_aggregation | Keep Protocol Labs evidence current | Refactored or wrapped loggen path and refreshed aggregate logs |
| 06_end_to_end_verification | Prove the system works live | Three or more runtime-driven ritual runs and demo-ready evidence |

## Pre-Phase Checklist

Before starting implementation:

- [x] Planning/design decisions documented
- [x] Runtime constraints documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_ritual_contract
- [ ] 02_fest_runtime_bridge
- [ ] 03_obey_daemon_runtime
- [ ] 04_ritual_decision_loop
- [ ] 05_artifact_aggregation
- [ ] 06_end_to_end_verification

## Notes

- The runtime must use the actual `fest` binary and the actual `obey` daemon runtime.
- No duplicate `festivals/` workspace is allowed inside `projects/agent-defi`.
- The daemon-backed, non-deterministic execution claim must be provable in logs and demo steps, not just implied by code structure.