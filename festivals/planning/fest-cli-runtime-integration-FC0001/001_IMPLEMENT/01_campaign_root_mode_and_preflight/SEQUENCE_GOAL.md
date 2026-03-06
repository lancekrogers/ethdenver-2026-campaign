---
fest_type: sequence
fest_id: 01_campaign_root_mode_and_preflight
fest_name: campaign_root_mode_and_preflight
fest_parent: 001_IMPLEMENT
fest_order: 1
fest_status: pending
fest_created: 2026-03-06T13:39:51.991935-07:00
fest_tracking: true
---

# Sequence Goal: 01_campaign_root_mode_and_preflight

**Sequence:** 01_campaign_root_mode_and_preflight | **Phase:** 001_IMPLEMENT | **Status:** Pending

## Sequence Objective

**Primary Goal:** Implement root-level mode and preflight behavior required for runtime fest integration.

**Contribution to Phase Goal:** Establishes fail-fast live behavior and deterministic demo fallback before project-specific code changes.

## Success Criteria

- [ ] Root just commands expose fest health/status workflows.
- [ ] Live preflight validates fest availability/selector/parse health.
- [ ] Demo mode allows synthetic fallback when fest is unavailable.
- [ ] Sequence starts with mandatory project-switch protocol.

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_switch_to_campaign_root_and_link_festival | Navigate via `cgo` and link festival to campaign root | Enforces project-switch protocol |
| 02_implement_root_fest_just_commands | Add root just command surface for fest runtime checks | Improves operator UX |
| 03_enforce_live_preflight_fest_gates | Add strict live preflight fest gates | Prevents silent misconfiguration |
| 04_verify_demo_fallback_live_failfast | Validate demo fallback and live fail-fast behavior | Confirms mode contract correctness |

Quality gate tasks `05_testing`, `06_review`, `07_iterate`, `08_fest_commit` are required.
