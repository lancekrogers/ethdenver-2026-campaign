---
fest_type: task
fest_id: 04_document_protocol_labs_evidence.md
fest_name: document protocol labs evidence
fest_parent: 05_artifact_aggregation
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-18T07:27:43.535789-06:00
fest_tracking: true
---

# Task: Document protocol labs evidence

## Objective

Explain how the refreshed evidence maps to Protocol Labs judging requirements and where judges can inspect it.


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

- [ ] Tie the live runtime artifacts back to the submission guide requirements for agent logs and process evidence.
- [ ] Document the locations of the key files judges or reviewers should inspect.

## Implementation

1. Read `docs/2026_requirements/synthesis/submission-guide.md` and note the Protocol Labs-specific requirements.
2. Document how `decision.json`, `agent_log_entry.json`, and `agent_log.json` satisfy those expectations.
3. Write down the file paths and demo steps needed to show the evidence quickly.
4. Keep the notes aligned with the actual runtime path built in earlier sequences.



## Verification Commands

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects/agent-defi
go test ./...
go run ./cmd/loggen -rituals /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/festivals/dungeon/completed -out agent_log.json
jq '.' agent_log.json >/dev/null
```

## Done When

- [ ] All requirements met
- [ ] A reviewer can follow the documentation from runtime behavior to Protocol Labs evidence without guessing.
