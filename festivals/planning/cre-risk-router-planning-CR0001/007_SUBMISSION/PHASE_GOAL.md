---
fest_type: phase
fest_id: 007_SUBMISSION
fest_name: SUBMISSION
fest_parent: cre-risk-router-planning-CR0001
fest_order: 7
fest_status: pending
fest_created: 2026-03-01T17:42:33.441741-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 005_SUBMISSION

**Phase:** 005_SUBMISSION | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Produce all submission artifacts (README, scenarios, e2e demo, evidence, Moltbook post) and publish the hackathon entry before the March 8, 2026 11:59 PM ET deadline.

**Context:** This phase builds on the working simulation from Phase 004. All code is complete; this phase focuses on documentation, evidence capture, and the submission process. The Moltbook post must follow the exact required format with all 10 sections. The GitHub repo must be made public before submission.

## Required Outcomes

Deliverables this phase must produce:

- [ ] `README.md` with project description, setup instructions (under 5 commands), simulation commands, architecture overview
- [ ] 5 JSON scenarios in `scenarios/`: approved_trade, denied_low_confidence, denied_high_risk, denied_stale_signal, denied_price_deviation, each with expected outcome documented
- [ ] `demo/e2e.sh` script curling HTTP trigger with coordinator-format payload, capturing on-chain receipt
- [ ] Simulation logs captured with tx hash clearly visible
- [ ] Tx verified on block explorer with screenshot/link
- [ ] Moltbook post drafted with all 10 required sections per spec Section 12, including genuine CRE Experience Feedback
- [ ] Human operator registration form completed at `https://forms.gle/xk1PcnRmky2k7yDF7`
- [ ] Final review: format matches template, no placeholder text, all sections filled, tx hash present, repo is public
- [ ] Moltbook post published before March 8, 2026 11:59 PM ET

## Quality Standards

Quality criteria for all work in this phase:

- [ ] README enables clone-to-simulate in under 5 commands
- [ ] Each scenario JSON has documented expected outcome matching spec Section 9
- [ ] Evidence artifacts show real simulation output, not fabricated data
- [ ] Moltbook post has non-empty CRE Experience Feedback section with genuine observations
- [ ] No secrets, placeholder text, or TODO markers remain in any submitted artifact

## Sequence Alignment

| Sequence | Goal | Key Deliverable |
|----------|------|-----------------|
| 01_documentation | Create README, scenarios, and integration demo | `README.md`, `scenarios/*.json`, `demo/e2e.sh` |
| 02_evidence | Capture simulation evidence for submission | Logs with tx hash, block explorer verification |
| 03_publish | Draft, review, and publish the Moltbook submission | Published Moltbook post + completed registration form |

## Pre-Phase Checklist

Before starting implementation:

- [ ] Planning phase complete
- [ ] Architecture/design decisions documented
- [ ] Dependencies resolved
- [ ] Development environment ready

## Phase Progress

### Sequence Completion

- [ ] 01_documentation
- [ ] 02_evidence
- [ ] 03_publish

## Notes

The repo must be made public before submission. The e2e demo constructs a `RiskRequest` matching the exact format `agent-coordinator` would produce (same agent IDs, task ID format, signal structure). Deadline is absolute: March 8, 2026 11:59 PM ET. Requirements traced: P0.17-P0.23.

---

*Implementation phases use numbered sequences. Create sequences with `fest create sequence`.*
