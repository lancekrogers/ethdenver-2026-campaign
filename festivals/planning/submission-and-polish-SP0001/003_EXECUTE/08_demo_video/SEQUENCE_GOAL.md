---
fest_type: sequence
fest_id: 08_demo_video
fest_name: demo_video
fest_parent: 003_EXECUTE
fest_order: 8
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Sequence Goal: 08_demo_video

**Sequence:** 08_demo_video | **Phase:** 003_EXECUTE | **Status:** Pending | **Created:** 2026-02-18T14:00:00-07:00

## Sequence Objective

**Primary Goal:** Write a 2-minute demo script, rehearse it to eliminate dead time, and record the final demo video with screen capture and voiceover for all bounty submissions.

**Contribution to Phase Goal:** The demo video is the single most impactful submission artifact. Judges typically watch the video before reading documentation. A tight, well-rehearsed 2-minute demo showing live agents, real-time dashboard, and the full economy cycle will differentiate this submission from text-only entries.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Demo Script**: `docs/demo-script.md` with timed sections (intro 15s, architecture 20s, dashboard walkthrough 60s, highlights 20s, closing 5s), talking points, and screen transitions
- [ ] **Rehearsal Notes**: Timing verified, no dead time > 5 seconds, all dashboard panels active during recording window
- [ ] **Recorded Video**: MP4 with screen capture and voiceover, under 2 minutes, uploaded to YouTube or similar with public URL

### Quality Standards

- [ ] Demo flows smoothly with no awkward pauses
- [ ] Dashboard shows live agent activity during recording
- [ ] Key features are clearly highlighted and explained
- [ ] Audio is clear and professional
- [ ] Video resolution is at least 1080p

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_link_project.md | Link to dashboard for demo recording | Enables `fgo` navigation to dashboard |
| 02_write_demo_script.md | Write the 2-minute demo script | Structured plan for the recording |
| 03_rehearse.md | Rehearse and time the demo | Eliminates dead time and verifies flow |
| 04_record.md | Record the demo video | Produces the final video artifact |
| 05_testing_and_verify.md | Quality gate: testing | Verifies video quality and content accuracy |
| 06_code_review.md | Quality gate: code review | Reviews demo content for completeness |
| 07_review_results_iterate.md | Quality gate: iterate | Addresses findings and confirms readiness |

## Dependencies

### Prerequisites (from other sequences)

- 07_deploy: Agents must be running on testnet and dashboard deployed before recording
- 02-06 packaging sequences: All documentation must be finalized for reference during demo

### Provides (to other sequences)

- **Demo Video URL**: Used in all bounty submission forms in 004_SUBMIT

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Agents crash during recording | Medium | High | Pre-warm agents, have restart script ready, keep recording sessions short |
| Dashboard shows no activity | Low | High | Trigger a test transaction before recording, verify WebSocket connection |
| Audio quality issues | Low | Medium | Use a quiet environment, test audio before full recording |
