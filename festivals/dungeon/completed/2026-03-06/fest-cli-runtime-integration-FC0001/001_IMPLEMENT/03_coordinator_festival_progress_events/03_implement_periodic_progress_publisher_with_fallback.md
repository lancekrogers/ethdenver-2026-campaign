---
fest_type: task
fest_id: 03_implement_periodic_progress_publisher_with_fallback.md
fest_name: implement_periodic_progress_publisher_with_fallback
fest_parent: 03_coordinator_festival_progress_events
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.962184-07:00
fest_updated: 2026-03-06T15:45:32.894234-07:00
fest_tracking: true
---


# Task: Implement Periodic Progress Publisher With Fallback

## Objective
Publish periodic festival progress snapshots to HCS, with explicit fallback behavior when fest data cannot be read.

## Requirements

- [ ] Add publisher loop with configurable interval.
- [ ] Publish `source=fest` when adapter succeeds.
- [ ] Publish `source=synthetic` only when fallback is enabled.
- [ ] Return/propagate hard failure when fallback is disabled.

## Implementation

1. Confirm context:
```bash
cgo agent-coordinator
fest link .
```

2. Add a publisher component in coordinator package (new file recommended):
- suggested path: `internal/coordinator/festival_progress_publisher.go`
- responsibilities:
  - ticker loop (`FEST_POLL_INTERVAL_SECONDS`, default 10)
  - call festival adapter snapshot method
  - map to envelope payload
  - publish to status topic via existing publisher

3. Implement fallback policy using env values:
- `FEST_FALLBACK_ALLOW_SYNTHETIC` (`true|false`)
- if `false`, stop startup or return error on adapter failure
- if `true`, emit synthetic snapshot with reason code

4. Add logging for each publish cycle:
- selector
- source
- duration
- outcome

## Done When

- [ ] All requirements met
- [ ] Publisher emits events on interval in running coordinator
- [ ] Fallback policy behaves as configured