# FC0001 Release Handoff

Festival: `fest-cli-runtime-integration-FC0001`  
Phase: `001_IMPLEMENT`  
Prepared: `2026-03-06`

## 1. Sequence-By-Sequence Summary

### S01 Campaign Root Mode + Preflight

- Added root `just fest status` and `just fest doctor` commands.
- Added fest readiness gates in `scripts/preflight-live.sh`.
- Added fest env controls in `.env.demo.example`, `.env.live.example`, `.env.docker.example`.
- Captured command evidence matrix in `workflow/explore/cre-demo/fest-mode-matrix.md`.

### S02 Coordinator Fest Adapter Core

- Implemented fest reader + selector resolution + roadmap parsing in `projects/agent-coordinator/internal/festival/*`.
- Added fixture-driven parser tests in `projects/agent-coordinator/testdata/fest/*` and `internal/festival/*_test.go`.

### S03 Coordinator Festival Progress Events

- Added HCS message type `festival_progress`.
- Added runtime publisher + fallback behavior in `projects/agent-coordinator/internal/coordinator/fest_runtime.go`.
- Wired startup provider selection in `projects/agent-coordinator/cmd/coordinator/main.go`.
- Added runtime publisher tests in `internal/coordinator/fest_runtime_test.go`.

### S04 Dashboard Festival Progress Consumer

- Added typed `festival_progress` payload model and source metadata in `projects/dashboard/src/lib/data/types.ts`.
- Updated parser priority/compatibility in `projects/dashboard/src/hooks/useMirrorNode.ts`.
- Added source badge rendering in `projects/dashboard/src/components/panels/FestivalView.tsx`.
- Added source badge tests in `projects/dashboard/src/components/panels/__tests__/FestivalView.test.tsx`.

### S05 Docs + Demo Evidence Updates

- Updated root README runtime integration narrative and command UX.
- Added `docs/guides/fest-runtime-integration.md`.
- Updated chainlink mock/live guides with fallback/strict matrix and source-label evidence checklist.

### S06 Cross-Project Validation + Release

- Ran validation matrix and captured command logs under:
  - `workflow/explore/cre-demo/runs/20260306-155414/`
- Added matrix summary:
  - `workflow/explore/cre-demo/fest-validation-matrix.md`
- Captured required artifact bundle files:
  - `preflight-live.json`, `preflight-live.txt`, `fest-mode-matrix.md`, `fest-validation-matrix.md`, `dashboard-source-label.md`

## 2. Touched Files By Repo

### Campaign Root

- `README.md`
- `.justfiles/fest.just`
- `.justfiles/mode.just`
- `scripts/preflight-live.sh`
- `.env.demo.example`
- `.env.live.example`
- `.env.docker.example`
- `docs/guides/fest-runtime-integration.md`
- `docs/guides/chainlink-demo-mock-e2e.md`
- `docs/guides/chainlink-demo-live-e2e.md`
- `docs/guides/runtime-modes.md`
- `workflow/explore/cre-demo/fest-mode-matrix.md`
- `workflow/explore/cre-demo/fest-validation-matrix.md`
- `workflow/explore/cre-demo/runs/20260306-155414/*`

### `projects/agent-coordinator`

- `cmd/coordinator/main.go`
- `internal/hedera/hcs/message.go`
- `internal/coordinator/fest_runtime.go`
- `internal/coordinator/fest_runtime_test.go`
- `internal/festival/*`
- `testdata/fest/*`

### `projects/dashboard`

- `src/lib/data/types.ts`
- `src/lib/data/mirror-node.ts`
- `src/hooks/useMirrorNode.ts`
- `src/hooks/useSyntheticMirrorNode.ts`
- `src/hooks/useLiveData.ts`
- `src/components/panels/FestivalView.tsx`
- `src/components/panels/__tests__/FestivalView.test.tsx`
- `src/app/page.tsx`

## 3. Validation Highlights

Validation matrix run: `workflow/explore/cre-demo/runs/20260306-155414/validation-results.tsv`

- `just fest status` -> exit `0`
- `just fest doctor` -> exit `0`
- `just demo run` -> exit `0`
- `just mode doctor` -> exit `1` (expected strict-live failure due missing `LIVE_ALLOW_SIMULATED_CRE` and low Base balance)
- `agent-coordinator` `go test ./...` -> exit `0`
- `agent-coordinator` `go build ./cmd/coordinator` -> exit `0`
- `dashboard` `npm test -- --runInBand` -> exit `0`
- `dashboard` `npm run build` -> exit `0`

## 4. Known Limitations / Follow-Ups

- Live strict mode still blocks without explicit `LIVE_ALLOW_SIMULATED_CRE=true` acknowledgement and funded Base wallet.
- Demo source-label evidence in this run is captured via test-backed note (`dashboard-source-label.md`) rather than UI screenshot artifact.
- `fest commit` in campaign root stages additional fest tracking files automatically; verify staged scope before future sequence commits if tighter partitioning is required.

## 5. Final Command Checklist

Run from campaign root:

```bash
fest status
fest progress
fest validate
git status --short
git diff --stat
fest commit -m "FC0001 S06: run cross-project validation matrix and prepare release handoff evidence"
git log -1 --oneline
```

Push flow:

1. Push project repos first (`projects/agent-coordinator`, `projects/dashboard`) if not already pushed.
2. Push campaign root commit(s).
3. Run `camp push all` from campaign root for coordinated publication.
