---
fest_type: phase
fest_id: 004_SUBMIT
fest_name: SUBMIT
fest_parent: submission-and-polish-SP0001
fest_order: 4
fest_status: pending
fest_created: 2026-02-18T14:00:00-07:00
fest_phase_type: implementation
fest_tracking: true
---

# Phase Goal: 004_SUBMIT

**Phase:** 004_SUBMIT | **Status:** Pending | **Type:** Implementation

## Phase Objective

**Primary Goal:** Perform final cross-project review, submit all five bounty tracks to ETHDenver, and verify submissions are accessible to judges.

**Context:** The execute phase produced all submission materials: polished READMEs, architecture docs, compute metrics, P&L proof, deployed agents, deployed dashboard, and a demo video. This submit phase is the final checkpoint: review everything one last time, fill out each bounty submission form, and verify judges can access all linked materials. This is the last festival -- there is no recovery if something is missed.

## Sequences

| Sequence | Project | Objective |
|----------|---------|-----------|
| 01_final_review | agent-coordinator | Cross-project review of all READMEs, deployments, and submission materials |
| 02_submit_all_tracks | agent-coordinator | Submit all five bounty tracks and perform post-submission verification |

## Success Criteria

This submit phase is complete when:

- [ ] All six project READMEs reviewed and pass completeness checklist
- [ ] All deployments verified live (agents on testnet, dashboard accessible, demo video URL works)
- [ ] All links in READMEs are valid and resolve correctly
- [ ] Hedera Track 3 bounty submitted with all required materials
- [ ] Hedera Track 4 bounty submitted with all required materials
- [ ] 0G Track 2 bounty submitted with all required materials
- [ ] 0G Track 3 bounty submitted with all required materials
- [ ] Base bounty submitted with all required materials
- [ ] Post-submission verification confirms judges can see all repos, demos, and documentation
- [ ] Final fest commit chain completed for the entire festival

## Dependencies

- 003_EXECUTE must be complete (all submission materials ready, agents deployed, demo recorded)

## Notes

- This is the final phase of the final festival. Triple-check everything.
- Submission forms may have character limits -- prepare answers ahead of time.
- After submission, do not modify repos or deployed services until judging is complete.
- The final fest commit captures the entire festival's work as a single commit chain.

---

*Implementation phases use sequences with numbered tasks. Each sequence targets a single project.*
