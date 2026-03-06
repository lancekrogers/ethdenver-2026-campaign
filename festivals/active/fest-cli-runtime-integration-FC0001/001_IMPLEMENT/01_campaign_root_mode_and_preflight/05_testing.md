---
fest_type: gate
fest_id: 05_testing.md
fest_name: Testing and Verification
fest_parent: 01_campaign_root_mode_and_preflight
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_gate_type: testing
fest_created: 2026-03-06T13:39:01.567684-07:00
fest_tracking: true
---

# Task: Testing and Verification

**Task Number:** 05 | **Dependencies:** Tasks 01-04 | **Autonomy:** medium

## Objective
Prove this sequence is operational by running all verification commands defined in tasks 02-04 and recording outcomes.

## Required Test Run

1. Command surface checks:
```bash
cgo obey-agent-economy
fest link .
just --list --list-submodules
just fest status
just fest doctor
```

2. Live preflight checks:
```bash
just mode doctor || true
FEST_SELECTOR=fest-cli-runtime-integration-FC0001 just mode doctor || true
```

3. Mode behavior checks:
```bash
just demo run || true
FEST_FALLBACK_ALLOW_SYNTHETIC=false just mode doctor || true
```

## Verification Criteria

- [ ] Every command above has been executed at least once.
- [ ] Failures are expected/understood and documented with root cause.
- [ ] No silent failure mode remains for live preflight fest checks.
- [ ] Demo fallback behavior is explicitly observable.

## Evidence

Create/update:
- `workflow/explore/cre-demo/fest-mode-matrix.md`
- `workflow/explore/cre-demo/runs/<timestamp>/preflight-live.json`

## Definition of Done

- [ ] All verification criteria satisfied
- [ ] Evidence artifacts updated and referenced in this task notes
