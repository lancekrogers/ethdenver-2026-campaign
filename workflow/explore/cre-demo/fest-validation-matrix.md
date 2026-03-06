# Fest Runtime Validation Matrix

Run timestamp: `2026-03-06 15:54:14` (local)

Artifact directory:

- `workflow/explore/cre-demo/runs/20260306-155414/`

## Results

| Scope | Command | Exit Code | Expected Result | Actual Result |
|-------|---------|-----------|-----------------|---------------|
| Root | `just fest status` | `0` | Pass and print fest candidate status | Pass; candidate `fest-cli-runtime-integration-FC0001` shown |
| Root | `just fest doctor` | `0` | Pass selector + roadmap checks | Pass; `fest doctor: PASS` |
| Root | `just demo run` | `0` | Demo flow runs end-to-end | Pass; approved + denied CRE outputs emitted |
| Root | `just mode doctor` | `1` | May fail in strict live preflight if live constraints unmet | Failed as expected; blocked by `LIVE_ALLOW_SIMULATED_CRE` and insufficient Base balance |
| Coordinator | `go test ./...` | `0` | Full test suite passes | Pass |
| Coordinator | `go build ./cmd/coordinator` | `0` | Coordinator builds | Pass |
| Dashboard | `npm test -- --runInBand` | `0` | Dashboard tests pass | Pass (`12/12` suites) |
| Dashboard | `npm run build` | `0` | Dashboard production build succeeds | Pass (Next.js build success) |

## Log Files

- `workflow/explore/cre-demo/runs/20260306-155414/root_just_fest_status.log`
- `workflow/explore/cre-demo/runs/20260306-155414/root_just_fest_doctor.log`
- `workflow/explore/cre-demo/runs/20260306-155414/root_just_demo_run.log`
- `workflow/explore/cre-demo/runs/20260306-155414/root_just_mode_doctor.log`
- `workflow/explore/cre-demo/runs/20260306-155414/coordinator_go_test_all.log`
- `workflow/explore/cre-demo/runs/20260306-155414/coordinator_go_build.log`
- `workflow/explore/cre-demo/runs/20260306-155414/dashboard_npm_test.log`
- `workflow/explore/cre-demo/runs/20260306-155414/dashboard_npm_build.log`
