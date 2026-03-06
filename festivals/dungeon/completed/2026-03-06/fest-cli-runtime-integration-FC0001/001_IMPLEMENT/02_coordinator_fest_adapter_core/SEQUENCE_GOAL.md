---
fest_type: sequence
fest_id: 02_coordinator_fest_adapter_core
fest_name: coordinator_fest_adapter_core
fest_parent: 001_IMPLEMENT
fest_order: 2
fest_status: completed
fest_created: 2026-03-06T13:39:52.066481-07:00
fest_updated: 2026-03-06T15:36:50.598081-07:00
fest_tracking: true
---


# Sequence Goal: 02_coordinator_fest_adapter_core

**Sequence:** 02_coordinator_fest_adapter_core | **Phase:** 001_IMPLEMENT | **Status:** Pending

## Sequence Objective

**Primary Goal:** Implement the coordinator-side fest adapter, selector resolution, and core JSON parsing/mapping.

**Contribution to Phase Goal:** Replaces static planning assumptions with real fest runtime data.

## Success Criteria

- [ ] Coordinator can execute required fest commands and parse outputs.
- [ ] Selector resolution behaves correctly across status buckets.
- [ ] Parsed data maps to coordinator plan model.
- [ ] Adapter unit tests cover success and failure paths.

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_switch_to_agent_coordinator_and_link_festival | Navigate/link to coordinator project | Enforces project-switch protocol |
| 02_implement_fest_command_executor_and_selector | Build command executor and selector resolution | Enables runtime command integration |
| 03_implement_show_json_parsers_and_plan_mapper | Parse `show` JSON and map to plan types | Converts fest output to executable state |
| 04_add_adapter_tests_with_recorded_fixtures | Add fixture-based tests for parser/mapper | Ensures integration correctness |

Quality gate tasks `05_testing`, `06_review`, `07_iterate`, `08_fest_commit` are required.