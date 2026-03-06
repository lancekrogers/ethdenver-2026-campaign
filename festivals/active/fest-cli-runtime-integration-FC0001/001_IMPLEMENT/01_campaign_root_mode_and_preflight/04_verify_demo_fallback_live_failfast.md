---
fest_type: task
fest_id: 04_verify_demo_fallback_live_failfast.md
fest_name: verify_demo_fallback_live_failfast
fest_parent: 01_campaign_root_mode_and_preflight
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.929918-07:00
fest_tracking: true
---

# Task: Verify Demo Fallback And Live Fail-Fast

## Objective
Execute and document a mode matrix proving demo fallback behavior and live strict behavior are both working as designed.

## Requirements

- [ ] Validate demo mode success with fest available.
- [ ] Validate demo mode success with simulated fest unavailable when fallback is enabled.
- [ ] Validate live mode failure when fest requirements are unmet.
- [ ] Capture command outputs in run artifacts.

## Implementation

1. Ensure root context:
```bash
cgo obey-agent-economy
fest link .
fest link --show
```

2. Run matrix case A (demo + fest present):
```bash
just demo run
```
Expected: command succeeds.

3. Run matrix case B (demo + fest missing simulation + fallback true):
```bash
FEST_FALLBACK_ALLOW_SYNTHETIC=true PATH="/usr/bin:/bin" MODE=demo ENV_FILE=.env.demo just demo run || true
```
Expected: system continues via synthetic fallback or returns a clearly labeled warning path.

4. Run matrix case C (live strict mode):
```bash
FEST_FALLBACK_ALLOW_SYNTHETIC=false just mode doctor || true
```
Expected: non-zero on unmet fest requirements.

5. Save evidence summary:
- Create/update `workflow/explore/cre-demo/fest-mode-matrix.md` with:
  - exact commands,
  - exit codes,
  - expected vs actual,
  - links to generated preflight report files.

## Done When

- [ ] All requirements met
- [ ] Mode matrix evidence file exists with command-level results and conclusions
- [ ] At least one explicit failing live check and one passing demo fallback check are documented
