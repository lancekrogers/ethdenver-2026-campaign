---
fest_type: task
fest_id: 02_add_festival_progress_message_type_and_payload.md
fest_name: add_festival_progress_message_type_and_payload
fest_parent: 03_coordinator_festival_progress_events
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.961915-07:00
fest_tracking: true
---

# Task: Add Festival Progress Message Type And Payload

## Objective
Define canonical message contract for festival progress publishing from coordinator.

## Requirements

- [ ] Add `festival_progress` message type constant.
- [ ] Define payload struct with source metadata and snapshot payload.
- [ ] Keep serialization compatible with existing envelope format.

## Implementation

1. Ensure context:
```bash
cgo agent-coordinator
fest link .
```

2. Update message type constants in:
- `internal/hedera/hcs/message.go`

Add:
```go
MessageTypeFestivalProgress MessageType = "festival_progress"
```

3. Add payload struct in festival package (or coordinator package):
- fields:
  - `version`
  - `source` (`fest` | `synthetic`)
  - `selector`
  - `snapshot_time`
  - `stale_after_seconds`
  - `festivalProgress` (dashboard-compatible shape)
  - optional `fallback_reason`

4. Ensure JSON tags match dashboard expectation.

## Done When

- [ ] All requirements met
- [ ] Payload struct can be marshaled and embedded in HCS envelope without custom hacks
