---
fest_type: phase
fest_id: 001_IMPLEMENT
fest_name: IMPLEMENT
fest_parent: fest-cli-runtime-integration-FC0001
fest_order: 1
fest_status: pending
fest_created: 2026-03-06T13:36:57.746487-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 001_IMPLEMENT

**Phase:** 001_IMPLEMENT | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Implement and validate true runtime fest integration across campaign root, coordinator, and dashboard.

**Context:** This phase translates the design package in `workflow/design/fest-cli-integration/` into executable implementation tasks with strong mode contracts and demo/live evidence.

## Required Outcomes

- [ ] Coordinator uses `fest` CLI output as runtime plan/progress source.
- [ ] Dashboard Festival View can consume canonical `festival_progress` payloads.
- [ ] Root mode commands and preflight enforce live strictness and demo fallback behavior.
- [ ] Documentation and evidence workflow reflect real and fallback operation paths.

## Quality Standards

- [ ] Every project-change sequence begins with explicit `cgo <project-name>` and `fest link .` instructions.
- [ ] Parser and mapping logic is covered by tests.
- [ ] Live-mode preflight failures are actionable and deterministic.

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_campaign_root_mode_and_preflight | Add root just/preflight mode contracts for fest | Root command and validation gates |
| 02_coordinator_fest_adapter_core | Build fest adapter/parser and plan mapping | Coordinator fest adapter core |
| 03_coordinator_festival_progress_events | Publish canonical festival progress events | HCS `festival_progress` events |
| 04_dashboard_festival_progress_consumer | Consume and render canonical festival progress | Dashboard integration + source labels |
| 05_docs_demo_evidence_updates | Update runtime and demo documentation | Guides + README updates |
| 06_cross_project_validation_release | Run validation matrix and release checks | Evidence and release notes |

## Pre-Phase Checklist

- [x] Design package exists in `workflow/design/fest-cli-integration/`
- [ ] Sequence goals and task instructions finalized
- [ ] Required environment keys documented
- [ ] Validation commands defined

## Phase Progress

### Sequence Completion

- [ ] 01_campaign_root_mode_and_preflight
- [ ] 02_coordinator_fest_adapter_core
- [ ] 03_coordinator_festival_progress_events
- [ ] 04_dashboard_festival_progress_consumer
- [ ] 05_docs_demo_evidence_updates
- [ ] 06_cross_project_validation_release

## Notes

Project-switch protocol is mandatory at every repository boundary.
