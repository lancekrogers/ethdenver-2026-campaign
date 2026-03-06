---
fest_type: sequence
fest_id: 04_dashboard_festival_progress_consumer
fest_name: dashboard_festival_progress_consumer
fest_parent: 001_IMPLEMENT
fest_order: 4
fest_status: pending
fest_created: 2026-03-06T13:39:52.219244-07:00
fest_tracking: true
---

# Sequence Goal: 04_dashboard_festival_progress_consumer

**Sequence:** 04_dashboard_festival_progress_consumer | **Phase:** 001_IMPLEMENT | **Status:** Pending

## Sequence Objective

**Primary Goal:** Update dashboard to consume and render canonical festival progress events with source labeling.

**Contribution to Phase Goal:** Makes real fest integration visible in the primary demo surface.

## Success Criteria

- [ ] Dashboard types include `festival_progress` message support.
- [ ] Mirror node parsing prioritizes explicit progress events.
- [ ] Legacy payload compatibility remains intact.
- [ ] Festival panel shows source label (`fest` or `synthetic`) with tests.

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_switch_to_dashboard_and_link_festival | Navigate/link to dashboard project | Enforces project-switch protocol |
| 02_add_festival_progress_types_and_source_metadata | Update data types/contracts | Enables parsing of canonical payload |
| 03_prioritize_festival_progress_message_parsing | Adjust parsing path and compatibility behavior | Ensures real runtime source is preferred |
| 04_render_source_badge_and_add_component_tests | Show source in UI and add tests | Provides proof and reliability |

Quality gate tasks `05_testing`, `06_review`, `07_iterate`, `08_fest_commit` are required.
