---
fest_type: task
fest_id: 04_wire_plan_provider_selection_in_main.md
fest_name: wire_plan_provider_selection_in_main
fest_parent: 03_coordinator_festival_progress_events
fest_order: 4
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.962425-07:00
fest_updated: 2026-03-06T15:45:32.910337-07:00
fest_tracking: true
---


# Task: Wire Plan Provider Selection In Main

## Objective
Wire coordinator startup to use fest-derived provider and start the festival progress publisher.

## Requirements

- [ ] Replace direct static plan call in main startup path.
- [ ] Instantiate adapter/provider using env config.
- [ ] Start periodic progress publisher alongside existing background loops.
- [ ] Keep explicit fallback behavior visible in startup logs.

## Implementation

1. Ensure context:
```bash
cgo agent-coordinator
fest link .
```

2. Update startup wiring:
- target: `cmd/coordinator/main.go`
- replace usage of `IntegrationCyclePlan(...)` as default source.
- inject provider call for current selector-derived plan.

3. Start progress publisher goroutine after monitor/result-handler wiring.

4. Add startup logs:
- selected selector
- fallback setting
- initial source (`fest` or `synthetic`)

5. Validate build:
```bash
go build ./cmd/coordinator
```

## Done When

- [ ] All requirements met
- [ ] Coordinator starts with provider/publisher wiring and logs selected source mode