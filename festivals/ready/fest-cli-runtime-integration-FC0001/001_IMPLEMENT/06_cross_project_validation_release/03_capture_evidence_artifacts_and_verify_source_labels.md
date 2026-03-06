---
fest_type: task
fest_id: 03_capture_evidence_artifacts_and_verify_source_labels.md
fest_name: capture_evidence_artifacts_and_verify_source_labels
fest_parent: 06_cross_project_validation_release
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-06T13:38:56.009606-07:00
fest_tracking: true
---

# Task: Capture Evidence Artifacts And Verify Source Labels

## Objective
Collect demonstration artifacts proving runtime fest integration and source labeling behavior.

## Requirements

- [ ] Capture preflight JSON/text reports.
- [ ] Capture dashboard evidence showing source label state.
- [ ] Archive validation matrix and key command outputs.

## Implementation

1. Ensure root context:
```bash
cgo obey-agent-economy
fest link .
```

2. Capture artifacts directory:
- `workflow/explore/cre-demo/runs/<timestamp>/`

3. Required artifacts:
- `preflight-live.json`
- `preflight-live.txt`
- `fest-mode-matrix.md`
- `fest-validation-matrix.md`
- dashboard screenshot or note proving source label (`fest` or `synthetic`).

4. Verify source labeling evidence includes:
- visible label text
- run context (demo/live)
- timestamp

## Done When

- [ ] All requirements met
- [ ] Evidence artifacts are complete and traceable to executed commands
