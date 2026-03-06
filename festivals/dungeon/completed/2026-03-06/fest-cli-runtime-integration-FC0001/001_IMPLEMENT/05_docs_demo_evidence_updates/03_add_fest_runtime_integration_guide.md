---
fest_type: task
fest_id: 03_add_fest_runtime_integration_guide.md
fest_name: add_fest_runtime_integration_guide
fest_parent: 05_docs_demo_evidence_updates
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-06T13:38:55.994437-07:00
fest_updated: 2026-03-06T15:52:34.847448-07:00
fest_tracking: true
---


# Task: Add Fest Runtime Integration Guide

## Objective
Create a dedicated operator guide that explains architecture, fallback modes, and verification workflow for runtime fest integration.

## Requirements

- [ ] Add new guide file in `docs/guides/`.
- [ ] Include command matrix for demo/live and expected outcomes.
- [ ] Include troubleshooting section for common fest failures.

## Implementation

1. Ensure root context:
```bash
cgo obey-agent-economy
fest link .
```

2. Create file:
- `docs/guides/fest-runtime-integration.md`

Required sections:
- overview and architecture
- mode matrix (`source=fest`, `source=synthetic`, fail-fast)
- commands and expected results
- troubleshooting (`fest missing`, selector not found, parse errors)

3. Link guide from README or existing docs index where appropriate.

## Done When

- [ ] All requirements met
- [ ] Guide can be followed by a new contributor without hidden assumptions