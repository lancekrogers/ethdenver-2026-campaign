---
fest_type: task
fest_id: 03_prioritize_festival_progress_message_parsing.md
fest_name: prioritize_festival_progress_message_parsing
fest_parent: 04_dashboard_festival_progress_consumer
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.978677-07:00
fest_tracking: true
---

# Task: Prioritize Festival Progress Message Parsing

## Objective
Ensure live dashboard parsing prefers explicit `festival_progress` events over legacy ad-hoc payload extraction.

## Requirements

- [ ] Update mirror-node parser to handle explicit `festival_progress` events first.
- [ ] Preserve backward compatibility for legacy `payload.festivalProgress` path.
- [ ] Avoid duplicate/conflicting festival state updates from mixed message types.

## Implementation

1. Confirm dashboard context:
```bash
cgo dashboard
fest link .
```

2. Update parser logic:
- Target: `src/hooks/useMirrorNode.ts`
- In message loop:
  - first branch on `msg.messageType === "festival_progress"`
  - parse typed payload and update `festivalProgress` state
  - fallback branch for legacy payload (`parsed.festivalProgress`)

3. Add defensive parsing:
- ignore malformed JSON safely
- avoid throwing in render loop

4. Verify by building and running tests:
```bash
npm test -- --runInBand
npm run build
```

## Done When

- [ ] All requirements met
- [ ] Explicit `festival_progress` path works and legacy compatibility remains
