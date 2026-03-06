# Target Architecture

## Design Objectives
1. Use `fest` as the source of truth for coordinator plan/progress.
2. Publish festival progress snapshots into existing event streams for dashboard consumption.
3. Keep demo UX deterministic even when `fest` is absent.
4. Avoid direct dependency on private `fest` code internals by integrating through CLI JSON outputs.

## Runtime Data Flow

```text
fest CLI (show/progress JSON)
        |
        v
Coordinator Festival Adapter
  - selector resolution
  - CLI execution
  - JSON parsing
  - canonical snapshot mapping
        |
        v
HCS status messages (festival_progress envelope)
        |
        v
Dashboard MirrorNode hook
  - parse festival_progress
  - render Festival View
```

## Components

### A. Festival Adapter (Coordinator)
Purpose:
- Execute `fest` commands from coordinator runtime.
- Convert raw CLI output into canonical `FestivalProgressSnapshot`.
- Provide plan extraction for task assignment.

Responsibilities:
- Resolve target festival selector (`FEST_SELECTOR`, or auto-detect by status priority).
- Run `fest show --festival <selector> --json --roadmap`.
- Optionally run `fest progress --json` for aggregate guard values.
- Parse and normalize into coordinator `Plan` + dashboard `FestivalProgress` shape.

### B. Festival Progress Publisher
Purpose:
- Emit periodic and edge-triggered progress updates as runtime events.

Responsibilities:
- Publish `festival_progress` payloads to status topic.
- Include metadata: `source`, `selector`, `snapshot_time`, `stale_after_seconds`.
- Emit health event on adapter failures.

### C. Dashboard Festival Consumer
Purpose:
- Consume canonical runtime `festival_progress` events.

Responsibilities:
- Prefer event type `festival_progress`.
- Keep backward compatibility with legacy `payload.festivalProgress` envelopes.
- Expose data source marker in UI: `fest` vs `synthetic`.

## Canonical Event Contract

Envelope fields (existing pattern):
- `type`: `festival_progress`
- `agentId`: `coordinator`
- `timestamp`: ISO-8601 UTC
- `payload`: object below

Payload contract:

```json
{
  "version": "v1",
  "source": "fest",
  "selector": "root-runtime-modes-phase-1-RR0001",
  "snapshot_time": "2026-03-06T18:00:00Z",
  "stale_after_seconds": 30,
  "festivalProgress": {
    "festivalId": "RR0001",
    "festivalName": "root-runtime-modes-phase-1",
    "overallCompletionPercent": 62,
    "phases": []
  }
}
```

## Selector Resolution Rules
1. If `FEST_SELECTOR` is set: use it directly.
2. Else choose first festival by priority:
   - `active`
   - `ready`
   - `planning`
   - `dungeon/someday`
3. Ignore `dungeon/completed` unless `FEST_ALLOW_COMPLETED=true`.
4. If no selectable festival exists: adapter returns typed `no_festival_available` error.

## CLI Invocation Contract
All invocations run from campaign root.

Required calls:
- `fest show all --json` (catalog and status buckets)
- `fest show --festival <selector> --json --roadmap` (hierarchy + task statuses)

Optional call:
- `fest progress --json` executed inside selected festival path for aggregate parity checks.

Timeout defaults:
- show-all: 5s
- show-roadmap: 8s
- progress: 5s

## Mapping Rules (Fest -> Dashboard)

Source fields:
- `festival.metadata_id` -> `festivalId`
- `festival.metadata_name` -> `festivalName`
- `festival.stats.progress` -> `overallCompletionPercent`
- `roadmap.phases[].name` -> `phase.id` and display `phase.name`
- `roadmap.phases[].sequences[]` -> dashboard sequences
- `tasks[].status` -> task status

Status normalization:
- `in_progress` -> `active`
- `blocked` -> `blocked`
- `done`/`completed` -> `completed`
- unknown -> `pending`

Completion derivation:
- Sequence completion = completed tasks / total tasks.
- Phase completion = completed sequence-tasks / total sequence-tasks.

## Security and Operational Constraints
- Never shell out with untrusted selector strings without validation.
- Escape/validate selector as `[A-Za-z0-9._/-]+`.
- Do not log secrets; only log selector, command, duration, and stderr summary.
- Treat parse failures as health events, not panics.
