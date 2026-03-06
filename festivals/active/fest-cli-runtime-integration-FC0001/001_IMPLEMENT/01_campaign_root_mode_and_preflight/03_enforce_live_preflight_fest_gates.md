---
fest_type: task
fest_id: 03_enforce_live_preflight_fest_gates.md
fest_name: enforce_live_preflight_fest_gates
fest_parent: 01_campaign_root_mode_and_preflight
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.929643-07:00
fest_tracking: true
---

# Task: Enforce Live Preflight Fest Gates

## Objective
Extend live preflight to enforce required fest runtime conditions so `live-testnet` mode fails fast when festival state cannot be resolved.

## Requirements

- [ ] Add explicit fest checks to `scripts/preflight-live.sh`.
- [ ] Fail live preflight if fest binary is missing (unless explicit fallback override is enabled).
- [ ] Fail live preflight when selector resolution or roadmap JSON parsing fails.
- [ ] Persist gate results in existing JSON/text preflight artifacts.

## Implementation

1. Confirm root context and link:
```bash
cgo obey-agent-economy
fest link .
fest link --show
```

2. Update preflight script:
- Target file: `scripts/preflight-live.sh`
- Add gates for:
  - `fest` binary availability (`command -v fest`).
  - selector resolution:
    - use `FEST_SELECTOR` when provided,
    - otherwise resolve from `fest show all --json` status priority (`active`, `ready`, `planning`, `dungeon/someday`).
  - roadmap parse check:
```bash
fest show --festival "$selector" --json --roadmap
```
  - fallback policy via env (`FEST_FALLBACK_ALLOW_SYNTHETIC`).

3. Add env key handling:
- `.env.live.example`: default strict live values (`FEST_FALLBACK_ALLOW_SYNTHETIC=false`).
- `.env.demo.example`: default permissive demo values (`FEST_FALLBACK_ALLOW_SYNTHETIC=true`).
- `.env.docker.example`: document override behavior.

4. Ensure preflight outputs include fest results:
- Update generated JSON fields to include fest gate statuses and failure reasons.
- Keep existing output paths under `workflow/explore/cre-demo/runs/<timestamp>/`.

5. Verify behavior:
```bash
just mode doctor
FEST_SELECTOR=fest-cli-runtime-integration-FC0001 just mode doctor
```

6. Negative-path verification (simulate missing fest while preserving shell):
```bash
PATH="/usr/bin:/bin" MODE=live-testnet ENV_FILE=.env.live bash scripts/preflight-live.sh || true
```
Confirm failure reason includes missing fest binary.

## Done When

- [ ] All requirements met
- [ ] Live preflight returns non-zero with clear fest error when fest checks fail
- [ ] Live preflight passes when selector and roadmap checks succeed
