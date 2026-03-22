---
fest_type: task
fest_id: 01_capture_demo_gif_for_submission.md
fest_name: capture demo gif for submission
fest_parent: 06_end_to_end_verification
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 0001-01-01T00:00:00Z
fest_updated: 2026-03-22T17:06:40.185075-06:00
fest_tracking: true
---


# Task: Capture Demo GIF for Submission

## Objective

Capture a screenshot or animated GIF of the dashboard running with real agent data for the hackathon submission.

## Requirements

- [ ] GIF or screenshot shows all 7 panels with real agent data populated
- [ ] No "synthetic" or "fallback" labels visible
- [ ] GIF saved to docs/images/ for README reference
- [ ] Submission updated with new dashboard image via `just synthesis update-from-payload`

## Implementation

1. Run `just demo up` and wait for all panels to populate
2. Use a screen capture tool (QuickTime, Kap, or Remotion) to capture the dashboard
3. Save as docs/images/dashboard-demo.gif (replacing the existing placeholder)
4. Update README.md dashboard section if image path changed
5. Update hackathon submission with `just synthesis video` or description update

## Done When

- [ ] All requirements met
- [ ] Dashboard GIF shows real agent data from all 7 panels
- [ ] README references the updated image