# Root Runtime Modes Design (Demo vs Live Testnet)

## Goal
Design a root-level command model so the campaign can be run predictably in two explicit modes:

1. `demo` (deterministic, low-friction, hackathon walkthrough)
2. `live-testnet` (real multichain integration path)

This is a design document only. No implementation changes are included.

## Problem Statement
Current root workflows are close, but mode boundaries are still implicit and easy to misuse:

- Live stack can run with hidden mocks (example: DeFi mock mode defaults true unless explicitly disabled).
- CRE bridge currently evaluates with mock oracle data in HTTP path.
- Inference task defaults may not match available live providers.
- HCS subscriptions start from epoch and replay historical traffic, causing noisy duplicate processing after restarts.

Result: commands succeed operationally, but "all-live multichain" is not guaranteed by default.

## Design Principles
- Explicit mode contract: every run declares mode (`demo` or `live-testnet`).
- Fail fast in live mode: preflight checks block startup when required live prerequisites are missing.
- Deterministic demo mode: stable and reproducible outputs for judge walkthroughs.
- No silent downgrade: live mode must not silently fall back to mocks.
- One root UX: operators should not need to remember long docker compose invocations.

## Proposed Root Command UX
### Top-level commands
- `just demo up`
- `just demo run`
- `just demo down`
- `just live up`
- `just live run`
- `just live down`
- `just mode status`
- `just mode doctor`

### Backward-compatible aliases
- `just demo` -> `just demo run`
- `just live` -> `just live run`

### Behavioral contract
- `demo run`: starts demo stack + executes deterministic CRE scenario + prints artifact locations.
- `live run`: runs strict preflight, starts live stack, executes live smoke scenario, and exits non-zero if any critical component fails.

## Mode Contracts
## 1) Demo mode
Purpose: reliable local demo for presentation and evidence collection.

Required behavior:
- Dashboard mock-friendly UI enabled.
- CRE risk responses deterministic (approved + denied scenario coverage).
- DeFi/inference may run in mock-safe mode.
- No funded wallets required.

Inputs:
- `.env.demo` (new)
- Fallback to safe defaults for local execution.

## 2) Live-testnet mode
Purpose: true multichain integration on Hedera + Base Sepolia + 0G testnets.

Required behavior:
- Dashboard live data mode enabled.
- DeFi mock mode disabled.
- CRE path uses live oracle read path (or explicitly labeled as simulation-only if unavailable).
- Inference model/provider mapping validated against real 0G availability.
- Startup fails when required credentials/funding/endpoints are missing.

Inputs:
- `.env.live` (new)
- Optional secrets overlays per project.

## Configuration Model
## Environment files
- `.env.demo`: deterministic local demo settings.
- `.env.live`: strict live testnet settings.
- `.env.docker`: legacy compatibility layer; deprecated as primary mode selector.

## Mode selector
- `MODE=demo|live-testnet` set by root recipes.
- All mode-aware recipes must consume MODE and the mapped env file.

## Required live flags (minimum)
- `NEXT_PUBLIC_USE_MOCK=false`
- `DEFI_MOCK_MODE=false`
- `CRE_ENDPOINT=http://cre-bridge:8080/evaluate-risk` (or equivalent reachable endpoint)
- Valid Hedera account/topic config for coordinator + agents
- Valid Base wallet + funded balance for DeFi on-chain actions
- Valid 0G provider/model configuration for inference

## Preflight and Validation Gates
## Gate A: Config completeness
- Verify required env vars by mode.
- Reject missing mandatory live values.

## Gate B: Network reachability
- Hedera testnet reachable.
- Base Sepolia RPC reachable.
- 0G RPC/compute endpoints reachable.
- CRE endpoint reachable.

## Gate C: Funding and chain readiness (live mode)
- DeFi wallet base ETH balance above minimum gas threshold.
- Optional: check ERC-8004 contract address is non-zero and callable.

## Gate D: Functional smoke
- Coordinator assigns one inference + one DeFi task.
- Inference returns successful task result.
- DeFi accepts CRE decision and emits non-mock execution evidence.
- Dashboard surfaces risk + task lifecycle events.

## Gate E: Replay protection sanity
- Ensure restart does not re-process historical backlog as new work.
- Validate subscription offset behavior and dedupe safeguards.

## Runtime Architecture (Design Target)
- Keep root `just` as control plane.
- Add a `mode.just` module that owns mode contracts and env resolution.
- Existing modules (`docker.just`, `chainlink.just`, `evidence.just`) become mode-aware via shared helper variables.
- Add machine-readable preflight output for CI and demo scripts (`json` summary + human summary).

## Observability and Artifacts
For both modes, standardize output in:
- `workflow/explore/cre-demo/runs/<timestamp>/`

Artifacts:
- service health snapshot
- scenario responses
- condensed logs by service
- mode manifest (effective config, redacted secrets)
- pass/fail gate report

## Open Design Decisions
1. Should live mode block startup if CRE oracle is simulation-backed?
2. Should inference fallback to a known "public test model" when configured model unavailable, or fail hard?
3. Should HCS replay be solved via start-time-now, sequence checkpointing, or message-id dedupe?
4. Should `just live run` include automatic teardown on failure?

## Phased Implementation Plan (for later)
1. Mode framework: add mode selector, env file split, and command aliases.
2. Live gating: add strict preflight with fail-fast checks.
3. Multichain correctness: remove/flag mock paths in live mode, address replay handling, tighten smoke tests.
4. Evidence packaging: unify artifacts for submission and regression verification.

## Acceptance Criteria
- A newcomer can run `just demo run` and get deterministic evidence in one pass.
- A builder can run `just live run` and know immediately if the system is truly live-ready.
- Live mode cannot accidentally run with DeFi/CRE mock execution without explicit warning and failed status.
- Root commands remain short, memorable, and self-describing.
