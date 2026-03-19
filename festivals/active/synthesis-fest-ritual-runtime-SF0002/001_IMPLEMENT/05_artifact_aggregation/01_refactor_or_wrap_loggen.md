---
fest_type: task
fest_id: 01_refactor_or_wrap_loggen.md
fest_name: refactor or wrap loggen
fest_parent: 05_artifact_aggregation
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.534976-06:00
fest_tracking: true
---

# Task: Refactor or wrap loggen

## Objective

Make the existing log generation path reusable from runtime code without duplicating its logic.


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

- [ ] Choose either a shared internal package or a controlled wrapper around the existing loggen path.
- [ ] Keep the behavior aligned with the existing Protocol Labs artifact format.

## Implementation

1. Inspect `projects/agent-defi/cmd/loggen/main.go` and identify what should move into a reusable package.
2. Implement the smallest change that lets runtime code trigger the same aggregation logic.
3. Avoid duplicating parsing or formatting rules across two independent implementations.
4. Document the chosen approach so later maintenance stays clear.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
go run ./cmd/loggen -rituals /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/festivals/dungeon/completed -out agent_log.json
jq '.' agent_log.json >/dev/null
```

## Done When

- [ ] All requirements met
- [ ] The runtime can trigger aggregate log generation through one authoritative code path.
