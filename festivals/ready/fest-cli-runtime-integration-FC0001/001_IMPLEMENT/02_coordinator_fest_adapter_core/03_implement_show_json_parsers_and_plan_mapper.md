---
fest_type: task
fest_id: 03_implement_show_json_parsers_and_plan_mapper.md
fest_name: implement_show_json_parsers_and_plan_mapper
fest_parent: 02_coordinator_fest_adapter_core
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.945638-07:00
fest_tracking: true
---

# Task: Implement Show JSON Parsers And Plan Mapper

## Objective
Parse roadmap JSON from fest and map it to coordinator runtime plan types.

## Requirements

- [ ] Parse `fest show --festival <selector> --json --roadmap` into internal structs.
- [ ] Normalize task status values.
- [ ] Map parsed roadmap into `internal/coordinator.Plan`.
- [ ] Build canonical festival progress snapshot model for downstream event publishing.

## Implementation

1. Confirm context:
```bash
cgo agent-coordinator
fest link .
```

2. Add/extend protocol structs in:
- `internal/festival/protocol.go`
- `internal/festival/messages.go`

Minimum parsed fields:
- `festival.metadata_id`
- `festival.metadata_name`
- `festival.stats.progress`
- `roadmap.phases[].name`
- `roadmap.phases[].sequences[].name`
- `roadmap.phases[].sequences[].steps[].tasks[]`
  - `name`
  - `status`
  - `is_gate`

3. Implement parser function in `internal/festival/reader.go`:
- input: selector
- command:
```bash
fest show --festival "$selector" --json --roadmap
```
- output:
  - `coordinator.Plan`
  - `FestivalProgressSnapshot` (internal struct)

4. Status normalization rules:
- `in_progress` -> `active`
- `completed`/`done` -> `completed`
- `blocked` -> `blocked`
- unknown -> `pending`

5. Mapping rules:
- skip gate tasks when generating executable task assignments (or mark as gate tasks based on coordinator conventions).
- preserve deterministic task ordering by phase->sequence->step->task number.

## Done When

- [ ] All requirements met
- [ ] Parser produces non-empty plan for a known selector
- [ ] Mapping is deterministic and stable across repeated runs
