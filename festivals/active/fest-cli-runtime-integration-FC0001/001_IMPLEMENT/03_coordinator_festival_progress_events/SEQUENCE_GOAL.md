---
fest_type: sequence
fest_id: 03_coordinator_festival_progress_events
fest_name: coordinator_festival_progress_events
fest_parent: 001_IMPLEMENT
fest_order: 3
fest_status: completed
fest_created: 2026-03-06T13:39:52.154256-07:00
fest_updated: 2026-03-06T15:46:11.746675-07:00
fest_tracking: true
---


# Sequence Goal: 03_coordinator_festival_progress_events

**Sequence:** 03_coordinator_festival_progress_events | **Phase:** 001_IMPLEMENT | **Status:** Pending

## Sequence Objective

**Primary Goal:** Add canonical `festival_progress` event publishing from coordinator runtime.

**Contribution to Phase Goal:** Creates the runtime data bridge dashboard needs to visualize real fest state.

## Success Criteria

- [ ] HCS message type contract includes `festival_progress`.
- [ ] Coordinator periodically emits progress payload with source metadata.
- [ ] Fallback behavior is explicit (`fest` vs `synthetic` vs fail).
- [ ] Coordinator startup path uses provider selection logic.

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_switch_to_agent_coordinator_and_confirm_link | Reconfirm coordinator context/link before edits | Enforces project-switch protocol |
| 02_add_festival_progress_message_type_and_payload | Extend message contract for progress events | Defines canonical event format |
| 03_implement_periodic_progress_publisher_with_fallback | Publish snapshots on interval with fallback mode | Feeds runtime progress to observers |
| 04_wire_plan_provider_selection_in_main | Connect provider and publishing logic in startup flow | Activates runtime behavior |

Quality gate tasks `05_testing`, `06_review`, `07_iterate`, `08_fest_commit` are required.