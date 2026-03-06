# Fest Runtime Integration Guide

This guide describes how runtime `fest` integration works across coordinator and dashboard, and how to verify behavior in demo and live modes from campaign root.

## Overview

Runtime flow:

1. `agent-coordinator` executes `fest show all --json` and `fest show --festival <selector> --json --roadmap`.
2. Coordinator maps fest roadmap tasks into an execution plan.
3. Coordinator publishes `festival_progress` events to HCS status topic.
4. Dashboard prefers explicit `festival_progress` messages and labels source as:
   - `fest`
   - `synthetic` (fallback)

## Architecture

- Runtime adapter: `projects/agent-coordinator/internal/festival/*`
- Progress publisher: `projects/agent-coordinator/internal/coordinator/fest_runtime.go`
- Dashboard parser and source rendering:
  - `projects/dashboard/src/hooks/useMirrorNode.ts`
  - `projects/dashboard/src/components/panels/FestivalView.tsx`

## Mode Matrix

| Mode | Key env settings | Expected source | Expected behavior |
|------|------------------|-----------------|-------------------|
| Demo fallback | `MODE=demo`, `FEST_FALLBACK_ALLOW_SYNTHETIC=true` | `synthetic` if fest fails, otherwise `fest` | stack still runs; dashboard shows fallback badge when needed |
| Demo strict | `MODE=demo`, `FEST_FALLBACK_ALLOW_SYNTHETIC=false` | `fest` only | coordinator exits if fest data cannot load |
| Live strict (default) | `MODE=live-testnet`, `FEST_FALLBACK_ALLOW_SYNTHETIC=false` | `fest` only | preflight + coordinator fail fast when fest gates fail |
| Live permissive | `MODE=live-testnet`, `FEST_FALLBACK_ALLOW_SYNTHETIC=true` | `synthetic` on failures | available for debugging only; not recommended for final proof |

## Commands And Expected Results

Run from campaign root:

```bash
just fest status
just fest doctor
just mode status
```

Expected:

- `just fest status` prints fest version + selector candidate summary.
- `just fest doctor` prints `PASS` when selector/roadmap are valid.
- `just mode status` shows mode command matrix including fest commands.

Demo validation:

```bash
just demo run
```

Expected:

- stack starts and runs deterministic CRE scenarios.
- dashboard Festival View renders source badge (`fest` or `synthetic (fallback)`).

Live validation:

```bash
just live run
```

Expected:

- preflight gates run first.
- strict mode fails early if fest prerequisites are not met.
- on success, dashboard shows `Source: fest`.

## Troubleshooting

### `fest` binary missing

Symptoms:

- `just fest status` or `just fest doctor` fails immediately.

Fix:

1. Install `fest`.
2. Confirm `fest version` works in shell.
3. Re-run `just fest doctor`.

### Selector not found

Symptoms:

- errors about unresolved selector / no active-ready-planning festival.

Fix:

1. Set `FEST_SELECTOR` explicitly in env file.
2. Or create/promote a festival to an eligible state.
3. Re-run:
   ```bash
   just fest status
   just fest doctor
   ```

### Roadmap parse failure

Symptoms:

- coordinator logs parse errors for `fest show --json --roadmap`.

Fix:

1. Run command directly to inspect output:
   ```bash
   fest show --festival "$FEST_SELECTOR" --json --roadmap
   ```
2. Ensure output is valid JSON and selector points to a valid festival.
3. Retry coordinator startup (`just demo run` or `just live run`).

