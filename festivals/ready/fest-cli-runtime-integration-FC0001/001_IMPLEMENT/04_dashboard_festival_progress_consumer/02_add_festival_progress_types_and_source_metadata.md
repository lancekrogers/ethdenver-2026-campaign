---
fest_type: task
fest_id: 02_add_festival_progress_types_and_source_metadata.md
fest_name: add_festival_progress_types_and_source_metadata
fest_parent: 04_dashboard_festival_progress_consumer
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.978398-07:00
fest_tracking: true
---

# Task: Add Festival Progress Types And Source Metadata

## Objective
Extend dashboard data contracts to include canonical `festival_progress` events and source metadata.

## Requirements

- [ ] Add `festival_progress` to supported daemon event types.
- [ ] Add typed payload interface for `festival_progress`.
- [ ] Include `source` metadata (`fest` or `synthetic`) in typed model.

## Implementation

1. Ensure context:
```bash
cgo dashboard
fest link .
fest link --show
```

2. Update type definitions:
- Target: `src/lib/data/types.ts`
- Add to event union:
```ts
| "festival_progress"
```
- Add payload interface with fields:
  - `version`
  - `source`
  - `selector`
  - `snapshot_time`
  - `festivalProgress`
  - optional `fallback_reason`

3. If needed, update hook return types to carry source metadata to panel layer.

4. Verify type-check/build:
```bash
npm run build
```

## Done When

- [ ] All requirements met
- [ ] TypeScript build passes with new event type and payload interfaces
