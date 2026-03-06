---
fest_type: gate
fest_id: 05_testing.md
fest_name: Testing and Verification
fest_parent: 04_dashboard_festival_progress_consumer
fest_order: 5
fest_status: completed
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-06T13:39:01.570264-07:00
fest_updated: 2026-03-06T15:49:34.981325-07:00
fest_tracking: true
---


# Task: Testing and Verification

**Task Number:** 05 | **Dependencies:** Tasks 01-04 | **Autonomy:** medium

## Objective
Verify dashboard type, parsing, and rendering changes for `festival_progress` integration.

## Required Test Run

```bash
cgo dashboard
fest link .
npm test -- --runInBand
npm run build
```

Optional local sanity run:
```bash
npm run dev
```
Validate Festival View renders and no runtime JSON parsing crashes occur.

## Verification Criteria

- [ ] Tests pass with new source metadata cases.
- [ ] Build succeeds without type regressions.
- [ ] Parsing logic handles malformed and legacy payloads safely.

## Done When

- [ ] All verification criteria satisfied
- [ ] Evidence of passing tests/build is captured