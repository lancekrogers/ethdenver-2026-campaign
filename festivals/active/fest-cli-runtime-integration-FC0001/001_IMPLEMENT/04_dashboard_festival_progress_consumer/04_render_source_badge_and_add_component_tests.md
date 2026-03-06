---
fest_type: task
fest_id: 04_render_source_badge_and_add_component_tests.md
fest_name: render_source_badge_and_add_component_tests
fest_parent: 04_dashboard_festival_progress_consumer
fest_order: 4
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.978935-07:00
fest_updated: 2026-03-06T15:49:34.964372-07:00
fest_tracking: true
---


# Task: Render Source Badge And Add Component Tests

## Objective
Make festival data origin visible in the Festival View and add tests proving source-label behavior.

## Requirements

- [ ] Add source badge in Festival View (`fest` vs `synthetic`).
- [ ] Add/extend tests for source rendering and fallback state.
- [ ] Ensure panel remains functional when source metadata is absent.

## Implementation

1. Confirm context:
```bash
cgo dashboard
fest link .
```

2. Update panel component:
- Target: `src/components/panels/FestivalView.tsx`
- Add small source indicator near header text.
- Display examples:
  - `Source: fest`
  - `Source: synthetic (fallback)`

3. Update tests:
- Target: `src/components/panels/__tests__/FestivalView.test.tsx`
- Add cases:
  - renders `Source: fest`
  - renders fallback source label
  - handles missing source gracefully

4. Run verification:
```bash
npm test -- --runInBand
npm run build
```

## Done When

- [ ] All requirements met
- [ ] Source label renders correctly in all tested states