---
fest_type: gate
fest_id: 06_review.md
fest_name: Code Review
fest_parent: 01_campaign_root_mode_and_preflight
fest_order: 6
fest_status: completed
fest_autonomy: low
fest_gate_type: review
fest_created: 2026-03-06T13:39:01.567949-07:00
fest_updated: 2026-03-06T15:30:57.174963-07:00
fest_tracking: true
---


# Task: Code Review

**Task Number:** 06 | **Dependencies:** 05_testing | **Autonomy:** low

## Objective
Perform a focused review of root-level mode/preflight changes for correctness, operator UX clarity, and failure safety.

## Review Scope

- `justfile`
- `.justfiles/fest.just`
- `.justfiles/mode.just`
- `scripts/preflight-live.sh`
- `.env.demo.example`
- `.env.live.example`
- `.env.docker.example`

## Review Steps

1. Inspect diff:
```bash
git diff -- justfile .justfiles/fest.just .justfiles/mode.just scripts/preflight-live.sh .env.demo.example .env.live.example .env.docker.example
```

2. Validate failure messaging quality:
- [ ] Every live fest gate failure has an actionable message.
- [ ] No ambiguous wording like "something failed" without remediation.

3. Validate UX discoverability:
- [ ] New fest recipes are visible in `just --list`.
- [ ] Mode status output references fest commands.

4. Validate safety:
- [ ] Live mode does not silently downgrade when fest checks fail.
- [ ] Demo mode fallback path is explicit.

## Done When

- [ ] Review complete with no high-severity unresolved findings
- [ ] Any findings are logged and routed to 07_iterate