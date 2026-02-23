---
fest_type: sequence
fest_id: 04_hiero_submission_prep
fest_name: hiero submission prep
fest_parent: 001_IMPLEMENT
fest_order: 4
fest_status: pending
fest_created: 2026-02-21T17:48:56.72717-07:00
fest_tracking: true
---

# Sequence Goal: 04_hiero_submission_prep

**Sequence:** 04_hiero_submission_prep | **Phase:** 001_IMPLEMENT | **Status:** Pending | **Created:** 2026-02-21T17:48:56-07:00

## Sequence Objective

**Primary Goal:** Polish the hiero-plugin submission materials (docs, test coverage, demo video script) so the plugin meets Hedera Track 4 ($10k) judging criteria for a production-quality CLI plugin.

**Contribution to Phase Goal:** The hiero-plugin code and templates already work, but the submission package needs updated docs referencing 0G templates, better test coverage for edge cases, a PR-ready branch, and a demo video walkthrough. Without these, judges lack evidence of quality.

## Success Criteria

The sequence goal is achieved when:

### Required Deliverables

- [ ] **Updated plugin docs**: submission.md, architecture.md, and usage-guide.md accurately describe all templates including 0G agent and iNFT
- [ ] **Test coverage**: At least 2 new test cases for 0G template generation and validation edge cases
- [ ] **PR branch**: Clean branch with conventional commits ready for hiero-plugin upstream PR
- [ ] **Demo script**: Written walkthrough script showing `camp create 0g-agent` and `camp create 0g-inft-build` end-to-end

### Quality Standards

- [ ] **All tests pass**: `cd projects/hiero-plugin && npm test` passes with 0 failures
- [ ] **Docs accuracy**: Every command shown in docs actually works when copy-pasted

### Completion Criteria

- [ ] All tasks in sequence completed successfully
- [ ] Quality verification tasks passed
- [ ] Code review completed and issues addressed

## Task Alignment

| Task | Task Objective | Contribution to Sequence Goal |
|------|----------------|-------------------------------|
| 01_update_plugin_docs | Update submission.md, architecture.md, usage-guide.md with 0G template content | Judges see complete, accurate documentation |
| 02_add_0g_test_coverage | Add test cases for 0G template generation | Test suite validates all templates work |
| 03_create_hiero_pr | Create clean PR branch with conventional commits | Submission-ready code for upstream |
| 04_record_demo_video | Write demo script and record walkthrough | Visual proof of plugin functionality |

## Dependencies

### Prerequisites (from other sequences)

- 02_erc7857_inft_contract: The iNFT template references the ERC-7857 contract, so that contract should exist before demoing

### Provides (to other sequences)

- Submission-ready plugin: Used by 002_REVIEW phase for Hedera Track 4 qualification check

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 0G template tests flaky on CI | Low | Medium | Run tests locally 3x before committing |
| Demo video tooling not available | Low | Low | Written script is sufficient fallback for judges |

## Progress Tracking

### Milestones

- [ ] **Milestone 1**: All three docs updated with 0G template sections
- [ ] **Milestone 2**: Test suite passes including new 0G test cases
- [ ] **Milestone 3**: PR branch created and demo script written

## Quality Gates

### Testing and Verification

- [ ] All unit tests pass
- [ ] Integration tests complete

### Code Review

- [ ] Code review conducted
- [ ] Review feedback addressed

### Iteration Decision

- [ ] Need another iteration? No
- [ ] If yes, new tasks created: N/A
