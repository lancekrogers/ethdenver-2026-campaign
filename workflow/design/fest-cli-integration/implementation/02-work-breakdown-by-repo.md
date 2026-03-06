# Work Breakdown by Repository

## Campaign Root

### Files
- `.justfiles/mode.just`
- `.justfiles/demo.just`
- `.justfiles/live.just`
- `scripts/preflight-live.sh`
- `.env.demo.example`
- `.env.live.example`
- `.env.docker.example`

### Tasks
1. Add fest health checks and selector diagnostics.
2. Expose `just fest status` and `just fest doctor` wrappers.
3. Enforce strict live behavior and permissive demo behavior.

## `projects/agent-coordinator`

### Files
- `cmd/coordinator/main.go`
- `internal/festival/reader.go`
- `internal/festival/messages.go`
- `internal/festival/protocol.go`
- `internal/coordinator/plan.go`
- `internal/coordinator/static_plan.go`
- `internal/hedera/hcs/message.go`

### Tasks
1. Implement fest adapter and parser.
2. Replace static plan source with fest provider.
3. Emit periodic `festival_progress` events to HCS.
4. Implement fallback policy (`fest` vs synthetic vs hard fail).

## `projects/dashboard`

### Files
- `src/lib/data/types.ts`
- `src/hooks/useMirrorNode.ts`
- `src/components/panels/FestivalView.tsx`
- `src/components/panels/__tests__/FestivalView.test.tsx`

### Tasks
1. Accept new `festival_progress` event type.
2. Prefer explicit festival progress event over ad-hoc payload detection.
3. Surface `source` badge (`fest` or `synthetic`) in panel.

## Documentation

### Files
- `README.md`
- `docs/guides/chainlink-demo-live-e2e.md`
- `docs/guides/chainlink-demo-mock-e2e.md`
- `docs/guides/fest-runtime-integration.md` (new)

### Tasks
1. Document proof commands and expected outputs.
2. Show how to run in strict live mode and fallback demo mode.
3. Provide judge-friendly evidence checklist.
