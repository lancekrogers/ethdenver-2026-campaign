---
fest_type: sequence
fest_id: 04_low_effort_bounties
fest_name: 04_low_effort_bounties
fest_parent: 001_IMPLEMENT
fest_order: 4
fest_status: completed
fest_created: 2026-03-16T21:34:06.761997-06:00
fest_updated: 2026-03-17T00:18:38.206785-06:00
fest_tracking: true
fest_working_dir: .
---


# Sequence Goal: 04_low_effort_bounties

**Sequence:** 04_low_effort_bounties | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-03-16T21:34:06-06:00

## Sequence Objective

**Primary Goal:** Claim Status Network ($50+ guaranteed) and Markee ($800 proportional) bounties with minimal effort.

**Contribution to Phase Goal:** These are guaranteed or near-guaranteed payouts that require under 45 minutes of total work. Status Network is qualification-based (equal share among all qualifiers). Markee is proportional to views/funds with a low disqualification bar.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Status Network deployment**: Contract deployed to Status Network Sepolia testnet
- [ ] **Status gasless tx**: At least 1 gasless transaction executed on Status Network
- [ ] **Status tx proof**: Transaction hash documented for submission
- [ ] **Markee integration**: Markee delimiter text added to a visible markdown file, OAuth granted, "Live" status confirmed

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Status Network tx hash is valid and verifiable on Status explorer
- [ ] Markee shows "Live" on GitHub integrations page

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_deploy_status_network | Deploy contract to Status Sepolia + gasless tx | Claims Status Network bounty |
| 02_setup_markee | Add Markee delimiter, grant OAuth, verify Live | Claims Markee bounty |

## Dependencies

### Prerequisites (from other sequences)

- None -- can run in parallel with all other sequences

### Provides (to other sequences)

- Status Network tx hash: Used by 06_submission_packaging (Status track submission)
- Markee Live confirmation: Used by 06_submission_packaging (Markee track submission)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Status Network Sepolia is down or unreachable | Low | Low -- $50 bounty | Retry later, it is a simple deployment |
| Markee OAuth flow fails | Low | Low -- $20-100 expected value | Follow Markee docs exactly, use claude-code-go repo (already public, 36 stars) |
| Less than 10 unique views on Markee | Low | Low -- only disqualifies if also no funds added | Active public repo should clear threshold |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: Contract deployed to Status Network Sepolia
- [ ] **Milestone 2**: Gasless tx executed and hash recorded
- [ ] **Milestone 3**: Markee integration live and verified