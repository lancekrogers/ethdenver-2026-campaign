---
fest_type: gate
fest_id: 07_iterate.md
fest_name: Review Results and Iterate
fest_parent: 01_campaign_root_mode_and_preflight
fest_order: 7
fest_status: completed
fest_autonomy: medium
fest_gate_type: iterate
fest_created: 2026-03-06T13:39:01.568147-07:00
fest_updated: 2026-03-06T15:31:03.222088-07:00
fest_tracking: true
---


# Task: Review Results and Iterate

**Task Number:** 07 | **Dependencies:** 06_review | **Autonomy:** medium

## Objective
Resolve all findings from testing and review, then rerun targeted verification until the sequence is stable.

## Iteration Workflow

1. Collect findings from tasks 05 and 06.
2. Apply fixes to affected root files.
3. Re-run minimum regression checks:
```bash
cgo obey-agent-economy
fest link .
just fest status
just fest doctor
just mode doctor || true
```
4. If behavior changed in mode handling, rerun:
```bash
just demo run || true
FEST_FALLBACK_ALLOW_SYNTHETIC=false just mode doctor || true
```

## Exit Criteria

- [ ] No unresolved high/medium findings remain
- [ ] Regression checks pass (or expected failures are documented)
- [ ] Evidence docs reflect final behavior