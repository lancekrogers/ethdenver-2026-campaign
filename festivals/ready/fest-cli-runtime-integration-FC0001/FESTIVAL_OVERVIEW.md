# Festival Overview: fest-cli-runtime-integration

## Problem Statement

**Current State:** Festival UX is partially synthetic in runtime paths. Coordinator still contains static planning behavior and dashboard festival data can come from synthetic generators or ad-hoc message parsing rather than canonical `fest` snapshots.

**Desired State:** Runtime orchestration and progress reporting are driven by `fest` CLI JSON output, with explicit fallback modes and clear source labeling.

**Why This Matters:** This project is explicitly positioned as a real-world demonstration of Obedience tooling (`camp`, `fest`, `obey`). Runtime integration must be authentic, auditable, and demo-safe.

## Scope

### In Scope

- Coordinator-side `fest` adapter and plan/progress mapping.
- Festival progress event contract and publication path.
- Dashboard consumption of canonical `festival_progress` events.
- Root mode/preflight checks for strict live behavior and synthetic demo fallback.
- Documentation and evidence updates for mock/live operation.

### Out of Scope

- New product features unrelated to fest runtime integration.
- Re-architecting non-festival dashboard panels.
- Replacing existing chain integrations (Hedera/Base/0G) outside required integration points.

## Planned Phases

### 001_IMPLEMENT

Implement adapter, event pipeline, dashboard consumption, mode gates, and documentation updates in one implementation phase with sequence-level quality gates.

## Notes

- Before each project change, sequence task 01 must run `cgo <project-name>` and `fest link .`.
- Festival starts in `planning` and is expected to execute via `fest next` from campaign root.
