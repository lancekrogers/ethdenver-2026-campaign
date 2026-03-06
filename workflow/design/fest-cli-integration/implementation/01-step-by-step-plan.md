# Step-by-Step Implementation Plan

## Implementation Principles
- Integrate via CLI process boundary (`fest` executable), not library imports.
- Keep deterministic fallback for demo mode.
- Fail fast in live mode unless fallback is explicitly enabled.
- Preserve existing HCS/WebSocket event model; extend it with `festival_progress`.

## Phase 0 - Contract Lock (P0)
Goal: lock interfaces before code changes.

1. Finalize canonical `festival_progress` payload schema.
2. Finalize env keys and defaults (`FEST_SELECTOR`, fallback flags, timeouts).
3. Decide selector policy for no-active-festival scenarios.

Deliverables:
- This design package approved.
- Short ADR in `docs/adr/` (optional but recommended).

## Phase 1 - Coordinator Fest Adapter Core
Goal: build an adapter that can query and parse `fest` output.

1. Implement command executor abstraction.
2. Implement selector resolver.
3. Implement JSON parsers for `show all` and `show --roadmap` outputs.
4. Map parsed output to internal coordinator `Plan` and dashboard snapshot model.
5. Add synthetic snapshot generator for fallback mode.
6. Add unit tests with recorded JSON fixtures.

Primary file targets:
- `projects/agent-coordinator/internal/festival/reader.go`
- `projects/agent-coordinator/internal/festival/protocol.go`
- `projects/agent-coordinator/internal/festival/messages.go`
- `projects/agent-coordinator/internal/festival/*_test.go` (new)
- `projects/agent-coordinator/testdata/fest/*.json` (new fixtures)

Verification commands:
- `cd projects/agent-coordinator && go test ./internal/festival/...`
- `cd projects/agent-coordinator && go test ./...`

Acceptance:
- Adapter can return a non-empty `Plan` from real `fest` output.
- Adapter returns typed fallback reason on failure.

## Phase 2 - Replace Static Plan Source
Goal: coordinator assignments are fed by `fest` instead of static hardcoded tasks.

1. Introduce `PlanProvider` interface in coordinator package.
2. Implement `FestPlanProvider` using festival adapter.
3. Keep `StaticPlanProvider` as explicit fallback/testing implementation.
4. Wire provider selection in `cmd/coordinator/main.go` by mode/env.
5. Remove direct call to `IntegrationCyclePlan(...)` from startup path.

Primary file targets:
- `projects/agent-coordinator/internal/coordinator/plan.go`
- `projects/agent-coordinator/internal/coordinator/static_plan.go`
- `projects/agent-coordinator/cmd/coordinator/main.go`
- `projects/agent-coordinator/internal/coordinator/*_test.go`

Verification commands:
- `cd projects/agent-coordinator && go test ./internal/coordinator/...`
- Start coordinator with and without `FEST_SELECTOR` and validate logs.

Acceptance:
- In live/test mode, startup log states selected festival and source `fest`.
- Hardcoded integration-cycle plan is no longer default runtime source.

## Phase 3 - Festival Progress Event Publishing
Goal: publish real `festival_progress` snapshots for dashboard consumption.

1. Add `MessageTypeFestivalProgress` to HCS envelope message types.
2. Add periodic publisher loop in coordinator (default every 10s).
3. Emit event payload with `source`, `selector`, `snapshot_time`, `festivalProgress`.
4. On adapter error: emit degraded event (`source=synthetic`) if allowed; else fail.
5. Add rate limiting/debounce to avoid noisy duplicate publishes.

Primary file targets:
- `projects/agent-coordinator/internal/hedera/hcs/message.go`
- `projects/agent-coordinator/internal/coordinator/` (new publisher module)
- `projects/agent-coordinator/cmd/coordinator/main.go`

Verification commands:
- `cd projects/agent-coordinator && go test ./...`
- Run local stack and inspect status topic messages for `festival_progress`.

Acceptance:
- HCS status topic includes periodic `festival_progress` events.
- Payload is parseable by dashboard type contract.

## Phase 4 - Dashboard Consumption and Visibility
Goal: dashboard clearly shows real fest state and fallback state.

1. Add `festival_progress` to `DaemonEventType` unions.
2. Update mirror-node parsing to prioritize explicit `festival_progress` messages.
3. Keep backward-compatible parsing of legacy `payload.festivalProgress`.
4. Add source badge/label in Festival panel (`fest` or `synthetic`).
5. Add tests for both source paths.

Primary file targets:
- `projects/dashboard/src/lib/data/types.ts`
- `projects/dashboard/src/hooks/useMirrorNode.ts`
- `projects/dashboard/src/hooks/useLiveData.ts` (if source metadata passed through)
- `projects/dashboard/src/components/panels/FestivalView.tsx`
- `projects/dashboard/src/components/panels/__tests__/FestivalView.test.tsx`

Verification commands:
- `cd projects/dashboard && npm test`
- `cd projects/dashboard && npm run build`

Acceptance:
- Festival View renders from runtime `fest` snapshot when available.
- UI explicitly indicates fallback state when synthetic source is active.

## Phase 5 - Root Just/Preflight Integration
Goal: one-command operation in demo/live with explicit fest behavior.

1. Add `just fest status` and `just fest doctor` module commands.
2. Extend `scripts/preflight-live.sh` with fest gates:
   - binary available
   - selector resolution valid
   - show-roadmap parse succeeds
3. Extend demo flow to warn and auto-fallback if `fest` unavailable.
4. Write run artifacts with festival source and selector metadata.

Primary file targets:
- `.justfiles/mode.just`
- `.justfiles/demo.just`
- `.justfiles/live.just`
- `.justfiles/status.just` (optional summary additions)
- `scripts/preflight-live.sh`
- `.env.demo.example`, `.env.live.example`, `.env.docker.example`

Verification commands:
- `just mode doctor`
- `just demo run`
- `just live up` (with strict mode expectations)

Acceptance:
- Live preflight blocks on fest misconfiguration by default.
- Demo command succeeds without manual intervention.

## Phase 6 - Evidence and Documentation
Goal: make this a strong, auditable hackathon demonstration of real fest usage.

1. Add guide for real vs fallback execution evidence.
2. Capture sample event payloads and screenshots.
3. Add short section to root README explaining runtime fest integration.

Primary file targets:
- `docs/guides/fest-runtime-integration.md` (new)
- `docs/guides/chainlink-demo-live-e2e.md`
- `docs/guides/chainlink-demo-mock-e2e.md`
- `README.md`

Verification commands:
- Run documented commands from clean shell.
- Confirm generated artifacts in `workflow/explore/cre-demo/runs/<timestamp>/`.

Acceptance:
- A reviewer can prove, with logs/artifacts, that festival progress came from `fest`.

## Test Matrix (Required)
1. Demo mode with `fest` installed: `source=fest`.
2. Demo mode without `fest`: `source=synthetic`, run still passes.
3. Live mode with `fest` installed and selector valid: startup passes.
4. Live mode without `fest`: startup fails with actionable message.
5. Live mode with fallback override enabled: startup passes but labeled degraded.

## Rollout Recommendation
1. Ship Phases 1-2 first (plan correctness).
2. Ship Phase 3 immediately after (data emission).
3. Ship Phase 4 with UI source labeling.
4. Finish with Phase 5 preflight hardening and Phase 6 docs.
