---
fest_type: sequence
fest_id: 06_submission_packaging
fest_name: 06_submission_packaging
fest_parent: 001_IMPLEMENT
fest_order: 6
fest_status: pending
fest_created: 2026-03-16T21:36:16.57431-06:00
fest_tracking: true
fest_working_dir: "."
---

# Sequence Goal: 06_submission_packaging

**Sequence:** 06_submission_packaging | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-03-16T21:36:16-06:00

## Sequence Objective

**Primary Goal:** Create all submission materials (video demo, conversationLog, Moltbook post) and submit to all target tracks via Synthesis API before the deadline.

**Contribution to Phase Goal:** This is the final sequence -- all previous work converges here. Without completed submissions, no bounties are awarded regardless of how good the underlying work is.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Video demo**: ~3 minute video covering 6 checkpoints (boundaries, identity, festival plan, trading loop, verification, dashboard)
- [ ] **ConversationLog**: Human-agent collaboration log compiled from development history
- [ ] **Moltbook post**: Published post summarizing the OBEY project
- [ ] **Track submissions**: Confirmed submissions to Protocol Labs Cook, Protocol Labs Receipts, Uniswap Agentic Finance, Synthesis Open Track, Status Network, and Markee

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Video demo is watchable and covers all 6 checkpoints
- [ ] Each track submission includes correct metadata, repo URL, and track-specific narrative
- [ ] Submission confirmations received from Synthesis API

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_record_video_demo | Record ~3 min video with 6 checkpoints | Provides required video for all tracks |
| 02_compile_conversation_log | Compile conversationLog from dev history | Satisfies submission requirement |
| 03_write_moltbook_post | Write and publish Moltbook post | Additional submission material |
| 04_submit_protocol_labs_cook | Submit to "Let the Agent Cook" track | Targets $8K bounty |
| 05_submit_protocol_labs_receipts | Submit to "Agents With Receipts" track | Targets $8K bounty |
| 06_submit_uniswap | Submit to "Agentic Finance" track | Targets $5K bounty |
| 07_submit_open_track | Submit to Synthesis Open Track | Targets $19.5K bounty |
| 08_submit_status_markee | Submit to Status Network + Markee tracks | Claims guaranteed bounties |

## Dependencies

### Prerequisites (from other sequences)

- 01_verify_uniswap_api: Integration documentation for Uniswap submission narrative
- 02_protocol_labs_artifacts: agent.json, agent_log.json, and differentiated narratives
- 03_mainnet_deployment: Mainnet TxIDs and Basescan links for all submissions
- 04_low_effort_bounties: Status Network tx hash and Markee Live confirmation
- 05_repo_cleanup: Public repo URL required for all submissions

### Provides (to other sequences)

- None -- this is the final sequence

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Video demo takes too long (re-takes) | Medium | Medium -- delays all submissions | Script in advance, pre-stage all transactions, use dashboard as visual anchor |
| Synthesis API submission fails | Low | High -- no submission = no bounty | Test API with a draft submission first, have manual fallback plan |
| Missing prerequisite from earlier sequence | Low | High -- blocks specific track | Track sequence dependencies carefully, prioritize blockers |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Video demo recorded and finalized
- [ ] **Milestone 2**: ConversationLog and Moltbook post complete
- [ ] **Milestone 3**: All 6 track submissions confirmed
