---
fest_type: task
fest_id: 03_verify_archived_artifact_intake.md
fest_name: verify archived artifact intake
fest_parent: 05_artifact_aggregation
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.535573-06:00
fest_tracking: true
---

# Task: Verify archived artifact intake

## Objective

Confirm that completed ritual artifacts remain visible to the aggregate evidence pipeline after lifecycle transitions.


## Primary Files

- `projects/agent-defi/cmd/loggen/main.go (`loadRitualEntries`, `loadSwapEvents`)`
- `projects/agent-defi/internal/loggen/*.go (if extraction is needed)`
- `projects/agent-defi/internal/loop/runner.go`
- `docs/2026_requirements/synthesis/submission-guide.md`

## Evidence To Capture

- [ ] `projects/agent-defi/agent_log.json` refreshes from ritual artifacts plus execution evidence.
- [ ] Discover entries come from ritual outputs rather than from synthetic code comments or prompt text.
- [ ] The documentation explains exactly which files support the Protocol Labs evidence story.

## Requirements

- [ ] Aggregation must not lose discover artifacts when runs leave `festivals/active/`.
- [ ] The evidence pipeline must stay correct across active and completed run locations.

## Implementation

1. Trace how loggen discovers ritual artifacts today.
2. Verify the search logic includes the real completed/archive locations used by fest.
3. Adjust the path logic if active-only assumptions would drop older runs.
4. Test the result against at least one completed or archived ritual run once available.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
go run ./cmd/loggen -rituals /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/festivals/dungeon/completed -out agent_log.json
jq '.' agent_log.json >/dev/null
```

## Done When

- [ ] All requirements met
- [ ] Aggregate evidence still sees ritual artifacts after fest archives completed runs.
