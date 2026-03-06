---
fest_type: task
fest_id: 04_update_chainlink_demo_guides_for_fallback_matrix.md
fest_name: update_chainlink_demo_guides_for_fallback_matrix
fest_parent: 05_docs_demo_evidence_updates
fest_order: 4
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.994648-07:00
fest_tracking: true
---

# Task: Update Chainlink Demo Guides For Fallback Matrix

## Objective
Update existing Chainlink mock/live demo guides so they explicitly demonstrate fest-source and synthetic-fallback flows.

## Requirements

- [ ] Update mock guide with fallback-focused flow.
- [ ] Update live guide with strict preflight/fail-fast flow.
- [ ] Add evidence checklist fields for source labels.

## Implementation

1. Confirm root context:
```bash
cgo obey-agent-economy
fest link .
```

2. Update files:
- `docs/guides/chainlink-demo-mock-e2e.md`
- `docs/guides/chainlink-demo-live-e2e.md`

3. Add explicit command sequences and expected outcomes for:
- mock/demo with fallback
- live mode strict checks

4. Add final verification checklist:
- source label visible in dashboard
- preflight report captured
- command outputs archived

## Done When

- [ ] All requirements met
- [ ] Both guides include up-to-date command and evidence instructions
