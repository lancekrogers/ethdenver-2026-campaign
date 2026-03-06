# Current State Audit

## Verified Findings

### 1. Dashboard Festival View is not wired to `fest` runtime
Evidence:
- `projects/dashboard/src/hooks/useSyntheticMirrorNode.ts:41` sets `festivalProgress` from `generateFestivalProgress()`.
- `projects/dashboard/src/lib/data/synthetic-events.ts:319` defines static `generateFestivalProgress()` data.
- `projects/dashboard/src/hooks/useMirrorNode.ts:47-54` only sets festival progress when incoming HCS payload already contains `parsed.festivalProgress`.

Impact:
- Festival View can look real in mock mode, but live mode does not independently derive progress from `fest`.

### 2. Mirror Node client is transport-only
Evidence:
- `projects/dashboard/src/lib/data/mirror-node.ts:73-226` fetches and decodes HCS messages but does not call `fest` nor derive hierarchical phase/sequence/task status.

Impact:
- Live festival state depends on another component injecting `festivalProgress` into HCS payloads.

### 3. Coordinator has no implemented `fest` adapter
Evidence:
- `projects/agent-coordinator/internal/festival/reader.go:1`, `messages.go:1`, and `protocol.go:1` are stubs (`package festival`).
- `projects/agent-coordinator/cmd/coordinator/main.go:117-125` still uses `coordinator.IntegrationCyclePlan(...)`.
- `projects/agent-coordinator/internal/coordinator/static_plan.go:5-34` hardcodes the task plan.

Impact:
- Runtime orchestration is not driven by festival methodology data from `fest`.

### 4. Existing runtime still assumes planned future daemon behavior
Evidence:
- `workflow/design/e2e-demo-plan/README.md` already proposes periodic `fest show --json` broadcasting, but no production implementation currently exists.

Impact:
- Design intent exists, but integration path is incomplete.

### 5. `fest` CLI is available locally and provides parseable JSON surfaces
Verified commands in this campaign root:
- `fest version` returns `fest version dev (built 2026-03-06T16:14:37Z, commit d2b1cdb)`.
- `fest show --json` fails outside festival context unless selector is provided (`{"error":"not in a festival directory or linked project"}`).
- `fest show all --json` works from campaign root and returns status-grouped catalog.
- `fest show --festival <selector> --json --roadmap` returns detailed hierarchy + task statuses.
- `fest progress --json` works when run inside a festival directory and returns aggregate completion metrics.

Impact:
- We can integrate immediately via CLI invocation + JSON parsing with selector-based execution from campaign root.

## Summary of Gaps to Close
1. Replace coordinator static plan source with `fest`-derived source.
2. Introduce a canonical runtime event contract for festival progress snapshots.
3. Add mode-aware fallback behavior when `fest` is unavailable.
4. Enforce live-mode strictness via preflight (no silent fallback in live mode).
5. Align dashboard data source semantics so users can see `source=fest|synthetic` explicitly.
