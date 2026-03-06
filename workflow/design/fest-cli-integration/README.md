# Fest CLI Integration Design

## Goal
Make `fest` a real runtime dependency of the Obey Agent Economy (not just planning artifacts in `festivals/`) while preserving demo reliability with a synthetic fallback when `fest` is unavailable.

## Scope
This design covers:
- Coordinator-side `fest` integration for festival task sourcing and progress snapshots.
- Dashboard data path changes so Festival View reflects real `fest` state.
- Root `just` and preflight UX for `demo` vs `live-testnet` operation.
- Fallback rules when `fest` binary/repo is unavailable.

This design does not implement code changes.

## Directory Map
- `findings/01-current-state-audit.md`: verified current behavior and gaps.
- `design/01-target-architecture.md`: target runtime architecture and contracts.
- `design/02-fallback-mode-spec.md`: fallback policy and mode-specific behavior.
- `implementation/01-step-by-step-plan.md`: phased implementation plan with concrete file targets.

## Definition of "True Fest Integration"
The system is considered truly integrated when all conditions are met:
1. Coordinator obtains executable plan/progress from `fest` CLI output (not static hardcoded plan).
2. Festival progress emitted to dashboard is derived from real `fest` state in runtime.
3. `just live run` fails fast if `fest` is required but unavailable/misconfigured.
4. `just demo run` still works end-to-end via explicit synthetic fallback mode.
5. Evidence artifacts include the exact `fest` snapshot used during the run.

## Note on Fest Repository Visibility
Because the `fest` repo is currently private and expected to become public soon, this design intentionally integrates via stable CLI JSON interfaces (`fest show --json --roadmap`, `fest progress --json`, `fest show all --json`) rather than importing internal `fest` code packages. This keeps integration stable across private->public transition.
