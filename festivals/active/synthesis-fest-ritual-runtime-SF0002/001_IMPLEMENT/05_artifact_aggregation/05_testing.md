---
fest_type: gate
fest_id: 05_testing.md
fest_name: Testing and Verification
fest_parent: 05_artifact_aggregation
fest_order: 5
fest_status: completed
fest_autonomy: medium
fest_gate_id: testing
fest_gate_type: testing
fest_created: 2026-03-18T07:27:46.562971-06:00
fest_updated: 2026-03-19T02:20:25.192973-06:00
fest_tracking: true
---


# Task: Testing and Verification

**Task Number:** <no value> | **Parallel Group:** None | **Dependencies:** All implementation tasks | **Autonomy:** medium

## Objective

Prove aggregate Protocol Labs evidence is generated from real ritual artifacts and real execution data.

## Required Evidence

- [ ] `go test ./...` passes in `projects/agent-defi`.
- [ ] `go run ./cmd/loggen ...` completes successfully.
- [ ] `agent_log.json` is valid JSON.
- [ ] At least one discover entry in the aggregate log came from a ritual artifact.
- [ ] The evidence notes point judges to the exact files to inspect.

## Commands To Run

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
go run ./cmd/loggen -rituals /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/festivals/dungeon/completed -out agent_log.json
jq '.' agent_log.json >/dev/null
```

## Manual Checks

1. Show which ritual artifact files fed the aggregate log.
2. Confirm the log still reads archived ritual runs after they leave `festivals/active/`.
3. Verify the documentation maps each artifact type to the Protocol Labs narrative.

## Definition of Done

- [ ] Aggregate log generation passes
- [ ] Discover entries come from ritual artifacts
- [ ] Archived artifact intake works
- [ ] Evidence notes are judge-ready

## Notes

- `go test ./...` passed in `projects/agent-defi` on 2026-03-19 after adding `internal/loggen` coverage.
- `go test ./internal/loggen ./...` passed and specifically covered:
  `TestLoadRitualEntriesWalksArchivedAndActiveRuns`
  `TestRefresherRefreshWritesAggregateLog`
- Live aggregate regeneration command:

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
BASE_RPC_URL=https://sepolia.base.org VAULT_ADDRESS=0xbAbDd92397Cd812593e79A5b4c2a32bB4aDb06b1 go run ./cmd/loggen -rituals /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/festivals -out agent_log.json
jq '.entries | {count:length, phases: map(.phase), actions: map(.action)}' agent_log.json
```

- Live regeneration result: `agent_log.json` was written with `2` entries and phases `discover`, `execute`.
- The discover entry came from `/Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/festivals/active/agent-market-research-RI-AM0001-0002/003_DECIDE/01_synthesize_decision/results/agent_log_entry.json`.
- Archived-intake protection is now explicit: `LoadRitualEntries` walks the supplied root recursively, and `TestLoadRitualEntriesWalksArchivedAndActiveRuns` verifies both `active/.../agent_log_entry.json` and `dungeon/completed/.../agent_log_entry.json` are included.
- Judge-facing documentation is now in `docs/2026_requirements/synthesis/submission-guide.md` under `Runtime Evidence Quick Map`.

---

**Test Results Summary:**

- Unit tests: [x] Pass / [ ] Fail
- Integration tests: [x] Pass / [ ] Fail
- Aggregate log valid JSON: [x] Yes / [ ] No
- Discover entry from ritual artifact: [x] Verified / [ ] Failed
- Archived artifact intake: [x] Verified / [ ] Failed