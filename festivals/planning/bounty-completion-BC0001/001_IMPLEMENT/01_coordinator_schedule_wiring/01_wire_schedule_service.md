---
fest_type: task
fest_id: 01_wire_schedule_service.md
fest_name: wire schedule service
fest_parent: 01_coordinator_schedule_wiring
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:46.776059-07:00
fest_tracking: true
---

# Task: Wire Schedule Service into Coordinator

## Objective

Import the schedule package and wire `ScheduleService` and `HeartbeatRunner` into `cmd/coordinator/main.go` so the coordinator activates all 4 Hedera native services at startup.

## Requirements

- [ ] Import `internal/hedera/schedule` package in main.go
- [ ] Instantiate `ScheduleService` using `schedule.NewScheduleService(hederaClient)`
- [ ] Create `HeartbeatConfig` using `schedule.DefaultHeartbeatConfig()` and populate `AgentID` and `AccountID` fields
- [ ] Create `HeartbeatRunner` using `schedule.NewHeartbeat(hederaClient, scheduleSvc, cfg)`
- [ ] Start the heartbeat runner as a goroutine that respects the main context for clean shutdown

## Implementation

Before writing any code, read the schedule package source to confirm struct and function names:

```
projects/agent-coordinator/internal/hedera/schedule/
```

Look for: `NewScheduleService`, `DefaultHeartbeatConfig`, `NewHeartbeat`, and the `HeartbeatConfig` struct fields.

Open `projects/agent-coordinator/cmd/coordinator/main.go`. Find the line where `transferSvc` is instantiated (approximately line 50). After that block, add the following (~12 lines):

```go
// Schedule service — 4th Hedera native service
scheduleSvc := schedule.NewScheduleService(hederaClient)

heartbeatCfg := schedule.DefaultHeartbeatConfig()
heartbeatCfg.AgentID = cfg.AgentID       // use whatever field name cfg exposes
heartbeatCfg.AccountID = cfg.AccountID   // use whatever field name cfg exposes

heartbeat := schedule.NewHeartbeat(hederaClient, scheduleSvc, heartbeatCfg)
go func() {
    if err := heartbeat.Run(ctx); err != nil {
        log.Printf("heartbeat stopped: %v", err)
    }
}()
```

Adjust field names to match what the `Config` struct and `HeartbeatConfig` struct actually expose. Do not guess — read the source first.

Add the import for the schedule package at the top of main.go alongside the other internal imports:

```go
"github.com/yourusername/agent-coordinator/internal/hedera/schedule"
```

Replace the module path with the actual module path from `go.mod`.

Run `just build` in `projects/agent-coordinator` to confirm the binary compiles cleanly.

## Done When

- [ ] All requirements met
- [ ] `just build` passes in projects/agent-coordinator with no errors
- [ ] Coordinator binary starts and logs indicate schedule service / heartbeat is running
