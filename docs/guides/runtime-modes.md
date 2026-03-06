# Runtime Modes (Campaign Root)

This campaign now supports two explicit root modes:

- `demo` (deterministic local demo)
- `live-testnet` (strict multichain live path)

## Command Matrix

```bash
just mode status
just mode doctor

just demo up
just demo run
just demo down

just live up
just live run
just live down
```

Shortcuts:

- `just demo` runs `just demo run`
- `just live` runs `just live run`

## Environment Resolution

Mode wrappers resolve env files in this order:

- Demo: `.env.demo` -> `.env.docker` -> `.env.demo.example`
- Live: `.env.live` -> `.env.docker` -> `.env.live.example`

Use `just mode status` to see exactly which file is active.

## Live Preflight (Phase 1)

`just live up` and `just mode doctor` run `scripts/preflight-live.sh`.

Current gates:

1. Config completeness (required vars present)
2. Mode contracts (`NEXT_PUBLIC_USE_MOCK=false`, `DEFI_MOCK_MODE=false`)
3. Network reachability (Base RPC, 0G RPC, Hedera mirror)
4. Funding readiness (`DEFI_WALLET_ADDRESS` minimum wei check)

Artifacts are written to:

`workflow/explore/cre-demo/runs/<timestamp>/preflight-live.json`

## Current Known Live Constraints

Phase 1 intentionally fails hard by default until this flag is acknowledged:

- `LIVE_ALLOW_SIMULATED_CRE=true`

Reason: current CRE bridge HTTP path is simulation-backed for oracle data.

For fest runtime source behavior (`fest` vs `synthetic`) and troubleshooting, see:

- `docs/guides/fest-runtime-integration.md`
