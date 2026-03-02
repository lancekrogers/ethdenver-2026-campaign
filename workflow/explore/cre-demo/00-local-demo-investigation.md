# CRE Demo Investigation

## Goal

Define the strongest local demo path for the new Chainlink CRE Risk Router functionality, reusing the ETHDenver dashboard + `justfile` orchestration pattern already used in this campaign.

## Scope of this exploration

- Read how the original ETHDenver demo stack was run locally.
- Extract reusable `just` orchestration patterns.
- Map current CRE integration points and constraints.
- Propose demo runbooks for hackathon submission.

## Sources reviewed

- Root orchestration: `justfile`, `justfiles/*.just`, `docker-compose.yml`, root `README.md`
- Dashboard: `projects/dashboard/README.md`, `projects/dashboard/justfile`, `src/hooks/*`, `src/lib/data/*`
- Agent repos: `projects/agent-coordinator/justfile`, `projects/agent-inference/justfile`, `projects/agent-defi/justfile`
- CRE repo: `projects/cre-risk-router/README.md`, `justfile`, `demo/e2e.sh`, `workflow.go`, `workflow.yaml`, `project.yaml`
- Daemon/data tier expectations: `docs/obey/daemon-requirements.md`, `workflow/design/e2e-demo-plan/README.md`

## How the original ETHDenver local demo worked

### 1. Root-level orchestration model

The campaign already uses a strong two-mode root `just` entrypoint:

- `just demo`
- `just live`
- `just down`

Supporting modular files (`justfiles/docker.just`, `justfiles/build.just`, `justfiles/test.just`, `justfiles/lint.just`, `justfiles/status.just`) keep orchestration clean and composable.

### 2. Demo mode split (what worked well)

Mode 1, zero-config mock demo:

- `just demo` builds dashboard image and starts compose with dashboard only.
- `NEXT_PUBLIC_USE_MOCK` is true by default in compose build args.
- Result: all 5 dashboard panels render deterministically with synthetic data.

Mode 2, live-ish stack mode:

- `just live` builds dashboard + agent images with `--profile agents`.
- Uses `.env.docker` for chain credentials and topic IDs.
- Forces `NEXT_PUBLIC_USE_MOCK=false`.
- Result today: real Mirror Node-backed data for Festival + HCS panels, agents can run real chain interactions.

### 3. Dashboard data tier design (key to demo reliability)

The dashboard intentionally supports tiers:

- Mock mode (`NEXT_PUBLIC_USE_MOCK=true`): no external dependencies.
- Mirror Node mode: Festival/HCS via Hedera REST polling.
- WebSocket mode: Agent Activity, DeFi P&L, Inference Metrics require daemon event stream.

This tiered design is the core reason demos can still run when one runtime component is missing.

## What CRE functionality currently adds

### 1. Standalone CRE project with its own `just` interface

`projects/cre-risk-router/justfile` already provides:

- `just simulate`
- `just broadcast`
- `just demo`
- `just test`

This matches the campaign style: every project has its own local command surface, with root-level orchestration as an outer layer.

### 2. Integration hooks exist in agent economy repos

- Coordinator has optional CRE client (`CRE_ENDPOINT`) and performs risk checks before assigning DeFi tasks.
- Inference publishes `signal_confidence` and `risk_score` fields in task results.
- DeFi has CRE position guard support (`CRE_MAX_POSITION_USD`) and clamps size when enabled.

### 3. Current implementation constraints affecting demo design

Constraint A:

- `cre-risk-router/workflow.go` currently registers only a cron handler in `InitWorkflow()`.
- It does not currently expose an HTTP trigger in runtime code.

Constraint B:

- Coordinator CRE client expects an HTTP endpoint (`POST` risk request).
- This is currently a protocol mismatch with the cron-only CRE workflow path.

Constraint C:

- Full 5-panel “live agent telemetry” still depends on obey daemon WebSocket feed.
- The campaign repo local stack is designed to run without requiring daemon for basic demo tiers.

Constraint D:

- Root README says `cp .env.example .env` for live mode, but repo actually provides `.env.docker.example`.
- Operationally, local stack should use `.env.docker`.

## Reusable orchestration pattern for CRE demo

Use the same pattern that worked at ETHDenver:

- Keep a deterministic zero-config path.
- Keep a higher-fidelity path with real testnet writes.
- Keep one root command surface that fans out to project-local `just` commands.

Proposed command tiers for the CRE submission demo:

Tier 1, deterministic local proof (fast fallback):

- Dashboard mock mode (`just demo`)
- CRE dry-run simulation (`cd projects/cre-risk-router && just demo`)
- Multiple scenario outputs captured from CRE project

Tier 2, chain-backed CRE proof:

- CRE broadcast run for on-chain receipt (`just broadcast` or `just demo --broadcast` equivalent)
- Dashboard in live mode (`just live`) for Mirror Node/HCS context panels

Tier 3, integrated runtime proof (stretch / once protocol alignment exists):

- Coordinator calls CRE endpoint directly for per-task risk decision
- DeFi executes with CRE constraint handoff
- Dashboard shows end-to-end events

## Practical local runbooks (today)

### Runbook A: local deterministic demo (no private keys)

1. `just demo`
2. Open dashboard at `http://localhost:3000`
3. `cd projects/cre-risk-router && just simulate`
4. `cd projects/cre-risk-router && just demo`

Outcome:

- Dashboard fully visible and stable.
- CRE logic demonstrated with reproducible simulation output.

### Runbook B: submission evidence run (on-chain receipt)

1. `cp projects/cre-risk-router/.env.example projects/cre-risk-router/.env` and set `CRE_ETH_PRIVATE_KEY`
2. `cd projects/cre-risk-router && just broadcast`
3. Save tx hash output and explorer link.
4. Optionally run `just live` at repo root for chain-context dashboard panels.

Outcome:

- Satisfies on-chain write evidence requirement.
- Preserves reproducibility via project-local `just` commands.

### Runbook C: original ETHDenver “live stack” baseline

1. `cp .env.docker.example .env.docker`
2. Fill Hedera/0G/Base values.
3. `just live`
4. Verify Festival + HCS panels from Mirror Node and agent container health via `just docker ps`.

Outcome:

- Reuses known-good local orchestration pattern.
- Demonstrates broader agent economy context.

## Recommendation for hackathon demo strategy

Primary judge path:

- Lead with CRE-native proof (simulate + broadcast + denied/approved scenarios).
- Use dashboard as context and credibility layer, not as the only source of proof.

Fallback policy:

- If any live dependency is flaky, switch immediately to Tier 1 deterministic runbook and keep the same narrative.
- Preserve tx hash screenshots/logs as pre-captured evidence artifacts.

Narrative framing:

- “We reused the ETHDenver local orchestration model: zero-config demo mode plus chain-backed mode, then added CRE risk receipts as a new verifiable control layer.”

## Suggested follow-up (separate implementation task)

If we want a single-command CRE demo UX at campaign root, add a new modular justfile (for example `justfiles/cre-demo.just`) and expose root recipes like:

- `just cre-demo.local`
- `just cre-demo.broadcast`
- `just cre-demo.evidence`

No implementation done in this exploration; this is only the command architecture recommendation.
