# Festival Overview: synthesis-fest-ritual-runtime

## Problem Statement

**Current State:** OBEY has a strong local design for a fest-native ritual runtime, but the live trading loop in `projects/agent-defi` still bypasses `fest` and does not prove a real daemon-backed `obey` session is driving ritual execution. The ritual template exists in `festivals/ritual/agent-market-research-RI-AM0001/`, yet no truthful runtime path currently creates ritual runs, starts an agent inside them, and emits the Protocol Labs artifact trail.

**Desired State:** The Synthesis submission uses the real `fest` CLI and the real `obey` daemon runtime at execution time. Each vault-agent cycle creates a real ritual run in `festivals/active/`, binds a real agent session to that run with `--workdir`, executes the actual `fest next` loop, and produces `decision.json`, `agent_log_entry.json`, and a refreshed aggregate `agent_log.json`.

**Why This Matters:** This turns the Synthesis submission from a mostly-packaged prototype into a truthful agent runtime story that can win Protocol Labs and Open Track money. It also puts the actual `fest` product in the demo path instead of hiding it behind a custom reimplementation.

## Scope

### In Scope

- Harden the ritual in `festivals/ritual/agent-market-research-RI-AM0001/` so an agent can run it unattended.
- Add a thin `fest` bridge inside `projects/agent-defi` that creates ritual runs, inspects status, and resolves artifact paths.
- Extend the `obey` runtime integration so vault cycles create real daemon-backed sessions with dynamic festival IDs and `--workdir`.
- Replace direct strategy-only decisioning with ritual-backed decision parsing and trade gating.
- Refresh `projects/agent-defi/agent_log.json` from ritual artifacts plus execution evidence.
- Verify at least three real runtime-driven ritual runs for the Synthesis submission.

### Out of Scope

- Rebuilding `fest` workflow logic inside Go.
- Creating a second `festivals/` workspace inside `projects/agent-defi`.
- Expanding the general OBEY dashboard beyond what is needed for demo evidence.
- Changing core ObeyVault contract logic unless verification exposes a hard blocker.
- Claiming Uniswap track readiness before the runtime and evidence path are truthful.

## Planned Phases

### 001_IMPLEMENT

Execute the runtime integration in six sequences: lock the campaign-side ritual contract, add the `fest` bridge, add the daemon-backed `obey` bridge, wire ritual decisions into the vault loop, refresh Protocol Labs artifacts continuously, and run end-to-end validation for submission readiness.

## Notes

- Primary design input: `workflow/design/2026-03-18-synthesis-fest-ritual-runtime/README.md`
- Related submission packaging festival: `festivals/active/synthesis-submission-SS0001`
- This festival intentionally keeps the ritual source of truth in the campaign root and treats `projects/agent-defi` as a consumer of `fest`, not an owner of duplicated festival state.
- The daemon-backed, non-deterministic runtime requirement is mandatory for this festival to count as complete.
